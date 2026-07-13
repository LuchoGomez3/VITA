"""Lógica de autenticación de sesión.

Delega la validación de credenciales en el proveedor configurado
(``get_auth_provider``) y carga el perfil desde la tabla ``usuarios``. No emite
ni valida JWT por su cuenta: el token lo devuelve el proveedor (Supabase en
entornos reales), de modo que sea válido para ``get_current_user``.
"""

from sqlalchemy.ext.asyncio import AsyncSession

from api.auth.providers import AuthProvider, AuthResult, InvalidCredentialsError
from api.modules.usuarios.models import Usuario
from api.modules.usuarios.repository import UsuarioRepository


class AuthService:
    def __init__(self, session: AsyncSession, auth_provider: AuthProvider) -> None:
        self.repository = UsuarioRepository(session)
        self.auth_provider = auth_provider

    async def login(self, email: str, password: str) -> tuple[Usuario, AuthResult]:
        """Valida credenciales contra el proveedor y devuelve perfil + sesión.

        Lanza ``InvalidCredentialsError`` si las credenciales son inválidas o si
        no existe un perfil en ``usuarios`` para el usuario autenticado.
        """
        auth_result = await self.auth_provider.sign_in(email, password)
        return await self._with_profile(auth_result)

    async def refresh(self, refresh_token: str) -> tuple[Usuario, AuthResult]:
        """Renueva la sesión a partir del ``refresh_token`` y recarga el perfil.

        Es el paso que el cliente ejecuta al recuperar conexión, antes de drenar
        la cola offline, para tener un ``access_token`` válido.
        """
        auth_result = await self.auth_provider.refresh(refresh_token)
        return await self._with_profile(auth_result)

    async def _with_profile(
        self, auth_result: AuthResult
    ) -> tuple[Usuario, AuthResult]:
        usuario = await self.repository.get_by_id(auth_result.user_id)
        if usuario is None:
            raise InvalidCredentialsError(
                "Perfil no encontrado para estas credenciales"
            )
        return usuario, auth_result
