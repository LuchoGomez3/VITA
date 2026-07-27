"""DTOs Pydantic del módulo categorías."""

from datetime import datetime
from uuid import UUID

from pydantic import BaseModel, ConfigDict, field_validator

from api.shared.schemas import SyncFields


class CategoriaCreate(SyncFields):
    """Alta de una categoría propia del establecimiento.

    Hereda ``SyncFields``: el cliente offline-first envía su propio
    ``id``/``created_at``/``updated_at`` y el backend los respeta (alta idempotente
    con last-write-wins). No se pueden crear categorías del catálogo global desde la
    API (esas se siembran); ``establecimiento_id`` es obligatorio.
    """

    establecimiento_id: UUID
    nombre: str
    descripcion: str | None = None

    @field_validator("nombre")
    @classmethod
    def _nombre_no_vacio(cls, v: str) -> str:
        v = v.strip()
        if not v:
            raise ValueError("El nombre de la categoría es obligatorio")
        return v


class CategoriaUpdate(SyncFields):
    """Edición de una categoría propia. ``updated_at`` dirime el conflicto (LWW) y
    ``deleted_at`` permite propagar un soft delete desde el cliente."""

    nombre: str | None = None
    descripcion: str | None = None

    @field_validator("nombre")
    @classmethod
    def _nombre_no_vacio(cls, v: str | None) -> str | None:
        if v is None:
            return v
        v = v.strip()
        if not v:
            raise ValueError("El nombre de la categoría no puede quedar vacío")
        return v


class CategoriaRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    # null = categoría del catálogo global (no editable por el usuario).
    establecimiento_id: UUID | None = None
    nombre: str
    descripcion: str | None = None
    created_at: datetime
    updated_at: datetime
    # Se expone para la descarga delta: un registro con deleted_at != null le indica
    # al cliente que debe borrarlo localmente.
    deleted_at: datetime | None = None
