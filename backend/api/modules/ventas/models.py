"""Modelos persistentes de la venta de hacienda y su composición de animales."""

from datetime import date
from decimal import Decimal
from uuid import UUID

from sqlalchemy import CheckConstraint, Date, Index, Numeric, String, UniqueConstraint
from sqlmodel import Field

from api.shared.enums import TipoComprador, TipoVenta
from database.models import Base, SoftDeleteMixin


def _valores_sql(enum: type[TipoVenta] | type[TipoComprador]) -> str:
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
    tipo_comprador: TipoComprador = Field(sa_type=String, nullable=False)
    # Razón social del frigorífico o remate, o nombre de pila de un particular.
    nombre_comprador: str = Field(nullable=False)
    # Solo aplica cuando el comprador es una persona física.
    apellido_comprador: str | None = None
    # Documento de Tránsito electrónico de SENASA. Nullable a propósito: se emite
    # después de cerrar el trato y la venta puede registrarse en el campo sin él.
    nro_dte: str | None = None
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
