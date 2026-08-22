"""Lógica de negocio del módulo usuarios."""

import logging
from uuid import UUID

from sqlalchemy.exc import IntegrityError
from sqlalchemy.ext.asyncio import AsyncSession

from api.auth.providers import AuthProvider, AuthResult
from api.modules.usuarios.exceptions import UsuarioYaRegistradoError
from api.modules.usuarios.models import Usuario
from api.modules.usuarios.repository import UsuarioRepository
from api.modules.usuarios.schemas import UsuarioRead, UsuarioRegistroCreate
from api.shared.cuit import CuitInvalidoError, validar_cuit

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
