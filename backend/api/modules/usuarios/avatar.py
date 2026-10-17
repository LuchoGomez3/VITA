"""Validación y normalización de la foto de perfil.

Entra JPEG, PNG o WebP (la galería de Android puede devolver PNG aunque se pida
JPEG) y sale siempre un JPEG: es lo único que acepta el bucket ``avatars``.

Funciones puras sobre ``bytes``: sin red, sin base y sin FastAPI, así los casos
borde se prueban sin levantar nada. Mismo criterio que la imagen de calibración
del módulo ``calibraciones_ml`` (PR #52), con otro tamaño de salida.

Por qué se recomprime y no se guarda el original: el proyecto corre en el plan
free de Supabase (1 GB de Storage) y el bucket ``avatars`` rechaza más de 1 MB.
Una foto de celular pesa ~4,5 MB; la de perfil se ve en un círculo de ~72 px,
así que un cuadrado de 512 px a calidad 85 (~40 KB) sobra.
"""

import io
import logging
from uuid import UUID

from PIL import Image, ImageOps, UnidentifiedImageError

from api.modules.usuarios.exceptions import (
    AvatarFormatoInvalidoError,
    ImagenDemasiadoGrandeError,
    ImagenVaciaError,
)
from core.config import settings

logger = logging.getLogger(__name__)

# Formatos de entrada que acepta Pillow para la foto de perfil. El
# ``content_type`` del multipart lo declara el cliente, así que no alcanza para
# saber qué llegó: se mira la firma de los primeros bytes.
_FORMATOS_ACEPTADOS = {"JPEG", "PNG", "WEBP"}

# Fondo sobre el que se aplana una foto con transparencia: JPEG no tiene canal
# alfa y, sin aplanar, lo transparente quedaría negro.
_FONDO_TRANSPARENCIA = (255, 255, 255)


def _formato_por_firma(datos: bytes) -> str | None:
    if datos.startswith(b"\xff\xd8\xff"):
        return "JPEG"
    if datos.startswith(b"\x89PNG\r\n\x1a\n"):
        return "PNG"
    if datos[:4] == b"RIFF" and datos[8:12] == b"WEBP":
        return "WEBP"
    return None


def _a_rgb(imagen: Image.Image) -> Image.Image:
    """Pasa a RGB aplanando la transparencia (si la hay) sobre blanco."""
    if imagen.mode == "P":
        imagen = imagen.convert("RGBA")
    if imagen.mode in ("RGBA", "LA"):
        fondo = Image.new("RGB", imagen.size, _FONDO_TRANSPARENCIA)
        fondo.paste(imagen, mask=imagen.getchannel("A"))
        return fondo
    return imagen.convert("RGB")


def validar_tamanio_declarado(content_length: int | None) -> None:
    """Rechaza por ``Content-Length`` antes de leer el cuerpo.

    Es un atajo, no la validación: el header lo pone el cliente y puede mentir o
    faltar. El chequeo que manda es el de ``normalizar_avatar`` sobre los bytes
    reales; este solo evita traer 200 MB a memoria para después descartarlos.
    """
    maximo = settings.AVATAR_IMAGEN_MAX_BYTES
    if content_length is not None and content_length > maximo:
        raise ImagenDemasiadoGrandeError(maximo)


def normalizar_avatar(datos: bytes) -> bytes:
    """Valida la foto (JPEG, PNG o WebP) y devuelve el JPEG de perfil.

    La salida es un cuadrado de hasta ``AVATAR_IMAGEN_LADO_MAX`` px recortado al
    centro (se muestra en un círculo), en RGB y sin metadatos. Levanta
    ``ImagenVaciaError`` / ``ImagenDemasiadoGrandeError`` /
    ``AvatarFormatoInvalidoError`` ante cualquier problema, así nada inválido
    llega a Storage.
    """
    if not datos:
        raise ImagenVaciaError()

    maximo = settings.AVATAR_IMAGEN_MAX_BYTES
    if len(datos) > maximo:
        raise ImagenDemasiadoGrandeError(maximo)

    formato = _formato_por_firma(datos)
    if formato is None:
        raise AvatarFormatoInvalidoError()

    # ``verify()`` detecta el archivo truncado o corrupto, pero deja la imagen
    # inutilizable, así que hay que reabrirla para trabajarla.
    try:
        with Image.open(io.BytesIO(datos)) as sonda:
            # La firma y el decodificador tienen que coincidir: un PNG con
            # extensión .jpg pasa, un archivo que solo empieza "parecido", no.
            if sonda.format != formato or sonda.format not in _FORMATOS_ACEPTADOS:
                raise AvatarFormatoInvalidoError()
            sonda.verify()
    except (UnidentifiedImageError, OSError, SyntaxError, ValueError) as exc:
        # Sin el detalle de Pillow en el mensaje al usuario: no puede hacer nada
        # con él.
        logger.warning("[AVATAR] Foto rechazada por ilegible (%s)", type(exc).__name__)
        raise AvatarFormatoInvalidoError() from exc

    try:
        with Image.open(io.BytesIO(datos)) as imagen:
            # La cámara guarda la rotación en el EXIF: hay que aplicarla antes de
            # descartarlo o la foto queda acostada.
            imagen = _a_rgb(ImageOps.exif_transpose(imagen))
            lado = min(settings.AVATAR_IMAGEN_LADO_MAX, *imagen.size)
            # ``fit`` recorta al centro y achica sin deformar; una foto ya chica
            # no se agranda (``lado`` nunca supera su lado menor).
            imagen = ImageOps.fit(imagen, (lado, lado), method=Image.Resampling.LANCZOS)

            salida = io.BytesIO()
            # Guardar sin pasar ``exif`` lo descarta: la foto puede traer el GPS
            # de dónde se sacó, que no hace falta para un avatar.
            imagen.save(
                salida,
                format="JPEG",
                quality=settings.AVATAR_IMAGEN_CALIDAD,
                optimize=True,
            )
    except (OSError, ValueError) as exc:
        logger.warning(
            "[AVATAR] Foto rechazada al recomprimir (%s)", type(exc).__name__
        )
        raise AvatarFormatoInvalidoError() from exc

    return salida.getvalue()


def clave_de_avatar(usuario_id: UUID) -> str:
    """Clave del objeto en el bucket: ``{usuario_id}.jpg``.

    Fija por usuario: subir otra foto pisa la anterior (upsert), así nunca hay
    dos fotos del mismo usuario ni quedan huérfanas si algo falla a la mitad
    (adr-0011).
    """
    return f"{usuario_id}.jpg"
