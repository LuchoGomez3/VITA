"""Endpoints del módulo animales."""

from uuid import UUID

from fastapi import APIRouter, Depends, Query, status
from sqlalchemy.ext.asyncio import AsyncSession

from api.auth.dependencies import get_current_user
from api.modules.animales.schemas import AnimalCreate
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
    session: AsyncSession = Depends(get_session),
    current_user: Usuario = Depends(get_current_user),
):
    """Lista los animales de un establecimiento (filtrable por lote/sexo/estado)."""
    service = AnimalService(session)
    animales = await service.listar(
        current_user, establecimiento_id, lote_id=lote_id, sexo=sexo, estado=estado
    )
    return StandardResponse(success=True, data=[a.model_dump() for a in animales])


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
