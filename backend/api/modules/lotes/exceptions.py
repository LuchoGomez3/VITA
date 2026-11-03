"""Excepciones de dominio del módulo lotes.

Los ``code`` son parte del contrato con el cliente offline: Brick los lee de
``errors[0].code`` y los guarda como motivo del rechazo. Cambiar uno rompe la
clasificación de errores en la app, así que se tratan como API pública.

Importante: el cliente solo reintenta 5xx. Todo 4xx es un rechazo definitivo,
que es justamente la semántica buscada para estos errores de regla de negocio.
"""

from uuid import UUID

from api.shared.exceptions import ConflictError, NotFoundError, ValidationError


class NombreLoteDuplicadoError(ConflictError):
    code = "nombre_lote_duplicado"

    def __init__(self, nombre: str) -> None:
        super().__init__(
            f"Ya existe un lote llamado '{nombre}' en este establecimiento",
            details={"field": "nombre"},
        )


class GeometriaLoteInvalidaError(ValidationError):
    code = "geometria_lote_invalida"

    def __init__(self, motivo: str) -> None:
        super().__init__(motivo, details={"field": "geometria_local"})


class LotesSuperpuestosError(ConflictError):
    code = "lotes_superpuestos"

    def __init__(self, lote_id: UUID, nombre: str) -> None:
        super().__init__(
            f"La geometría se superpone con el lote '{nombre}'",
            details={"field": "geometria_local", "lote_id": str(lote_id)},
        )


class LoteConAnimalesError(ConflictError):
    code = "lote_con_animales"

    def __init__(self, cantidad: int) -> None:
        super().__init__(
            f"El lote tiene {cantidad} animal(es) vigente(s): "
            "moverlos antes de inactivarlo o borrarlo",
            details={"animales_vigentes": cantidad},
        )


class LoteNoEncontradoError(NotFoundError):
    code = "lote_no_encontrado"

    def __init__(self) -> None:
        super().__init__("Lote no encontrado o sin acceso")
