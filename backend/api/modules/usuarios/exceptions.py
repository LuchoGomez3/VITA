"""Excepciones de dominio del módulo usuarios."""

from api.shared.exceptions import ConflictError


class UsuarioYaRegistradoError(ConflictError):
    """Conflicto unificado para evitar revelar qué identificador existe."""

    code = "usuario_ya_registrado"

    def __init__(self) -> None:
        super().__init__(
            "El CUIT o correo ingresado ya se encuentran asociados a una cuenta activa. "
            "Por favor, iniciá sesión."
        )
