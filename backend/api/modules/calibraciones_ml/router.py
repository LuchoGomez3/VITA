"""Endpoints del módulo calibraciones_ml.

El alta viaja en dos requests y no en un único multipart. No es una preferencia
estética: la cola offline del cliente (Brick) solo sabe persistir y reproducir
requests de texto — un ``MultipartRequest`` la esquiva y, sin señal, la captura
se pierde. Partirlo deja la metadata dentro de la cola (reintento gratis,
idempotente por UUID) y la imagen en un canal que el cliente reintenta aparte.
"""

from datetime import datetime
from uuid import UUID

from fastapi import APIRouter, Depends, File, Query, Request, UploadFile, status
from sqlalchemy.ext.asyncio import AsyncSession

from api.auth.dependencies import get_current_user
from api.modules.calibraciones_ml.imagen import validar_tamanio_declarado
from api.modules.calibraciones_ml.schemas import (
    MuestraCalibracionCreate,
    MuestraCalibracionUpdate,
)
from api.modules.calibraciones_ml.service import MuestraCalibracionService
from api.modules.usuarios.models import Usuario
from api.shared.schemas import StandardResponse
from core.storage import ObjectStorage, get_storage_calibraciones
from database.database import get_session

router = APIRouter(prefix="/v1/calibraciones_ml", tags=["calibraciones_ml"])


@router.post("", response_model=StandardResponse, status_code=status.HTTP_201_CREATED)
async def crear_muestra_calibracion(
    data: MuestraCalibracionCreate,
    session: AsyncSession = Depends(get_session),
    current_user: Usuario = Depends(get_current_user),
):
    """Registra la metadata de una muestra (alta idempotente offline-first).

    La muestra nace en ``pendiente_imagen``: existe, pero todavía no entrena.
    """
    service = MuestraCalibracionService(session)
    muestra = await service.crear(current_user, data)
    return StandardResponse(success=True, data=muestra.model_dump())


@router.post("/{muestra_id}/imagen", response_model=StandardResponse)
async def adjuntar_imagen_calibracion(
    muestra_id: UUID,
    request: Request,
    imagen: UploadFile = File(..., description="Foto lateral del animal, JPEG."),
    session: AsyncSession = Depends(get_session),
    current_user: Usuario = Depends(get_current_user),
    storage: ObjectStorage = Depends(get_storage_calibraciones),
):
    """Sube la foto lateral de una muestra ya registrada y la deja ``completa``.

    Idempotente: la clave del objeto se deriva del UUID de la muestra, así que
    reenviar la misma foto pisa el objeto anterior en vez de duplicarlo.
    """
    # Corte temprano por el header declarado, para no traer a memoria un archivo
    # que igual se va a rechazar. El chequeo que vale es el de los bytes reales,
    # dentro de ``normalizar_jpeg``.
    content_length = request.headers.get("content-length")
    validar_tamanio_declarado(int(content_length) if content_length else None)

    datos = await imagen.read()
    service = MuestraCalibracionService(session, storage=storage)
    muestra = await service.adjuntar_imagen(current_user, muestra_id, datos)
    return StandardResponse(success=True, data=muestra.model_dump())


@router.get("", response_model=StandardResponse)
async def listar_muestras_calibracion(
    establecimiento_id: UUID = Query(...),
    animal_id: UUID | None = Query(default=None),
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
    """Muestras de calibración de un establecimiento."""
    service = MuestraCalibracionService(session)
    muestras = await service.listar(
        current_user,
        establecimiento_id,
        animal_id=animal_id,
        updated_since=updated_since,
        include_deleted=include_deleted,
    )
    return StandardResponse(success=True, data=[m.model_dump() for m in muestras])


@router.put("/{muestra_id}", response_model=StandardResponse)
async def actualizar_muestra_calibracion(
    muestra_id: UUID,
    data: MuestraCalibracionUpdate,
    session: AsyncSession = Depends(get_session),
    current_user: Usuario = Depends(get_current_user),
):
    """Corrige una muestra (p. ej. el peso mal anotado) con last-write-wins."""
    service = MuestraCalibracionService(session)
    muestra = await service.actualizar(current_user, muestra_id, data)
    return StandardResponse(success=True, data=muestra.model_dump())


@router.delete("/{muestra_id}", response_model=StandardResponse)
async def borrar_muestra_calibracion(
    muestra_id: UUID,
    deleted_at: datetime | None = Query(default=None),
    updated_at: datetime | None = Query(default=None),
    session: AsyncSession = Depends(get_session),
    current_user: Usuario = Depends(get_current_user),
):
    """Soft delete: marca ``deleted_at`` para que el borrado se sincronice."""
    service = MuestraCalibracionService(session)
    muestra = await service.borrar(
        current_user, muestra_id, deleted_at=deleted_at, updated_at=updated_at
    )
    return StandardResponse(success=True, data=muestra.model_dump())


@router.get("/{muestra_id}", response_model=StandardResponse)
async def detalle_muestra_calibracion(
    muestra_id: UUID,
    session: AsyncSession = Depends(get_session),
    current_user: Usuario = Depends(get_current_user),
):
    """Detalle de una muestra del establecimiento del usuario."""
    service = MuestraCalibracionService(session)
    muestra = await service.detalle(current_user, muestra_id)
    return StandardResponse(success=True, data=muestra.model_dump())
