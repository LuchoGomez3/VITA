from fastapi import APIRouter, Depends
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.ext.asyncio import AsyncSession

from api.auth.dependencies import get_bearer_token, get_current_user
from api.auth.providers import AuthProvider, AuthResult, get_auth_provider
from api.auth.schemas import RefreshRequest, TokenResponse, UsuarioSesion
from api.auth.service import AuthService
from api.modules.usuarios.models import Usuario
from api.shared.schemas import StandardResponse
from database.database import get_session
from core.auth_rate_limit import limit_login, limit_refresh

router = APIRouter(prefix="/auth", tags=["auth"])


def _token_response(usuario: Usuario, auth_result: AuthResult) -> TokenResponse:
    return TokenResponse(
        access_token=auth_result.access_token,
        refresh_token=auth_result.refresh_token,
        expires_in=auth_result.expires_in,
        usuario=UsuarioSesion(
            id=usuario.id,
            nombre=usuario.nombre,
            apellido=usuario.apellido,
            email=usuario.email,
            cuit=usuario.cuit,
        ),
    )


@router.post(
    "/login",
    response_model=StandardResponse,
    dependencies=[Depends(limit_login)],
)
async def login(
    form_data: OAuth2PasswordRequestForm = Depends(),
    session: AsyncSession = Depends(get_session),
    auth_provider: AuthProvider = Depends(get_auth_provider),
):
    """Inicia sesión contra el proveedor configurado y devuelve la sesión.

    ``username`` se interpreta como el email del usuario. Devuelve
    ``access_token`` (para autenticar el resto de los endpoints) y
    ``refresh_token`` + ``expires_in``, que el cliente cachea para renovar la
    sesión offline-first sin volver a pedir la contraseña.
    """
    service = AuthService(session, auth_provider)
    usuario, auth_result = await service.login(form_data.username, form_data.password)
    return StandardResponse(
        success=True,
        data=_token_response(usuario, auth_result).model_dump(mode="json"),
    )


@router.post(
    "/refresh",
    response_model=StandardResponse,
    dependencies=[Depends(limit_refresh)],
)
async def refresh(
    body: RefreshRequest,
    session: AsyncSession = Depends(get_session),
    auth_provider: AuthProvider = Depends(get_auth_provider),
):
    """Renueva la sesión a partir de un ``refresh_token``.

    El cliente lo llama al recuperar conexión (antes de drenar la cola offline)
    para obtener un ``access_token`` fresco. Un refresh vencido/revocado devuelve
    401 y el cliente debe pedir re-login.
    """
    service = AuthService(session, auth_provider)
    usuario, auth_result = await service.refresh(body.refresh_token)
    return StandardResponse(
        success=True,
        data=_token_response(usuario, auth_result).model_dump(mode="json"),
    )


@router.get("/me", response_model=StandardResponse)
async def me(current_user: Usuario = Depends(get_current_user)):
    return StandardResponse(
        success=True,
        data={
            "id": str(current_user.id),
            "nombre": current_user.nombre,
            "apellido": current_user.apellido,
            "email": current_user.email,
            "cuit": current_user.cuit,
        },
    )


@router.post("/logout", response_model=StandardResponse)
async def logout(
    token: str = Depends(get_bearer_token),
    current_user: Usuario = Depends(get_current_user),
    auth_provider: AuthProvider = Depends(get_auth_provider),
):
    """Revoca la sesión remota del usuario autenticado."""
    await auth_provider.sign_out(token)
    return StandardResponse(success=True, data={"user_id": str(current_user.id)})
