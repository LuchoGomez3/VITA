"""Endpoints del módulo usuarios."""

from fastapi import APIRouter, Depends, status
from sqlalchemy.ext.asyncio import AsyncSession

from api.auth.providers import AuthProvider, get_auth_provider
from api.modules.usuarios.schemas import UsuarioRegistroCreate
from api.modules.usuarios.service import UsuarioService
from api.shared.schemas import StandardResponse
from database.database import get_session

router = APIRouter(prefix="/v1/usuarios", tags=["usuarios"])


@router.post(
    "/registro",
    response_model=StandardResponse,
    status_code=status.HTTP_201_CREATED,
)
async def registrar_usuario(
    data: UsuarioRegistroCreate,
    session: AsyncSession = Depends(get_session),
    auth_provider: AuthProvider = Depends(get_auth_provider),
):
    """Registra un dueño de campo (endpoint público; requiere conexión).

    Crea las credenciales en el proveedor de identidad y el perfil en
    ``usuarios``; devuelve el perfil y una sesión completa (access + refresh +
    expiración), igual que ``/auth/login``, para que el cliente pueda seguir
    operando (p. ej. registrar su establecimiento) sin pedir login aparte.
    """
    service = UsuarioService(session, auth_provider)
    usuario, auth_result = await service.registrar(data)
    return StandardResponse(
        success=True,
        data={
            "usuario": usuario.model_dump(),
            "access_token": auth_result.access_token,
            "refresh_token": auth_result.refresh_token,
            "expires_in": auth_result.expires_in,
            "token_type": "bearer",
        },
    )
