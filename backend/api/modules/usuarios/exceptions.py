"""Excepciones de dominio del módulo usuarios."""

from api.shared.exceptions import (
    ConflictError,
    DomainException,
    NotFoundError,
    ValidationError,
)


class UsuarioYaRegistradoError(ConflictError):
    """Conflicto unificado para evitar revelar qué identificador existe."""

    code = "usuario_ya_registrado"

    def __init__(self) -> None:
        super().__init__(
            "El CUIT o correo ingresado ya se encuentran asociados a una cuenta activa. "
            "Por favor, iniciá sesión."
        )


class AvatarNoEncontradoError(NotFoundError):
    code = "avatar_no_encontrado"

    def __init__(self) -> None:
        super().__init__("El usuario no tiene foto de perfil")


class AvatarFormatoInvalidoError(ValidationError):
    """La foto no es un JPEG, PNG o WebP legible (o está truncada)."""

    code = "avatar_formato_invalido"

    def __init__(self) -> None:
        super().__init__("La foto tiene que ser JPEG, PNG o WebP.")


class ImagenVaciaError(ValidationError):
    code = "imagen_vacia"

    def __init__(self) -> None:
        super().__init__("No se recibió ninguna foto")


class ImagenDemasiadoGrandeError(DomainException):
    """413: el cliente tiene que achicar la foto antes de reintentar."""

    status_code = 413
    code = "imagen_demasiado_grande"

    def __init__(self, maximo_bytes: int) -> None:
        super().__init__(
            "La foto excede el tamaño máximo permitido "
            f"({maximo_bytes // 1024 // 1024} MB)",
            details={"maximo_bytes": maximo_bytes},
        )


class AlmacenamientoDeAvatarFallidoError(DomainException):
    """El almacenamiento no respondió (red, credenciales, bucket).

    502 y no 500: es un servicio externo, y el cliente debe distinguirlo de una
    foto inválida para conservarla y reintentar cuando haya conexión.
    """

    status_code = 502
    code = "almacenamiento_de_avatar_fallido"

    def __init__(self) -> None:
        super().__init__(
            "No se pudo guardar la foto de perfil. Reintentá cuando haya conexión."
        )
