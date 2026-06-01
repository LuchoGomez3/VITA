from decimal import Decimal
from uuid import UUID

from sqlalchemy import Numeric
from sqlmodel import Field

from database.models import Base


class Alimento(Base, table=True):
    __tablename__ = "alimentos"

    establecimiento_id: UUID | None = Field(
        default=None, foreign_key="establecimientos.id", index=True
    )
    nombre: str
    valor_proteico: Decimal | None = Field(default=None, sa_type=Numeric(6, 2))
    valor_vitaminico: Decimal | None = Field(default=None, sa_type=Numeric(6, 2))
    costo_unitario: Decimal | None = Field(default=None, sa_type=Numeric(14, 2))
    unidad: str = "kg"
