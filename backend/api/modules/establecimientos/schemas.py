"""DTOs Pydantic del módulo establecimientos."""

from datetime import datetime
from decimal import Decimal
from uuid import UUID

from pydantic import BaseModel, ConfigDict, field_validator


class EstablecimientoVertice(BaseModel):
    """Un vértice del polígono que delimita la superficie del campo."""

    orden: int
    latitud: float
    longitud: float


class EstablecimientoCreate(BaseModel):
    nombre: str
    nro_renspa: str
    cuit: str | None = None
    descripcion: str | None = None
    tipo_produccion: list[str] | None = None
    superficie_ha: Decimal | None = None
    provincia: str | None = None
    departamento: str | None = None
    localidad: str | None = None
    latitud: Decimal | None = None
    longitud: Decimal | None = None
    poligono: list[EstablecimientoVertice] | None = None

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
    descripcion: str | None = None
    tipo_produccion: list[str] | None = None
    superficie_ha: Decimal | None = None
    provincia: str | None = None
    departamento: str | None = None
    localidad: str | None = None
    latitud: Decimal | None = None
    longitud: Decimal | None = None
    poligono: list[EstablecimientoVertice] | None = None


class EstablecimientoRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    owner_id: UUID
    nombre: str
    descripcion: str | None = None
    tipo_produccion: list[str] | None = None
    nro_renspa: str | None = None
    cuit: str | None = None
    superficie_ha: Decimal | None = None
    provincia: str | None = None
    departamento: str | None = None
    localidad: str | None = None
    latitud: Decimal | None = None
    longitud: Decimal | None = None
    poligono: list[EstablecimientoVertice] | None = None
    created_at: datetime
    updated_at: datetime
