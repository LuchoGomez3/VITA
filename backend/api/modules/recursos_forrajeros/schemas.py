"""DTOs Pydantic del historial de recursos forrajeros."""

from datetime import date, datetime
from uuid import UUID

from pydantic import BaseModel, ConfigDict, field_validator, model_validator

from api.shared.enums import RecursoForrajero
from api.shared.schemas import SyncFields


class PeriodoRecursoForrajeroCreate(SyncFields):
    """Desde ``fecha_desde``, el lote tiene este recurso.

    No hace falta cerrar el período anterior: termina el día antes del siguiente.
    ``fecha_hasta`` solo se usa para un corte (el potrero queda sin recurso).
    """

    establecimiento_id: UUID
    lote_id: UUID
    recurso_forrajero_codigo: RecursoForrajero
    descripcion: str | None = None
    fecha_desde: date
    fecha_hasta: date | None = None
    # Se acepta por compatibilidad con el payload del cliente pero se descarta:
    # el autor siempre sale del JWT.
    registrado_por_id: UUID | None = None

    @field_validator("descripcion")
    @classmethod
    def _descripcion_limpia(cls, v: str | None) -> str | None:
        if v is None:
            return None
        return v.strip() or None

    @model_validator(mode="after")
    def _reglas(self) -> "PeriodoRecursoForrajeroCreate":
        if self.fecha_hasta is not None and self.fecha_hasta < self.fecha_desde:
            raise ValueError("La fecha de fin no puede ser anterior a la de inicio")
        if (
            self.recurso_forrajero_codigo == RecursoForrajero.otro
            and self.descripcion is None
        ):
            raise ValueError("Describí el recurso cuando elegís 'otro'")
        return self


class PeriodoRecursoForrajeroRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    establecimiento_id: UUID
    lote_id: UUID
    recurso_forrajero_codigo: RecursoForrajero
    descripcion: str | None = None
    fecha_desde: date
    fecha_hasta: date | None = None
    registrado_por_id: UUID | None = None
    created_at: datetime
    updated_at: datetime
    deleted_at: datetime | None = None
