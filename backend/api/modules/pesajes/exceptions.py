"""Excepciones de dominio del módulo pesajes."""

from api.shared.exceptions import (
    ForbiddenError,
    NotFoundError,
    ValidationError,
)


class PesajeNoEncontradoError(NotFoundError):
    code = "pesaje_no_encontrado"

    def __init__(self) -> None:
        super().__init__("Pesaje no encontrado o sin acceso")


class EstablecimientoNoAutorizadoError(ForbiddenError):
    code = "establecimiento_no_autorizado"

    def __init__(self) -> None:
        super().__init__("No tiene acceso al establecimiento indicado")


class AnimalNoPerteneceAlEstablecimientoError(ValidationError):
    code = "animal_no_pertenece_establecimiento"

    def __init__(self) -> None:
        super().__init__(
            "El animal no existe o no pertenece al establecimiento indicado"
        )
