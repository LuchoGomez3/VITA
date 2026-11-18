"""Endpoints del catálogo de alimentos."""

from datetime import datetime
from uuid import UUID

from fastapi import APIRouter, Depends, Query, status
from sqlalchemy.ext.asyncio import AsyncSession

from api.auth.dependencies import get_current_user
from api.modules.alimentos.schemas import AlimentoCreate
from api.modules.alimentos.service import AlimentoService
from api.modules.usuarios.models import Usuario
from api.shared.schemas import StandardResponse
from database.database import get_session

router = APIRouter(prefix="/v1/alimentos", tags=["alimentos"])


@router.post("", response_model=StandardResponse, status_code=status.HTTP_201_CREATED)
async def crear_alimento(
    data: AlimentoCreate,
    session: AsyncSession = Depends(get_session),
    current_user: Usuario = Depends(get_current_user),
):
    """Da de alta (o reproduce) un alimento del establecimiento."""
    alimento = await AlimentoService(session).crear(current_user, data)
    return StandardResponse(success=True, data=alimento.model_dump())


@router.get("", response_model=StandardResponse)
async def listar_alimentos(
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
    """Catálogo del establecimiento más los alimentos globales."""
    alimentos = await AlimentoService(session).listar(
        current_user,
        establecimiento_id,
        updated_since=updated_since,
        include_deleted=include_deleted,
    )
    return StandardResponse(success=True, data=[a.model_dump() for a in alimentos])
