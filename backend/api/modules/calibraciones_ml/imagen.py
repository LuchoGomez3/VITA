"""Validación y normalización del JPEG de una muestra de calibración.

Todo acá es función pura sobre ``bytes``: sin red, sin base y sin FastAPI. Es la
parte con más casos borde del módulo y así se testea sin levantar nada.

Por qué se recomprime y no se guarda el original: el proyecto corre en el plan
free de Supabase (1 GB de Storage). Una foto de celular sin tocar pesa ~4,5 MB,
lo que da unas 230 muestras antes de llenar el bucket; a 1280 px de lado mayor y
calidad 85 baja a ~350 KB, o sea ~3000 muestras. Y no se pierde nada útil: el
modelo de estimación entrena a 224-380 px.
"""

import io
import logging

from PIL import Image, ImageOps, UnidentifiedImageError

from api.modules.calibraciones_ml.exceptions import (
    ImagenDemasiadoGrandeError,
    ImagenNoEsJpegError,
    ImagenVaciaError,
)
from core.config import settings

logger = logging.getLogger(__name__)

# Marcador SOI de JPEG. El ``content_type`` del multipart lo declara el cliente,
# así que no alcanza para saber qué llegó.
_MAGIC_JPEG = b"\xff\xd8\xff"


def validar_tamanio_declarado(content_length: int | None) -> None:
    """Rechaza por ``Content-Length`` antes de leer el cuerpo.

    Es un atajo, no la validación: el header lo pone el cliente y puede mentir o
    faltar. El chequeo que manda es el de ``normalizar_jpeg`` sobre los bytes
    reales; este solo evita traer 200 MB a memoria para después descartarlos.
    """
    if (
        content_length is not None
        and content_length > settings.CALIBRACION_IMAGEN_MAX_BYTES
    ):
        raise ImagenDemasiadoGrandeError(settings.CALIBRACION_IMAGEN_MAX_BYTES)


def normalizar_jpeg(datos: bytes) -> bytes:
    """Valida que ``datos`` sea un JPEG legible y devuelve su versión recomprimida.

    Levanta ``ImagenVaciaError`` / ``ImagenDemasiadoGrandeError`` /
    ``ImagenNoEsJpegError`` (todas 4xx) ante cualquier problema, de modo que nada
    inválido llegue a Storage.
    """
    if not datos:
        raise ImagenVaciaError()

    maximo = settings.CALIBRACION_IMAGEN_MAX_BYTES
    if len(datos) > maximo:
        raise ImagenDemasiadoGrandeError(maximo)

    if not datos.startswith(_MAGIC_JPEG):
        raise ImagenNoEsJpegError()

    # ``verify()`` detecta el archivo truncado o corrupto, pero deja la imagen
    # inutilizable, así que hay que reabrirla para trabajarla.
    try:
        with Image.open(io.BytesIO(datos)) as sonda:
            if sonda.format != "JPEG":
                raise ImagenNoEsJpegError()
            sonda.verify()
    except (UnidentifiedImageError, OSError, SyntaxError, ValueError) as exc:
        # Sin el detalle de Pillow en el mensaje al usuario: el productor en el
        # campo no puede hacer nada con él.
        logger.warning(
            "[CALIBRACION] Imagen rechazada por ilegible (%s)", type(exc).__name__
        )
        raise ImagenNoEsJpegError() from exc

    try:
        with Image.open(io.BytesIO(datos)) as imagen:
            # La cámara guarda la foto en el sensor y la rotación en el EXIF. Hay
            # que aplicarla ANTES de descartar el EXIF, o la muestra queda
            # acostada y el animal deja de verse de perfil.
            imagen = ImageOps.exif_transpose(imagen)
            # El modelo espera 3 canales; un JPEG en escala de grises o CMYK
            # rompería el preprocesamiento del pipeline.
            imagen = imagen.convert("RGB")
            lado_max = settings.CALIBRACION_IMAGEN_LADO_MAX
            # ``thumbnail`` solo reduce: una foto ya chica no se agranda (no hay
            # detalle que inventar) y conserva la relación de aspecto, que es lo
            # que el modelo usa para inferir la proporción del cuerpo.
            imagen.thumbnail((lado_max, lado_max), Image.Resampling.LANCZOS)

            salida = io.BytesIO()
            # Guardar sin pasar ``exif`` lo descarta, y eso es deseable: la foto
            # de campo trae el GPS del establecimiento, que es dato identificable
            # del productor y no hace falta para entrenar.
            imagen.save(
                salida,
                format="JPEG",
                quality=settings.CALIBRACION_IMAGEN_CALIDAD,
                optimize=True,
            )
    except (OSError, ValueError) as exc:
        logger.warning(
            "[CALIBRACION] Imagen rechazada al recomprimir (%s)", type(exc).__name__
        )
        raise ImagenNoEsJpegError() from exc

    return salida.getvalue()


def clave_de_imagen(establecimiento_id, muestra_id) -> str:
    """Clave del objeto en el bucket: ``{establecimiento}/{muestra}.jpg``.

    Se deriva de los identificadores y no del nombre del archivo ni de la
    caravana: el nombre que manda el cliente puede repetirse o traer caracteres
    raros, y la caravana puede reasignarse. Al depender del UUID de la muestra
    (que es su PK), reenviar la misma muestra pisa el mismo objeto en vez de
    dejar un duplicado, y el prefijo por establecimiento mantiene los datasets de
    dos tenants separados incluso dentro del bucket.
    """
    return f"{establecimiento_id}/{muestra_id}.jpg"
