"""Excepciones de dominio compartidas.

Cada módulo define sus propias excepciones heredando de ``DomainException``.
El handler global (``core.middlewares.domain_exception_handler``) las traduce a
una respuesta ``StandardResponse(success=False, errors=[...])`` con el HTTP
status correspondiente, de modo que los servicios no arman respuestas HTTP.
"""

from typing import Any


class DomainException(Exception):
    """Error de dominio mapeable a una respuesta HTTP estándar.

    Atributos:
        status_code: código HTTP a devolver.
        code: identificador estable del error (para el front/móvil).
        message: mensaje legible para el usuario.
        details: payload opcional con contexto (p. ej. lista de datos faltantes).
    """

    status_code: int = 400
    code: str = "domain_error"

    def __init__(
        self,
        message: str,
        *,
        status_code: int | None = None,
        code: str | None = None,
        details: Any | None = None,
    ) -> None:
        self.message = message
        if status_code is not None:
            self.status_code = status_code
        if code is not None:
            self.code = code
        self.details = details
        super().__init__(message)


class NotFoundError(DomainException):
    status_code = 404
    code = "not_found"


class ConflictError(DomainException):
    status_code = 409
    code = "conflict"


class ValidationError(DomainException):
    status_code = 422
    code = "validation_error"


class ForbiddenError(DomainException):
    status_code = 403
    code = "forbidden"
