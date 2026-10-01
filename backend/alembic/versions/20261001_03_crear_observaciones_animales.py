"""Observaciones de un animal como entradas independientes (VITA-173).

1. Crea ``observaciones_animales``: texto, fecha y autor por entrada, sincronizable
   (UUID del cliente, ``updated_at``, ``deleted_at``), con su trigger de
   pertenencia e inmutabilidad y sus políticas RLS.
2. Convierte cada ``animales.observaciones`` no vacío en una entrada inicial:
   - El texto se copia íntegro.
   - El autor queda en null porque no se conoce.
   - ``fecha`` toma ``animales.created_at``: es el único timestamp disponible, y
     solo dice cuándo se dio de alta el animal, no cuándo se escribió la nota.
   - ``created_at``/``updated_at`` son el momento de la migración, para que la
     descarga delta (``updated_since``) de los clientes las baje.
   - El id es determinista, ``md5('observacion_legacy:' || animal_id)``, así que
     reejecutar la migración (o el script espejo) no duplica nada.

``animales.observaciones`` se conserva mientras haya clientes que la escriban
(ver ``docs/adr/adr-0007-observaciones-animales-como-entradas.md``).

Revision ID: 20261001_03
Revises: 20261001_02
Create Date: 2026-10-01
"""

from collections.abc import Sequence
import hashlib
from uuid import UUID

from alembic import op
import sqlalchemy as sa
from sqlalchemy.engine import Connection

revision: str = "20261001_03"
down_revision: str | None = "20261001_02"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None

_TABLA = "observaciones_animales"
_TABLAS_REQUERIDAS = ("establecimientos", "usuarios", "animales")
_PREFIJO_ID_LEGACY = "observacion_legacy:"

_CK_TEXTO = "ck_observaciones_animales_texto_no_vacio"
_INDICES = (
    ("ix_observaciones_animales_fecha", ["animal_id", "fecha"]),
    ("ix_observaciones_animales_sync", ["establecimiento_id", "updated_at"]),
)

# Copia literal de ``api.modules.observaciones_animales.models``: la migración no
# importa código de la aplicación. ``test_observaciones_animales_migration``
# verifica que coincidan.
_FUNCION_OBSERVACION_ANIMAL = """
create or replace function public.validar_observacion_animal()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
    v_establecimiento_id uuid;
begin
    if tg_op = 'UPDATE' then
        if new.animal_id <> old.animal_id
           or new.establecimiento_id <> old.establecimiento_id
           or new.autor_id is distinct from old.autor_id then
            raise exception 'Una observación no puede cambiar de animal, establecimiento ni autor'
                using errcode = 'check_violation';
        end if;
        return new;
    end if;

    select a.establecimiento_id
      into v_establecimiento_id
      from public.animales a
     where a.id = new.animal_id;

    -- Sin animal, la FK rechaza la fila.
    if found and v_establecimiento_id <> new.establecimiento_id then
        raise exception 'El animal pertenece a otro establecimiento'
            using errcode = 'check_violation';
    end if;

    return new;
end;
$$
"""

_TRIGGERS_OBSERVACION_ANIMAL = (
    "drop trigger if exists trg_observaciones_animales_validar"
    " on public.observaciones_animales",
    """
create trigger trg_observaciones_animales_validar
before insert or update on public.observaciones_animales
for each row execute function public.validar_observacion_animal()
""",
)

# Predicado de pertenencia al tenant, idéntico al del resto de las tablas.
_ES_MIEMBRO = """
    exists (
        select 1
        from public.usuarios_establecimientos ue
        where ue.establecimiento_id = observaciones_animales.establecimiento_id
          and ue.usuario_id = auth.uid()
          and ue.activo = true
    )
"""


def id_observacion_legacy(animal_id: UUID) -> UUID:
    """Id de la entrada migrada de un animal. Igual a ``md5(...)::uuid`` del SQL."""
    digest = hashlib.md5(f"{_PREFIJO_ID_LEGACY}{animal_id}".encode()).hexdigest()
    return UUID(digest)


def _exigir_tablas_previas(connection: Connection) -> None:
    inspector = sa.inspect(connection)
    faltantes = [t for t in _TABLAS_REQUERIDAS if not inspector.has_table(t)]
    if faltantes:
        raise RuntimeError(
            "No se puede crear observaciones_animales: faltan las tablas "
            f"{', '.join(faltantes)}."
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
        sa.Column("animal_id", sa.Uuid(), nullable=False),
        sa.Column("establecimiento_id", sa.Uuid(), nullable=False),
        sa.Column("texto", sa.Text(), nullable=False),
        sa.Column("fecha", sa.DateTime(timezone=True), nullable=False),
        sa.Column("autor_id", sa.Uuid(), nullable=True),
        sa.CheckConstraint("trim(texto) <> ''", name=_CK_TEXTO),
        sa.ForeignKeyConstraint(["animal_id"], ["animales.id"]),
        sa.ForeignKeyConstraint(["establecimiento_id"], ["establecimientos.id"]),
        sa.ForeignKeyConstraint(["autor_id"], ["usuarios.id"]),
        sa.PrimaryKeyConstraint("id"),
    )


def _crear_indices_faltantes(connection: Connection) -> None:
    existentes = {i["name"] for i in sa.inspect(connection).get_indexes(_TABLA)}
    for nombre, columnas in _INDICES:
        if nombre not in existentes:
            op.create_index(nombre, _TABLA, columnas, unique=False)


def _crear_trigger(connection: Connection) -> None:
    if connection.dialect.name != "postgresql":
        return
    for sentencia in (_FUNCION_OBSERVACION_ANIMAL, *_TRIGGERS_OBSERVACION_ANIMAL):
        connection.execute(sa.text(sentencia))


def _migrar_observaciones_legacy(connection: Connection) -> None:
    """Una entrada por cada ``animales.observaciones`` no vacío, sin duplicar."""
    animales = connection.execute(
        sa.text(
            "select id, establecimiento_id, observaciones, created_at, deleted_at"
            " from animales"
            " where observaciones is not null and trim(observaciones) <> ''"
        )
    ).all()
    for animal_id, establecimiento_id, texto, alta, borrado in animales:
        observacion_id = id_observacion_legacy(UUID(str(animal_id)))
        ya_migrada = connection.execute(
            sa.text(f"select 1 from {_TABLA} where id = :id"),
            {"id": observacion_id},
        ).first()
        if ya_migrada:
            continue
        connection.execute(
            sa.text(
                f"insert into {_TABLA}"
                " (id, animal_id, establecimiento_id, texto, fecha, autor_id,"
                " created_at, updated_at, deleted_at)"
                " values (:id, :animal_id, :establecimiento_id, :texto, :fecha,"
                " null, current_timestamp, current_timestamp, :deleted_at)"
            ),
            {
                "id": observacion_id,
                "animal_id": animal_id,
                "establecimiento_id": establecimiento_id,
                "texto": texto,
                "fecha": alta,
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
        with check (autor_id = auth.uid() and {_ES_MIEMBRO})
        """,
        # El borrado es soft (``deleted_at``), así que se cubre con update y no
        # se habilita ninguna política de delete. Cualquier miembro activo puede
        # editar cualquier nota del establecimiento; el autor no cambia (trigger).
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
    if not sa.inspect(connection).has_table(_TABLA):
        _crear_tabla()
    _crear_indices_faltantes(connection)
    _crear_trigger(connection)
    _migrar_observaciones_legacy(connection)
    _aplicar_rls(connection)


def downgrade() -> None:
    """Elimina la tabla. ``animales.observaciones`` nunca se tocó, así que las
    notas migradas siguen ahí; las creadas después se pierden."""
    connection = op.get_bind()
    if connection.dialect.name == "postgresql":
        connection.execute(
            sa.text(
                f"drop trigger if exists trg_observaciones_animales_validar"
                f" on public.{_TABLA}"
            )
        )
        connection.execute(
            sa.text("drop function if exists public.validar_observacion_animal()")
        )
    if sa.inspect(connection).has_table(_TABLA):
        op.drop_table(_TABLA)
