"""Lógica de negocio del módulo usuarios."""

from datetime import UTC, datetime
import logging

import anyio
from uuid import UUID

from sqlalchemy.exc import IntegrityError
from sqlalchemy.ext.asyncio import AsyncSession

from api.auth.providers import AuthProvider, AuthResult
from api.modules.usuarios.avatar import clave_de_avatar, normalizar_avatar
from api.modules.usuarios.exceptions import (
    AlmacenamientoDeAvatarFallidoError,
    AvatarNoEncontradoError,
    UsuarioYaRegistradoError,
)
from api.modules.usuarios.models import Usuario
from api.modules.usuarios.repository import UsuarioRepository
from api.modules.usuarios.schemas import (
    UsuarioPerfilUpdate,
    UsuarioRead,
    UsuarioRegistroCreate,
)
from api.shared.cuit import CuitInvalidoError, validar_cuit
from api.shared.exceptions import NotFoundError
from core.storage import ObjectStorage, StorageError

logger = logging.getLogger(__name__)


class UsuarioService:
    def __init__(self, session: AsyncSession, auth_provider: AuthProvider) -> None:
        self.repository = UsuarioRepository(session)
        self.auth_provider = auth_provider

    async def registrar(
        self, data: UsuarioRegistroCreate
    ) -> tuple[UsuarioRead, AuthResult]:
        """Registra un dueño de campo: credenciales en el proveedor + perfil.

        Devuelve el perfil creado y la sesión completa (access + refresh +
        expiración), igual que login: el registro abre sesión de inmediato, sin
        pedir credenciales de nuevo.
        """
        # Validación de dígito verificador (el formato ya lo validó el schema).
        if not validar_cuit(data.cuit):
            raise CuitInvalidoError(data.cuit)

        # Unicidad de email y CUIT (la constraint final la garantiza la DB,
        # pero validamos antes para devolver un error de dominio claro).
        if await self.repository.get_by_email(data.email) is not None:
            raise UsuarioYaRegistradoError()
        if await self.repository.get_by_cuit(data.cuit) is not None:
            raise UsuarioYaRegistradoError()

        # Credenciales en el proveedor de identidad (Supabase Auth en real).
        # El backend nunca persiste la contraseña.
        auth_result = await self.auth_provider.sign_up(data.email, data.password)

        usuario = Usuario(
            id=auth_result.user_id,
            nombre=data.nombre,
            apellido=data.apellido,
            email=data.email,
            cuit=data.cuit,
        )
        try:
            await self.repository.create(usuario)
        except IntegrityError as exc:
            await self._compensar_credencial(auth_result.user_id)
            raise UsuarioYaRegistradoError() from exc
        except Exception:
            # El alta cruza Supabase Auth y PostgreSQL, que no comparten una
            # transaccion. Si falla el perfil, compensamos la credencial para
            # que el productor pueda reintentar el registro con el mismo email.
            await self._compensar_credencial(auth_result.user_id)
            raise

        return UsuarioRead.model_validate(usuario), auth_result

    async def _compensar_credencial(self, user_id: UUID) -> None:
        try:
            await self.auth_provider.delete_user(user_id)
        except Exception:
            logger.exception(
                "[AUTH] No se pudo compensar el usuario %s tras fallar el perfil",
                user_id,
            )


class PerfilUsuarioService:
    """Personalización del propio perfil: color de la cabecera y foto (adr-0011).

    Siempre opera sobre el usuario autenticado: ninguna ruta recibe un id, así
    que no hay forma de tocar el perfil de otro.
    """

    def __init__(self, session: AsyncSession, storage: ObjectStorage) -> None:
        self.repository = UsuarioRepository(session)
        self.storage = storage

    async def _cargar(self, usuario_id: UUID) -> Usuario:
        # ``get_current_user`` puede venir de otra sesión: se recarga en la del
        # request para que los cambios se persistan con su commit.
        usuario = await self.repository.get_by_id(usuario_id)
        if usuario is None:
            raise NotFoundError("Usuario no encontrado")
        return usuario

    async def actualizar(
        self, usuario_id: UUID, data: UsuarioPerfilUpdate
    ) -> UsuarioRead:
        usuario = await self._cargar(usuario_id)
        usuario.color_cabecera = data.color_cabecera
        await self.repository.guardar(usuario)
        return UsuarioRead.model_validate(usuario)

    async def subir_avatar(self, usuario_id: UUID, datos: bytes) -> UsuarioRead:
        """Normaliza la foto y reemplaza la anterior (clave fija por usuario).

        La fecha se actualiza recién después de que Storage aceptó la foto: si
        la subida falla, el perfil sigue apuntando a la foto que había.
        """
        usuario = await self._cargar(usuario_id)
        # Pillow es CPU puro: en el event loop frenaría a todos los demás
        # requests mientras procesa una foto de cámara.
        foto = await anyio.to_thread.run_sync(normalizar_avatar, datos)
        try:
            await self.storage.subir_jpeg(clave_de_avatar(usuario.id), foto)
        except StorageError as exc:
            raise AlmacenamientoDeAvatarFallidoError() from exc
        usuario.avatar_actualizado_en = datetime.now(UTC)
        await self.repository.guardar(usuario)
        logger.info("[AVATAR] Foto de perfil actualizada para %s", usuario.id)
        return UsuarioRead.model_validate(usuario)

    async def descargar_avatar(self, usuario_id: UUID) -> bytes:
        usuario = await self._cargar(usuario_id)
        if usuario.avatar_actualizado_en is None:
            raise AvatarNoEncontradoError()
        try:
            return await self.storage.descargar(clave_de_avatar(usuario.id))
        except StorageError as exc:
            raise AlmacenamientoDeAvatarFallidoError() from exc

    async def borrar_avatar(self, usuario_id: UUID) -> UsuarioRead:
        """Borra la foto. Sin foto previa no hace nada (idempotente).

        Primero se borra el objeto y después la fecha: si Storage falla, el
        perfil sigue mostrando la foto que todavía existe. El objeto se borra
        aunque la fecha esté vacía: si una subida llegó al bucket pero no a la
        base, así no queda una foto huérfana ocupando espacio.
        """
        usuario = await self._cargar(usuario_id)
        try:
            await self.storage.borrar(clave_de_avatar(usuario.id))
        except StorageError as exc:
            raise AlmacenamientoDeAvatarFallidoError() from exc
        if usuario.avatar_actualizado_en is not None:
            usuario.avatar_actualizado_en = None
            await self.repository.guardar(usuario)
        return UsuarioRead.model_validate(usuario)
