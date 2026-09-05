"""DTOs Pydantic del módulo movimientos."""

from datetime import datetime
from uuid import UUID

from pydantic import BaseModel, ConfigDict, Field, field_validator

from api.shared.schemas import SyncFields


class MovimientoLoteCreate(SyncFields):
    """Traslado de un conjunto de animales entre lotes.

    Es una operación **batch**: se mueven todos los animales o ninguno. El ``id``
    del cliente es la clave de idempotencia — reproducirlo no puede mover dos
    veces ni duplicar el historial.
    """

    establecimiento_id: UUID
    lote_origen_id: UUID
    lote_destino_id: UUID
    animal_ids: list[UUID] = Field(min_length=1)
    fecha_movimiento: datetime
    motivo: str
    # Se acepta por compatibilidad con el payload del cliente pero se descarta:
    # el responsable siempre sale del JWT. Ver ``MovimientoLoteService.crear``.
    responsable_id: UUID | None = None

    @field_validator("animal_ids")
    @classmethod
    def _sin_repetidos(cls, v: list[UUID]) -> list[UUID]:
        if len(set(v)) != len(v):
            raise ValueError("La lista de animales tiene IDs repetidos")
        return v

    @field_validator("motivo")
    @classmethod
    def _motivo_no_vacio(cls, v: str) -> str:
        v = v.strip()
        if not v:
            raise ValueError("El motivo del movimiento es obligatorio")
        return v


class MovimientoLoteRead(BaseModel):
    """Representación autoritativa del movimiento.

    ``animal_ids`` se reconstruye desde el detalle: la cabecera no guarda la lista
    duplicada. ``motivo`` nunca es ``null`` en la respuesta porque el cliente lo
    castea de forma estricta al deserializar.
    """

    model_config = ConfigDict(from_attributes=True)

    id: UUID
    establecimiento_id: UUID
    lote_origen_id: UUID | None
    lote_destino_id: UUID
    animal_ids: list[UUID]
    fecha_movimiento: datetime
    motivo: str
    responsable_id: UUID | None = None
    created_at: datetime
    updated_at: datetime
    deleted_at: datetime | None = None
