"""Recurso forrajero del potrero con historial por período (adr-0015).

1. Amplía el catálogo de ``lotes.recurso_forrajero_codigo`` (pasturas, verdeos y
   rastrojos de la zona).
2. Crea ``lotes_recursos_forrajeros``: qué recurso tuvo cada lote desde qué
   fecha, sincronizable (UUID del cliente, ``updated_at``, ``deleted_at``), con su
   trigger de pertenencia y sus políticas RLS.
3. Convierte el recurso actual de cada lote en un período inicial:
   - ``fecha_desde`` toma ``lotes.created_at``: es el único dato disponible.
   - ``created_at``/``updated_at`` son el momento de la migración, para que la
     descarga delta de los clientes lo baje.
   - El id es determinista, ``md5('recurso_legacy:' || lote_id)``, así que
     reejecutar la migración (o el script espejo) no duplica nada.

``lotes.recurso_forrajero_codigo`` se conserva como el recurso vigente; desde
ahora lo mantiene el backend a partir de los períodos.

Defensiva: no recrea lo que ya exista. Espejo para el SQL Editor de Supabase:
``backend/scripts/crear_recursos_forrajeros_por_periodo.sql``.

Revision ID: 20261114_01
Revises: 20261017_02
Create Date: 2026-11-14
"""

from collections.abc import Sequence
import hashlib
from uuid import UUID

from alembic import op
import sqlalchemy as sa
from sqlalchemy.engine import Connection

revision: str = "20261114_01"
down_revision: str | None = "20261017_02"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None

_LOTES = "lotes"
_TABLA = "lotes_recursos_forrajeros"
_TABLAS_REQUERIDAS = ("establecimientos", "usuarios", _LOTES)
_PREFIJO_ID_LEGACY = "recurso_legacy:"

# Copia literal de ``api.shared.enums.RecursoForrajero``: la migración no importa
# código de la aplicación. ``test_lotes_modelo`` verifica que coincidan.
_RECURSOS_FORRAJEROS = (
    "pasto_natural",
    "alfalfa",
    "sorgo",
    "maiz",
    "avena",
    "otro",
    "pastura_consociada",
    "festuca",
    "agropiro",
    "raigras",
    "cebada",
    "centeno",
    "triticale",
    "moha",
    "gatton_panic",
    "grama_rhodes",
    "rastrojo_maiz",
    "rastrojo_sorgo",
    "rastrojo_soja",
    "verdeo_verano",
)
_RECURSOS_PREVIOS = ("pasto_natural", "alfalfa", "sorgo", "maiz", "avena", "otro")

_CK_LOTES_RECURSO = "ck_lotes_recurso_forrajero_valido"
_CK_CODIGO = "ck_lotes_recursos_forrajeros_codigo_valido"
_CK_FECHAS = "ck_lotes_recursos_forrajeros_fechas"
_CK_DESCRIPCION = "ck_lotes_recursos_forrajeros_descripcion_no_vacia"
_UQ_LOTE_DESDE = "uq_lotes_recursos_forrajeros_lote_desde"
_INDICES = (
    ("ix_lotes_recursos_forrajeros_sync", ["establecimiento_id", "updated_at"]),
    ("ix_lotes_recursos_forrajeros_lote", ["lote_id", "fecha_desde"]),
    ("ix_lotes_recursos_forrajeros_establecimiento_id", ["establecimiento_id"]),
)

_FUNCION_VALIDAR = """
create or replace function public.validar_lote_recurso_forrajero()
returns trigger
language plpgsql
security invoker
set search_path = public, pg_temp
as $$
declare
    v_establecimiento_id uuid;
begin
    if tg_op = 'UPDATE' then
        if new.lote_id <> old.lote_id
           or new.establecimiento_id <> old.establecimiento_id then
            raise exception 'Un período de recurso no puede cambiar de lote ni de establecimiento'
                using errcode = 'check_violation';
        end if;
        return new;
    end if;

    select l.establecimiento_id
      into v_establecimiento_id
      from public.lotes l
     where l.id = new.lote_id;

    -- Sin lote visible deciden la FK (backend) o el RLS (cliente directo).
    if found and v_establecimiento_id <> new.establecimiento_id then
        raise exception 'El lote pertenece a otro establecimiento'
            using errcode = 'check_violation';
    end if;

    return new;
end;
$$
"""

_TRIGGERS = (
    "drop trigger if exists trg_lotes_recursos_forrajeros_validar"
    " on public.lotes_recursos_forrajeros",
    """
create trigger trg_lotes_recursos_forrajeros_validar
before insert or update on public.lotes_recursos_forrajeros
for each row execute function public.validar_lote_recurso_forrajero()
""",
)

_ES_MIEMBRO = """
    exists (
        select 1
        from public.usuarios_establecimientos ue
        where ue.establecimiento_id = lotes_recursos_forrajeros.establecimiento_id
          and ue.usuario_id = auth.uid()
          and ue.activo = true
    )
"""


def _lista_sql(valores: Sequence[str]) -> str:
    return ", ".join(f"'{valor}'" for valor in valores)


def id_periodo_legacy(lote_id: UUID) -> UUID:
    """Id del período migrado de un lote. Igual a ``md5(...)::uuid`` del SQL."""
    digest = hashlib.md5(f"{_PREFIJO_ID_LEGACY}{lote_id}".encode()).hexdigest()
    return UUID(digest)


def _exigir_tablas_previas(connection: Connection) -> None:
    inspector = sa.inspect(connection)
    faltantes = [t for t in _TABLAS_REQUERIDAS if not inspector.has_table(t)]
    if faltantes:
        raise RuntimeError(
            "No se puede crear lotes_recursos_forrajeros: faltan las tablas "
            f"{', '.join(faltantes)}."
        )


def _reemplazar_check_de_lotes(connection: Connection, valores: Sequence[str]) -> None:
    """Redefine el catálogo admitido en ``lotes``.

    Solo en Postgres: en SQLite (tests) el esquema sale de ``create_all`` con el
    enum vigente y no hay constraint viejo que reemplazar.
    """
    if connection.dialect.name != "postgresql":
        return
    connection.execute(
        sa.text(
            f"alter table public.{_LOTES} drop constraint if exists {_CK_LOTES_RECURSO}"
        )
    )
    connection.execute(
        sa.text(
            f"alter table public.{_LOTES} add constraint {_CK_LOTES_RECURSO} check ("
            "recurso_forrajero_codigo is null"
            f" or recurso_forrajero_codigo in ({_lista_sql(valores)}))"
        )
    )


def _crear_tabla() -> None:
    op.create_table(
        _TABLA,
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
        sa.Column("deleted_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("establecimiento_id", sa.Uuid(), nullable=False),
        sa.Column("lote_id", sa.Uuid(), nullable=False),
        sa.Column("recurso_forrajero_codigo", sa.String(), nullable=False),
        sa.Column("descripcion", sa.String(), nullable=True),
        sa.Column("fecha_desde", sa.Date(), nullable=False),
        sa.Column("fecha_hasta", sa.Date(), nullable=True),
        sa.Column("registrado_por_id", sa.Uuid(), nullable=True),
        sa.CheckConstraint(
            f"recurso_forrajero_codigo in ({_lista_sql(_RECURSOS_FORRAJEROS)})",
            name=_CK_CODIGO,
        ),
        sa.CheckConstraint(
            "fecha_hasta is null or fecha_hasta >= fecha_desde", name=_CK_FECHAS
        ),
        sa.CheckConstraint(
            "descripcion is null or trim(descripcion) <> ''", name=_CK_DESCRIPCION
        ),
        sa.ForeignKeyConstraint(["establecimiento_id"], ["establecimientos.id"]),
        sa.ForeignKeyConstraint(["lote_id"], ["lotes.id"]),
        sa.ForeignKeyConstraint(["registrado_por_id"], ["usuarios.id"]),
        sa.PrimaryKeyConstraint("id"),
    )


def _crear_indices_faltantes(connection: Connection) -> None:
    existentes = {i["name"] for i in sa.inspect(connection).get_indexes(_TABLA)}
    for nombre, columnas in _INDICES:
        if nombre not in existentes:
            op.create_index(nombre, _TABLA, columnas, unique=False)
    if _UQ_LOTE_DESDE not in existentes:
        op.create_index(
            _UQ_LOTE_DESDE,
            _TABLA,
            ["lote_id", "fecha_desde"],
            unique=True,
            postgresql_where=sa.text("deleted_at is null"),
            sqlite_where=sa.text("deleted_at is null"),
        )


def _crear_trigger(connection: Connection) -> None:
    if connection.dialect.name != "postgresql":
        return
    for sentencia in (_FUNCION_VALIDAR, *_TRIGGERS):
        connection.execute(sa.text(sentencia))


def _migrar_recursos_legacy(connection: Connection) -> None:
    """Un período por cada lote con recurso, sin duplicar."""
    lotes = connection.execute(
        sa.text(
            "select id, establecimiento_id, recurso_forrajero_codigo, created_at,"
            " deleted_at"
            f" from {_LOTES}"
            " where recurso_forrajero_codigo is not null"
        )
    ).all()
    for lote_id, establecimiento_id, codigo, alta, borrado in lotes:
        periodo_id = id_periodo_legacy(UUID(str(lote_id)))
        ya_migrado = connection.execute(
            sa.text(f"select 1 from {_TABLA} where id = :id"),
            {"id": periodo_id},
        ).first()
        if ya_migrado:
            continue
        connection.execute(
            sa.text(
                f"insert into {_TABLA}"
                " (id, establecimiento_id, lote_id, recurso_forrajero_codigo,"
                " descripcion, fecha_desde, fecha_hasta, registrado_por_id,"
                " created_at, updated_at, deleted_at)"
                " values (:id, :establecimiento_id, :lote_id, :codigo,"
                " :descripcion, :fecha_desde, null, null,"
                " current_timestamp, current_timestamp, :deleted_at)"
            ),
            {
                "id": periodo_id,
                "establecimiento_id": establecimiento_id,
                "lote_id": lote_id,
                "codigo": codigo,
                # Un ``otro`` sin detalle no se puede describir mejor: el
                # cliente muestra el nombre del código.
                "descripcion": None,
                "fecha_desde": alta.date() if hasattr(alta, "date") else alta,
                "deleted_at": borrado,
            },
        )


def _soporta_rls(connection: Connection) -> bool:
    """Indica si la base es un Postgres con Supabase Auth (``auth.uid()``)."""
    if connection.dialect.name != "postgresql":
        return False
    return connection.execute(
        sa.text("select to_regprocedure('auth.uid()') is not null")
    ).scalar_one()


def _aplicar_rls(connection: Connection) -> None:
    if not _soporta_rls(connection):
        return
    sentencias = (
        f"alter table public.{_TABLA} enable row level security",
        f"drop policy if exists {_TABLA}_select_miembros on public.{_TABLA}",
        f"""
        create policy {_TABLA}_select_miembros on public.{_TABLA}
        for select to authenticated
        using ({_ES_MIEMBRO})
        """,
        f"drop policy if exists {_TABLA}_insert_miembros on public.{_TABLA}",
        f"""
        create policy {_TABLA}_insert_miembros on public.{_TABLA}
        for insert to authenticated
        with check (registrado_por_id = auth.uid() and {_ES_MIEMBRO})
        """,
        # El borrado es soft (``deleted_at``): se cubre con update y no hay
        # política de delete. Cualquier miembro activo, igual que en lotes.
        f"drop policy if exists {_TABLA}_update_miembros on public.{_TABLA}",
        f"""
        create policy {_TABLA}_update_miembros on public.{_TABLA}
        for update to authenticated
        using ({_ES_MIEMBRO})
        with check ({_ES_MIEMBRO})
        """,
        f"revoke all on public.{_TABLA} from anon",
        f"revoke all on public.{_TABLA} from authenticated",
        f"grant select, insert, update on public.{_TABLA} to authenticated",
    )
    for sentencia in sentencias:
        connection.execute(sa.text(sentencia))


def upgrade() -> None:
    connection = op.get_bind()
    _exigir_tablas_previas(connection)
    _reemplazar_check_de_lotes(connection, _RECURSOS_FORRAJEROS)
    if not sa.inspect(connection).has_table(_TABLA):
        _crear_tabla()
    _crear_indices_faltantes(connection)
    _crear_trigger(connection)
    _migrar_recursos_legacy(connection)
    _aplicar_rls(connection)


def downgrade() -> None:
    """Elimina el historial. ``lotes.recurso_forrajero_codigo`` vuelve al
    catálogo original: los lotes con un código nuevo quedan sin recurso."""
    connection = op.get_bind()
    if connection.dialect.name == "postgresql":
        connection.execute(
            sa.text(
                "drop trigger if exists trg_lotes_recursos_forrajeros_validar"
                f" on public.{_TABLA}"
            )
        )
        connection.execute(
            sa.text("drop function if exists public.validar_lote_recurso_forrajero()")
        )
    if sa.inspect(connection).has_table(_TABLA):
        op.drop_table(_TABLA)
    if connection.dialect.name == "postgresql":
        connection.execute(
            sa.text(
                f"update public.{_LOTES} set recurso_forrajero_codigo = null"
                " where recurso_forrajero_codigo is not null"
                f" and recurso_forrajero_codigo not in ({_lista_sql(_RECURSOS_PREVIOS)})"
            )
        )
    _reemplazar_check_de_lotes(connection, _RECURSOS_PREVIOS)
