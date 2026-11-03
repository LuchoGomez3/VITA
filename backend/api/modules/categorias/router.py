"""Endpoints del módulo categorías."""

from datetime import datetime

from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession

from api.auth.dependencies import get_current_user
from api.modules.categorias.service import CategoriaService
from api.modules.usuarios.models import Usuario
from api.shared.schemas import StandardResponse
from database.database import get_session

router = APIRouter(prefix="/v1/categorias", tags=["categorias"])


@router.get("", response_model=StandardResponse)
async def listar_categorias(
    updated_since: datetime | None = Query(
        default=None,
        description="Pull delta: devuelve solo lo modificado desde este instante.",
    ),
    include_deleted: bool = Query(
        default=False,
        description="Incluye las bajas para retirarlas del selector del cliente offline.",
    ),
    session: AsyncSession = Depends(get_session),
    _current_user: Usuario = Depends(get_current_user),
):
    """Catálogo global de categorías, igual para todos los establecimientos.

    Lo consume mobile en la sincronización inicial y para poblar el selector de
    categoría del alta de animal. Solo lectura: el catálogo se administra desde la
    base (adr-0010).
    """
    service = CategoriaService(session)
    categorias = await service.listar(
        updated_since=updated_since,
        include_deleted=include_deleted,
    )
    return StandardResponse(success=True, data=[c.model_dump() for c in categorias])
