"""Endpoints del historial de recursos forrajeros de los lotes."""

from datetime import datetime
from uuid import UUID

from fastapi import APIRouter, Depends, Query, status
from sqlalchemy.ext.asyncio import AsyncSession

from api.auth.dependencies import get_current_user
from api.modules.recursos_forrajeros.schemas import PeriodoRecursoForrajeroCreate
from api.modules.recursos_forrajeros.service import RecursoForrajeroService
from api.modules.usuarios.models import Usuario
from api.shared.schemas import StandardResponse
from database.database import get_session

# Ruta plana (no anidada bajo /lotes/{id}): la URL de upsert de Brick es estática.
router = APIRouter(prefix="/v1/lotes_recursos_forrajeros", tags=["lotes"])


@router.post("", response_model=StandardResponse, status_code=status.HTTP_201_CREATED)
async def crear_periodo_recurso(
    data: PeriodoRecursoForrajeroCreate,
    session: AsyncSession = Depends(get_session),
    current_user: Usuario = Depends(get_current_user),
):
    """Registra (o reproduce) un período de recurso forrajero de un lote."""
    periodo = await RecursoForrajeroService(session).crear(current_user, data)
    return StandardResponse(success=True, data=periodo.model_dump())


@router.get("", response_model=StandardResponse)
async def listar_periodos_recurso(
    establecimiento_id: UUID = Query(...),
    lote_id: UUID | None = Query(default=None),
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
    """Historial de recursos de los lotes del establecimiento (o de un lote)."""
    periodos = await RecursoForrajeroService(session).listar(
        current_user,
        establecimiento_id,
        lote_id=lote_id,
        updated_since=updated_since,
        include_deleted=include_deleted,
    )
    return StandardResponse(success=True, data=[p.model_dump() for p in periodos])
