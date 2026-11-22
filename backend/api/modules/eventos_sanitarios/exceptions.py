"""Excepciones de dominio del módulo eventos sanitarios.

Los rechazos que el operario puede corregir llevan en ``details`` el ``campo``
(con la ruta, por ejemplo ``datos.dosis`` o ``animales.1.referencia_muestra``)
y, si corresponde, el ``animal_id``. El celular usa esos datos para señalar qué
corregir sin perder el resto de la selección.
"""

from typing import Any
from uuid import UUID

from api.shared.exceptions import ConflictError, NotFoundError, ValidationError


def _detalles(campo: str | None, animal_id: UUID | None) -> dict[str, Any] | None:
    detalles: dict[str, Any] = {}
    if campo is not None:
        detalles["campo"] = campo
    if animal_id is not None:
        detalles["animal_id"] = str(animal_id)
    return detalles or None


class EventoSanitarioInvalidoError(ValidationError):
    code = "evento_sanitario_invalido"

    def __init__(
        self, mensaje: str, *, campo: str | None = None, animal_id: UUID | None = None
    ) -> None:
        super().__init__(mensaje, details=_detalles(campo, animal_id))


class AnimalNoDisponibleError(ValidationError):
    code = "animal_no_disponible"

    def __init__(self, campo: str, animal_id: UUID) -> None:
        super().__init__(
            "El animal no existe, no está activo o es de otro establecimiento",
            details=_detalles(campo, animal_id),
        )


class EventoSanitarioNoEncontradoError(NotFoundError):
    code = "evento_sanitario_no_encontrado"

    def __init__(self) -> None:
        super().__init__("Evento sanitario no encontrado o sin acceso")


class OperacionSanitariaConflictoError(ConflictError):
    """El UUID de operación ya se usó con otro contenido."""

    code = "operacion_sanitaria_conflicto"

    def __init__(self) -> None:
        super().__init__(
            "La operación ya se registró con datos distintos. Generá una nueva."
        )


class EventoSanitarioExistenteError(ConflictError):
    """El UUID de un evento ya pertenece a otra operación aceptada."""

    code = "evento_sanitario_existente"

    def __init__(self, campo: str, animal_id: UUID) -> None:
        super().__init__(
            "El evento ya fue registrado por otra operación",
            details=_detalles(campo, animal_id),
        )


class ResultadoYaCompletadoError(ConflictError):
    """Otra operación ya guardó el primer resultado del estudio."""

    code = "resultado_ya_completado"

    def __init__(self, evento: dict[str, Any]) -> None:
        super().__init__("El estudio ya tiene resultado", details={"evento": evento})
