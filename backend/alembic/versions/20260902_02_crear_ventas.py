"""Crea la estructura de ventas de hacienda y sus políticas de acceso.

La venta es una operación comercial (comprador, DTe, monto) y vive separada de
``egresos``, que registra salidas físicas no comerciales del animal.

Revision ID: 20260902_02
Revises: 20260827_02
Create Date: 2026-09-02
"""

from collections.abc import Sequence

from alembic import op
import sqlalchemy as sa
import sqlmodel
from sqlalchemy.engine import Connection

revision: str = "20260902_02"
down_revision: str | None = "20260827_02"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None

_VENTAS = "ventas"
_DETALLES = "ventas_detalles"
_TABLAS_REQUERIDAS = ("establecimientos", "usuarios", "animales")

# (nombre, tabla, columnas)
_INDICES = (
    ("ix_ventas_establecimiento_id", _VENTAS, ["establecimiento_id"]),
    ("ix_ventas_fecha_operacion", _VENTAS, ["fecha_operacion"]),
    ("ix_ventas_registrada_por_id", _VENTAS, ["registrada_por_id"]),
    # Sostiene la descarga delta del cliente offline (``updated_since``).
    ("ix_ventas_sync", _VENTAS, ["establecimiento_id", "updated_at"]),
    ("ix_ventas_detalles_venta_id", _DETALLES, ["venta_id"]),
    # Responde "¿este animal ya se vendió?" al armar una venta nueva.
    ("ix_ventas_detalles_animal_id", _DETALLES, ["animal_id"]),
)

# Predicado de pertenencia al tenant, idéntico al del resto de las tablas.
_ES_MIEMBRO = """
    exists (
        select 1
        from public.usuarios_establecimientos ue
        where ue.establecimiento_id = {tabla}.establecimiento_id
          and ue.usuario_id = auth.uid()
          and ue.activo = true
    )
"""

_ES_MIEMBRO_DE_LA_VENTA = """
    exists (
        select 1
        from public.ventas v
        join public.usuarios_establecimientos ue
          on ue.establecimiento_id = v.establecimiento_id
        where v.id = ventas_detalles.venta_id
          and ue.usuario_id = auth.uid()
          and ue.activo = true
    )
"""

# El animal debe pertenecer al mismo establecimiento que la venta: evita que un
# miembro arme una venta con hacienda de otro tenant.
_ANIMAL_DEL_MISMO_ESTABLECIMIENTO = """
    exists (
        select 1
        from public.ventas v
        join public.animales a
          on a.id = ventas_detalles.animal_id
         and a.establecimiento_id = v.establecimiento_id
        join public.usuarios_establecimientos ue
          on ue.establecimiento_id = v.establecimiento_id
        where v.id = ventas_detalles.venta_id
          and ue.usuario_id = auth.uid()
          and ue.activo = true
    )
"""


def _exigir_tablas_previas(connection: Connection) -> None:
    inspector = sa.inspect(connection)
    faltantes = [t for t in _TABLAS_REQUERIDAS if not inspector.has_table(t)]
    if faltantes:
        raise RuntimeError(
            "No se puede aplicar la migración: faltan las tablas "
            f"{', '.join(faltantes)} de las que dependen las ventas."
        )


def _crear_ventas() -> None:
    op.create_table(
        _VENTAS,
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
        sa.Column("fecha_operacion", sa.Date(), nullable=False),
        sa.Column("tipo_comprador", sa.String(), nullable=False),
        sa.Column(
            "nombre_comprador", sqlmodel.sql.sqltypes.AutoString(), nullable=False
        ),
        sa.Column(
            "apellido_comprador", sqlmodel.sql.sqltypes.AutoString(), nullable=True
        ),
        sa.Column("nro_dte", sqlmodel.sql.sqltypes.AutoString(), nullable=True),
        sa.Column("tipo_venta", sa.String(), nullable=False),
        sa.Column("peso_total_kg", sa.Numeric(precision=10, scale=3), nullable=True),
        sa.Column("precio_por_kg", sa.Numeric(precision=14, scale=2), nullable=True),
        sa.Column("monto_total", sa.Numeric(precision=14, scale=2), nullable=False),
        sa.Column("observaciones", sqlmodel.sql.sqltypes.AutoString(), nullable=True),
        sa.Column("registrada_por_id", sa.Uuid(), nullable=False),
        # La API valida el enum, pero la base también lo hace: Supabase acepta
        # escrituras directas y esas no pasan por Pydantic.
        sa.CheckConstraint(
            "tipo_comprador in ('frigorifico', 'remate', 'particular')",
            name="ck_ventas_tipo_comprador_valido",
        ),
        sa.CheckConstraint(
            "tipo_venta in ('por_kilo', 'al_bulto')",
            name="ck_ventas_tipo_venta_valido",
        ),
        sa.CheckConstraint("monto_total > 0", name="ck_ventas_monto_total_positivo"),
        sa.CheckConstraint(
            "peso_total_kg is null or peso_total_kg > 0",
            name="ck_ventas_peso_total_positivo",
        ),
        sa.CheckConstraint(
            "precio_por_kg is null or precio_por_kg > 0",
            name="ck_ventas_precio_por_kg_positivo",
        ),
        sa.CheckConstraint(
            "trim(nombre_comprador) <> ''",
            name="ck_ventas_nombre_comprador_no_vacio",
        ),
        sa.CheckConstraint(
            "tipo_venta <> 'por_kilo'"
            " or (peso_total_kg is not null and precio_por_kg is not null)",
            name="ck_ventas_por_kilo_requiere_peso_y_precio",
        ),
        sa.ForeignKeyConstraint(["establecimiento_id"], ["establecimientos.id"]),
        sa.ForeignKeyConstraint(["registrada_por_id"], ["usuarios.id"]),
        sa.PrimaryKeyConstraint("id"),
    )


def _crear_ventas_detalles() -> None:
    op.create_table(
        _DETALLES,
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
        sa.Column("venta_id", sa.Uuid(), nullable=False),
        sa.Column("animal_id", sa.Uuid(), nullable=False),
        sa.Column("peso_kg", sa.Numeric(precision=10, scale=3), nullable=True),
        sa.Column("precio", sa.Numeric(precision=14, scale=2), nullable=True),
        sa.CheckConstraint(
            "peso_kg is null or peso_kg > 0", name="ck_ventas_detalles_peso_positivo"
        ),
        sa.CheckConstraint(
            "precio is null or precio > 0", name="ck_ventas_detalles_precio_positivo"
        ),
        sa.ForeignKeyConstraint(["venta_id"], ["ventas.id"]),
        sa.ForeignKeyConstraint(["animal_id"], ["animales.id"]),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint("venta_id", "animal_id", name="uq_venta_animal"),
    )


def _crear_indices_faltantes(connection: Connection) -> None:
    inspector = sa.inspect(connection)
    for nombre, tabla, columnas in _INDICES:
        existentes = {i["name"] for i in inspector.get_indexes(tabla)}
        if nombre not in existentes:
            op.create_index(nombre, tabla, columnas, unique=False)


def _soporta_rls(connection: Connection) -> bool:
    """Indica si la base es un Postgres con Supabase Auth disponible.

    Las políticas se apoyan en ``auth.uid()``, que solo existe en Supabase. Un
    Postgres de desarrollo no la tiene y la migración debe seguir aplicándose:
    ahí el aislamiento por tenant lo garantiza el service, que filtra por
    membresía en toda consulta.
    """
    if connection.dialect.name != "postgresql":
        return False
    return connection.execute(
        sa.text("select to_regprocedure('auth.uid()') is not null")
    ).scalar_one()


def _aplicar_rls(connection: Connection) -> None:
    if not _soporta_rls(connection):
        return

    ventas_es_miembro = _ES_MIEMBRO.format(tabla="ventas")

    sentencias = [
        "alter table public.ventas enable row level security",
        "alter table public.ventas_detalles enable row level security",
        "drop policy if exists ventas_select_miembros on public.ventas",
        f"""
        create policy ventas_select_miembros on public.ventas
        for select to authenticated
        using ({ventas_es_miembro})
        """,
        "drop policy if exists ventas_insert_miembros on public.ventas",
        f"""
        create policy ventas_insert_miembros on public.ventas
        for insert to authenticated
        with check (registrada_por_id = auth.uid() and {ventas_es_miembro})
        """,
        # El borrado es soft (``deleted_at``), así que se cubre con update y no
        # se habilita ninguna política de delete.
        "drop policy if exists ventas_update_miembros on public.ventas",
        f"""
        create policy ventas_update_miembros on public.ventas
        for update to authenticated
        using ({ventas_es_miembro})
        with check ({ventas_es_miembro})
        """,
        "drop policy if exists ventas_detalles_select_miembros"
        " on public.ventas_detalles",
        f"""
        create policy ventas_detalles_select_miembros on public.ventas_detalles
        for select to authenticated
        using ({_ES_MIEMBRO_DE_LA_VENTA})
        """,
        "drop policy if exists ventas_detalles_insert_miembros"
        " on public.ventas_detalles",
        f"""
        create policy ventas_detalles_insert_miembros on public.ventas_detalles
        for insert to authenticated
        with check ({_ANIMAL_DEL_MISMO_ESTABLECIMIENTO})
        """,
        "revoke all on public.ventas from anon",
        "revoke all on public.ventas_detalles from anon",
        "grant select, insert, update on public.ventas to authenticated",
        # La composición se fija al crear la venta: no se edita ni se borra.
        "grant select, insert on public.ventas_detalles to authenticated",
    ]

    for sentencia in sentencias:
        connection.execute(sa.text(sentencia))


def upgrade() -> None:
    connection = op.get_bind()
    _exigir_tablas_previas(connection)

    tablas = set(sa.inspect(connection).get_table_names())
    if _VENTAS not in tablas:
        _crear_ventas()
    if _DETALLES not in tablas:
        _crear_ventas_detalles()

    _crear_indices_faltantes(connection)
    _aplicar_rls(connection)


def downgrade() -> None:
    connection = op.get_bind()
    tablas = set(sa.inspect(connection).get_table_names())
    # Las políticas y los índices se eliminan junto con sus tablas.
    if _DETALLES in tablas:
        op.drop_table(_DETALLES)
    if _VENTAS in tablas:
        op.drop_table(_VENTAS)
