from datetime import datetime
from decimal import Decimal
from uuid import UUID

from sqlalchemy import DateTime, Numeric, String, UniqueConstraint
from sqlmodel import Field

from api.shared.enums import TipoEgreso
from database.models import Base, SoftDeleteMixin


class Egreso(Base, SoftDeleteMixin, table=True):
    """Salida física no comercial de un animal. Las ventas viven en ``ventas``."""

    __tablename__ = "egresos"

    establecimiento_id: UUID = Field(foreign_key="establecimientos.id", index=True)
    # Sin default: el motivo de la salida siempre es una decisión explícita.
    tipo: TipoEgreso = Field(sa_type=String, nullable=False)
    fecha: datetime = Field(sa_type=DateTime(timezone=True), nullable=False)
    consignatario_id: UUID | None = Field(default=None, foreign_key="usuarios.id")
    comprador_texto: str | None = None
    peso_total_kg: Decimal | None = Field(default=None, sa_type=Numeric(10, 3))
    precio_total: Decimal | None = Field(default=None, sa_type=Numeric(14, 2))
    observaciones: str | None = None


class EgresoDetalle(Base, table=True):
    __tablename__ = "egresos_detalles"
    __table_args__ = (
        UniqueConstraint("egreso_id", "animal_id", name="uq_egreso_animal"),
    )

    egreso_id: UUID = Field(foreign_key="egresos.id", index=True)
    animal_id: UUID = Field(foreign_key="animales.id", index=True)
    peso_kg: Decimal | None = Field(default=None, sa_type=Numeric(10, 3))
    precio: Decimal | None = Field(default=None, sa_type=Numeric(14, 2))
