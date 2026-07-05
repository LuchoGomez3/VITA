"""Endpoints del módulo establecimientos."""

from uuid import UUID

from fastapi import APIRouter, Depends, status
from sqlalchemy.ext.asyncio import AsyncSession

from api.auth.dependencies import get_current_user
from api.modules.establecimientos.schemas import EstablecimientoCreate
from api.modules.establecimientos.service import EstablecimientoService
from api.modules.usuarios.models import Usuario
from api.shared.schemas import StandardResponse
from database.database import get_session

router = APIRouter(prefix="/v1/establecimientos", tags=["establecimientos"])


@router.post(
    "",
    response_model=StandardResponse,
    status_code=status.HTTP_201_CREATED,
)
async def crear_establecimiento(
    data: EstablecimientoCreate,
    session: AsyncSession = Depends(get_session),
    current_user: Usuario = Depends(get_current_user),
):
    """Registra un establecimiento y deja al usuario vinculado como owner."""
    service = EstablecimientoService(session)
    establecimiento = await service.crear(current_user, data)
    return StandardResponse(success=True, data=establecimiento.model_dump())


@router.get("", response_model=StandardResponse)
async def listar_establecimientos(
    session: AsyncSession = Depends(get_session),
    current_user: Usuario = Depends(get_current_user),
):
    """Lista los establecimientos a los que el usuario autenticado tiene acceso."""
    service = EstablecimientoService(session)
    establecimientos = await service.listar(current_user)
    return StandardResponse(
        success=True,
        data=[e.model_dump() for e in establecimientos],
    )


@router.get("/{establecimiento_id}", response_model=StandardResponse)
async def detalle_establecimiento(
    establecimiento_id: UUID,
    session: AsyncSession = Depends(get_session),
    current_user: Usuario = Depends(get_current_user),
):
    """Detalle de un establecimiento (incluye auditoría owner_id + created_at)."""
    service = EstablecimientoService(session)
    establecimiento = await service.detalle(current_user, establecimiento_id)
    return StandardResponse(success=True, data=establecimiento.model_dump())
