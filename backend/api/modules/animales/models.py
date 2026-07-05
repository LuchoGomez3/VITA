from datetime import date
from uuid import UUID

from sqlalchemy import String
from sqlmodel import Field

from api.shared.enums import EstadoAnimal, SexoAnimal
from database.models import Base, SoftDeleteMixin


class Animal(Base, SoftDeleteMixin, table=True):
    __tablename__ = "animales"

    establecimiento_id: UUID = Field(foreign_key="establecimientos.id", index=True)
    # Identificación electrónica RFID: única a nivel nacional (SENASA 530/2025).
    nro_caravana_rfid: str | None = Field(default=None, unique=True, index=True)
    caravana_visual: str | None = None
    sexo: SexoAnimal = Field(sa_type=String, nullable=False)
    raza: str | None = None
    fecha_nacimiento: date | None = None
    categoria_id: UUID | None = Field(default=None, foreign_key="categorias.id")
    lote_id: UUID | None = Field(default=None, foreign_key="lotes.id", index=True)
    padre_id: UUID | None = Field(default=None, foreign_key="animales.id")
    madre_id: UUID | None = Field(default=None, foreign_key="animales.id")
    pelaje: str | None = None
    estado: EstadoAnimal = Field(
        default=EstadoAnimal.activo, sa_type=String, nullable=False
    )
    observaciones: str | None = None
