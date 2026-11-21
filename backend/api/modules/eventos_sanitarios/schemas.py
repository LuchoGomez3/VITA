"""DTOs del módulo eventos sanitarios.

Los esquemas solo validan tipos. Las reglas que el operario puede corregir
(datos de la práctica, animales, fechas) se validan en el service, que responde
con el campo exacto a corregir; un 422 de Pydantic no lo indicaría.
"""

from datetime import datetime
from typing import Any
from uuid import UUID

from pydantic import BaseModel


class AnimalDeAlta(BaseModel):
    """Un integrante del grupo: recibe un evento con su propio UUID."""

    id: UUID
    animal_id: UUID
    caravana: str | None = None
    lote_id: UUID | None = None
    referencia_muestra: str | None = None
    created_at: datetime | None = None
    updated_at: datetime | None = None


class AltaSanitaria(BaseModel):
    """Operación de alta: una práctica sobre uno o varios animales."""

    id: UUID
    establecimiento_id: UUID
    practica_id: str
    fecha_aplicacion: datetime
    responsable: str
    observaciones: str | None = None
    datos: dict[str, Any]
    animales: list[AnimalDeAlta]


class ResultadoSanitario(BaseModel):
    """Operación que informa el primer resultado de un estudio."""

    id: UUID
    resultado: str
    fecha: datetime
