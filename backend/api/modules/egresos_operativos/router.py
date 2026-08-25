"""Endpoints autenticados para registrar y sincronizar egresos operativos."""

from datetime import datetime
from uuid import UUID

from fastapi import APIRouter, Depends, Query, status
from sqlalchemy.ext.asyncio import AsyncSession

from api.auth.dependencies import get_current_user
from api.modules.egresos_operativos.schemas import (
    CategoriaEgresoCreate,
    EgresoOperativoCreate,
)
from api.modules.egresos_operativos.service import EgresoOperativoService
from api.modules.usuarios.models import Usuario
from api.shared.schemas import StandardResponse
from database.database import get_session

router = APIRouter(prefix="/v1/egresos_operativos", tags=["egresos_operativos"])


@router.get("/catalogo", response_model=StandardResponse)
async def obtener_catalogo(
    establecimiento_id: UUID = Query(...),
    session: AsyncSession = Depends(get_session),
    current_user: Usuario = Depends(get_current_user),
):
    """Devuelve opciones base y personalizadas del establecimiento autorizado."""
    catalogo = await EgresoOperativoService(session).catalogo(
        current_user, establecimiento_id
    )
    return StandardResponse(success=True, data=[item.model_dump() for item in catalogo])


@router.post(
    "/categorias",
    response_model=StandardResponse,
    status_code=status.HTTP_201_CREATED,
)
async def crear_categoria_egreso(
    datos: CategoriaEgresoCreate,
    session: AsyncSession = Depends(get_session),
    current_user: Usuario = Depends(get_current_user),
):
    """Agrega una categoría al catálogo privado del establecimiento."""
    categoria = await EgresoOperativoService(session).crear_categoria(
        current_user, datos
    )
    return StandardResponse(success=True, data=categoria.model_dump())


@router.post("", response_model=StandardResponse, status_code=status.HTTP_201_CREATED)
async def crear_egreso_operativo(
    datos: EgresoOperativoCreate,
    session: AsyncSession = Depends(get_session),
    current_user: Usuario = Depends(get_current_user),
):
    """Registra un egreso o procesa de forma idempotente una mutación offline."""
    egreso = await EgresoOperativoService(session).crear(current_user, datos)
    return StandardResponse(success=True, data=egreso.model_dump())


@router.get("", response_model=StandardResponse)
async def listar_egresos_operativos(
    establecimiento_id: UUID = Query(...),
    updated_since: datetime | None = Query(default=None),
    include_deleted: bool = Query(default=False),
    session: AsyncSession = Depends(get_session),
    current_user: Usuario = Depends(get_current_user),
):
    """Lista el historial auditable y ofrece descarga incremental para sincronizar."""
    egresos = await EgresoOperativoService(session).listar(
        current_user,
        establecimiento_id,
        updated_since=updated_since,
        include_deleted=include_deleted,
    )
    return StandardResponse(
        success=True, data=[egreso.model_dump() for egreso in egresos]
    )
