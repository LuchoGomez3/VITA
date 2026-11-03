"""Endpoints del módulo lotes."""

from datetime import datetime
from uuid import UUID

from fastapi import APIRouter, Depends, Query, status
from sqlalchemy.ext.asyncio import AsyncSession

from api.auth.dependencies import get_current_user
from api.modules.lotes.schemas import LoteCreate, LoteUpdate
from api.modules.lotes.service import LoteService
from api.modules.usuarios.models import Usuario
from api.shared.enums import EstadoLote
from api.shared.schemas import StandardResponse
from database.database import get_session

router = APIRouter(prefix="/v1/lotes", tags=["lotes"])


@router.post("", response_model=StandardResponse, status_code=status.HTTP_201_CREATED)
async def crear_lote(
    data: LoteCreate,
    session: AsyncSession = Depends(get_session),
    current_user: Usuario = Depends(get_current_user),
):
    """Alta o reproducción de un lote (upsert idempotente por UUID del cliente).

    Devuelve 201 también cuando el UUID ya existía: para el cliente offline un
    replay no es un error, es la confirmación de que el registro está sincronizado.
    """
    service = LoteService(session)
    lote = await service.crear(current_user, data)
    return StandardResponse(success=True, data=lote.model_dump())


@router.get("", response_model=StandardResponse)
async def listar_lotes(
    establecimiento_id: UUID = Query(...),
    estado: EstadoLote | None = Query(default=None),
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
    """Lista los lotes de un establecimiento (UI y descarga delta del sync)."""
    service = LoteService(session)
    lotes = await service.listar(
        current_user,
        establecimiento_id,
        estado=estado,
        updated_since=updated_since,
        include_deleted=include_deleted,
    )
    return StandardResponse(success=True, data=[lote.model_dump() for lote in lotes])


@router.put("/{lote_id}", response_model=StandardResponse)
async def actualizar_lote(
    lote_id: UUID,
    data: LoteUpdate,
    session: AsyncSession = Depends(get_session),
    current_user: Usuario = Depends(get_current_user),
):
    """Actualiza un lote con last-write-wins. La geometría no es editable."""
    service = LoteService(session)
    lote = await service.actualizar(current_user, lote_id, data)
    return StandardResponse(success=True, data=lote.model_dump())


@router.delete("/{lote_id}", response_model=StandardResponse)
async def borrar_lote(
    lote_id: UUID,
    deleted_at: datetime | None = Query(default=None),
    updated_at: datetime | None = Query(default=None),
    session: AsyncSession = Depends(get_session),
    current_user: Usuario = Depends(get_current_user),
):
    """Soft delete: marca ``deleted_at`` para que el borrado se sincronice."""
    service = LoteService(session)
    lote = await service.borrar(
        current_user, lote_id, deleted_at=deleted_at, updated_at=updated_at
    )
    return StandardResponse(success=True, data=lote.model_dump())


@router.get("/{lote_id}", response_model=StandardResponse)
async def detalle_lote(
    lote_id: UUID,
    session: AsyncSession = Depends(get_session),
    current_user: Usuario = Depends(get_current_user),
):
    """Detalle de un lote del establecimiento del usuario."""
    service = LoteService(session)
    lote = await service.detalle(current_user, lote_id)
    return StandardResponse(success=True, data=lote.model_dump())
