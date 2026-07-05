from datetime import datetime
from typing import Any, Optional
from uuid import UUID

from pydantic import BaseModel, Field


class SyncFields(BaseModel):
    """Campos que el cliente offline-first genera localmente y el backend respeta.

    En offline-first el registro nace sin conexión: la app móvil (Brick + SQLite)
    genera el ``id`` (UUID) y los timestamps, los guarda local y luego los reproduce
    contra el backend. La nube debe TOMAR estos valores, no recrearlos. La resolución
    de conflictos es last-write-wins por ``updated_at``. Todos son opcionales para no
    romper clientes que aún no los envían (el backend cae a sus defaults).
    """

    id: UUID | None = None
    created_at: datetime | None = None
    updated_at: datetime | None = None
    deleted_at: datetime | None = None


class Pagination(BaseModel):
    page: int = Field(1, ge=1)
    size: int = Field(10, ge=1, le=100)
    total: Optional[int] = Field(default=None, ge=0)


class StandardResponse(BaseModel):
    success: bool
    data: Optional[Any] = None
    meta: Optional[dict[str, Any]] = None
    errors: Optional[list[dict[str, Any]]] = None
