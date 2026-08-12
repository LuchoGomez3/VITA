"""Excepciones de dominio del módulo usuarios."""

from api.shared.exceptions import ConflictError


class EmailYaRegistradoError(ConflictError):
    code = "email_ya_registrado"

    def __init__(self, email: str) -> None:
        super().__init__(f"El email '{email}' ya está registrado")


class CuitYaRegistradoError(ConflictError):
    code = "cuit_ya_registrado"

    def __init__(self, cuit: str) -> None:
        super().__init__(f"El CUIT/CUIL '{cuit}' ya está registrado")
