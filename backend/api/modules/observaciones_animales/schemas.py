"""DTOs Pydantic del módulo observaciones de animales."""

from datetime import datetime
from uuid import UUID

from pydantic import BaseModel, ConfigDict, field_validator

from api.shared.schemas import SyncFields


def _texto_no_vacio(v: str) -> str:
    # Se valida sin recortar: la nota se guarda tal como la escribió el usuario.
    if not v.strip():
        raise ValueError("La observación no puede estar vacía")
    return v


class ObservacionAnimalCreate(SyncFields):
    """Alta de una observación. Hereda ``SyncFields``: el cliente offline-first
    envía su propio ``id`` y timestamps, y reenviar el alta no la duplica.

    El autor no se recibe: sale del usuario autenticado.
    """

    establecimiento_id: UUID
    animal_id: UUID
    texto: str
    # Cuándo se hizo la observación. Si no viene, se usa ``created_at`` o ahora.
    fecha: datetime | None = None

    @field_validator("texto")
    @classmethod
    def _validar_texto(cls, v: str) -> str:
        return _texto_no_vacio(v)


class ObservacionAnimalUpdate(SyncFields):
    """Edición de una observación con last-write-wins.

    Solo se editan el texto y la fecha: animal, establecimiento y autor son
    inmutables y no forman parte del contrato.
    """

    texto: str | None = None
    fecha: datetime | None = None

    @field_validator("texto")
    @classmethod
    def _validar_texto(cls, v: str | None) -> str | None:
        return v if v is None else _texto_no_vacio(v)


class ObservacionAnimalRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    establecimiento_id: UUID
    animal_id: UUID
    texto: str
    fecha: datetime
    # Null en las notas migradas desde ``animales.observaciones``.
    autor_id: UUID | None = None
    created_at: datetime
    updated_at: datetime
    # Se expone para la descarga delta: un registro con deleted_at != null le indica
    # al cliente que debe borrarlo localmente.
    deleted_at: datetime | None = None
