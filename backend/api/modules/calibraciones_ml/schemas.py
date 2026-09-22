"""DTOs Pydantic del módulo calibraciones_ml."""

from datetime import datetime
from decimal import Decimal
from uuid import UUID

from pydantic import BaseModel, ConfigDict, field_validator

from api.shared.enums import EstadoMuestraCalibracion
from api.shared.schemas import SyncFields


class MuestraCalibracionCreate(SyncFields):
    """Alta de una muestra de calibración, **sin** la imagen.

    Hereda ``SyncFields``: el cliente offline genera el ``id`` y los timestamps y
    el backend los respeta (alta idempotente con last-write-wins). La foto se
    sube después, contra ``POST /{id}/imagen``: la cola offline del cliente solo
    reproduce requests de texto, así que meter el binario acá haría que una
    muestra capturada sin señal se perdiera en vez de reintentarse.
    """

    establecimiento_id: UUID
    animal_id: UUID
    peso_real_kg: Decimal
    peso_estimado_kg: Decimal | None = None
    fecha_captura: datetime | None = None
    observaciones: str | None = None

    @field_validator("peso_real_kg")
    @classmethod
    def _peso_real_positivo(cls, v: Decimal) -> Decimal:
        if v <= 0:
            raise ValueError("El peso real debe ser mayor a 0")
        return v

    @field_validator("peso_estimado_kg")
    @classmethod
    def _peso_estimado_positivo(cls, v: Decimal | None) -> Decimal | None:
        if v is not None and v <= 0:
            raise ValueError("El peso estimado debe ser mayor a 0")
        return v


class MuestraCalibracionUpdate(SyncFields):
    """Corrección de una muestra. ``updated_at`` dirime el conflicto (LWW) y
    ``deleted_at`` permite propagar un soft delete desde el cliente.

    ``imagen_key`` no es editable: la asigna el backend al recibir el archivo. Un
    cliente que pudiera escribirla apuntaría el registro a un objeto de otro
    establecimiento.
    """

    peso_real_kg: Decimal | None = None
    peso_estimado_kg: Decimal | None = None
    fecha_captura: datetime | None = None
    estado: EstadoMuestraCalibracion | None = None
    observaciones: str | None = None

    @field_validator("peso_real_kg")
    @classmethod
    def _peso_real_positivo(cls, v: Decimal | None) -> Decimal | None:
        if v is not None and v <= 0:
            raise ValueError("El peso real debe ser mayor a 0")
        return v

    @field_validator("peso_estimado_kg")
    @classmethod
    def _peso_estimado_positivo(cls, v: Decimal | None) -> Decimal | None:
        if v is not None and v <= 0:
            raise ValueError("El peso estimado debe ser mayor a 0")
        return v

    @field_validator("estado")
    @classmethod
    def _estado_editable(
        cls, v: EstadoMuestraCalibracion | None
    ) -> EstadoMuestraCalibracion | None:
        """El cliente solo puede descartar una muestra.

        ``pendiente_imagen`` y ``completa`` los deriva el backend de la presencia
        del objeto en Storage; dejar que el cliente los escriba permitiría marcar
        ``completa`` una muestra sin foto y colarla en el dataset.
        """
        if v is not None and v is not EstadoMuestraCalibracion.descartada:
            raise ValueError("Solo se puede cambiar el estado a 'descartada'")
        return v


class MuestraCalibracionRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    establecimiento_id: UUID
    animal_id: UUID
    peso_real_kg: Decimal
    peso_estimado_kg: Decimal | None = None
    fecha_captura: datetime
    # Clave del objeto en el bucket privado. Se expone para que el cliente sepa
    # que la foto llegó; NO es una URL y no sirve para descargarla sin
    # credenciales.
    imagen_key: str | None = None
    imagen_bytes: int | None = None
    estado: EstadoMuestraCalibracion
    responsable_id: UUID | None = None
    observaciones: str | None = None
    created_at: datetime
    updated_at: datetime
    # Se expone para la descarga delta: un registro con deleted_at != null le
    # indica al cliente que debe borrarlo localmente.
    deleted_at: datetime | None = None
