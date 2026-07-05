from datetime import datetime
from decimal import Decimal
from uuid import UUID

from sqlalchemy import DateTime, Numeric, String
from sqlmodel import Field

from api.shared.enums import MetodoPesaje
from database.models import Base, SoftDeleteMixin


class Pesaje(Base, SoftDeleteMixin, table=True):
    __tablename__ = "pesajes"

    establecimiento_id: UUID = Field(foreign_key="establecimientos.id", index=True)
    animal_id: UUID = Field(foreign_key="animales.id", index=True)
    fecha: datetime = Field(sa_type=DateTime(timezone=True), nullable=False)
    peso_kg: Decimal = Field(sa_type=Numeric(10, 3))
    metodo: MetodoPesaje = Field(
        default=MetodoPesaje.manual, sa_type=String, nullable=False
    )
    es_estimado: bool = False
    condicion_corporal: Decimal | None = Field(default=None, sa_type=Numeric(3, 1))
    foto_url: str | None = None
    responsable_id: UUID | None = Field(default=None, foreign_key="usuarios.id")
    observaciones: str | None = None
