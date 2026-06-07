"""Excepciones de dominio del módulo animales."""

from api.shared.exceptions import (
    ConflictError,
    ForbiddenError,
    NotFoundError,
    ValidationError,
)


class CaravanaDuplicadaError(ConflictError):
    code = "caravana_duplicada"

    def __init__(self, nro_caravana_rfid: str) -> None:
        super().__init__(
            f"Ya existe un animal con la caravana RFID '{nro_caravana_rfid}'"
        )


class LoteNoPerteneceAlEstablecimientoError(ValidationError):
    code = "lote_no_pertenece_establecimiento"

    def __init__(self) -> None:
        super().__init__("El lote no pertenece al establecimiento indicado")


class AnimalReferenciaInvalidaError(ValidationError):
    code = "referencia_invalida"

    def __init__(self, campo: str) -> None:
        super().__init__(
            f"La referencia '{campo}' es inválida o pertenece a otro establecimiento"
        )


class EstablecimientoNoAutorizadoError(ForbiddenError):
    code = "establecimiento_no_autorizado"

    def __init__(self) -> None:
        super().__init__("No tiene acceso al establecimiento indicado")


class AnimalNoEncontradoError(NotFoundError):
    code = "animal_no_encontrado"

    def __init__(self) -> None:
        super().__init__("Animal no encontrado o sin acceso")
