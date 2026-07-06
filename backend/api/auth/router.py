from fastapi import APIRouter, Depends
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.ext.asyncio import AsyncSession

from api.auth.dependencies import get_current_user
from api.auth.providers import AuthProvider, get_auth_provider
from api.auth.service import AuthService
from api.modules.usuarios.models import Usuario
from api.shared.schemas import StandardResponse
from database.database import get_session

router = APIRouter(prefix="/auth", tags=["auth"])


@router.post("/login", response_model=StandardResponse)
async def login(
    form_data: OAuth2PasswordRequestForm = Depends(),
    session: AsyncSession = Depends(get_session),
    auth_provider: AuthProvider = Depends(get_auth_provider),
):
    """Inicia sesión contra el proveedor configurado y devuelve un token válido.

    ``username`` se interpreta como el email del usuario. El token devuelto sirve
    para autenticar el resto de los endpoints (incluido el botón *Authorize*).
    """
    service = AuthService(session, auth_provider)
    usuario, access_token = await service.login(form_data.username, form_data.password)
    return StandardResponse(
        success=True,
        data={
            "access_token": access_token,
            "token_type": "bearer",
            "usuario": {
                "id": str(usuario.id),
                "nombre": usuario.nombre,
                "apellido": usuario.apellido,
                "email": usuario.email,
            },
        },
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
        },
    )
