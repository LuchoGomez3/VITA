"""Adaptador de Supabase Storage.

Solo objetos privados: el backend entra con la ``service_role`` key, que
bypassea las policies del bucket, y nunca emite URLs públicas ni firmadas. Lo
que se persiste en Postgres es la *clave* del objeto; quien necesita los bytes
(el script de exportación) los baja con estas mismas credenciales.

El cliente de ``supabase-py`` es síncrono, así que las llamadas de red van a un
thread aparte para no bloquear el event loop — mismo criterio que
``api/auth/providers/supabase_provider.py``.
"""

import logging
from functools import lru_cache
from typing import Protocol

import anyio
from supabase import create_client

from core.config import settings

logger = logging.getLogger(__name__)


class StorageError(Exception):
    """Falla al hablar con el almacenamiento de objetos.

    La capa de servicio la traduce a un error de dominio; nunca se deja escapar
    el detalle del proveedor al cliente.
    """


class ObjectStorage(Protocol):
    """Contrato mínimo que consume el módulo de calibraciones.

    Es un ``Protocol`` y no una clase base para que los tests puedan inyectar un
    doble en memoria sin heredar de nada ni tocar la red.
    """

    async def subir_jpeg(self, clave: str, datos: bytes) -> None:
        """Sube (o pisa) el objeto ``clave``. Debe ser idempotente."""
        ...

    async def descargar(self, clave: str) -> bytes: ...

    async def borrar(self, clave: str) -> None: ...


class SupabaseStorage:
    """Implementación sobre Supabase Storage."""

    def __init__(
        self, bucket: str, *, url: str = "", service_role_key: str = ""
    ) -> None:
        self._bucket_name = bucket
        self._url = url or settings.SUPABASE_URL
        self._key = service_role_key or settings.SUPABASE_SERVICE_ROLE_KEY

    def _bucket(self):
        if not self._url or not self._key:
            raise StorageError(
                "Supabase Storage no está configurado (falta SUPABASE_URL o "
                "SUPABASE_SERVICE_ROLE_KEY)"
            )
        return create_client(self._url, self._key).storage.from_(self._bucket_name)

    async def subir_jpeg(self, clave: str, datos: bytes) -> None:
        """Sube el JPEG pisando el objeto anterior si existe.

        ``upsert`` es lo que vuelve idempotente el reintento: la clave se deriva
        del UUID de la muestra, así que reenviar la misma muestra sobrescribe su
        objeto en vez de dejar un duplicado.
        """

        def _subir() -> None:
            self._bucket().upload(
                path=clave,
                file=datos,
                file_options={
                    "content-type": "image/jpeg",
                    "upsert": "true",
                    # Dataset de entrenamiento: se lee en lote, rara vez y desde
                    # un script. No tiene sentido que un CDN lo cachee.
                    "cache-control": "no-store",
                },
            )

        try:
            await anyio.to_thread.run_sync(_subir)
        except Exception as exc:
            # Sin el cuerpo de la excepción del proveedor en el mensaje: puede
            # traer la URL firmada o parte del token.
            logger.error(
                "[STORAGE] Falló la subida del objeto %s al bucket %s (%s)",
                clave,
                self._bucket_name,
                type(exc).__name__,
            )
            raise StorageError("No se pudo subir el objeto") from exc

    async def descargar(self, clave: str) -> bytes:
        def _descargar() -> bytes:
            return self._bucket().download(clave)

        try:
            return await anyio.to_thread.run_sync(_descargar)
        except Exception as exc:
            logger.error(
                "[STORAGE] Falló la descarga del objeto %s (%s)",
                clave,
                type(exc).__name__,
            )
            raise StorageError("No se pudo descargar el objeto") from exc

    async def borrar(self, clave: str) -> None:
        def _borrar() -> None:
            self._bucket().remove([clave])

        try:
            await anyio.to_thread.run_sync(_borrar)
        except Exception as exc:
            logger.error(
                "[STORAGE] Falló el borrado del objeto %s (%s)",
                clave,
                type(exc).__name__,
            )
            raise StorageError("No se pudo borrar el objeto") from exc


@lru_cache
def _storage_calibraciones() -> SupabaseStorage:
    return SupabaseStorage(settings.SUPABASE_STORAGE_BUCKET_CALIBRACIONES)


def get_storage_calibraciones() -> ObjectStorage:
    """Dependencia FastAPI del almacén de imágenes de calibración.

    Los tests la sobreescriben con ``app.dependency_overrides`` para correr sin
    red ni bucket real.
    """
    return _storage_calibraciones()
