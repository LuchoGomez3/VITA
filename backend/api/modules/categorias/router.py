"""Endpoints del módulo categorías."""

from datetime import datetime
from uuid import UUID

from fastapi import APIRouter, Depends, Query, status
from sqlalchemy.ext.asyncio import AsyncSession

from api.auth.dependencies import get_current_user
from api.modules.categorias.schemas import CategoriaCreate, CategoriaUpdate
from api.modules.categorias.service import CategoriaService
from api.modules.usuarios.models import Usuario
from api.shared.schemas import StandardResponse
from database.database import get_session

router = APIRouter(prefix="/v1/categorias", tags=["categorias"])


@router.post("", response_model=StandardResponse, status_code=status.HTTP_201_CREATED)
async def crear_categoria(
    data: CategoriaCreate,
    session: AsyncSession = Depends(get_session),
    current_user: Usuario = Depends(get_current_user),
):
    """Crea una categoría propia del establecimiento (alta idempotente offline-first)."""
    service = CategoriaService(session)
    categoria = await service.crear(current_user, data)
    return StandardResponse(success=True, data=categoria.model_dump())


@router.get("", response_model=StandardResponse)
async def listar_categorias(
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
    """Catálogo de categorías visibles para el establecimiento (global + propias).

    Es el endpoint que consume el frontend para poblar el selector de categoría al
    dar de alta o editar un animal, y para la descarga delta del sync offline-first.
    """
    service = CategoriaService(session)
    categorias = await service.listar(
        current_user,
        establecimiento_id,
        updated_since=updated_since,
        include_deleted=include_deleted,
    )
    return StandardResponse(success=True, data=[c.model_dump() for c in categorias])


@router.put("/{categoria_id}", response_model=StandardResponse)
async def actualizar_categoria(
    categoria_id: UUID,
    data: CategoriaUpdate,
    session: AsyncSession = Depends(get_session),
    current_user: Usuario = Depends(get_current_user),
):
    """Actualiza una categoría propia con last-write-wins."""
    service = CategoriaService(session)
    categoria = await service.actualizar(current_user, categoria_id, data)
    return StandardResponse(success=True, data=categoria.model_dump())


@router.delete("/{categoria_id}", response_model=StandardResponse)
async def borrar_categoria(
    categoria_id: UUID,
    deleted_at: datetime | None = Query(default=None),
    updated_at: datetime | None = Query(default=None),
    session: AsyncSession = Depends(get_session),
    current_user: Usuario = Depends(get_current_user),
):
    """Soft delete: marca ``deleted_at`` para que el borrado se sincronice.

    Se bloquea (409) si la categoría tiene animales asignados.
    """
    service = CategoriaService(session)
    categoria = await service.borrar(
        current_user, categoria_id, deleted_at=deleted_at, updated_at=updated_at
    )
    return StandardResponse(success=True, data=categoria.model_dump())
