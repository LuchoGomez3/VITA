"""Endpoints del módulo pesajes."""

from datetime import datetime
from uuid import UUID

from fastapi import APIRouter, Depends, Query, status
from sqlalchemy.ext.asyncio import AsyncSession

from api.auth.dependencies import get_current_user
from api.modules.pesajes.schemas import PesajeCreate, PesajeUpdate
from api.modules.pesajes.service import PesajeService
from api.modules.usuarios.models import Usuario
from api.shared.schemas import StandardResponse
from database.database import get_session

router = APIRouter(prefix="/v1/pesajes", tags=["pesajes"])


@router.post("", response_model=StandardResponse, status_code=status.HTTP_201_CREATED)
async def crear_pesaje(
    data: PesajeCreate,
    session: AsyncSession = Depends(get_session),
    current_user: Usuario = Depends(get_current_user),
):
    """Registra una pesada de un animal (alta idempotente offline-first)."""
    service = PesajeService(session)
    pesaje = await service.crear(current_user, data)
    return StandardResponse(success=True, data=pesaje.model_dump())


@router.get("", response_model=StandardResponse)
async def listar_pesajes(
    establecimiento_id: UUID = Query(...),
    animal_id: UUID | None = Query(
        default=None,
        description="Filtra el historial de pesajes de un único animal (GPD).",
    ),
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
    """Historial de pesajes de un establecimiento (o de un animal con ``animal_id``).

    Sirve para la UI (evolución de peso / GPD en el detalle del animal) y para la
    descarga delta del sync offline-first.
    """
    service = PesajeService(session)
    pesajes = await service.listar(
        current_user,
        establecimiento_id,
        animal_id=animal_id,
        updated_since=updated_since,
        include_deleted=include_deleted,
    )
    return StandardResponse(success=True, data=[p.model_dump() for p in pesajes])


@router.put("/{pesaje_id}", response_model=StandardResponse)
async def actualizar_pesaje(
    pesaje_id: UUID,
    data: PesajeUpdate,
    session: AsyncSession = Depends(get_session),
    current_user: Usuario = Depends(get_current_user),
):
    """Corrige un pesaje (edición) con last-write-wins."""
    service = PesajeService(session)
    pesaje = await service.actualizar(current_user, pesaje_id, data)
    return StandardResponse(success=True, data=pesaje.model_dump())


@router.delete("/{pesaje_id}", response_model=StandardResponse)
async def borrar_pesaje(
    pesaje_id: UUID,
    deleted_at: datetime | None = Query(default=None),
    updated_at: datetime | None = Query(default=None),
    session: AsyncSession = Depends(get_session),
    current_user: Usuario = Depends(get_current_user),
):
    """Soft delete: marca ``deleted_at`` para que el borrado se sincronice."""
    service = PesajeService(session)
    pesaje = await service.borrar(
        current_user, pesaje_id, deleted_at=deleted_at, updated_at=updated_at
    )
    return StandardResponse(success=True, data=pesaje.model_dump())


@router.get("/{pesaje_id}", response_model=StandardResponse)
async def detalle_pesaje(
    pesaje_id: UUID,
    session: AsyncSession = Depends(get_session),
    current_user: Usuario = Depends(get_current_user),
):
    """Detalle de un pesaje del establecimiento del usuario."""
    service = PesajeService(session)
    pesaje = await service.detalle(current_user, pesaje_id)
    return StandardResponse(success=True, data=pesaje.model_dump())
