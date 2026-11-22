"""DTOs Pydantic del catálogo de alimentos."""

from datetime import datetime
from uuid import UUID

from pydantic import BaseModel, ConfigDict, field_validator

from api.shared.enums import CategoriaAlimento, UnidadAlimento
from api.shared.schemas import SyncFields


class AlimentoCreate(SyncFields):
    """Alta de un alimento del establecimiento (idempotente, offline-first).

    El cliente lo crea sin conexión desde el registro de alimentación, así que el
    ``id`` del cliente se respeta y un reenvío se resuelve con last-write-wins.
    """

    establecimiento_id: UUID
    nombre: str
    categoria: CategoriaAlimento = CategoriaAlimento.otro
    unidad: UnidadAlimento = UnidadAlimento.kg
    # Se acepta por compatibilidad con el payload del cliente pero se descarta:
    # el autor siempre sale del JWT.
    creado_por_id: UUID | None = None

    @field_validator("nombre")
    @classmethod
    def _nombre_no_vacio(cls, v: str) -> str:
        v = v.strip()
        if not v:
            raise ValueError("El nombre del alimento es obligatorio")
        return v


class AlimentoRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    establecimiento_id: UUID | None = None
    nombre: str
    categoria: CategoriaAlimento
    unidad: UnidadAlimento
    creado_por_id: UUID | None = None
    created_at: datetime
    updated_at: datetime
    deleted_at: datetime | None = None
