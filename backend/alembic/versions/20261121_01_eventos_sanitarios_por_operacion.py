"""Eventos sanitarios por operación: catálogo, alta por grupo e historial (VITA-20).

1. ``eventos_sanitarios`` suma la operación de alta, la foto de la práctica y de
   sus datos, el contexto del animal (caravana, lote, referencia de muestra),
   el responsable informado, la autoría del JWT, el primer resultado con su
   autoría y la ``version`` que ordena el historial incremental.
2. ``productos_sanitarios`` suma ``deleted_at`` para retirar productos sin
   romper los eventos que ya los aplicaron.
3. Crea ``operaciones_sanitarias``: un registro por envío aceptado para
   responder reenvíos sin duplicar.
4. RLS: los miembros activos leen; nadie escribe directo. Las escrituras pasan
   por el backend, que asigna la versión bajo un lock por establecimiento.
   ``anon`` pierde todos los permisos.

Las filas anteriores no se completan: no tienen práctica ni versión y quedan
fuera del historial (en Supabase la tabla estaba vacía al migrar). Ver
``docs/adr/adr-0017-eventos-sanitarios-por-operacion.md``.

Revision ID: 20261121_01
Revises: 20261017_02
Create Date: 2026-11-21
"""

from collections.abc import Sequence

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql
from sqlalchemy.engine import Connection

revision: str = "20261121_01"
down_revision: str | None = "20261017_02"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None

_EVENTOS = "eventos_sanitarios"
_PRODUCTOS = "productos_sanitarios"
_OPERACIONES = "operaciones_sanitarias"
_TABLAS_REQUERIDAS = (
    "establecimientos",
    "usuarios",
    "animales",
    "lotes",
    _EVENTOS,
    _PRODUCTOS,
)

_CK_MODELO = "ck_eventos_sanitarios_practica_modelo"
_UQ_VERSION = "uq_eventos_sanitarios_version"
_CK_TIPO_OPERACION = "ck_operaciones_sanitarias_tipo"
_INDICES_EVENTOS = (
    ("ix_eventos_sanitarios_historial", ["animal_id", "fecha_aplicacion"]),
    ("ix_eventos_sanitarios_operacion", ["operacion_id"]),
)


def _json(connection: Connection) -> sa.types.TypeEngine:
    if connection.dialect.name == "postgresql":
        return postgresql.JSONB()
    return sa.JSON()


def _columnas_eventos(connection: Connection) -> tuple[sa.Column, ...]:
    return (
        sa.Column("operacion_id", sa.Uuid(), nullable=True),
        sa.Column("practica_id", sa.String(60), nullable=True),
        sa.Column("practica_nombre", sa.String(120), nullable=True),
        sa.Column("practica_modelo", sa.String(20), nullable=True),
        sa.Column("datos", _json(connection), nullable=True),
        sa.Column("caravana", sa.String(60), nullable=True),
        sa.Column("lote_id", sa.Uuid(), sa.ForeignKey("lotes.id"), nullable=True),
        sa.Column("referencia_muestra", sa.String(60), nullable=True),
        sa.Column("responsable", sa.String(120), nullable=True),
        sa.Column(
            "registrado_por_id", sa.Uuid(), sa.ForeignKey("usuarios.id"), nullable=True
        ),
        sa.Column("resultado_fecha", sa.DateTime(timezone=True), nullable=True),
        sa.Column(
            "resultado_registrado_por_id",
            sa.Uuid(),
            sa.ForeignKey("usuarios.id"),
            nullable=True,
        ),
        sa.Column("resultado_operacion_id", sa.Uuid(), nullable=True),
        sa.Column("version", sa.BigInteger(), nullable=True),
    )


# Predicado de pertenencia al tenant, idéntico al del resto de las tablas.
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


def _exigir_tablas_previas(connection: Connection) -> None:
    inspector = sa.inspect(connection)
    faltantes = [t for t in _TABLAS_REQUERIDAS if not inspector.has_table(t)]
    if faltantes:
        raise RuntimeError(
            f"No se puede migrar Sanidad: faltan las tablas {', '.join(faltantes)}."
        )


def _ampliar_eventos(connection: Connection) -> None:
    inspector = sa.inspect(connection)
    existentes = {c["name"] for c in inspector.get_columns(_EVENTOS)}
    with op.batch_alter_table(_EVENTOS) as batch:
        for columna in _columnas_eventos(connection):
            if columna.name not in existentes:
                batch.add_column(columna)

    inspector = sa.inspect(connection)
    checks = {c["name"] for c in inspector.get_check_constraints(_EVENTOS)}
    unicos = {u["name"] for u in inspector.get_unique_constraints(_EVENTOS)}
    with op.batch_alter_table(_EVENTOS) as batch:
        if _CK_MODELO not in checks:
            batch.create_check_constraint(
                _CK_MODELO,
                "practica_modelo is null"
                " or practica_modelo in ('aplicacion', 'muestreo', 'lesion')",
            )
        if _UQ_VERSION not in unicos:
            batch.create_unique_constraint(
                _UQ_VERSION, ["establecimiento_id", "version"]
            )

    indices = {i["name"] for i in sa.inspect(connection).get_indexes(_EVENTOS)}
    for nombre, columnas in _INDICES_EVENTOS:
        if nombre not in indices:
            op.create_index(nombre, _EVENTOS, columnas, unique=False)


def _retirar_productos(connection: Connection) -> None:
    columnas = {c["name"] for c in sa.inspect(connection).get_columns(_PRODUCTOS)}
    if "deleted_at" not in columnas:
        op.add_column(
            _PRODUCTOS,
            sa.Column("deleted_at", sa.DateTime(timezone=True), nullable=True),
        )


def _crear_operaciones(connection: Connection) -> None:
    if sa.inspect(connection).has_table(_OPERACIONES):
        return
    op.create_table(
        _OPERACIONES,
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
        sa.Column("establecimiento_id", sa.Uuid(), nullable=False),
        sa.Column("tipo", sa.String(20), nullable=False),
        sa.Column("evento_id", sa.Uuid(), nullable=True),
        sa.Column("huella", sa.String(64), nullable=False),
        sa.Column("usuario_id", sa.Uuid(), nullable=False),
        sa.CheckConstraint("tipo in ('alta', 'resultado')", name=_CK_TIPO_OPERACION),
        sa.ForeignKeyConstraint(["establecimiento_id"], ["establecimientos.id"]),
        sa.ForeignKeyConstraint(["evento_id"], [f"{_EVENTOS}.id"]),
        sa.ForeignKeyConstraint(["usuario_id"], ["usuarios.id"]),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index(
        "ix_operaciones_sanitarias_establecimiento_id",
        _OPERACIONES,
        ["establecimiento_id"],
        unique=False,
    )


def _soporta_rls(connection: Connection) -> bool:
    """Indica si la base es un Postgres con Supabase Auth (``auth.uid()``)."""
    if connection.dialect.name != "postgresql":
        return False
    return connection.execute(
        sa.text("select to_regprocedure('auth.uid()') is not null")
    ).scalar_one()


def sentencias_rls() -> tuple[str, ...]:
    """Políticas de solo lectura para miembros. Las comparte el SQL espejo."""
    sentencias: list[str] = []
    for tabla in (_EVENTOS, _OPERACIONES):
        sentencias += [
            f"alter table public.{tabla} enable row level security",
            f"drop policy if exists {tabla}_select_miembros on public.{tabla}",
            f"""
            create policy {tabla}_select_miembros on public.{tabla}
            for select to authenticated
            using ({_es_miembro(tabla)})
            """,
        ]
    sentencias += [
        f"alter table public.{_PRODUCTOS} enable row level security",
        f"drop policy if exists {_PRODUCTOS}_select_catalogo on public.{_PRODUCTOS}",
        # Globales para cualquier usuario autenticado; propios, para miembros.
        f"""
        create policy {_PRODUCTOS}_select_catalogo on public.{_PRODUCTOS}
        for select to authenticated
        using (establecimiento_id is null or {_es_miembro(_PRODUCTOS)})
        """,
    ]
    for tabla in (_EVENTOS, _OPERACIONES, _PRODUCTOS):
        sentencias += [
            f"revoke all on public.{tabla} from anon",
            f"revoke all on public.{tabla} from authenticated",
            f"grant select on public.{tabla} to authenticated",
        ]
    return tuple(sentencias)


def _aplicar_rls(connection: Connection) -> None:
    if not _soporta_rls(connection):
        return
    for sentencia in sentencias_rls():
        connection.execute(sa.text(sentencia))


def upgrade() -> None:
    connection = op.get_bind()
    _exigir_tablas_previas(connection)
    _ampliar_eventos(connection)
    _retirar_productos(connection)
    _crear_operaciones(connection)
    _aplicar_rls(connection)


def downgrade() -> None:
    """Quita lo agregado. Se pierden las operaciones y los datos de VITA-20."""
    connection = op.get_bind()
    inspector = sa.inspect(connection)
    if inspector.has_table(_OPERACIONES):
        op.drop_table(_OPERACIONES)

    indices = {i["name"] for i in inspector.get_indexes(_EVENTOS)}
    for nombre, _ in _INDICES_EVENTOS:
        if nombre in indices:
            op.drop_index(nombre, table_name=_EVENTOS)
    checks = {c["name"] for c in inspector.get_check_constraints(_EVENTOS)}
    unicos = {u["name"] for u in inspector.get_unique_constraints(_EVENTOS)}
    columnas = {c["name"] for c in inspector.get_columns(_EVENTOS)}
    with op.batch_alter_table(_EVENTOS) as batch:
        if _UQ_VERSION in unicos:
            batch.drop_constraint(_UQ_VERSION, type_="unique")
        if _CK_MODELO in checks:
            batch.drop_constraint(_CK_MODELO, type_="check")
        for columna in _columnas_eventos(connection):
            if columna.name in columnas:
                batch.drop_column(columna.name)

    if "deleted_at" in {c["name"] for c in inspector.get_columns(_PRODUCTOS)}:
        op.drop_column(_PRODUCTOS, "deleted_at")
