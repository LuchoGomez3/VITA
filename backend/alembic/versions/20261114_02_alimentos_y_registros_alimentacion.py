"""Catálogo de alimentos y registros de alimentación (adr-0016).

1. Adopta ``alimentos``, que existía en Supabase desde el esquema base sin API,
   sin migración y con RLS activo sin políticas:
   - La crea si no existe (CI, bases nuevas).
   - Le suma lo que falte para sincronizarla: ``created_at``, ``updated_at``,
     ``deleted_at``, ``categoria`` y ``creado_por_id``.
   - Sus CHECK se agregan ``not valid`` en Postgres: valen para lo que se
     escriba de ahora en más sin rechazar filas viejas que no se conocen.
   - Le pone políticas: cada establecimiento ve y edita las suyas; las filas
     sin establecimiento (catálogo global) son de solo lectura. ``anon`` pierde
     todos los permisos.
2. Crea ``registros_alimentacion`` (cabecera: qué, dónde, cuándo, cuánto) y
   ``registros_alimentacion_animales`` (detalle: a quiénes), con triggers de
   pertenencia y RLS.

Defensiva: no recrea lo que ya exista. Espejo para el SQL Editor de Supabase:
``backend/scripts/crear_alimentacion.sql``.

Revision ID: 20261114_02
Revises: 20261114_01
Create Date: 2026-11-14
"""

from collections.abc import Sequence

from alembic import op
import sqlalchemy as sa
from sqlalchemy.engine import Connection

revision: str = "20261114_02"
down_revision: str | None = "20261114_01"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None

_ALIMENTOS = "alimentos"
_REGISTROS = "registros_alimentacion"
_DETALLE = "registros_alimentacion_animales"
_TABLAS_REQUERIDAS = ("establecimientos", "usuarios", "lotes", "animales")

# Copias literales de ``api.shared.enums``: la migración no importa código de la
# aplicación. ``test_alimentacion_migration`` verifica que coincidan.
_CATEGORIAS_ALIMENTO = (
    "grano",
    "concentrado",
    "heno",
    "silaje",
    "subproducto",
    "mineral",
    "otro",
)
_UNIDADES = ("kg", "g", "l", "fardo", "rollo", "bolsa")
_TIPOS_REGISTRO = ("suplemento", "dieta")
_BASES_CANTIDAD = ("por_animal_dia", "grupo_dia")

_INDICES_ALIMENTOS = (
    ("ix_alimentos_sync", ["establecimiento_id", "updated_at"]),
    ("ix_alimentos_establecimiento_id", ["establecimiento_id"]),
)
_INDICES_REGISTROS = (
    ("ix_registros_alimentacion_sync", ["establecimiento_id", "updated_at"]),
    ("ix_registros_alimentacion_fecha", ["establecimiento_id", "fecha_desde"]),
    ("ix_registros_alimentacion_establecimiento_id", ["establecimiento_id"]),
    ("ix_registros_alimentacion_alimento_id", ["alimento_id"]),
)
_INDICES_DETALLE = (
    (
        "ix_registros_alimentacion_animales_registro_alimentacion_id",
        ["registro_alimentacion_id"],
    ),
    ("ix_registros_alimentacion_animales_animal_id", ["animal_id"]),
)


def _lista_sql(valores: Sequence[str]) -> str:
    return ", ".join(f"'{valor}'" for valor in valores)


_CHECKS_ALIMENTOS = (
    ("ck_alimentos_nombre_no_vacio", "trim(nombre) <> ''"),
    (
        "ck_alimentos_categoria_valida",
        f"categoria in ({_lista_sql(_CATEGORIAS_ALIMENTO)})",
    ),
    ("ck_alimentos_unidad_valida", f"unidad in ({_lista_sql(_UNIDADES)})"),
)

_FUNCION_VALIDAR_REGISTRO = """
create or replace function public.validar_registro_alimentacion()
returns trigger
language plpgsql
security invoker
set search_path = public, pg_temp
as $$
declare
    v_establecimiento_id uuid;
begin
    if tg_op = 'UPDATE' then
        if new.establecimiento_id <> old.establecimiento_id
           or new.alimento_id <> old.alimento_id
           or new.tipo <> old.tipo then
            raise exception 'Un registro de alimentación no puede cambiar de establecimiento, alimento ni tipo'
                using errcode = 'check_violation';
        end if;
    end if;

    select a.establecimiento_id
      into v_establecimiento_id
      from public.alimentos a
     where a.id = new.alimento_id;
    -- El catálogo global (establecimiento null) lo puede usar cualquiera.
    if found and v_establecimiento_id is not null
       and v_establecimiento_id <> new.establecimiento_id then
        raise exception 'El alimento pertenece a otro establecimiento'
            using errcode = 'check_violation';
    end if;

    if new.lote_id is not null then
        select l.establecimiento_id
          into v_establecimiento_id
          from public.lotes l
         where l.id = new.lote_id;
        if found and v_establecimiento_id <> new.establecimiento_id then
            raise exception 'El lote pertenece a otro establecimiento'
                using errcode = 'check_violation';
        end if;
    end if;

    return new;
end;
$$
"""

_FUNCION_VALIDAR_DETALLE = """
create or replace function public.validar_registro_alimentacion_animal()
returns trigger
language plpgsql
security invoker
set search_path = public, pg_temp
as $$
declare
    v_registro uuid;
    v_animal uuid;
begin
    select r.establecimiento_id
      into v_registro
      from public.registros_alimentacion r
     where r.id = new.registro_alimentacion_id;

    select a.establecimiento_id
      into v_animal
      from public.animales a
     where a.id = new.animal_id;

    -- Sin filas visibles deciden la FK (backend) o el RLS (cliente directo).
    if v_registro is not null and v_animal is not null and v_registro <> v_animal then
        raise exception 'El animal pertenece a otro establecimiento'
            using errcode = 'check_violation';
    end if;

    return new;
end;
$$
"""

_TRIGGERS = (
    f"drop trigger if exists trg_registros_alimentacion_validar on public.{_REGISTROS}",
    f"""
create trigger trg_registros_alimentacion_validar
before insert or update on public.{_REGISTROS}
for each row execute function public.validar_registro_alimentacion()
""",
    "drop trigger if exists trg_registros_alimentacion_animales_validar"
    f" on public.{_DETALLE}",
    f"""
create trigger trg_registros_alimentacion_animales_validar
before insert or update on public.{_DETALLE}
for each row execute function public.validar_registro_alimentacion_animal()
""",
)


def _es_miembro(tabla: str) -> str:
    return f"""
    exists (
        select 1
        from public.usuarios_establecimientos ue
        where ue.establecimiento_id = {tabla}.establecimiento_id
          and ue.usuario_id = auth.uid()
          and ue.activo = true
    )
"""


_ES_MIEMBRO_DEL_REGISTRO = """
    exists (
        select 1
        from public.registros_alimentacion r
        join public.usuarios_establecimientos ue
          on ue.establecimiento_id = r.establecimiento_id
        where r.id = registros_alimentacion_animales.registro_alimentacion_id
          and ue.usuario_id = auth.uid()
          and ue.activo = true
    )
"""

_ANIMAL_DEL_REGISTRO = """
    exists (
        select 1
        from public.registros_alimentacion r
        where r.id = registros_alimentacion_animales.registro_alimentacion_id
          and public.animal_pertenece_a_establecimiento(
              registros_alimentacion_animales.animal_id, r.establecimiento_id
          )
    )
"""


def _exigir_tablas_previas(connection: Connection) -> None:
    inspector = sa.inspect(connection)
    faltantes = [t for t in _TABLAS_REQUERIDAS if not inspector.has_table(t)]
    if faltantes:
        raise RuntimeError(
            "No se puede crear la alimentación: faltan las tablas "
            f"{', '.join(faltantes)}."
        )


def _columnas_sync() -> list[sa.Column]:
    return [
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column(
            "created_at",
            sa.DateTime(timezone=True),
            server_default=sa.text("now()"),
            nullable=False,
        ),
        sa.Column(
            "updated_at",
            sa.DateTime(timezone=True),
            server_default=sa.text("now()"),
            nullable=False,
        ),
    ]


# ---------------------------------------------------------------- alimentos


def _crear_alimentos() -> None:
    op.create_table(
        _ALIMENTOS,
        *_columnas_sync(),
        sa.Column("deleted_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("establecimiento_id", sa.Uuid(), nullable=True),
        sa.Column("nombre", sa.String(), nullable=False),
        sa.Column(
            "categoria", sa.String(), server_default=sa.text("'otro'"), nullable=False
        ),
        sa.Column(
            "unidad", sa.String(), server_default=sa.text("'kg'"), nullable=False
        ),
        sa.Column("valor_proteico", sa.Numeric(6, 2), nullable=True),
        sa.Column("valor_vitaminico", sa.Numeric(6, 2), nullable=True),
        sa.Column("costo_unitario", sa.Numeric(14, 2), nullable=True),
        sa.Column("creado_por_id", sa.Uuid(), nullable=True),
        *(
            sa.CheckConstraint(condicion, name=nombre)
            for nombre, condicion in _CHECKS_ALIMENTOS
        ),
        sa.ForeignKeyConstraint(["establecimiento_id"], ["establecimientos.id"]),
        sa.ForeignKeyConstraint(["creado_por_id"], ["usuarios.id"]),
        sa.PrimaryKeyConstraint("id"),
    )


def _completar_alimentos(connection: Connection) -> None:
    """Suma a la tabla heredada las columnas que le faltan para sincronizarse."""
    existentes = {c["name"] for c in sa.inspect(connection).get_columns(_ALIMENTOS)}
    faltantes = (
        sa.Column(
            "created_at",
            sa.DateTime(timezone=True),
            server_default=sa.text("now()"),
            nullable=False,
        ),
        sa.Column(
            "updated_at",
            sa.DateTime(timezone=True),
            server_default=sa.text("now()"),
            nullable=False,
        ),
        sa.Column("deleted_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column(
            "categoria", sa.String(), server_default=sa.text("'otro'"), nullable=False
        ),
        sa.Column(
            "creado_por_id", sa.Uuid(), sa.ForeignKey("usuarios.id"), nullable=True
        ),
    )
    for columna in faltantes:
        if columna.name not in existentes:
            op.add_column(_ALIMENTOS, columna)

    if connection.dialect.name != "postgresql":
        return
    actuales = {
        c["name"] for c in sa.inspect(connection).get_check_constraints(_ALIMENTOS)
    }
    for nombre, condicion in _CHECKS_ALIMENTOS:
        if nombre not in actuales:
            # ``not valid``: no se conocen las filas que pueda haber cargado
            # alguien a mano antes de la adopción, y no deben trabar el deploy.
            connection.execute(
                sa.text(
                    f"alter table public.{_ALIMENTOS} add constraint {nombre}"
                    f" check ({condicion}) not valid"
                )
            )


# ------------------------------------------------------------------ registros


def _crear_registros() -> None:
    op.create_table(
        _REGISTROS,
        *_columnas_sync(),
        sa.Column("deleted_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("establecimiento_id", sa.Uuid(), nullable=False),
        sa.Column("tipo", sa.String(), nullable=False),
        sa.Column("alimento_id", sa.Uuid(), nullable=False),
        sa.Column("lote_id", sa.Uuid(), nullable=True),
        sa.Column("fecha_desde", sa.Date(), nullable=False),
        sa.Column("fecha_hasta", sa.Date(), nullable=True),
        sa.Column("cantidad", sa.Numeric(12, 3), nullable=False),
        sa.Column("unidad", sa.String(), nullable=False),
        sa.Column("base_cantidad", sa.String(), nullable=False),
        sa.Column("motivo", sa.String(), nullable=True),
        sa.Column("responsable_id", sa.Uuid(), nullable=True),
        sa.CheckConstraint(
            f"tipo in ({_lista_sql(_TIPOS_REGISTRO)})",
            name="ck_registros_alimentacion_tipo_valido",
        ),
        sa.CheckConstraint(
            f"unidad in ({_lista_sql(_UNIDADES)})",
            name="ck_registros_alimentacion_unidad_valida",
        ),
        sa.CheckConstraint(
            f"base_cantidad in ({_lista_sql(_BASES_CANTIDAD)})",
            name="ck_registros_alimentacion_base_valida",
        ),
        sa.CheckConstraint("cantidad > 0", name="ck_registros_alimentacion_cantidad"),
        sa.CheckConstraint(
            "fecha_hasta is null or fecha_hasta >= fecha_desde",
            name="ck_registros_alimentacion_fechas",
        ),
        sa.ForeignKeyConstraint(["establecimiento_id"], ["establecimientos.id"]),
        sa.ForeignKeyConstraint(["alimento_id"], ["alimentos.id"]),
        sa.ForeignKeyConstraint(["lote_id"], ["lotes.id"]),
        sa.ForeignKeyConstraint(["responsable_id"], ["usuarios.id"]),
        sa.PrimaryKeyConstraint("id"),
    )


def _crear_detalle() -> None:
    op.create_table(
        _DETALLE,
        *_columnas_sync(),
        sa.Column("registro_alimentacion_id", sa.Uuid(), nullable=False),
        sa.Column("animal_id", sa.Uuid(), nullable=False),
        sa.ForeignKeyConstraint(
            ["registro_alimentacion_id"], ["registros_alimentacion.id"]
        ),
        sa.ForeignKeyConstraint(["animal_id"], ["animales.id"]),
        sa.UniqueConstraint(
            "registro_alimentacion_id",
            "animal_id",
            name="uq_registro_alimentacion_animal",
        ),
        sa.PrimaryKeyConstraint("id"),
    )


def _crear_indices_faltantes(
    connection: Connection, tabla: str, indices: Sequence[tuple[str, list[str]]]
) -> None:
    existentes = {i["name"] for i in sa.inspect(connection).get_indexes(tabla)}
    for nombre, columnas in indices:
        if nombre not in existentes:
            op.create_index(nombre, tabla, columnas, unique=False)


def _crear_triggers(connection: Connection) -> None:
    if connection.dialect.name != "postgresql":
        return
    for sentencia in (_FUNCION_VALIDAR_REGISTRO, _FUNCION_VALIDAR_DETALLE, *_TRIGGERS):
        connection.execute(sa.text(sentencia))


# ------------------------------------------------------------------------ RLS


def _soporta_rls(connection: Connection) -> bool:
    """Indica si la base es un Postgres con Supabase Auth (``auth.uid()``)."""
    if connection.dialect.name != "postgresql":
        return False
    return connection.execute(
        sa.text("select to_regprocedure('auth.uid()') is not null")
    ).scalar_one()


def _politicas_alimentos() -> tuple[str, ...]:
    miembro = _es_miembro(_ALIMENTOS)
    return (
        f"alter table public.{_ALIMENTOS} enable row level security",
        f"drop policy if exists {_ALIMENTOS}_select_miembros on public.{_ALIMENTOS}",
        f"""
        create policy {_ALIMENTOS}_select_miembros on public.{_ALIMENTOS}
        for select to authenticated
        using (establecimiento_id is null or {miembro})
        """,
        f"drop policy if exists {_ALIMENTOS}_insert_miembros on public.{_ALIMENTOS}",
        f"""
        create policy {_ALIMENTOS}_insert_miembros on public.{_ALIMENTOS}
        for insert to authenticated
        with check (
            establecimiento_id is not null
            and creado_por_id = auth.uid()
            and {miembro}
        )
        """,
        f"drop policy if exists {_ALIMENTOS}_update_miembros on public.{_ALIMENTOS}",
        f"""
        create policy {_ALIMENTOS}_update_miembros on public.{_ALIMENTOS}
        for update to authenticated
        using (establecimiento_id is not null and {miembro})
        with check (establecimiento_id is not null and {miembro})
        """,
        f"revoke all on public.{_ALIMENTOS} from anon",
        f"revoke all on public.{_ALIMENTOS} from authenticated",
        f"grant select, insert, update on public.{_ALIMENTOS} to authenticated",
    )


def _politicas_registros() -> tuple[str, ...]:
    miembro = _es_miembro(_REGISTROS)
    return (
        f"alter table public.{_REGISTROS} enable row level security",
        f"drop policy if exists {_REGISTROS}_select_miembros on public.{_REGISTROS}",
        f"""
        create policy {_REGISTROS}_select_miembros on public.{_REGISTROS}
        for select to authenticated
        using ({miembro})
        """,
        f"drop policy if exists {_REGISTROS}_insert_miembros on public.{_REGISTROS}",
        f"""
        create policy {_REGISTROS}_insert_miembros on public.{_REGISTROS}
        for insert to authenticated
        with check (responsable_id = auth.uid() and {miembro})
        """,
        # Borrado soft: se cubre con update, sin política de delete.
        f"drop policy if exists {_REGISTROS}_update_miembros on public.{_REGISTROS}",
        f"""
        create policy {_REGISTROS}_update_miembros on public.{_REGISTROS}
        for update to authenticated
        using ({miembro})
        with check ({miembro})
        """,
        f"revoke all on public.{_REGISTROS} from anon",
        f"revoke all on public.{_REGISTROS} from authenticated",
        f"grant select, insert, update on public.{_REGISTROS} to authenticated",
        f"alter table public.{_DETALLE} enable row level security",
        f"drop policy if exists {_DETALLE}_select_miembros on public.{_DETALLE}",
        f"""
        create policy {_DETALLE}_select_miembros on public.{_DETALLE}
        for select to authenticated
        using ({_ES_MIEMBRO_DEL_REGISTRO})
        """,
        f"drop policy if exists {_DETALLE}_insert_miembros on public.{_DETALLE}",
        f"""
        create policy {_DETALLE}_insert_miembros on public.{_DETALLE}
        for insert to authenticated
        with check ({_ES_MIEMBRO_DEL_REGISTRO} and {_ANIMAL_DEL_REGISTRO})
        """,
        # El detalle es inmutable: corregir los animales es borrar el registro y
        # crear otro. Sin update ni delete.
        f"revoke all on public.{_DETALLE} from anon",
        f"revoke all on public.{_DETALLE} from authenticated",
        f"grant select, insert on public.{_DETALLE} to authenticated",
    )


def _aplicar_rls(connection: Connection) -> None:
    if not _soporta_rls(connection):
        return
    for sentencia in (*_politicas_alimentos(), *_politicas_registros()):
        connection.execute(sa.text(sentencia))


def upgrade() -> None:
    connection = op.get_bind()
    _exigir_tablas_previas(connection)

    if sa.inspect(connection).has_table(_ALIMENTOS):
        _completar_alimentos(connection)
    else:
        _crear_alimentos()
    _crear_indices_faltantes(connection, _ALIMENTOS, _INDICES_ALIMENTOS)

    inspector = sa.inspect(connection)
    if not inspector.has_table(_REGISTROS):
        _crear_registros()
    if not inspector.has_table(_DETALLE):
        _crear_detalle()
    _crear_indices_faltantes(connection, _REGISTROS, _INDICES_REGISTROS)
    _crear_indices_faltantes(connection, _DETALLE, _INDICES_DETALLE)

    _crear_triggers(connection)
    _aplicar_rls(connection)


def downgrade() -> None:
    """Elimina los registros. ``alimentos`` se conserva (existía antes de esta
    revisión); solo pierde sus políticas y queda como estaba: RLS sin políticas."""
    connection = op.get_bind()
    if connection.dialect.name == "postgresql":
        for sentencia in (
            "drop trigger if exists trg_registros_alimentacion_animales_validar"
            f" on public.{_DETALLE}",
            f"drop trigger if exists trg_registros_alimentacion_validar on public.{_REGISTROS}",
            "drop function if exists public.validar_registro_alimentacion_animal()",
            "drop function if exists public.validar_registro_alimentacion()",
            f"drop policy if exists {_ALIMENTOS}_select_miembros on public.{_ALIMENTOS}",
            f"drop policy if exists {_ALIMENTOS}_insert_miembros on public.{_ALIMENTOS}",
            f"drop policy if exists {_ALIMENTOS}_update_miembros on public.{_ALIMENTOS}",
        ):
            connection.execute(sa.text(sentencia))
    inspector = sa.inspect(connection)
    if inspector.has_table(_DETALLE):
        op.drop_table(_DETALLE)
    if inspector.has_table(_REGISTROS):
        op.drop_table(_REGISTROS)
