"""Modelos persistentes de la venta de hacienda y su composición de animales."""

from datetime import date
from decimal import Decimal
from uuid import UUID

from sqlalchemy import (
    DDL,
    CheckConstraint,
    Date,
    Index,
    Numeric,
    String,
    UniqueConstraint,
    event,
)
from sqlmodel import Field

from api.shared.enums import MedioCobro, TipoComprador, TipoVenta
from database.models import Base, SoftDeleteMixin


def _valores_sql(enum: type[TipoVenta | TipoComprador | MedioCobro]) -> str:
    """Lista los valores del enum para un ``CHECK ... IN`` sin duplicar literales.

    Derivarla del enum evita que la restricción de la base y la validación de
    Python queden desalineadas cuando se agrega una variante.
    """
    return ", ".join(f"'{miembro.value}'" for miembro in enum)


class Venta(Base, SoftDeleteMixin, table=True):
    """Operación comercial que retira del stock a los animales que la componen.

    Es una entidad sincronizable: la app la crea offline con su propio UUID y el
    backend resuelve conflictos por ``updated_at`` (last-write-wins).
    """

    __tablename__ = "ventas"
    __table_args__ = (
        # La API valida el enum, pero la base también lo hace: Supabase acepta
        # escrituras directas y esas no pasan por Pydantic.
        CheckConstraint(
            f"tipo_comprador in ({_valores_sql(TipoComprador)})",
            name="ck_ventas_tipo_comprador_valido",
        ),
        CheckConstraint(
            f"tipo_venta in ({_valores_sql(TipoVenta)})",
            name="ck_ventas_tipo_venta_valido",
        ),
        CheckConstraint("monto_total > 0", name="ck_ventas_monto_total_positivo"),
        CheckConstraint(
            "peso_total_kg is null or peso_total_kg > 0",
            name="ck_ventas_peso_total_positivo",
        ),
        CheckConstraint(
            "precio_por_kg is null or precio_por_kg > 0",
            name="ck_ventas_precio_por_kg_positivo",
        ),
        CheckConstraint(
            "trim(nombre_comprador) <> ''",
            name="ck_ventas_nombre_comprador_no_vacio",
        ),
        CheckConstraint(
            "trim(nro_dte) <> ''",
            name="ck_ventas_nro_dte_no_vacio",
        ),
        CheckConstraint(
            "(es_empresa and apellido_comprador is null)"
            " or (not es_empresa and apellido_comprador is not null"
            " and trim(apellido_comprador) <> '')",
            name="ck_ventas_apellido_segun_comprador",
        ),
        # La venta al bulto se pacta por un monto cerrado; la venta por kilo solo
        # existe si se conocen los dos factores con los que se calcula el monto.
        CheckConstraint(
            "tipo_venta <> 'por_kilo'"
            " or (peso_total_kg is not null and precio_por_kg is not null)",
            name="ck_ventas_por_kilo_requiere_peso_y_precio",
        ),
        # El cliente offline descarga su delta filtrando por establecimiento y
        # ``updated_at``; este es el índice que sostiene esa consulta.
        Index("ix_ventas_sync", "establecimiento_id", "updated_at"),
    )

    establecimiento_id: UUID = Field(foreign_key="establecimientos.id", index=True)
    fecha_operacion: date = Field(sa_type=Date, nullable=False, index=True)
    # Clasifica el canal o clase comercial; no determina si el comprador es empresa.
    tipo_comprador: TipoComprador = Field(sa_type=String, nullable=False)
    # Razón social de una empresa o nombre de pila de una persona física.
    nombre_comprador: str = Field(nullable=False)
    es_empresa: bool = Field(nullable=False)
    # Obligatorio para personas físicas; no corresponde cuando es una empresa.
    apellido_comprador: str | None = None
    # Se ingresa manualmente si VITA está offline; no requiere consultar a SENASA.
    nro_dte: str = Field(nullable=False)
    tipo_venta: TipoVenta = Field(sa_type=String, nullable=False)
    peso_total_kg: Decimal | None = Field(default=None, sa_type=Numeric(10, 3))
    precio_por_kg: Decimal | None = Field(default=None, sa_type=Numeric(14, 2))
    monto_total: Decimal = Field(sa_type=Numeric(14, 2), nullable=False)
    observaciones: str | None = None
    # La identidad siempre proviene del JWT; el cliente nunca puede elegirla.
    registrada_por_id: UUID = Field(foreign_key="usuarios.id", index=True)


class VentaDetalle(Base, table=True):
    """Animal incluido en una venta.

    Sin ``SoftDeleteMixin``: la venta es un agregado atómico y sus detalles viajan
    dentro de su payload, así que no se sincronizan ni se borran por separado.
    """

    __tablename__ = "ventas_detalles"
    __table_args__ = (
        UniqueConstraint("venta_id", "animal_id", name="uq_venta_animal"),
        CheckConstraint(
            "peso_kg is null or peso_kg > 0", name="ck_ventas_detalles_peso_positivo"
        ),
        CheckConstraint(
            "precio is null or precio > 0", name="ck_ventas_detalles_precio_positivo"
        ),
    )

    venta_id: UUID = Field(foreign_key="ventas.id", index=True)
    # Indexado: responde "¿este animal ya se vendió?" al armar una venta nueva.
    animal_id: UUID = Field(foreign_key="animales.id", index=True)
    # Opcionales: habilitan distribuir peso y precio por animal cuando la
    # operación lo discrimina, sin obligar a hacerlo en la venta por tropa.
    peso_kg: Decimal | None = Field(default=None, sa_type=Numeric(10, 3))
    precio: Decimal | None = Field(default=None, sa_type=Numeric(14, 2))


# Tope de cobros. Vive en la base porque Supabase acepta escrituras directas y
# porque dos dispositivos pueden sincronizar cobros de la misma venta a la vez:
# el ``for update`` sobre la venta serializa esas escrituras, y la suma posterior
# ve lo que la otra transacción ya commiteó.
#
# Es ``security invoker`` a propósito: los triggers BEFORE corren antes del
# WITH CHECK del RLS, así que una función privilegiada leería (y bloquearía) la
# venta de otro tenant y su mensaje de error revelaría saldo o estado. Como
# invoker, una venta ajena es invisible: no se bloquea, no se suma y el rechazo
# es siempre el del RLS. La suma es completa porque quien puede insertar un cobro
# ve, por la misma política, todos los cobros de esa venta. El backend conecta
# como dueño de las tablas y no está sujeto a RLS.
FUNCION_TOPE_COBROS = """
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

# Cierra el invariante por la otra punta: bajar el monto de una venta no puede
# dejarla con más cobrado que vendido.
FUNCION_MONTO_CUBRE_COBROS = """
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

# Rechaza cobros con fecha futura. Es trigger y no CHECK porque el "hoy" cambia
# y Postgres exige que un CHECK sea inmutable.
FUNCION_FECHA_COBRO = """
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

TRIGGERS_COBROS = (
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


class VentaCobro(Base, SoftDeleteMixin, table=True):
    """Dinero efectivamente recibido por una venta.

    La venta conserva el importe comercial; el estado de cobro (pendiente,
    parcial, cobrada) y el saldo se calculan sumando los cobros activos y nunca
    se almacenan. Anular un cobro es un soft delete, así que recalcula el saldo
    y se propaga al cliente offline.

    No lleva ``establecimiento_id``: el tenant se resuelve por la venta, y
    duplicarlo abriría la puerta a un cobro de un campo atado a la venta de otro.
    """

    __tablename__ = "ventas_cobros"
    __table_args__ = (
        CheckConstraint("monto > 0", name="ck_ventas_cobros_monto_positivo"),
        CheckConstraint(
            f"medio_cobro in ({_valores_sql(MedioCobro)})",
            name="ck_ventas_cobros_medio_cobro_valido",
        ),
        # Lleva ``venta_id`` adelante, así que también sostiene la FK y el cálculo
        # del saldo: un índice solo por ``venta_id`` sería redundante.
        Index("ix_ventas_cobros_sync", "venta_id", "updated_at"),
        Index("ix_ventas_cobros_updated_at", "updated_at"),
    )

    venta_id: UUID = Field(foreign_key="ventas.id")
    # Cuándo se recibió el dinero, no cuándo se cargó: alimenta el flujo de caja.
    fecha_cobro: date = Field(sa_type=Date, nullable=False, index=True)
    # Sin unicidad por fecha y monto: dos pagos iguales el mismo día son reales.
    monto: Decimal = Field(sa_type=Numeric(14, 2), nullable=False)
    medio_cobro: MedioCobro = Field(sa_type=String, nullable=False)
    # La identidad siempre proviene del JWT; el cliente nunca puede elegirla.
    registrado_por_id: UUID = Field(foreign_key="usuarios.id", index=True)
    observaciones: str | None = None


# ``create_all`` (LOCAL contra Postgres) también instala los triggers; SQLite no
# los soporta en este dialecto y en producción los crea la migración.
for _sentencia in (
    FUNCION_FECHA_COBRO,
    FUNCION_TOPE_COBROS,
    FUNCION_MONTO_CUBRE_COBROS,
    *TRIGGERS_COBROS,
):
    event.listen(
        VentaCobro.__table__,
        "after_create",
        DDL(_sentencia).execute_if(dialect="postgresql"),
    )
