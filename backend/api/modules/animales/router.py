"""Endpoints del módulo animales."""

from datetime import datetime
from uuid import UUID

from fastapi import APIRouter, Depends, Query, status
from sqlalchemy.ext.asyncio import AsyncSession

from api.auth.dependencies import get_current_user
from api.modules.animales.schemas import AnimalCreate, AnimalUpdate
from api.modules.animales.service import AnimalService
from api.modules.usuarios.models import Usuario
from api.shared.enums import EstadoAnimal, SexoAnimal
from api.shared.schemas import StandardResponse
from database.database import get_session

router = APIRouter(prefix="/v1/animales", tags=["animales"])


@router.post("", response_model=StandardResponse, status_code=status.HTTP_201_CREATED)
async def crear_animal(
    data: AnimalCreate,
    session: AsyncSession = Depends(get_session),
    current_user: Usuario = Depends(get_current_user),
):
    """Registra un animal y su pesaje inicial en la misma operación."""
    service = AnimalService(session)
    animal = await service.crear(current_user, data)
    return StandardResponse(success=True, data=animal.model_dump())


@router.get("", response_model=StandardResponse)
async def listar_animales(
    establecimiento_id: UUID = Query(...),
    lote_id: UUID | None = Query(default=None),
    sexo: SexoAnimal | None = Query(default=None),
    estado: EstadoAnimal | None = Query(default=None),
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
    """Lista los animales de un establecimiento.

    Sirve para UI (filtros lote/sexo/estado) y para la descarga delta del sync
    offline-first (``updated_since`` + ``include_deleted``).
    """
    service = AnimalService(session)
    animales = await service.listar(
        current_user,
        establecimiento_id,
        lote_id=lote_id,
        sexo=sexo,
        estado=estado,
        updated_since=updated_since,
        include_deleted=include_deleted,
    )
    return StandardResponse(success=True, data=[a.model_dump() for a in animales])


@router.put("/{animal_id}", response_model=StandardResponse)
async def actualizar_animal(
    animal_id: UUID,
    data: AnimalUpdate,
    session: AsyncSession = Depends(get_session),
    current_user: Usuario = Depends(get_current_user),
):
    """Actualiza un animal (edición / replay de update de Brick) con last-write-wins."""
    service = AnimalService(session)
    animal = await service.actualizar(current_user, animal_id, data)
    return StandardResponse(success=True, data=animal.model_dump())


@router.delete("/{animal_id}", response_model=StandardResponse)
async def borrar_animal(
    animal_id: UUID,
    deleted_at: datetime | None = Query(default=None),
    updated_at: datetime | None = Query(default=None),
    session: AsyncSession = Depends(get_session),
    current_user: Usuario = Depends(get_current_user),
):
    """Soft delete: marca ``deleted_at`` para que el borrado se sincronice."""
    service = AnimalService(session)
    animal = await service.borrar(
        current_user, animal_id, deleted_at=deleted_at, updated_at=updated_at
    )
    return StandardResponse(success=True, data=animal.model_dump())


@router.get("/{animal_id}", response_model=StandardResponse)
async def detalle_animal(
    animal_id: UUID,
    session: AsyncSession = Depends(get_session),
    current_user: Usuario = Depends(get_current_user),
):
    """Detalle de un animal del establecimiento del usuario."""
    service = AnimalService(session)
    animal = await service.detalle(current_user, animal_id)
    return StandardResponse(success=True, data=animal.model_dump())
