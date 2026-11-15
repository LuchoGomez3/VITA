"""Excepciones de dominio de los registros de alimentación."""

from uuid import UUID

from api.shared.exceptions import ConflictError, ValidationError


class AlimentoNoDisponibleError(ValidationError):
    code = "alimento_no_disponible"

    def __init__(self) -> None:
        super().__init__(
            "El alimento no existe, fue borrado o es de otro establecimiento"
        )


class LoteNoDisponibleError(ValidationError):
    code = "lote_no_disponible"

    def __init__(self) -> None:
        super().__init__("El potrero no existe o es de otro establecimiento")


class AnimalesNoDisponiblesError(ValidationError):
    """Algún animal no existe, fue borrado o es de otro establecimiento.

    Rechaza el registro entero: guardar "los que se pueda" dejaría al cliente y al
    servidor con historiales distintos sin que nadie se entere.
    """

    code = "animales_no_disponibles"

    def __init__(self, animal_ids: list[UUID]) -> None:
        super().__init__(
            "Algunos animales no existen o no pertenecen al establecimiento",
            details={"animal_ids": [str(a) for a in animal_ids]},
        )


class FechaFuturaError(ValidationError):
    code = "fecha_futura"

    def __init__(self) -> None:
        super().__init__("La fecha de inicio no puede ser futura")


class RegistroAlimentacionIdEnConflictoError(ConflictError):
    """El UUID ya identifica otro registro (otro alimento, tipo o animales).

    Es un 409 y no un reintento: Brick marca el registro como rechazado.
    """

    code = "registro_alimentacion_id_en_conflicto"

    def __init__(self) -> None:
        super().__init__(
            "El identificador del registro ya corresponde a otra alimentación"
        )
