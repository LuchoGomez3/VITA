"""Endpoints del módulo movimientos entre lotes."""

from datetime import datetime
from uuid import UUID

from fastapi import APIRouter, Depends, Query, status
from sqlalchemy.ext.asyncio import AsyncSession

from api.auth.dependencies import get_current_user
from api.modules.movimientos.schemas import MovimientoLoteCreate
from api.modules.movimientos.service import MovimientoLoteService
from api.modules.usuarios.models import Usuario
from api.shared.schemas import StandardResponse
from database.database import get_session

router = APIRouter(prefix="/v1/movimientos_lotes", tags=["movimientos_lotes"])


@router.post("", response_model=StandardResponse, status_code=status.HTTP_201_CREATED)
async def crear_movimiento(
    data: MovimientoLoteCreate,
    session: AsyncSession = Depends(get_session),
    current_user: Usuario = Depends(get_current_user),
):
    """Mueve un conjunto de animales entre lotes en una sola operación atómica.

    Idempotente por el UUID del cliente: reproducir el mismo movimiento devuelve
    el registro persistido sin volver a mover a nadie.
    """
    service = MovimientoLoteService(session)
    movimiento = await service.crear(current_user, data)
    return StandardResponse(success=True, data=movimiento.model_dump())


@router.get("", response_model=StandardResponse)
async def listar_movimientos(
    establecimiento_id: UUID = Query(...),
    updated_since: datetime | None = Query(
        default=None,
        description="Pull delta: devuelve solo lo modificado desde este instante.",
    ),
    include_deleted: bool = Query(
        default=False,
        description="Incluye soft-deleted para propagar borrados al cliente offline.",
    ),
    session: AsyncSession = Depends(get_session),
    current_user: Usuario = Depends(get_current_user),
):
    """Historial de movimientos del establecimiento (UI y descarga delta)."""
    service = MovimientoLoteService(session)
    movimientos = await service.listar(
        current_user,
        establecimiento_id,
        updated_since=updated_since,
        include_deleted=include_deleted,
    )
    return StandardResponse(success=True, data=[m.model_dump() for m in movimientos])
