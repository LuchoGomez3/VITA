"""Endpoints de los registros de alimentación."""

from datetime import datetime
from uuid import UUID

from fastapi import APIRouter, Depends, Query, status
from sqlalchemy.ext.asyncio import AsyncSession

from api.auth.dependencies import get_current_user
from api.modules.alimentacion.schemas import RegistroAlimentacionCreate
from api.modules.alimentacion.service import RegistroAlimentacionService
from api.modules.usuarios.models import Usuario
from api.shared.schemas import StandardResponse
from database.database import get_session

router = APIRouter(prefix="/v1/registros_alimentacion", tags=["alimentacion"])


@router.post("", response_model=StandardResponse, status_code=status.HTTP_201_CREATED)
async def crear_registro_alimentacion(
    data: RegistroAlimentacionCreate,
    session: AsyncSession = Depends(get_session),
    current_user: Usuario = Depends(get_current_user),
):
    """Registra (o reproduce) un suplemento o dieta para uno o varios animales."""
    registro = await RegistroAlimentacionService(session).crear(current_user, data)
    return StandardResponse(success=True, data=registro.model_dump(mode="json"))


@router.get("", response_model=StandardResponse)
async def listar_registros_alimentacion(
    establecimiento_id: UUID = Query(...),
    animal_id: UUID | None = Query(
        default=None,
        description="Filtra los registros que incluyen a un animal (su historial).",
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
    """Registros de alimentación del establecimiento (o de un animal)."""
    registros = await RegistroAlimentacionService(session).listar(
        current_user,
        establecimiento_id,
        animal_id=animal_id,
        updated_since=updated_since,
        include_deleted=include_deleted,
    )
    return StandardResponse(
        success=True, data=[r.model_dump(mode="json") for r in registros]
    )
