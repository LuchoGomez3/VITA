"""DTOs Pydantic del módulo establecimientos."""

from datetime import datetime
from decimal import Decimal
from uuid import UUID

from pydantic import BaseModel, ConfigDict, field_validator


class EstablecimientoCreate(BaseModel):
    nombre: str
    nro_renspa: str
    cuit: str | None = None
    superficie_ha: Decimal | None = None
    provincia: str | None = None
    departamento: str | None = None
    localidad: str | None = None

    @field_validator("nombre")
    @classmethod
    def _nombre_no_vacio(cls, v: str) -> str:
        v = v.strip()
        if not v:
            raise ValueError("El nombre es obligatorio")
        return v


class EstablecimientoUpdate(BaseModel):
    nombre: str | None = None
    nro_renspa: str | None = None
    cuit: str | None = None
    superficie_ha: Decimal | None = None
    provincia: str | None = None
    departamento: str | None = None
    localidad: str | None = None


class EstablecimientoRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    owner_id: UUID
    nombre: str
    nro_renspa: str | None = None
    cuit: str | None = None
    superficie_ha: Decimal | None = None
    provincia: str | None = None
    departamento: str | None = None
    localidad: str | None = None
    created_at: datetime
    updated_at: datetime
