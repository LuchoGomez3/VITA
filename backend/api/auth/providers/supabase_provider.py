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
    IdentityAlreadyExistsError,
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


def _result_from_session(user_id: UUID, session) -> AuthResult:
    """Construye un ``AuthResult`` a partir de la sesión de Supabase (gotrue).

    Incluye ``refresh_token`` y ``expires_in`` para que el cliente pueda renovar
    la sesión offline-first sin volver a pedir la contraseña.
    """
    return AuthResult(
        user_id=user_id,
        access_token=session.access_token,
        refresh_token=getattr(session, "refresh_token", None),
        expires_in=getattr(session, "expires_in", None),
    )


@lru_cache(maxsize=1)
def _get_admin_client():
    """Cliente Supabase con la service-role key (operaciones admin)."""
    from supabase import create_client

    if not settings.SUPABASE_URL or not settings.SUPABASE_SERVICE_ROLE_KEY:
        raise AuthProviderError(
            "Supabase no está configurado (SUPABASE_URL / SUPABASE_SERVICE_ROLE_KEY)"
        )
    return create_client(settings.SUPABASE_URL, settings.SUPABASE_SERVICE_ROLE_KEY)


def _create_public_client():
    """Crea un cliente aislado para autenticar a un usuario final.

    No se cachea porque ``supabase-py`` conserva la sesion dentro del cliente.
    Compartirlo entre requests podria mezclar sesiones y nunca debe reemplazar
    la identidad del cliente administrativo.
    """
    from supabase import create_client

    if not settings.SUPABASE_URL or not settings.SUPABASE_ANON_KEY:
        raise AuthProviderError(
            "Supabase no está configurado (SUPABASE_URL / SUPABASE_ANON_KEY)"
        )
    return create_client(settings.SUPABASE_URL, settings.SUPABASE_ANON_KEY)


class SupabaseAuthProvider(AuthProvider):
    async def sign_up(self, email: str, password: str) -> AuthResult:
        return await anyio.to_thread.run_sync(self._sign_up_sync, email, password)

    def _sign_up_sync(self, email: str, password: str) -> AuthResult:
        admin_client = _get_admin_client()
        raw_user_id: str | None = None
        user_id: UUID | None = None
        try:
            created = admin_client.auth.admin.create_user(
                {"email": email, "password": password, "email_confirm": True}
            )
            user = getattr(created, "user", None) or created
            raw_user_id = str(user.id)
            try:
                user_id = UUID(raw_user_id)
            except ValueError as exc:
                raise AuthProviderError(
                    "Supabase devolvió un identificador de usuario inválido"
                ) from exc

            # Iniciar sesión para devolver un token de sesión al cliente.
            # Un cliente publico aislado evita reemplazar la service-role del
            # cliente administrativo con la sesion del usuario recien creado.
            session = _create_public_client().auth.sign_in_with_password(
                {"email": email, "password": password}
            )
            return _result_from_session(user_id, session.session)
        except Exception as exc:  # red / API de Supabase
            # raw_user_id se conserva antes del parseo para poder eliminar una
            # credencial que Supabase ya creó aunque devuelva un UUID malformado.
            if raw_user_id is not None:
                try:
                    admin_client.auth.admin.delete_user(raw_user_id)
                except Exception:
                    logger.exception(
                        "[AUTH] No se pudo compensar la credencial %s tras fallar sign_up",
                        raw_user_id,
                    )
            if isinstance(exc, AuthProviderError):
                raise
            if getattr(exc, "code", None) in {
                "email_exists",
                "identity_already_exists",
                "user_already_exists",
            }:
                raise IdentityAlreadyExistsError() from exc
            logger.error("[AUTH] Supabase sign_up falló: %s", exc, exc_info=True)
            raise AuthProviderError(
                "No se pudo crear el usuario en el proveedor de identidad"
            ) from exc

    async def sign_in(self, email: str, password: str) -> AuthResult:
        return await anyio.to_thread.run_sync(self._sign_in_sync, email, password)

    async def delete_user(self, user_id: UUID) -> None:
        """Elimina credenciales mediante el cliente administrativo aislado."""
        await anyio.to_thread.run_sync(self._delete_user_sync, user_id)

    def _delete_user_sync(self, user_id: UUID) -> None:
        try:
            _get_admin_client().auth.admin.delete_user(str(user_id))
        except Exception as exc:
            logger.error(
                "[AUTH] Supabase delete_user falló para %s: %s",
                user_id,
                exc,
                exc_info=True,
            )
            raise AuthProviderError(
                "No se pudo eliminar el usuario del proveedor de identidad"
            ) from exc

    async def sign_out(self, access_token: str) -> None:
        """Revoca en Supabase todas las sesiones del usuario autenticado."""
        await anyio.to_thread.run_sync(self._sign_out_sync, access_token)

    def _sign_out_sync(self, access_token: str) -> None:
        if not settings.SUPABASE_URL or not settings.SUPABASE_ANON_KEY:
            raise AuthProviderError(
                "Supabase no está configurado (SUPABASE_URL / SUPABASE_ANON_KEY)"
            )
        try:
            response = httpx.post(
                f"{settings.SUPABASE_URL.rstrip('/')}/auth/v1/logout?scope=global",
                headers={
                    "apikey": settings.SUPABASE_ANON_KEY,
                    "Authorization": f"Bearer {access_token}",
                },
                timeout=10,
            )
        except Exception as exc:
            logger.error("[AUTH] Supabase logout falló (red): %s", exc)
            raise AuthProviderError("No se pudo cerrar la sesión en Supabase") from exc
        if response.status_code >= 400:
            logger.error(
                "[AUTH] Supabase logout respondió %s: %s",
                response.status_code,
                response.text,
            )
            raise AuthProviderError("No se pudo cerrar la sesión en Supabase")

    def _sign_in_sync(self, email: str, password: str) -> AuthResult:
        client = _create_public_client()
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

        return _result_from_session(UUID(str(session.user.id)), session.session)

    async def refresh(self, refresh_token: str) -> AuthResult:
        return await anyio.to_thread.run_sync(self._refresh_sync, refresh_token)

    def _refresh_sync(self, refresh_token: str) -> AuthResult:
        # El refresh no necesita service-role: se hace contra el endpoint público
        # de GoTrue con la anon key. Devuelve un access nuevo y un refresh rotado.
        if not settings.SUPABASE_URL or not settings.SUPABASE_ANON_KEY:
            raise AuthProviderError(
                "Supabase no está configurado (SUPABASE_URL / SUPABASE_ANON_KEY)"
            )
        url = f"{settings.SUPABASE_URL.rstrip('/')}/auth/v1/token?grant_type=refresh_token"
        try:
            resp = httpx.post(
                url,
                headers={
                    "apikey": settings.SUPABASE_ANON_KEY,
                    "Content-Type": "application/json",
                },
                json={"refresh_token": refresh_token},
                timeout=10,
            )
        except Exception as exc:  # red / proyecto mal configurado
            logger.error("[AUTH] Supabase refresh falló (red): %s", exc)
            raise AuthProviderError(
                "No se pudo renovar la sesión con Supabase"
            ) from exc

        # 400/401 => refresh vencido o revocado: el cliente debe re-loguearse.
        if resp.status_code in (400, 401, 403):
            raise InvalidCredentialsError("Refresh token inválido o expirado")
        if resp.status_code >= 400:
            logger.error(
                "[AUTH] Supabase refresh respondió %s: %s", resp.status_code, resp.text
            )
            raise AuthProviderError("No se pudo renovar la sesión con Supabase")

        body = resp.json()
        user = body.get("user") or {}
        user_id = user.get("id")
        if not user_id:
            raise AuthProviderError("Respuesta de refresh sin usuario")

        return AuthResult(
            user_id=UUID(str(user_id)),
            access_token=body["access_token"],
            refresh_token=body.get("refresh_token"),
            expires_in=body.get("expires_in"),
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
                issuer=f"{settings.SUPABASE_URL.rstrip('/')}/auth/v1",
            )
        except JWTError as exc:
            raise AuthProviderError("Token inválido o expirado") from exc
