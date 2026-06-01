from decimal import Decimal
from uuid import UUID

from sqlalchemy import Numeric
from sqlmodel import Field

from database.models import Base, SoftDeleteMixin


class PlanAlimenticio(Base, SoftDeleteMixin, table=True):
    __tablename__ = "planes_alimenticios"

    establecimiento_id: UUID = Field(foreign_key="establecimientos.id", index=True)
    nombre: str
    descripcion: str | None = None


class PlanAlimentoItem(Base, table=True):
    __tablename__ = "planes_alimenticios_items"

    plan_id: UUID = Field(foreign_key="planes_alimenticios.id", index=True)
    alimento_id: UUID = Field(foreign_key="alimentos.id", index=True)
    cantidad: Decimal = Field(sa_type=Numeric(10, 2))
    unidad: str = "kg"
