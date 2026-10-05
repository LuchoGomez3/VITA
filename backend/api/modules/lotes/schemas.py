"""DTOs Pydantic del módulo lotes."""

from datetime import datetime
from decimal import ROUND_HALF_UP, Decimal
from typing import Any
from uuid import UUID

from pydantic import BaseModel, ConfigDict, field_validator

from api.modules.lotes.models import MODO_GEOMETRIA_LOCAL
from api.shared.enums import EstadoLote, RecursoForrajero
from api.shared.schemas import SyncFields

# El cliente guarda la superficie en décimas exactas de hectárea y envía un
# decimal con un dígito. El backend fija esa precisión como autoritativa: si
# aceptara más, el ida y vuelta perdería información contra el valor local.
PRECISION_SUPERFICIE = Decimal("0.1")


def cuantizar_superficie(valor: Decimal) -> Decimal:
    """Redondea la superficie a la precisión autoritativa de un decimal."""
    return valor.quantize(PRECISION_SUPERFICIE, rounding=ROUND_HALF_UP)


class LoteCreate(SyncFields):
    """Alta o reproducción de un lote.

    Hereda de ``SyncFields``: el cliente offline envía su propio ``id`` y sus
    timestamps, y el backend los respeta. El mismo payload sirve para el alta, la
    edición y el tombstone, porque el POST es un upsert idempotente por UUID.
    """

    establecimiento_id: UUID
    nombre: str
    geometria_local: dict[str, Any]
    superficie_ha: Decimal
    modo_geometria: str = MODO_GEOMETRIA_LOCAL
    recurso_forrajero_codigo: RecursoForrajero | None = None
    tiene_agua: bool = False
    estado: EstadoLote = EstadoLote.activo

    @field_validator("nombre")
    @classmethod
    def _nombre_no_vacio(cls, v: str) -> str:
        v = v.strip()
        if not v:
            raise ValueError("El nombre del lote es obligatorio")
        return v

    @field_validator("superficie_ha")
    @classmethod
    def _superficie_positiva(cls, v: Decimal) -> Decimal:
        if v <= 0:
            raise ValueError("La superficie debe ser mayor a 0")
        return cuantizar_superficie(v)

    @field_validator("modo_geometria")
    @classmethod
    def _modo_soportado(cls, v: str) -> str:
        if v != MODO_GEOMETRIA_LOCAL:
            raise ValueError(
                f"Modo de geometría no soportado: '{v}'. "
                f"Esta versión solo admite '{MODO_GEOMETRIA_LOCAL}'"
            )
        return v


class LoteUpdate(SyncFields):
    """Edición de un lote. ``None`` significa "no tocar".

    ``geometria_local`` no está: la geometría queda bloqueada después del alta en
    esta versión. Un payload que la traiga (Brick reenvía el registro completo) la
    ve ignorada, no rechazada, para no convertir un replay legítimo en un rechazo.
    """

    nombre: str | None = None
    superficie_ha: Decimal | None = None
    recurso_forrajero_codigo: RecursoForrajero | None = None
    tiene_agua: bool | None = None
    estado: EstadoLote | None = None

    @field_validator("nombre")
    @classmethod
    def _nombre_no_vacio(cls, v: str | None) -> str | None:
        if v is None:
            return None
        v = v.strip()
        if not v:
            raise ValueError("El nombre del lote es obligatorio")
        return v

    @field_validator("superficie_ha")
    @classmethod
    def _superficie_positiva(cls, v: Decimal | None) -> Decimal | None:
        if v is None:
            return None
        if v <= 0:
            raise ValueError("La superficie debe ser mayor a 0")
        return cuantizar_superficie(v)


class LoteRead(BaseModel):
    """Representación autoritativa que se devuelve al cliente.

    Expone todos los campos, ``deleted_at`` incluido: el adapter de Brick castea
    la respuesta del POST de forma estricta, así que un campo ausente o un ``null``
    inesperado rompe la deserialización en el dispositivo.
    """

    model_config = ConfigDict(from_attributes=True)

    id: UUID
    establecimiento_id: UUID
    nombre: str
    geometria_local: dict[str, Any]
    modo_geometria: str
    superficie_ha: Decimal
    recurso_forrajero_codigo: RecursoForrajero | None = None
    tiene_agua: bool
    estado: EstadoLote
    created_at: datetime
    updated_at: datetime
    # Un registro con ``deleted_at`` no nulo le dice al cliente que lo borre local.
    deleted_at: datetime | None = None
