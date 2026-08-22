"""Dependencias de autenticación.

``get_current_user`` valida el token con el proveedor configurado, extrae el
``sub`` (UUID del usuario) y carga el perfil desde la tabla ``usuarios``.
Devuelve el modelo ``Usuario`` para que los módulos filtren multi-tenant por
``current_user.id``.
"""

from typing import Optional
from uuid import UUID

from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.ext.asyncio import AsyncSession

from api.auth.providers import AuthProvider, AuthProviderError, get_auth_provider
from api.modules.usuarios.models import Usuario
from api.modules.usuarios.repository import UsuarioRepository
from database.database import get_session

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/auth/login", auto_error=False)

_credentials_exception = HTTPException(
    status_code=status.HTTP_401_UNAUTHORIZED,
    detail="Could not validate credentials",
    headers={"WWW-Authenticate": "Bearer"},
)


async def get_current_user(
    token: Optional[str] = Depends(oauth2_scheme),
    session: AsyncSession = Depends(get_session),
    auth_provider: AuthProvider = Depends(get_auth_provider),
) -> Usuario:
    if not token:
        raise _credentials_exception

    try:
        claims = auth_provider.verify_token(token)
    except AuthProviderError as exc:
        raise _credentials_exception from exc

    sub = claims.get("sub")
    if not sub:
        raise _credentials_exception

    try:
        usuario_id = UUID(str(sub))
    except (ValueError, TypeError) as exc:
        raise _credentials_exception from exc

    usuario = await UsuarioRepository(session).get_by_id(usuario_id)
    if usuario is None:
        raise _credentials_exception
    return usuario
