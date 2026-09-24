"""Excepciones de dominio del módulo calibraciones_ml.

Los ``code`` son contrato con el cliente offline: según el código, el móvil
decide si deja la muestra en ``pending`` para reintentar (fallo de
infraestructura) o la marca ``rejected`` y deja de insistir (dato inválido).
"""

from api.shared.exceptions import (
    DomainException,
    NotFoundError,
    ValidationError,
)


class MuestraCalibracionNoEncontradaError(NotFoundError):
    code = "muestra_calibracion_no_encontrada"

    def __init__(self) -> None:
        super().__init__("Muestra de calibración no encontrada o sin acceso")


class AnimalNoPerteneceAlEstablecimientoError(ValidationError):
    code = "animal_no_pertenece_establecimiento"

    def __init__(self) -> None:
        super().__init__(
            "El animal no existe o no pertenece al establecimiento indicado"
        )


class ImagenNoEsJpegError(ValidationError):
    code = "imagen_no_es_jpeg"

    def __init__(self) -> None:
        super().__init__("La imagen debe ser un archivo JPEG legible")


class ImagenDemasiadoGrandeError(ValidationError):
    code = "imagen_demasiado_grande"

    def __init__(self, maximo_bytes: int) -> None:
        super().__init__(
            "La imagen excede el tamaño máximo permitido "
            f"({maximo_bytes // 1024 // 1024} MB)",
            details={"maximo_bytes": maximo_bytes},
        )


class ImagenVaciaError(ValidationError):
    code = "imagen_vacia"

    def __init__(self) -> None:
        super().__init__("No se recibió ninguna imagen")


class SubidaDeImagenFallidaError(DomainException):
    """El almacenamiento no aceptó la imagen (red, credenciales, bucket).

    502 y no 500: el fallo es de un servicio externo, y el cliente debe
    distinguirlo de un dato inválido para conservar la muestra y reintentarla.
    """

    status_code = 502
    code = "subida_de_imagen_fallida"

    def __init__(self) -> None:
        super().__init__(
            "No se pudo guardar la imagen. La muestra queda pendiente; "
            "reintente cuando haya conexión."
        )
