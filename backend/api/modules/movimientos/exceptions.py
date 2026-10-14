"""Excepciones de dominio del módulo movimientos.

Los ``code`` son parte del contrato con el cliente offline (Brick los lee de
``errors[0].code``) y se tratan como API pública.
"""

from uuid import UUID

from api.shared.exceptions import NotFoundError, ValidationError


class MovimientoLoteInvalidoError(ValidationError):
    """El movimiento no describe una operación posible.

    Cubre los casos estructurales: origen igual a destino, lista de animales
    vacía o con IDs repetidos.
    """

    code = "movimiento_lote_invalido"

    def __init__(self, motivo: str) -> None:
        super().__init__(motivo)


class LoteDestinoNoDisponibleError(ValidationError):
    code = "lote_destino_no_disponible"

    def __init__(self, motivo: str) -> None:
        super().__init__(motivo, details={"field": "lote_destino_id"})


class LoteOrigenNoDisponibleError(ValidationError):
    code = "lote_origen_no_disponible"

    def __init__(self, motivo: str) -> None:
        super().__init__(motivo, details={"field": "lote_origen_id"})


class AnimalesNoPertenecenAlLoteOrigenError(ValidationError):
    """El estado remoto no coincide con el que el cliente asumía al mover.

    Es el conflicto típico del offline: otro dispositivo ya movió, vendió o borró
    alguno de esos animales. La operación se rechaza entera y el cliente debe
    volver a leer antes de reintentar.
    """

    code = "animales_no_pertenecen_lote_origen"

    def __init__(self, animal_ids: list[UUID]) -> None:
        super().__init__(
            "Algunos animales no están disponibles en el lote de origen",
            details={"animal_ids": [str(a) for a in animal_ids]},
        )


class MovimientoLoteNoEncontradoError(NotFoundError):
    code = "movimiento_lote_no_encontrado"

    def __init__(self) -> None:
        super().__init__("Movimiento no encontrado o sin acceso")
