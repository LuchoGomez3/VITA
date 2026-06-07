"""DTOs Pydantic del módulo animales."""

from datetime import date, datetime
from decimal import Decimal
from uuid import UUID

from pydantic import BaseModel, ConfigDict, field_validator

from api.shared.enums import EstadoAnimal, MetodoPesaje, SexoAnimal


class AnimalCreate(BaseModel):
    """Alta de un animal. Incluye el pesaje inicial (criterio 'debe tener peso').

    El número de caravana llega como string ya resuelto (Bluetooth/manual/OCR
    son del lado móvil; el backend es agnóstico al método de captura).
    """

    nro_caravana_rfid: str
    sexo: SexoAnimal
    raza: str
    fecha_nacimiento: date
    lote_id: UUID
    establecimiento_id: UUID

    # Opcionales
    madre_id: UUID | None = None
    padre_id: UUID | None = None
    categoria_id: UUID | None = None
    caravana_visual: str | None = None
    pelaje: str | None = None
    observaciones: str | None = None

    # Pesaje inicial
    peso_inicial: Decimal
    metodo_pesaje: MetodoPesaje = MetodoPesaje.manual
    fecha_pesaje: datetime | None = None

    @field_validator("nro_caravana_rfid")
    @classmethod
    def _caravana_15_digitos(cls, v: str) -> str:
        v = v.strip()
        if not v.isdigit() or len(v) != 15:
            raise ValueError(
                "El número de caravana RFID debe tener 15 dígitos (ISO 11784/85)"
            )
        return v

    @field_validator("raza")
    @classmethod
    def _raza_no_vacia(cls, v: str) -> str:
        v = v.strip()
        if not v:
            raise ValueError("La raza es obligatoria")
        return v

    @field_validator("peso_inicial")
    @classmethod
    def _peso_positivo(cls, v: Decimal) -> Decimal:
        if v <= 0:
            raise ValueError("El peso inicial debe ser mayor a 0")
        return v


class AnimalUpdate(BaseModel):
    raza: str | None = None
    fecha_nacimiento: date | None = None
    categoria_id: UUID | None = None
    lote_id: UUID | None = None
    pelaje: str | None = None
    observaciones: str | None = None
    estado: EstadoAnimal | None = None


class AnimalRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    establecimiento_id: UUID
    nro_caravana_rfid: str | None = None
    caravana_visual: str | None = None
    sexo: SexoAnimal
    raza: str | None = None
    fecha_nacimiento: date | None = None
    categoria_id: UUID | None = None
    lote_id: UUID | None = None
    padre_id: UUID | None = None
    madre_id: UUID | None = None
    pelaje: str | None = None
    estado: EstadoAnimal
    observaciones: str | None = None
    created_at: datetime
    updated_at: datetime
