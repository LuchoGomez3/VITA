"""Lógica de negocio del módulo usuarios."""

from sqlalchemy.ext.asyncio import AsyncSession

from api.auth.providers import AuthProvider
from api.modules.usuarios.exceptions import (
    CuitInvalidoError,
    CuitYaRegistradoError,
    EmailYaRegistradoError,
)
from api.modules.usuarios.models import Usuario
from api.modules.usuarios.repository import UsuarioRepository
from api.modules.usuarios.schemas import UsuarioRead, UsuarioRegistroCreate
from api.modules.usuarios.utils import validar_cuit


class UsuarioService:
    def __init__(self, session: AsyncSession, auth_provider: AuthProvider) -> None:
        self.repository = UsuarioRepository(session)
        self.auth_provider = auth_provider

    async def registrar(self, data: UsuarioRegistroCreate) -> tuple[UsuarioRead, str]:
        """Registra un dueño de campo: credenciales en el proveedor + perfil.

        Devuelve el perfil creado y un token de sesión.
        """
        # Validación de dígito verificador (el formato ya lo validó el schema).
        if not validar_cuit(data.cuit):
            raise CuitInvalidoError(data.cuit)

        # Unicidad de email y CUIT (la constraint final la garantiza la DB,
        # pero validamos antes para devolver un error de dominio claro).
        if await self.repository.get_by_email(data.email) is not None:
            raise EmailYaRegistradoError(data.email)
        if await self.repository.get_by_cuit(data.cuit) is not None:
            raise CuitYaRegistradoError(data.cuit)

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
        await self.repository.create(usuario)

        return UsuarioRead.model_validate(usuario), auth_result.access_token
