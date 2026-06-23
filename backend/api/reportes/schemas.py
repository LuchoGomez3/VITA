"""DTOs Pydantic del módulo reportes."""

from datetime import datetime
from typing import Literal
from uuid import UUID

from pydantic import BaseModel


class ReporteSenasaFiltros(BaseModel):
    """Filtros del reporte SENASA (provienen de query params)."""

    establecimiento_id: UUID
    formato: Literal["csv", "pdf"] = "csv"
    desde: datetime | None = None
    hasta: datetime | None = None
    lote_id: UUID | None = None
    tipo_evento: str | None = None
    incluir_responsable: bool = False
    responsable_nombre: str | None = None
    responsable_dni: str | None = None


class ReporteFila(BaseModel):
    """Una fila del reporte: campos obligatorios SENASA."""

    renspa: str | None
    identificador_animal: str | None
    fecha_hora: datetime
    tipo_evento: str


class AnimalIncompleto(BaseModel):
    animal_id: UUID
    caravana: str | None
    faltante: list[str]


class ReporteValidacionResult(BaseModel):
    animales_incompletos: list[AnimalIncompleto]
