"""Proveedor de auth local: emite y valida JWT con ``JWT_SECRET``.

Pensado para desarrollo y tests: no requiere red ni Supabase. Genera un UUID
para el usuario (que se usa como ``id`` del perfil en ``usuarios``) y un JWT
firmado localmente con ``sub`` = ese UUID.
"""

from datetime import datetime, timedelta, timezone
from uuid import UUID, uuid4

from jose import JWTError, jwt

from api.auth.providers.base import AuthProvider, AuthProviderError, AuthResult
from core.config import settings


class LocalAuthProvider(AuthProvider):
    async def sign_up(self, email: str, password: str) -> AuthResult:
        user_id = uuid4()
        token = self._create_token(str(user_id))
        return AuthResult(user_id=user_id, access_token=token)

    def verify_token(self, token: str) -> dict:
        try:
            return jwt.decode(
                token,
                settings.JWT_SECRET,
                algorithms=[settings.JWT_ALGORITHM],
            )
        except JWTError as exc:
            raise AuthProviderError("Token inválido o expirado") from exc

    def _create_token(self, sub: str) -> str:
        expire = datetime.now(timezone.utc) + timedelta(
            minutes=settings.JWT_ACCESS_TOKEN_EXPIRE_MINUTES
        )
        return jwt.encode(
            {"sub": sub, "exp": expire},
            settings.JWT_SECRET,
            algorithm=settings.JWT_ALGORITHM,
        )

    def create_token_for(self, user_id: UUID) -> str:
        """Helper para tests/seed: emite un token para un usuario existente."""
        return self._create_token(str(user_id))
