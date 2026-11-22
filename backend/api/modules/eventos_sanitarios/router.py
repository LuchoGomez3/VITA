"""Endpoints de Sanidad (VITA-20): catálogo, alta por grupo, resultado e historial."""

from uuid import UUID

from fastapi import APIRouter, Depends, Query, status
from sqlalchemy.ext.asyncio import AsyncSession

from api.auth.dependencies import get_current_user
from api.modules.eventos_sanitarios.schemas import AltaSanitaria, ResultadoSanitario
from api.modules.eventos_sanitarios.service import EventoSanitarioService
from api.modules.eventos_sanitarios.validacion import RutaSanitaria
from api.modules.usuarios.models import Usuario
from api.shared.schemas import StandardResponse
from database.database import get_session

router = APIRouter(
    prefix="/v1/eventos_sanitarios",
    tags=["eventos_sanitarios"],
    route_class=RutaSanitaria,
)


@router.get("/catalogo", response_model=StandardResponse)
async def catalogo(
    establecimiento_id: UUID = Query(...),
    session: AsyncSession = Depends(get_session),
    current_user: Usuario = Depends(get_current_user),
):
    """Prácticas y productos vigentes del establecimiento, para usar sin señal."""
    data = await EventoSanitarioService(session).catalogo(
        current_user, establecimiento_id
    )
    return StandardResponse(success=True, data=data)


@router.post("", response_model=StandardResponse, status_code=status.HTTP_201_CREATED)
async def registrar(
    data: AltaSanitaria,
    session: AsyncSession = Depends(get_session),
    current_user: Usuario = Depends(get_current_user),
):
    """Registra una práctica sobre un grupo de animales (un evento por animal).

    Idempotente por el ``id`` de la operación: un reenvío idéntico devuelve los
    mismos eventos con su estado vigente.
    """
    eventos = await EventoSanitarioService(session).registrar(current_user, data)
    return StandardResponse(success=True, data=eventos)


@router.put("/{evento_id}/resultado", response_model=StandardResponse)
async def registrar_resultado(
    evento_id: UUID,
    data: ResultadoSanitario,
    session: AsyncSession = Depends(get_session),
    current_user: Usuario = Depends(get_current_user),
):
    """Informa el primer resultado de un estudio. Otro resultado ya guardado es 409."""
    evento = await EventoSanitarioService(session).registrar_resultado(
        current_user, evento_id, data
    )
    return StandardResponse(success=True, data=evento)


@router.get("", response_model=StandardResponse)
async def historial(
    establecimiento_id: UUID = Query(...),
    cursor: str | None = Query(
        default=None, description="``next_cursor`` de la página anterior."
    ),
    session: AsyncSession = Depends(get_session),
    current_user: Usuario = Depends(get_current_user),
):
    """Cambios del historial sanitario en orden de confirmación, de a páginas."""
    eventos, meta = await EventoSanitarioService(session).historial(
        current_user, establecimiento_id, cursor
    )
    return StandardResponse(success=True, data=eventos, meta=meta)
