"""Excepciones de dominio del módulo equipo.

Cada una tiene un ``code`` estable: la app lo usa para mostrar un mensaje
específico (código vencido vs. usado vs. revocado) sin parsear el texto.
"""

from api.shared.exceptions import (
    ConflictError,
    ForbiddenError,
    NotFoundError,
    ValidationError,
)


class GestionEquipoNoPermitidaError(ForbiddenError):
    code = "equipo_sin_permiso"

    def __init__(self) -> None:
        super().__init__(
            "Solo el dueño o un administrador del establecimiento pueden gestionar "
            "el equipo"
        )


class RolNoAsignableError(ForbiddenError):
    code = "rol_no_asignable"

    def __init__(self) -> None:
        super().__init__("Tu rol no te permite gestionar a alguien con ese rol")


class YaEsMiembroError(ConflictError):
    code = "ya_es_miembro"

    def __init__(self) -> None:
        super().__init__("Esa persona ya forma parte del equipo del establecimiento")


class InvitacionPendienteDuplicadaError(ConflictError):
    code = "invitacion_pendiente_duplicada"

    def __init__(self) -> None:
        super().__init__(
            "Ya hay una invitación pendiente para ese email. Podés reenviarla desde "
            "la lista del equipo"
        )


class InvitacionNoEncontradaError(NotFoundError):
    code = "invitacion_no_encontrada"

    def __init__(self) -> None:
        super().__init__("Invitación no encontrada")


class InvitacionNoPendienteError(ConflictError):
    code = "invitacion_no_pendiente"

    def __init__(self) -> None:
        super().__init__("La invitación ya fue aceptada o cancelada")


class CodigoInvalidoError(ValidationError):
    code = "codigo_invalido"

    def __init__(self) -> None:
        super().__init__(
            "El código no es válido. Revisá que esté bien escrito o pedí uno nuevo"
        )


class CodigoVencidoError(ValidationError):
    code = "codigo_vencido"

    def __init__(self) -> None:
        super().__init__("El código venció. Pedile a quien te invitó que lo reenvíe")


class CodigoUsadoError(ConflictError):
    code = "codigo_usado"

    def __init__(self) -> None:
        super().__init__("Este código ya se usó")


class CodigoRevocadoError(ValidationError):
    code = "codigo_revocado"

    def __init__(self) -> None:
        super().__init__(
            "La invitación fue cancelada. Pedile a quien te invitó una nueva"
        )


class CodigoDeOtroEmailError(ForbiddenError):
    code = "codigo_de_otro_email"

    def __init__(self) -> None:
        super().__init__(
            "Este código es para otro email. Iniciá sesión con el email al que llegó "
            "la invitación"
        )


class NoPodesQuitarteError(ValidationError):
    code = "no_podes_quitarte"

    def __init__(self) -> None:
        super().__init__("No podés quitarte a vos mismo del equipo")


class TitularNoRemovibleError(ConflictError):
    code = "titular_no_removible"

    def __init__(self) -> None:
        super().__init__("No se puede quitar al titular del establecimiento")


class MiembroNoEncontradoError(NotFoundError):
    code = "miembro_no_encontrado"

    def __init__(self) -> None:
        super().__init__("Esa persona no forma parte del equipo")
