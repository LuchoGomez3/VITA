"""Errores de dominio del registro de ventas de hacienda.

Los códigos son parte del contrato con mobile: permiten distinguir un rechazo
funcional de una falla transitoria que sí debe permanecer en la cola offline.
"""

from uuid import UUID

from api.shared.exceptions import ConflictError, ForbiddenError


class AccesoComercialDenegadoError(ForbiddenError):
    """El rol del miembro no permite registrar operaciones comerciales."""

    code = "acceso_comercial_denegado"

    def __init__(self) -> None:
        super().__init__(
            "Acceso denegado. No posee privilegios para registrar "
            "operaciones comerciales"
        )


class AnimalesNoDisponiblesVentaError(ConflictError):
    """Uno o más animales no pueden formar parte de la venta.

    No distingue entre inexistente, ajeno, borrado o no activo para evitar
    filtrar información de otro establecimiento. Los IDs permiten que mobile
    reconcilie el stock local e informe exactamente qué selección revisar.
    """

    code = "animales_no_disponibles_venta"

    def __init__(self, animal_ids: list[UUID]) -> None:
        super().__init__(
            "El animal seleccionado no se encuentra en el stock activo del "
            "establecimiento",
            details={"animal_ids": [str(animal_id) for animal_id in animal_ids]},
        )


class VentaIdEnConflictoError(ConflictError):
    """El UUID ya identifica una venta cuyo contenido es diferente."""

    code = "venta_id_en_conflicto"

    def __init__(self) -> None:
        super().__init__("El identificador de la venta ya existe con datos diferentes")


class VentaIntegridadEnConflictoError(ConflictError):
    """La base rechazó una combinación de datos que no cambiará al reintentar."""

    code = "venta_conflicto_integridad"

    def __init__(self) -> None:
        super().__init__(
            "La venta no pudo registrarse porque sus datos entraron en "
            "conflicto con otra operación"
        )
