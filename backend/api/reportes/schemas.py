"""DTOs Pydantic del módulo reportes."""

from datetime import datetime
from typing import Literal
from uuid import UUID

from pydantic import BaseModel


class ReporteSenasaFiltros(BaseModel):
    """Filtros internos para declarar dispositivos electrónicos aplicados."""

    establecimiento_id: UUID
    formato: Literal["txt", "pdf"] = "txt"
    desde: datetime | None = None
    hasta: datetime | None = None
    tipo_exportacion: Literal["declaracion_identificacion", "novedad_nacimientos"] = (
        "declaracion_identificacion"
    )
    incluir_responsable: bool = False
    responsable_nombre: str | None = None
    responsable_dni: str | None = None
    nombre_archivo: str | None = None


class DeclaracionDispositivosRequest(BaseModel):
    """Solicitud oficial para generar el TXT importable por SIGSA."""

    establecimiento_id: UUID
    desde: datetime | None = None
    hasta: datetime | None = None
    nombre_archivo: str | None = None


class ReporteDispositivo(BaseModel):
    """Datos normalizados de un dispositivo para exportar a SENASA."""

    dispositivo: str
    sexo: str
    raza: str
    fecha_nacimiento: str


class AnimalIncompleto(BaseModel):
    animal_id: UUID
    caravana: str | None
    faltante: list[str]


class ValidacionDeclaracionDispositivos(BaseModel):
    """Resultado de validar una declaración sin crear un archivo histórico."""

    cantidad_exportable: int
    animales_incompletos: list[AnimalIncompleto]


class ExportacionSenasaRead(BaseModel):
    """Metadatos públicos del archivo; excluye el contenido binario pesado."""

    id: UUID
    establecimiento_id: UUID
    usuario_generador_id: UUID
    nombre_archivo: str
    formato: str
    tipo_exportacion: str
    media_type: str
    hash_sha256: str
    cantidad_animales: int
    desde: datetime | None
    hasta: datetime | None
    created_at: datetime
