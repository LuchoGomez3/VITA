"""Proveedor de auth local: emite y valida JWT con ``JWT_SECRET``.

Pensado para desarrollo y tests: no requiere red ni Supabase. Genera un UUID
para el usuario (que se usa como ``id`` del perfil en ``usuarios``) y un JWT
firmado localmente con ``sub`` = ese UUID.
"""

from datetime import datetime, timedelta, timezone
from uuid import UUID, uuid4

from jose import JWTError, jwt

from api.auth.providers.base import (
    AuthProvider,
    AuthProviderError,
    AuthResult,
    InvalidCredentialsError,
)
from core.config import settings


class LocalAuthProvider(AuthProvider):
    async def sign_up(self, email: str, password: str) -> AuthResult:
        user_id = uuid4()
        token = self._create_token(str(user_id))
        return AuthResult(
            user_id=user_id,
            access_token=token,
            refresh_token=self._create_refresh_token(str(user_id)),
            expires_in=settings.JWT_ACCESS_TOKEN_EXPIRE_MINUTES * 60,
        )

    async def sign_in(self, email: str, password: str) -> AuthResult:
        # El proveedor local no guarda contraseñas ni puede recuperar el UUID del
        # perfil a partir del email (el alta genera un UUID aleatorio). Para
        # desarrollo/test, obtené un token con ``/registro`` o ``create_token_for``.
        raise InvalidCredentialsError(
            "El login por contraseña no está disponible con AUTH_PROVIDER=local; "
            "usá /api/v1/usuarios/registro para obtener un token de sesión."
        )

    async def refresh(self, refresh_token: str) -> AuthResult:
        try:
            claims = jwt.decode(
                refresh_token,
                settings.JWT_SECRET,
                algorithms=[settings.JWT_ALGORITHM],
            )
        except JWTError as exc:
            raise InvalidCredentialsError("Refresh token inválido o expirado") from exc

        if claims.get("typ") != "refresh":
            raise InvalidCredentialsError("El token provisto no es un refresh token")

        sub = str(claims.get("sub", ""))
        if not sub:
            raise InvalidCredentialsError("Refresh token sin 'sub'")

        return AuthResult(
            user_id=UUID(sub),
            access_token=self._create_token(sub),
            refresh_token=self._create_refresh_token(sub),
            expires_in=settings.JWT_ACCESS_TOKEN_EXPIRE_MINUTES * 60,
        )

    async def delete_user(self, user_id: UUID) -> None:
        """No requiere limpieza: el proveedor local no persiste credenciales."""

    async def sign_out(self, access_token: str) -> None:
        """No persiste sesiones; el cierre local del cliente es suficiente."""

    def verify_token(self, token: str) -> dict:
        try:
            claims = jwt.decode(
                token,
                settings.JWT_SECRET,
                algorithms=[settings.JWT_ALGORITHM],
            )
        except JWTError as exc:
            raise AuthProviderError("Token inválido o expirado") from exc
        if claims.get("typ") == "refresh":
            raise AuthProviderError("Un refresh token no puede autenticar requests")
        return claims

    def _create_token(self, sub: str) -> str:
        expire = datetime.now(timezone.utc) + timedelta(
            minutes=settings.JWT_ACCESS_TOKEN_EXPIRE_MINUTES
        )
        return jwt.encode(
            {"sub": sub, "exp": expire},
            settings.JWT_SECRET,
            algorithm=settings.JWT_ALGORITHM,
        )

    def _create_refresh_token(self, sub: str) -> str:
        # El refresh vive mucho más que el access: en el campo el dispositivo puede
        # estar días sin conexión antes de poder renovar la sesión.
        expire = datetime.now(timezone.utc) + timedelta(days=30)
        return jwt.encode(
            {"sub": sub, "exp": expire, "typ": "refresh"},
            settings.JWT_SECRET,
            algorithm=settings.JWT_ALGORITHM,
        )

    def create_token_for(self, user_id: UUID) -> str:
        """Helper para tests/seed: emite un token para un usuario existente."""
        return self._create_token(str(user_id))

    def create_refresh_token_for(self, user_id: UUID) -> str:
        """Helper para tests/seed: emite un refresh token para un usuario."""
        return self._create_refresh_token(str(user_id))
