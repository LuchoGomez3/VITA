"""Excepciones de dominio del historial de recursos forrajeros."""

from api.shared.exceptions import ConflictError, ValidationError


class LoteNoDisponibleError(ValidationError):
    code = "lote_no_disponible"

    def __init__(self) -> None:
        super().__init__(
            "El potrero no existe, fue borrado o es de otro establecimiento"
        )


class FechaFuturaError(ValidationError):
    code = "fecha_futura"

    def __init__(self) -> None:
        super().__init__("La fecha de inicio no puede ser futura")


class PeriodoRecursoDuplicadoError(ConflictError):
    """Ya hay un período del mismo potrero que empieza ese día."""

    code = "periodo_recurso_duplicado"

    def __init__(self) -> None:
        super().__init__("El potrero ya tiene un recurso cargado desde esa fecha")


class PeriodoRecursoIdEnConflictoError(ConflictError):
    """El UUID ya identifica un período de otro lote o establecimiento."""

    code = "periodo_recurso_id_en_conflicto"

    def __init__(self) -> None:
        super().__init__("El identificador del período ya está en uso")
