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
