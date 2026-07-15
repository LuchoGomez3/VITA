"""DTOs Pydantic del módulo pesajes."""

from datetime import datetime
from decimal import Decimal
from uuid import UUID

from pydantic import BaseModel, ConfigDict, field_validator

from api.shared.enums import MetodoPesaje
from api.shared.schemas import SyncFields


class PesajeCreate(SyncFields):
    """Registro de un pesaje (pesada en la manga posterior al alta).

    Hereda ``SyncFields``: el cliente offline-first envía su propio
    ``id``/``created_at``/``updated_at`` y el backend los respeta (alta idempotente
    con last-write-wins). El pesaje inicial del animal se crea en el alta del animal;
    este endpoint cubre las pesadas siguientes que alimentan la GPD.
    """

    establecimiento_id: UUID
    animal_id: UUID
    peso_kg: Decimal
    fecha: datetime | None = None
    metodo: MetodoPesaje = MetodoPesaje.manual
    es_estimado: bool = False
    condicion_corporal: Decimal | None = None
    foto_url: str | None = None
    responsable_id: UUID | None = None
    observaciones: str | None = None

    @field_validator("peso_kg")
    @classmethod
    def _peso_positivo(cls, v: Decimal) -> Decimal:
        if v <= 0:
            raise ValueError("El peso debe ser mayor a 0")
        return v


class PesajeUpdate(SyncFields):
    """Edición de un pesaje (corrección). ``updated_at`` dirime el conflicto (LWW) y
    ``deleted_at`` permite propagar un soft delete desde el cliente."""

    peso_kg: Decimal | None = None
    fecha: datetime | None = None
    metodo: MetodoPesaje | None = None
    es_estimado: bool | None = None
    condicion_corporal: Decimal | None = None
    foto_url: str | None = None
    observaciones: str | None = None

    @field_validator("peso_kg")
    @classmethod
    def _peso_positivo(cls, v: Decimal | None) -> Decimal | None:
        if v is not None and v <= 0:
            raise ValueError("El peso debe ser mayor a 0")
        return v


class PesajeRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    establecimiento_id: UUID
    animal_id: UUID
    fecha: datetime
    peso_kg: Decimal
    metodo: MetodoPesaje
    es_estimado: bool
    condicion_corporal: Decimal | None = None
    foto_url: str | None = None
    responsable_id: UUID | None = None
    observaciones: str | None = None
    created_at: datetime
    updated_at: datetime
    # Se expone para la descarga delta: un registro con deleted_at != null le indica
    # al cliente que debe borrarlo localmente.
    deleted_at: datetime | None = None
