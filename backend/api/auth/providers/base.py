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


@dataclass(frozen=True)
class AuthResult:
    """Resultado del alta de credenciales."""

    user_id: UUID
    access_token: str


class AuthProvider(ABC):
    @abstractmethod
    async def sign_up(self, email: str, password: str) -> AuthResult:
        """Crea las credenciales y devuelve el id del usuario y un token de sesión.

        Lanza ``AuthProviderError`` si el proveedor rechaza el alta.
        """
        raise NotImplementedError

    @abstractmethod
    def verify_token(self, token: str) -> dict:
        """Valida el token y devuelve los claims (debe incluir ``sub``).

        Lanza ``AuthProviderError`` si el token es inválido o expiró.
        """
        raise NotImplementedError
