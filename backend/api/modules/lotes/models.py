from decimal import Decimal
from uuid import UUID

from sqlalchemy import Numeric
from sqlmodel import Field

from database.models import Base, SoftDeleteMixin


class Lote(Base, SoftDeleteMixin, table=True):
    __tablename__ = "lotes"

    establecimiento_id: UUID = Field(foreign_key="establecimientos.id", index=True)
    nombre: str
    superficie_ha: Decimal | None = Field(default=None, sa_type=Numeric(12, 2))
    plan_alimenticio_id: UUID | None = Field(
        default=None, foreign_key="planes_alimenticios.id"
    )
