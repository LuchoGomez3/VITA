"""Endpoint autenticado para registrar ventas de hacienda."""

from uuid import UUID

from fastapi import APIRouter, Depends, Query, status
from sqlalchemy.ext.asyncio import AsyncSession

from api.auth.dependencies import get_current_user
from api.modules.usuarios.models import Usuario
from api.modules.ventas.schemas import VentaCreate
from api.modules.ventas.service import VentaService
from api.shared.schemas import StandardResponse
from database.database import get_session

router = APIRouter(prefix="/v1/ventas", tags=["ventas"])


@router.get("", response_model=StandardResponse)
async def listar_ventas(
    establecimiento_id: UUID = Query(...),
    include_deleted: bool = Query(default=False),
    session: AsyncSession = Depends(get_session),
    current_user: Usuario = Depends(get_current_user),
):
    """Descarga el historial comercial autorizado para uso offline."""
    ventas = await VentaService(session).listar(
        current_user,
        establecimiento_id,
        include_deleted=include_deleted,
    )
    return StandardResponse(
        success=True,
        data=[venta.model_dump() for venta in ventas],
    )


@router.post("", response_model=StandardResponse, status_code=status.HTTP_201_CREATED)
async def crear_venta(
    datos: VentaCreate,
    session: AsyncSession = Depends(get_session),
    current_user: Usuario = Depends(get_current_user),
):
    """Registra venta, animales, cobro inicial y baja de stock atómicamente."""
    venta = await VentaService(session).crear(current_user, datos)
    return StandardResponse(success=True, data=venta.model_dump())
