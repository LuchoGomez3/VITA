"""Interfaz de proveedor de autenticación.

Abstrae el alta de credenciales y la validación de tokens para que el resto del
backend no dependa de Supabase directamente. Hay dos adaptadores:

- ``LocalAuthProvider``: emite/valida JWT con ``JWT_SECRET`` (desarrollo/test).
- ``SupabaseAuthProvider``: delega en Supabase Auth (entornos reales).
"""

from abc import ABC, abstractmethod
from dataclasses import dataclass
from uuid import UUID

from api.shared.exceptions import DomainException


class AuthProviderError(DomainException):
    """Falla al hablar con el proveedor de identidad (alta o validación)."""

    status_code = 502
    code = "auth_provider_error"


class InvalidCredentialsError(DomainException):
    """Email o contraseña incorrectos al iniciar sesión."""

    status_code = 401
    code = "invalid_credentials"


class IdentityAlreadyExistsError(DomainException):
    """La identidad ya existe sin revelar qué dato produjo el conflicto."""

    status_code = 409
    code = "usuario_ya_registrado"

    def __init__(self) -> None:
        super().__init__(
            "El CUIT o correo ingresado ya se encuentran asociados a una cuenta activa. "
            "Por favor, iniciá sesión."
        )


@dataclass(frozen=True)
class AuthResult:
    """Resultado de una operación de sesión (alta, login o refresh).

    ``refresh_token`` y ``expires_in`` son la clave del offline-first: el cliente
    los guarda para renovar el ``access_token`` (que vive poco) sin pedir la
    contraseña de nuevo cuando recupera conexión. Son opcionales para no romper
    proveedores que no los expongan.
    """

    user_id: UUID
    access_token: str
    refresh_token: str | None = None
    expires_in: int | None = None


class AuthProvider(ABC):
    @abstractmethod
    async def sign_up(self, email: str, password: str) -> AuthResult:
        """Crea las credenciales y devuelve el id del usuario y un token de sesión.

        Lanza ``AuthProviderError`` si el proveedor rechaza el alta.
        """
        raise NotImplementedError

    @abstractmethod
    async def sign_in(self, email: str, password: str) -> AuthResult:
        """Valida credenciales y devuelve el id del usuario y un token de sesión.

        Lanza ``InvalidCredentialsError`` si email/contraseña son incorrectos y
        ``AuthProviderError`` ante fallos de red o del proveedor.
        """
        raise NotImplementedError

    @abstractmethod
    async def refresh(self, refresh_token: str) -> AuthResult:
        """Renueva la sesión a partir de un ``refresh_token``.

        Devuelve un nuevo ``AuthResult`` (access + refresh rotado + expiración).
        Lanza ``InvalidCredentialsError`` si el refresh venció o fue revocado y
        ``AuthProviderError`` ante fallos de red o del proveedor.
        """
        raise NotImplementedError

    @abstractmethod
    async def delete_user(self, user_id: UUID) -> None:
        """Elimina credenciales creadas que no pudieron asociarse a un perfil."""
        raise NotImplementedError

    @abstractmethod
    async def sign_out(self, access_token: str) -> None:
        """Revoca remotamente la sesión identificada por el access token."""
        raise NotImplementedError

    @abstractmethod
    def verify_token(self, token: str) -> dict:
        """Valida el token y devuelve los claims (debe incluir ``sub``).

        Lanza ``AuthProviderError`` si el token es inválido o expiró.
        """
        raise NotImplementedError
