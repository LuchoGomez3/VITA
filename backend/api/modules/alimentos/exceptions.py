"""Excepciones de dominio del catálogo de alimentos."""

from api.shared.exceptions import ConflictError


class AlimentoIdEnConflictoError(ConflictError):
    """El UUID ya identifica un alimento de otro establecimiento.

    Es un 409 y no un reintento: Brick marca el registro como rechazado y no lo
    vuelve a mandar.
    """

    code = "alimento_id_en_conflicto"

    def __init__(self) -> None:
        super().__init__("El identificador del alimento ya está en uso")
