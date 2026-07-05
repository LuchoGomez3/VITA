from datetime import datetime
from uuid import UUID

from sqlalchemy import DateTime
from sqlmodel import Field

from database.models import Base


class MovimientoLote(Base, table=True):
    __tablename__ = "movimientos_lote"

    establecimiento_id: UUID = Field(foreign_key="establecimientos.id", index=True)
    animal_id: UUID = Field(foreign_key="animales.id", index=True)
    lote_origen_id: UUID | None = Field(default=None, foreign_key="lotes.id")
    lote_destino_id: UUID = Field(foreign_key="lotes.id")
    fecha: datetime = Field(sa_type=DateTime(timezone=True), nullable=False)
    motivo: str | None = None
    responsable_id: UUID | None = Field(default=None, foreign_key="usuarios.id")
