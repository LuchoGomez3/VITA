"""DTOs Pydantic de los registros de alimentación."""

from datetime import date, datetime
from decimal import Decimal
from uuid import UUID

from pydantic import BaseModel, Field, field_validator, model_validator

from api.shared.enums import (
    BaseCantidadAlimento,
    TipoRegistroAlimentacion,
    UnidadAlimento,
)
from api.shared.schemas import SyncFields

# Tope de animales por registro: una tropa grande cabe de sobra, y evita payloads
# que la cola offline no pueda reintentar.
MAX_ANIMALES_POR_REGISTRO = 500
_ESCALA_CANTIDAD = Decimal("0.001")


class RegistroAlimentacionCreate(SyncFields):
    """Suplemento o dieta que recibió un conjunto de animales.

    El ``id`` del cliente es la clave de idempotencia. Un reenvío del mismo UUID
    puede cerrar una dieta en curso o corregir cantidad, lugar y motivo
    (last-write-wins); la lista de animales, el alimento y el tipo no cambian.
    """

    establecimiento_id: UUID
    tipo: TipoRegistroAlimentacion
    alimento_id: UUID
    lote_id: UUID | None = None
    fecha_desde: date
    fecha_hasta: date | None = None
    cantidad: Decimal
    unidad: UnidadAlimento
    base_cantidad: BaseCantidadAlimento
    motivo: str | None = None
    animal_ids: list[UUID] = Field(min_length=1, max_length=MAX_ANIMALES_POR_REGISTRO)
    # Se acepta por compatibilidad con el payload del cliente pero se descarta:
    # el responsable siempre sale del JWT.
    responsable_id: UUID | None = None

    @field_validator("animal_ids")
    @classmethod
    def _sin_repetidos(cls, v: list[UUID]) -> list[UUID]:
        if len(set(v)) != len(v):
            raise ValueError("La lista de animales tiene IDs repetidos")
        return v

    @field_validator("cantidad")
    @classmethod
    def _cantidad_positiva(cls, v: Decimal) -> Decimal:
        if v <= 0:
            raise ValueError("La cantidad debe ser mayor a 0")
        # Misma escala que la columna (numeric(12, 3)): la respuesta del alta y la
        # de un reenvío tienen que verse igual.
        return v.quantize(_ESCALA_CANTIDAD)

    @field_validator("motivo")
    @classmethod
    def _motivo_limpio(cls, v: str | None) -> str | None:
        if v is None:
            return None
        return v.strip() or None

    @model_validator(mode="after")
    def _fechas(self) -> "RegistroAlimentacionCreate":
        if self.fecha_hasta is not None and self.fecha_hasta < self.fecha_desde:
            raise ValueError("La fecha de fin no puede ser anterior a la de inicio")
        return self


class RegistroAlimentacionRead(BaseModel):
    id: UUID
    establecimiento_id: UUID
    tipo: TipoRegistroAlimentacion
    alimento_id: UUID
    lote_id: UUID | None = None
    fecha_desde: date
    fecha_hasta: date | None = None
    cantidad: Decimal
    unidad: UnidadAlimento
    base_cantidad: BaseCantidadAlimento
    motivo: str | None = None
    animal_ids: list[UUID]
    responsable_id: UUID | None = None
    created_at: datetime
    updated_at: datetime
    deleted_at: datetime | None = None
