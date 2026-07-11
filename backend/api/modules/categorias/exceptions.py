"""Excepciones de dominio del módulo categorías."""

from api.shared.exceptions import (
    ConflictError,
    ForbiddenError,
    NotFoundError,
)


class CategoriaNoEncontradaError(NotFoundError):
    code = "categoria_no_encontrada"

    def __init__(self) -> None:
        super().__init__("Categoría no encontrada o sin acceso")


class EstablecimientoNoAutorizadoError(ForbiddenError):
    code = "establecimiento_no_autorizado"

    def __init__(self) -> None:
        super().__init__("No tiene acceso al establecimiento indicado")


class CategoriaGlobalNoEditableError(ForbiddenError):
    code = "categoria_global_no_editable"

    def __init__(self) -> None:
        super().__init__(
            "Las categorías del catálogo global no se pueden modificar ni eliminar"
        )


class NombreCategoriaDuplicadoError(ConflictError):
    code = "categoria_duplicada"

    def __init__(self, nombre: str) -> None:
        super().__init__(
            f"Ya existe una categoría llamada '{nombre}' en este establecimiento"
        )


class CategoriaEnUsoError(ConflictError):
    code = "categoria_en_uso"

    def __init__(self) -> None:
        super().__init__(
            "No se puede eliminar la categoría porque hay animales asignados a ella"
        )
