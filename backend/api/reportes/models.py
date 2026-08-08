"""Modelos persistentes para conservar exportaciones históricas de SENASA."""

from datetime import datetime
from uuid import UUID

from sqlalchemy import DateTime, LargeBinary, String, UniqueConstraint
from sqlmodel import Field

from database.models import Base


class ExportacionSenasa(Base, table=True):
    """Archivo SENASA inmutable generado para un establecimiento.

    El contenido binario se conserva tal como fue descargado originalmente. Esto
    evita que una corrección posterior del animal cambie un documento histórico.
    """

    __tablename__ = "exportaciones_senasa"

    establecimiento_id: UUID = Field(
        foreign_key="establecimientos.id", index=True, nullable=False
    )
    usuario_generador_id: UUID = Field(foreign_key="usuarios.id", nullable=False)
    nombre_archivo: str = Field(sa_type=String(255), nullable=False)
    formato: str = Field(sa_type=String(10), nullable=False)
    tipo_exportacion: str = Field(sa_type=String(40), nullable=False)
    media_type: str = Field(sa_type=String(100), nullable=False)
    contenido: bytes = Field(sa_type=LargeBinary, nullable=False)
    hash_sha256: str = Field(sa_type=String(64), nullable=False)
    cantidad_animales: int = Field(nullable=False)
    desde: datetime | None = Field(
        default=None, sa_type=DateTime(timezone=True), nullable=True
    )
    hasta: datetime | None = Field(
        default=None, sa_type=DateTime(timezone=True), nullable=True
    )


class ExportacionSenasaAnimal(Base, table=True):
    """Vincula una exportación con cada animal incluido en su contenido."""

    __tablename__ = "exportaciones_senasa_animales"
    __table_args__ = (
        UniqueConstraint(
            "exportacion_senasa_id",
            "animal_id",
            name="uq_exportacion_senasa_animal",
        ),
    )

    exportacion_senasa_id: UUID = Field(
        foreign_key="exportaciones_senasa.id", index=True, nullable=False
    )
    animal_id: UUID = Field(foreign_key="animales.id", index=True, nullable=False)
