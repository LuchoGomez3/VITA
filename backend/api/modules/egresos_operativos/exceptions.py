"""Errores de dominio propios de los egresos operativos."""

from api.shared.exceptions import (
    ConflictError,
    ForbiddenError,
    NotFoundError,
    ValidationError,
)


class EstablecimientoNoAutorizadoError(ForbiddenError):
    """El usuario no posee una membresía activa en el establecimiento."""

    code = "establecimiento_no_autorizado"

    def __init__(self) -> None:
        super().__init__("No tiene acceso al establecimiento indicado")


class EgresoOperativoNoEncontradoError(NotFoundError):
    """El movimiento no existe o pertenece a otro tenant."""

    code = "egreso_operativo_no_encontrado"

    def __init__(self) -> None:
        super().__init__("Egreso operativo no encontrado o sin acceso")


class CategoriaEgresoInvalidaError(ValidationError):
    """La categoría no existe para ese campo o pertenece al otro tipo contable."""

    code = "categoria_egreso_invalida"

    def __init__(self) -> None:
        super().__init__("La categoría no corresponde al tipo de egreso seleccionado")


class CategoriaEgresoDuplicadaError(ConflictError):
    """Ya existe una categoría con el mismo valor normalizado en el campo."""

    code = "categoria_egreso_duplicada"

    def __init__(self) -> None:
        super().__init__("Ya existe una categoría con ese nombre en el establecimiento")


class CategoriaEgresoIdEnConflictoError(ConflictError):
    """El UUID de sincronización ya identifica una categoría con otros datos."""

    code = "categoria_egreso_id_en_conflicto"

    def __init__(self) -> None:
        """Informa una colisión de identidad sin confundirla con un nombre repetido."""
        super().__init__(
            "El identificador de la categoría ya existe con datos diferentes"
        )
