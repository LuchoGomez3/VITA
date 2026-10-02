"""Crea los cobros de ventas, su tope concurrente y sus políticas de acceso.

Una venta conserva el importe comercial y ``ventas_cobros`` registra cada pago
efectivamente recibido. El estado de cobro y el saldo se calculan desde los
cobros activos; la base garantiza que nunca superen el monto de la venta.

Revision ID: 20261001_01
Revises: 20260910_02
Create Date: 2026-10-01
"""

from collections.abc import Sequence

from alembic import op
import sqlalchemy as sa
import sqlmodel
from sqlalchemy.engine import Connection

revision: str = "20261001_01"
down_revision: str | None = "20260910_02"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None

_TABLA = "ventas_cobros"
_TABLAS_REQUERIDAS = ("ventas", "usuarios", "usuarios_establecimientos")
# Misma allowlist inmutable que 20260910_01: los cobros son importes comerciales.
_ROLES_COMERCIALES = ("admin", "owner")
_ROLES_COMERCIALES_SQL = ", ".join(f"'{rol}'" for rol in _ROLES_COMERCIALES)

# (nombre, columnas)
_INDICES = (
    # Lleva ``venta_id`` adelante: sostiene la FK, el saldo y el pull delta.
    ("ix_ventas_cobros_sync", ["venta_id", "updated_at"]),
    ("ix_ventas_cobros_fecha_cobro", ["fecha_cobro"]),
    ("ix_ventas_cobros_registrado_por_id", ["registrado_por_id"]),
    ("ix_ventas_cobros_updated_at", ["updated_at"]),
)

# El tenant se resuelve por la venta: un cobro solo puede colgar de una venta de
# un establecimiento donde el usuario tiene rol comercial activo.
_ES_COMERCIAL_DE_LA_VENTA = f"""
    exists (
        select 1
        from public.ventas v
        join public.usuarios_establecimientos ue
          on ue.establecimiento_id = v.establecimiento_id
        where v.id = ventas_cobros.venta_id
          and ue.usuario_id = auth.uid()
          and ue.activo = true
          and ue.rol in ({_ROLES_COMERCIALES_SQL})
    )
"""

# Copia literal de ``api.modules.ventas.models``: la migración no importa código
# de la app para no cambiar si el modelo cambia. Un test verifica que coincidan.
_FUNCION_TOPE_COBROS = """
create or replace function public.validar_tope_cobros_venta()
returns trigger
language plpgsql
security invoker
set search_path = public, pg_temp
as $$
declare
    v_monto_total numeric(14, 2);
    v_venta_borrada timestamptz;
    v_cobrado numeric(14, 2);
begin
    if tg_op = 'UPDATE' and (
        new.id <> old.id
        or new.venta_id <> old.venta_id
        or new.registrado_por_id <> old.registrado_por_id
    ) then
        raise exception 'Un cobro no puede cambiar de id, de venta ni de autor'
            using errcode = 'check_violation';
    end if;

    -- Anular un cobro solo puede bajar lo cobrado.
    if new.deleted_at is not null then
        return new;
    end if;

    select v.monto_total, v.deleted_at
      into v_monto_total, v_venta_borrada
      from public.ventas v
     where v.id = new.venta_id
       for update;

    -- Sin venta, la FK rechaza la fila.
    if not found then
        return new;
    end if;

    if v_venta_borrada is not null
       and (tg_op = 'INSERT' or old.deleted_at is not null) then
        raise exception 'No se pueden registrar cobros de una venta eliminada'
            using errcode = 'check_violation';
    end if;

    select coalesce(sum(c.monto), 0)
      into v_cobrado
      from public.ventas_cobros c
     where c.venta_id = new.venta_id
       and c.deleted_at is null
       and c.id <> new.id;

    if v_cobrado + new.monto > v_monto_total then
        raise exception 'Los cobros superan el monto total de la venta'
            using errcode = 'check_violation';
    end if;

    return new;
end;
$$
"""

_FUNCION_FECHA_COBRO = """
create or replace function public.validar_fecha_cobro()
returns trigger
language plpgsql
security invoker
set search_path = public, pg_temp
as $$
begin
    -- Un cobro es dinero ya recibido. Se compara contra el día de Córdoba, no
    -- el de UTC: entre las 21 y las 24 hora local ya es mañana en UTC.
    if (tg_op = 'INSERT' or new.fecha_cobro is distinct from old.fecha_cobro)
       and new.fecha_cobro
           > cast(now() at time zone 'America/Argentina/Cordoba' as date) then
        raise exception 'La fecha de cobro no puede ser futura'
            using errcode = 'check_violation';
    end if;

    return new;
end;
$$
"""

_FUNCION_MONTO_CUBRE_COBROS = """
create or replace function public.validar_monto_venta_cubre_cobros()
returns trigger
language plpgsql
security invoker
set search_path = public, pg_temp
as $$
declare
    v_cobrado numeric(14, 2);
begin
    if new.monto_total >= old.monto_total then
        return new;
    end if;

    select coalesce(sum(c.monto), 0)
      into v_cobrado
      from public.ventas_cobros c
     where c.venta_id = new.id
       and c.deleted_at is null;

    if v_cobrado > new.monto_total then
        raise exception 'El monto total no puede quedar por debajo de lo cobrado'
            using errcode = 'check_violation';
    end if;

    return new;
end;
$$
"""

_TRIGGERS = (
    "drop trigger if exists ventas_cobros_validar_fecha on public.ventas_cobros",
    """
create trigger ventas_cobros_validar_fecha
before insert or update on public.ventas_cobros
for each row execute function public.validar_fecha_cobro()
""",
    "drop trigger if exists ventas_cobros_validar_tope on public.ventas_cobros",
    """
create trigger ventas_cobros_validar_tope
before insert or update on public.ventas_cobros
for each row execute function public.validar_tope_cobros_venta()
""",
    "drop trigger if exists ventas_validar_monto_cubre_cobros on public.ventas",
    """
create trigger ventas_validar_monto_cubre_cobros
before update of monto_total on public.ventas
for each row execute function public.validar_monto_venta_cubre_cobros()
""",
)


def _exigir_tablas_previas(connection: Connection) -> None:
    inspector = sa.inspect(connection)
    faltantes = [t for t in _TABLAS_REQUERIDAS if not inspector.has_table(t)]
    if faltantes:
        raise RuntimeError(
            "No se puede aplicar la migración: faltan las tablas "
            f"{', '.join(faltantes)} de las que dependen los cobros."
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
        sa.Column("venta_id", sa.Uuid(), nullable=False),
        sa.Column("fecha_cobro", sa.Date(), nullable=False),
        sa.Column("monto", sa.Numeric(precision=14, scale=2), nullable=False),
        sa.Column("registrado_por_id", sa.Uuid(), nullable=False),
        sa.Column("observaciones", sqlmodel.sql.sqltypes.AutoString(), nullable=True),
        sa.CheckConstraint("monto > 0", name="ck_ventas_cobros_monto_positivo"),
        sa.ForeignKeyConstraint(["venta_id"], ["ventas.id"]),
        sa.ForeignKeyConstraint(["registrado_por_id"], ["usuarios.id"]),
        sa.PrimaryKeyConstraint("id"),
    )


def _crear_indices_faltantes(connection: Connection) -> None:
    existentes = {i["name"] for i in sa.inspect(connection).get_indexes(_TABLA)}
    for nombre, columnas in _INDICES:
        if nombre not in existentes:
            op.create_index(nombre, _TABLA, columnas, unique=False)


def _crear_triggers(connection: Connection) -> None:
    """Instala el tope de cobros; ``create or replace`` lo hace reaplicable."""
    if connection.dialect.name != "postgresql":
        return
    for sentencia in (
        _FUNCION_FECHA_COBRO,
        _FUNCION_TOPE_COBROS,
        _FUNCION_MONTO_CUBRE_COBROS,
        *_TRIGGERS,
    ):
        connection.execute(sa.text(sentencia))


def _soporta_rls(connection: Connection) -> bool:
    """Indica si la base es un Postgres con Supabase Auth disponible."""
    if connection.dialect.name != "postgresql":
        return False
    return connection.execute(
        sa.text("select to_regprocedure('auth.uid()') is not null")
    ).scalar_one()


def _sentencias_politicas() -> list[str]:
    return [
        "alter table public.ventas_cobros enable row level security",
        "drop policy if exists ventas_cobros_select_miembros on public.ventas_cobros",
        f"""
        create policy ventas_cobros_select_miembros on public.ventas_cobros
        for select to authenticated
        using ({_ES_COMERCIAL_DE_LA_VENTA})
        """,
        "drop policy if exists ventas_cobros_insert_miembros on public.ventas_cobros",
        f"""
        create policy ventas_cobros_insert_miembros on public.ventas_cobros
        for insert to authenticated
        with check (registrado_por_id = auth.uid() and {_ES_COMERCIAL_DE_LA_VENTA})
        """,
        # El borrado es soft (``deleted_at``): se cubre con update y no existe
        # política ni permiso de delete.
        "drop policy if exists ventas_cobros_update_miembros on public.ventas_cobros",
        f"""
        create policy ventas_cobros_update_miembros on public.ventas_cobros
        for update to authenticated
        using ({_ES_COMERCIAL_DE_LA_VENTA})
        with check ({_ES_COMERCIAL_DE_LA_VENTA})
        """,
        # Supabase otorga todo por defecto a anon y authenticated en public.
        "revoke all on public.ventas_cobros from anon, authenticated",
        "grant select, insert, update on public.ventas_cobros to authenticated",
    ]


def _aplicar_rls(connection: Connection) -> None:
    if not _soporta_rls(connection):
        return
    for sentencia in _sentencias_politicas():
        connection.execute(sa.text(sentencia))


def upgrade() -> None:
    connection = op.get_bind()
    _exigir_tablas_previas(connection)

    if not sa.inspect(connection).has_table(_TABLA):
        _crear_tabla()

    _crear_indices_faltantes(connection)
    _crear_triggers(connection)
    _aplicar_rls(connection)


def downgrade() -> None:
    connection = op.get_bind()
    if connection.dialect.name == "postgresql":
        connection.execute(
            sa.text(
                "drop trigger if exists ventas_validar_monto_cubre_cobros"
                " on public.ventas"
            )
        )
    # Las políticas, los índices y los triggers propios se van con la tabla.
    if sa.inspect(connection).has_table(_TABLA):
        op.drop_table(_TABLA)
    if connection.dialect.name == "postgresql":
        for funcion in (
            "validar_fecha_cobro",
            "validar_tope_cobros_venta",
            "validar_monto_venta_cubre_cobros",
        ):
            connection.execute(sa.text(f"drop function if exists public.{funcion}()"))
