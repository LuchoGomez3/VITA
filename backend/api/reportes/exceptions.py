"""Excepciones de dominio del módulo reportes."""

from typing import Any

from api.shared.exceptions import ForbiddenError, NotFoundError, ValidationError


class DatosIncompletosParaReporteError(ValidationError):
    """Hay datos incompatibles con el formato SENASA solicitado."""

    code = "datos_incompletos_para_reporte"

    def __init__(self, animales_incompletos: list[dict[str, Any]]) -> None:
        super().__init__(
            "Hay datos incompletos o sin código SENASA; corregilos antes de "
            "generar el reporte",
            details={"animales_incompletos": animales_incompletos},
        )


class EstablecimientoNoAutorizadoError(ForbiddenError):
    code = "establecimiento_no_autorizado"

    def __init__(self) -> None:
        super().__init__("No tiene acceso al establecimiento indicado")


class ExportacionSenasaNoEncontradaError(NotFoundError):
    """La exportación no existe o pertenece a otro establecimiento."""

    code = "exportacion_senasa_no_encontrada"

    def __init__(self) -> None:
        super().__init__("No se encontró la exportación SENASA solicitada")
