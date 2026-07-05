"""Adaptador de Supabase Auth.

Crea credenciales vía la API admin de Supabase y valida los JWT que emite
Supabase (audiencia ``authenticated``). Soporta los dos esquemas de firma:

- **Asimétrico (ES256/RS256)**: el esquema actual de Supabase. Las claves
  públicas se obtienen del JWKS del proyecto y se cachean por ``kid``.
- **Simétrico (HS256)**: esquema legacy, validado con ``SUPABASE_JWT_SECRET``.

El cliente de ``supabase-py`` es síncrono; las llamadas de red se ejecutan en un
thread aparte para no bloquear el event loop.
"""

import logging
from functools import lru_cache
from uuid import UUID

import anyio
import httpx
from jose import JWTError, jwt

from api.auth.providers.base import (
    AuthProvider,
    AuthProviderError,
    AuthResult,
    InvalidCredentialsError,
)
from core.config import settings

logger = logging.getLogger(__name__)

# Algoritmos de firma aceptados para los JWT de Supabase.
_ALLOWED_ALGS = {"HS256", "ES256", "RS256"}

# Cache de claves públicas del JWKS, indexada por ``kid``. Se refresca ante un
# ``kid`` desconocido (rotación de claves).
_JWKS_CACHE: dict[str, dict] = {}


def _jwks_url() -> str:
    return f"{settings.SUPABASE_URL.rstrip('/')}/auth/v1/.well-known/jwks.json"


def _fetch_jwks() -> dict[str, dict]:
    """Descarga el JWKS del proyecto y refresca el cache."""
    try:
        resp = httpx.get(_jwks_url(), timeout=10)
        resp.raise_for_status()
    except Exception as exc:  # red / proyecto mal configurado
        logger.error("[AUTH] No se pudo obtener el JWKS de Supabase: %s", exc)
        raise AuthProviderError(
            "No se pudieron obtener las claves públicas de Supabase (JWKS)"
        ) from exc

    keys = {k["kid"]: k for k in resp.json().get("keys", []) if k.get("kid")}
    _JWKS_CACHE.clear()
    _JWKS_CACHE.update(keys)
    return _JWKS_CACHE


def _get_signing_key(kid: str) -> dict:
    if kid in _JWKS_CACHE:
        return _JWKS_CACHE[kid]
    keys = _fetch_jwks()
    if kid not in keys:
        raise AuthProviderError(
            "No se encontró la clave de firma del token (kid desconocido)"
        )
    return keys[kid]


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

    async def sign_in(self, email: str, password: str) -> AuthResult:
        return await anyio.to_thread.run_sync(self._sign_in_sync, email, password)

    def _sign_in_sync(self, email: str, password: str) -> AuthResult:
        client = _get_admin_client()
        try:
            session = client.auth.sign_in_with_password(
                {"email": email, "password": password}
            )
        except AuthProviderError:
            raise
        except Exception as exc:  # credenciales inválidas / red / API de Supabase
            logger.warning("[AUTH] Supabase sign_in falló para %s: %s", email, exc)
            raise InvalidCredentialsError("Email o contraseña incorrectos") from exc

        if session is None or session.session is None or session.user is None:
            raise InvalidCredentialsError("Email o contraseña incorrectos")

        return AuthResult(
            user_id=UUID(str(session.user.id)),
            access_token=session.session.access_token,
        )

    def verify_token(self, token: str) -> dict:
        try:
            header = jwt.get_unverified_header(token)
        except JWTError as exc:
            raise AuthProviderError("Token inválido") from exc

        alg = header.get("alg", "")
        if alg not in _ALLOWED_ALGS:
            raise AuthProviderError(f"Algoritmo de firma no soportado: {alg}")

        if alg == "HS256":
            # Esquema legacy: secreto simétrico compartido.
            if not settings.SUPABASE_JWT_SECRET:
                raise AuthProviderError("SUPABASE_JWT_SECRET no configurado")
            key: object = settings.SUPABASE_JWT_SECRET
        else:
            # Esquema actual: clave pública del JWKS según el ``kid`` del token.
            kid = header.get("kid")
            if not kid:
                raise AuthProviderError("Token sin 'kid' en el encabezado")
            key = _get_signing_key(kid)

        try:
            return jwt.decode(
                token,
                key,
                algorithms=[alg],
                audience="authenticated",
            )
        except JWTError as exc:
            raise AuthProviderError("Token inválido o expirado") from exc
