"""Excepciones de dominio del módulo observaciones de animales."""

from api.shared.exceptions import ForbiddenError, NotFoundError, ValidationError


class ObservacionNoEncontradaError(NotFoundError):
    code = "observacion_no_encontrada"

    def __init__(self) -> None:
        super().__init__("Observación no encontrada o sin acceso")


class AnimalNoPerteneceAlEstablecimientoError(ValidationError):
    code = "animal_no_pertenece_establecimiento"

    def __init__(self) -> None:
        super().__init__("El animal no existe o no pertenece al establecimiento")


class ObservacionInmutableError(ValidationError):
    code = "observacion_inmutable"

    def __init__(self) -> None:
        super().__init__(
            "Una observación no puede cambiar de animal ni de establecimiento"
        )


class ObservacionSoloAutorError(ForbiddenError):
    code = "observacion_solo_autor"

    def __init__(self) -> None:
        super().__init__("Solo el autor puede editar esta observación")


class ObservacionBorradoNoPermitidoError(ForbiddenError):
    code = "observacion_borrado_no_permitido"

    def __init__(self) -> None:
        super().__init__(
            "Solo el autor, el dueño o un administrador pueden borrar esta observación"
        )
