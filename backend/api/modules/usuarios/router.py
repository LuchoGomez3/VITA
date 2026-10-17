"""Endpoints del módulo usuarios."""

from fastapi import APIRouter, Depends, File, Header, Response, UploadFile, status
from sqlalchemy.ext.asyncio import AsyncSession

from api.auth.dependencies import get_current_user
from api.auth.providers import AuthProvider, get_auth_provider
from api.modules.usuarios.avatar import validar_tamanio_declarado
from api.modules.usuarios.models import Usuario
from api.modules.usuarios.schemas import UsuarioPerfilUpdate, UsuarioRegistroCreate
from api.modules.usuarios.service import PerfilUsuarioService, UsuarioService
from api.shared.schemas import StandardResponse
from core.storage import ObjectStorage, get_storage_avatares
from database.database import get_session
from core.auth_rate_limit import limit_registration

router = APIRouter(prefix="/v1/usuarios", tags=["usuarios"])


@router.post(
    "/registro",
    response_model=StandardResponse,
    status_code=status.HTTP_201_CREATED,
    dependencies=[Depends(limit_registration)],
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


def _perfil_service(
    session: AsyncSession = Depends(get_session),
    storage: ObjectStorage = Depends(get_storage_avatares),
) -> PerfilUsuarioService:
    return PerfilUsuarioService(session, storage)


@router.patch("/me", response_model=StandardResponse)
async def actualizar_mi_perfil(
    data: UsuarioPerfilUpdate,
    current_user: Usuario = Depends(get_current_user),
    service: PerfilUsuarioService = Depends(_perfil_service),
):
    """Cambia el color de la cabecera de Perfil (``null`` = verde por defecto)."""
    perfil = await service.actualizar(current_user.id, data)
    return StandardResponse(success=True, data=perfil.model_dump(mode="json"))


@router.put("/me/avatar", response_model=StandardResponse)
async def subir_mi_avatar(
    archivo: UploadFile = File(...),
    content_length: int | None = Header(default=None),
    current_user: Usuario = Depends(get_current_user),
    service: PerfilUsuarioService = Depends(_perfil_service),
):
    """Reemplaza la foto de perfil (JPEG, PNG o WebP). Requiere conexión.

    El backend la recorta a un cuadrado de 512 px, la pasa a JPEG sin metadatos
    y la guarda con una clave fija por usuario, así que nunca hay más de una.
    """
    validar_tamanio_declarado(content_length)
    perfil = await service.subir_avatar(current_user.id, await archivo.read())
    return StandardResponse(success=True, data=perfil.model_dump(mode="json"))


@router.get(
    "/me/avatar",
    response_class=Response,
    responses={200: {"content": {"image/jpeg": {}}}},
)
async def descargar_mi_avatar(
    current_user: Usuario = Depends(get_current_user),
    service: PerfilUsuarioService = Depends(_perfil_service),
):
    """Devuelve los bytes de la foto (el bucket es privado).

    No usa ``StandardResponse``: es un binario, y envolverlo en JSON obligaría a
    pasarlo a base64 (+33 % de egress). Los errores sí salen como
    ``StandardResponse`` (404 ``avatar_no_encontrado``).
    """
    foto = await service.descargar_avatar(current_user.id)
    # ``private``: es la foto de una persona, ningún proxy compartido la guarda.
    # El cliente decide cuándo volver a bajarla con ``avatar_actualizado_en``.
    return Response(
        content=foto,
        media_type="image/jpeg",
        headers={"Cache-Control": "private, max-age=86400"},
    )


@router.delete("/me/avatar", response_model=StandardResponse)
async def borrar_mi_avatar(
    current_user: Usuario = Depends(get_current_user),
    service: PerfilUsuarioService = Depends(_perfil_service),
):
    """Quita la foto de perfil. Sin foto previa no hace nada."""
    perfil = await service.borrar_avatar(current_user.id)
    return StandardResponse(success=True, data=perfil.model_dump(mode="json"))
