"""Selección del proveedor de autenticación según configuración."""

from functools import lru_cache

from api.auth.providers.base import (
    AuthProvider,
    AuthProviderError,
    AuthResult,
    IdentityAlreadyExistsError,
    InvalidCredentialsError,
)
from api.auth.providers.local_provider import LocalAuthProvider
from core.config import settings

__all__ = [
    "AuthProvider",
    "AuthProviderError",
    "AuthResult",
    "IdentityAlreadyExistsError",
    "InvalidCredentialsError",
    "get_auth_provider",
]


@lru_cache(maxsize=1)
def get_auth_provider() -> AuthProvider:
    """Devuelve el proveedor configurado (``settings.AUTH_PROVIDER``).

    Inyectable como dependencia de FastAPI: ``Depends(get_auth_provider)``.
    """
    if settings.AUTH_PROVIDER == "supabase":
        # Import diferido: evita exigir el SDK de Supabase en entornos locales.
        from api.auth.providers.supabase_provider import SupabaseAuthProvider

        return SupabaseAuthProvider()
    return LocalAuthProvider()
