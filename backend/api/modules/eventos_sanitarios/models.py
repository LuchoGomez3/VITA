from datetime import date, datetime
from uuid import UUID

from sqlalchemy import DateTime, String
from sqlmodel import Field

from api.shared.enums import TipoEventoSanitario
from database.models import Base, SoftDeleteMixin


class EventoSanitario(Base, SoftDeleteMixin, table=True):
    __tablename__ = "eventos_sanitarios"

    establecimiento_id: UUID = Field(foreign_key="establecimientos.id", index=True)
    animal_id: UUID = Field(foreign_key="animales.id", index=True)
    tipo: TipoEventoSanitario = Field(sa_type=String, nullable=False)
    producto_id: UUID | None = Field(
        default=None, foreign_key="productos_sanitarios.id"
    )
    fecha_aplicacion: datetime = Field(sa_type=DateTime(timezone=True), nullable=False)
    dosis: str | None = None
    periodo_carencia_dias: int | None = None
    fecha_fin_carencia: date | None = None
    resultado: str | None = None
    responsable_id: UUID | None = Field(default=None, foreign_key="usuarios.id")
    observaciones: str | None = None
