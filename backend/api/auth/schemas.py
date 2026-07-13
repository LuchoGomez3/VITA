"""DTOs de autenticación.

El login usa ``OAuth2PasswordRequestForm`` (no necesita schema de entrada). Acá
viven la respuesta de sesión (con ``refresh_token`` para el ciclo offline-first)
y el body del refresh.
"""

from uuid import UUID

from pydantic import BaseModel


class UsuarioSesion(BaseModel):
    """Datos mínimos del perfil que el cliente cachea junto con la sesión."""

    id: UUID
    nombre: str
    apellido: str
    email: str


class TokenResponse(BaseModel):
    """Sesión devuelta por ``/auth/login`` y ``/auth/refresh``.

    ``refresh_token`` permite renovar el ``access_token`` (corto) sin pedir la
    contraseña; ``expires_in`` (segundos) le dice al cliente cuándo renovar.
    """

    access_token: str
    refresh_token: str | None = None
    expires_in: int | None = None
    token_type: str = "bearer"
    usuario: UsuarioSesion


class RefreshRequest(BaseModel):
    """Body de ``/auth/refresh``."""

    refresh_token: str
