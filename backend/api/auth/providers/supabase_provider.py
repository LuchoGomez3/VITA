"""Adaptador de Supabase Auth.

Crea credenciales vía la API admin de Supabase y valida los JWT que emite
Supabase (firmados con ``SUPABASE_JWT_SECRET``, HS256, audiencia ``authenticated``).

El cliente de ``supabase-py`` es síncrono; las llamadas de red se ejecutan en un
thread aparte para no bloquear el event loop.
"""

import logging
from functools import lru_cache
from uuid import UUID

import anyio
from jose import JWTError, jwt

from api.auth.providers.base import AuthProvider, AuthProviderError, AuthResult
from core.config import settings

logger = logging.getLogger(__name__)


@lru_cache(maxsize=1)
def _get_admin_client():
    """Cliente Supabase con la service-role key (operaciones admin)."""
    from supabase import create_client

    if not settings.SUPABASE_URL or not settings.SUPABASE_SERVICE_ROLE_KEY:
        raise AuthProviderError(
            "Supabase no está configurado (SUPABASE_URL / SUPABASE_SERVICE_ROLE_KEY)"
        )
    return create_client(settings.SUPABASE_URL, settings.SUPABASE_SERVICE_ROLE_KEY)


class SupabaseAuthProvider(AuthProvider):
    async def sign_up(self, email: str, password: str) -> AuthResult:
        return await anyio.to_thread.run_sync(self._sign_up_sync, email, password)

    def _sign_up_sync(self, email: str, password: str) -> AuthResult:
        client = _get_admin_client()
        try:
            created = client.auth.admin.create_user(
                {"email": email, "password": password, "email_confirm": True}
            )
            user = getattr(created, "user", None) or created
            user_id = UUID(str(user.id))

            # Iniciar sesión para devolver un token de sesión al cliente.
            session = client.auth.sign_in_with_password(
                {"email": email, "password": password}
            )
            access_token = session.session.access_token
        except AuthProviderError:
            raise
        except Exception as exc:  # red / API de Supabase
            logger.error("[AUTH] Supabase sign_up falló: %s", exc, exc_info=True)
            raise AuthProviderError(
                "No se pudo crear el usuario en el proveedor de identidad"
            ) from exc

        return AuthResult(user_id=user_id, access_token=access_token)

    def verify_token(self, token: str) -> dict:
        if not settings.SUPABASE_JWT_SECRET:
            raise AuthProviderError("SUPABASE_JWT_SECRET no configurado")
        try:
            return jwt.decode(
                token,
                settings.SUPABASE_JWT_SECRET,
                algorithms=["HS256"],
                audience="authenticated",
            )
        except JWTError as exc:
            raise AuthProviderError("Token inválido o expirado") from exc
