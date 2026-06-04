"""Excepciones de dominio del módulo reportes."""

from typing import Any

from api.shared.exceptions import ForbiddenError, ValidationError


class DatosIncompletosParaReporteError(ValidationError):
    """Hay animales sin RFID de 15 dígitos o sin categoría: no se genera archivo."""

    code = "datos_incompletos_para_reporte"

    def __init__(self, animales_incompletos: list[dict[str, Any]]) -> None:
        super().__init__(
            "Hay animales con datos incompletos (RFID de 15 dígitos o categoría); "
            "corregilos antes de generar el reporte",
            details={"animales_incompletos": animales_incompletos},
        )


class EstablecimientoNoAutorizadoError(ForbiddenError):
    code = "establecimiento_no_autorizado"

    def __init__(self) -> None:
        super().__init__("No tiene acceso al establecimiento indicado")
