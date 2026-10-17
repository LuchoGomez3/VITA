"""Endpoints del equipo de un establecimiento (adr-0012).

Todos son online-only: invitar necesita mandar el email y canjear necesita que
el servidor valide el código. La lista del equipo la cachea la app.
"""

from uuid import UUID

from fastapi import APIRouter, Depends, Response, status
from sqlalchemy.ext.asyncio import AsyncSession

from api.auth.dependencies import get_current_user
from api.modules.equipo.schemas import CodigoInvitacion, InvitacionCreate
from api.modules.equipo.service import EquipoService
from api.modules.usuarios.models import Usuario
from api.shared.schemas import StandardResponse
from core.auth_rate_limit import auth_rate_limiter
from core.config import settings
from core.email import EmailSender, get_email_sender
from database.database import get_session

router = APIRouter(prefix="/v1", tags=["equipo"])


async def limitar_intentos_de_codigo(
    current_user: Usuario = Depends(get_current_user),
) -> None:
    """Frena a quien prueba códigos al azar: el límite sigue al usuario."""
    await auth_rate_limiter.check_key(
        f"invitacion_codigo:{current_user.id}",
        limit=settings.INVITACION_CODIGO_RATE_LIMIT,
        window_seconds=settings.INVITACION_CODIGO_RATE_WINDOW_SECONDS,
    )


@router.get(
    "/establecimientos/{establecimiento_id}/usuarios",
    response_model=StandardResponse,
)
async def listar_usuarios(
    establecimiento_id: UUID,
    session: AsyncSession = Depends(get_session),
    current_user: Usuario = Depends(get_current_user),
):
    """Miembros activos del equipo, visibles para cualquier miembro."""
    miembros = await EquipoService(session).listar_miembros(
        current_user, establecimiento_id
    )
    return StandardResponse(success=True, data=[m.model_dump() for m in miembros])


@router.delete(
    "/establecimientos/{establecimiento_id}/usuarios/{usuario_id}",
    status_code=status.HTTP_204_NO_CONTENT,
)
async def quitar_usuario(
    establecimiento_id: UUID,
    usuario_id: UUID,
    session: AsyncSession = Depends(get_session),
    current_user: Usuario = Depends(get_current_user),
):
    """Quita a una persona del equipo (su membresía pasa a inactiva)."""
    await EquipoService(session).quitar_miembro(
        current_user, establecimiento_id, usuario_id
    )
    return Response(status_code=status.HTTP_204_NO_CONTENT)


@router.get(
    "/establecimientos/{establecimiento_id}/invitaciones",
    response_model=StandardResponse,
)
async def listar_invitaciones(
    establecimiento_id: UUID,
    session: AsyncSession = Depends(get_session),
    current_user: Usuario = Depends(get_current_user),
):
    """Invitaciones pendientes, incluidas las vencidas (``vencida=true``)."""
    invitaciones = await EquipoService(session).listar_invitaciones(
        current_user, establecimiento_id
    )
    return StandardResponse(success=True, data=[i.model_dump() for i in invitaciones])


@router.post(
    "/establecimientos/{establecimiento_id}/invitaciones",
    response_model=StandardResponse,
    status_code=status.HTTP_201_CREATED,
)
async def invitar(
    establecimiento_id: UUID,
    data: InvitacionCreate,
    session: AsyncSession = Depends(get_session),
    current_user: Usuario = Depends(get_current_user),
    email_sender: EmailSender = Depends(get_email_sender),
):
    """Invita por email con un rol. ``email_enviado=false`` si el envío falló."""
    invitacion = await EquipoService(session, email_sender=email_sender).invitar(
        current_user, establecimiento_id, data
    )
    return StandardResponse(success=True, data=invitacion.model_dump())


@router.post(
    "/establecimientos/{establecimiento_id}/invitaciones/{invitacion_id}/reenvios",
    response_model=StandardResponse,
)
async def reenviar_invitacion(
    establecimiento_id: UUID,
    invitacion_id: UUID,
    session: AsyncSession = Depends(get_session),
    current_user: Usuario = Depends(get_current_user),
    email_sender: EmailSender = Depends(get_email_sender),
):
    """Genera un código nuevo (el anterior deja de servir) y lo reenvía."""
    invitacion = await EquipoService(session, email_sender=email_sender).reenviar(
        current_user, establecimiento_id, invitacion_id
    )
    return StandardResponse(success=True, data=invitacion.model_dump())


@router.delete(
    "/establecimientos/{establecimiento_id}/invitaciones/{invitacion_id}",
    status_code=status.HTTP_204_NO_CONTENT,
)
async def cancelar_invitacion(
    establecimiento_id: UUID,
    invitacion_id: UUID,
    session: AsyncSession = Depends(get_session),
    current_user: Usuario = Depends(get_current_user),
):
    """Cancela una invitación pendiente: su código deja de servir."""
    await EquipoService(session).cancelar(
        current_user, establecimiento_id, invitacion_id
    )
    return Response(status_code=status.HTTP_204_NO_CONTENT)


@router.post(
    "/invitaciones/validaciones",
    response_model=StandardResponse,
    dependencies=[Depends(limitar_intentos_de_codigo)],
)
async def validar_codigo(
    data: CodigoInvitacion,
    session: AsyncSession = Depends(get_session),
    current_user: Usuario = Depends(get_current_user),
):
    """Muestra a qué campo y con qué rol se suma, sin consumir el código."""
    previa = await EquipoService(session).previsualizar(current_user, data.codigo)
    return StandardResponse(success=True, data=previa.model_dump())


@router.post(
    "/invitaciones/aceptaciones",
    response_model=StandardResponse,
    status_code=status.HTTP_201_CREATED,
    dependencies=[Depends(limitar_intentos_de_codigo)],
)
async def aceptar_invitacion(
    data: CodigoInvitacion,
    session: AsyncSession = Depends(get_session),
    current_user: Usuario = Depends(get_current_user),
):
    """Canjea el código: crea la membresía y devuelve el campo con el rol."""
    establecimiento = await EquipoService(session).aceptar(current_user, data.codigo)
    return StandardResponse(success=True, data=establecimiento.model_dump())
