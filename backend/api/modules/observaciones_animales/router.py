"""Endpoints del módulo observaciones de animales."""

from datetime import datetime
from uuid import UUID

from fastapi import APIRouter, Depends, Query, status
from sqlalchemy.ext.asyncio import AsyncSession

from api.auth.dependencies import get_current_user
from api.modules.observaciones_animales.schemas import (
    ObservacionAnimalCreate,
    ObservacionAnimalUpdate,
)
from api.modules.observaciones_animales.service import ObservacionAnimalService
from api.modules.usuarios.models import Usuario
from api.shared.schemas import StandardResponse
from database.database import get_session

router = APIRouter(prefix="/v1/observaciones_animales", tags=["observaciones_animales"])


@router.post("", response_model=StandardResponse, status_code=status.HTTP_201_CREATED)
async def crear_observacion(
    data: ObservacionAnimalCreate,
    session: AsyncSession = Depends(get_session),
    current_user: Usuario = Depends(get_current_user),
):
    """Agrega una observación a un animal (alta idempotente offline-first)."""
    service = ObservacionAnimalService(session)
    observacion = await service.crear(current_user, data)
    return StandardResponse(success=True, data=observacion.model_dump())


@router.get("", response_model=StandardResponse)
async def listar_observaciones(
    establecimiento_id: UUID = Query(...),
    animal_id: UUID | None = Query(
        default=None,
        description="Filtra las observaciones de un único animal.",
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
    """Observaciones de un establecimiento (o de un animal), de la más reciente a
    la más vieja.

    Sirve para el detalle del animal y para la descarga delta del sync.
    """
    service = ObservacionAnimalService(session)
    observaciones = await service.listar(
        current_user,
        establecimiento_id,
        animal_id=animal_id,
        updated_since=updated_since,
        include_deleted=include_deleted,
    )
    return StandardResponse(success=True, data=[o.model_dump() for o in observaciones])


@router.put("/{observacion_id}", response_model=StandardResponse)
async def actualizar_observacion(
    observacion_id: UUID,
    data: ObservacionAnimalUpdate,
    session: AsyncSession = Depends(get_session),
    current_user: Usuario = Depends(get_current_user),
):
    """Edita una observación con last-write-wins, sin tocar las demás."""
    service = ObservacionAnimalService(session)
    observacion = await service.actualizar(current_user, observacion_id, data)
    return StandardResponse(success=True, data=observacion.model_dump())


@router.delete("/{observacion_id}", response_model=StandardResponse)
async def borrar_observacion(
    observacion_id: UUID,
    deleted_at: datetime | None = Query(default=None),
    updated_at: datetime | None = Query(default=None),
    session: AsyncSession = Depends(get_session),
    current_user: Usuario = Depends(get_current_user),
):
    """Soft delete: marca ``deleted_at`` para que el borrado se sincronice."""
    service = ObservacionAnimalService(session)
    observacion = await service.borrar(
        current_user, observacion_id, deleted_at=deleted_at, updated_at=updated_at
    )
    return StandardResponse(success=True, data=observacion.model_dump())
