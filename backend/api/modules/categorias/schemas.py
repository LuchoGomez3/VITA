"""DTOs Pydantic del módulo categorías."""

from datetime import datetime
from uuid import UUID

from pydantic import BaseModel, ConfigDict

from api.shared.enums import SexoPermitido


class CategoriaRead(BaseModel):
    """Una categoría del catálogo global.

    Mobile usa ``id`` y ``nombre`` (ver adr-0010); las reglas acompañan para quien
    quiera ofrecer solo las categorías compatibles con el sexo del animal.
    """

    model_config = ConfigDict(from_attributes=True)

    id: UUID
    nombre: str
    descripcion: str | None = None
    sexo_permitido: SexoPermitido
    permite_estado_reproductivo: bool
    created_at: datetime
    updated_at: datetime
    # Se expone para la descarga delta: un registro con deleted_at != null le indica
    # al cliente que debe retirarlo de su selector local.
    deleted_at: datetime | None = None
