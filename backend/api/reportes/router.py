"""Generación, historial y descarga de reportes SENASA."""

from datetime import datetime
from typing import Literal
from uuid import UUID

from fastapi import APIRouter, Depends, Query, Response
from sqlalchemy.ext.asyncio import AsyncSession

from api.auth.dependencies import get_current_user
from api.modules.usuarios.models import Usuario
from api.reportes.schemas import DeclaracionDispositivosRequest, ReporteSenasaFiltros
from api.reportes.service import ReporteService
from api.shared.schemas import StandardResponse
from database.database import get_session

router = APIRouter(prefix="/v1/reportes", tags=["reportes"])


@router.post("/senasa/declaraciones_dispositivos")
async def generar_declaracion_dispositivos(
    data: DeclaracionDispositivosRequest,
    session: AsyncSession = Depends(get_session),
    current_user: Usuario = Depends(get_current_user),
):
    """Genera y conserva el TXT oficial de dispositivos aplicados."""
    filtros = ReporteSenasaFiltros(**data.model_dump(), formato="txt")
    service = ReporteService(session)
    contenido, media_type, filename = await service.generar(current_user, filtros)
    return Response(
        content=contenido,
        media_type=media_type,
        headers={"Content-Disposition": f'attachment; filename="{filename}"'},
    )


@router.post(
    "/senasa/declaraciones_dispositivos/validacion",
    response_model=StandardResponse,
)
async def validar_declaracion_dispositivos(
    data: DeclaracionDispositivosRequest,
    session: AsyncSession = Depends(get_session),
    current_user: Usuario = Depends(get_current_user),
):
    """Valida el conjunto seleccionado sin crear una exportación histórica."""
    filtros = ReporteSenasaFiltros(**data.model_dump(), formato="txt")
    service = ReporteService(session)
    cantidad_exportable, incompletos = await service.validar_declaracion(
        current_user, filtros
    )
    return StandardResponse(
        success=True,
        data={
            "cantidad_exportable": cantidad_exportable,
            "animales_incompletos": incompletos,
        },
    )


@router.get("/senasa", deprecated=True)
async def reporte_senasa(
    establecimiento_id: UUID = Query(...),
    formato: Literal["txt", "pdf"] = Query("txt"),
    desde: datetime | None = Query(default=None),
    hasta: datetime | None = Query(default=None),
    tipo_evento: Literal["declaracion_identificacion", "novedad_nacimientos"] = Query(
        default="declaracion_identificacion",
        description="Alias temporal; acta_vacunacion ya no está admitido.",
    ),
    incluir_responsable: bool = Query(default=False),
    responsable_nombre: str | None = Query(default=None),
    responsable_dni: str | None = Query(default=None),
    nombre_archivo: str | None = Query(default=None),
    session: AsyncSession = Depends(get_session),
    current_user: Usuario = Depends(get_current_user),
):
    """Adaptador temporal para el cliente móvil anterior.

    El TXT es importable por SIGSA. El PDF es únicamente un resumen interno sin
    validez oficial y no representa un acta ni una declaración aceptada.
    """
    filtros = ReporteSenasaFiltros(
        establecimiento_id=establecimiento_id,
        formato=formato,
        desde=desde,
        hasta=hasta,
        tipo_exportacion=tipo_evento,
        incluir_responsable=incluir_responsable,
        responsable_nombre=responsable_nombre,
        responsable_dni=responsable_dni,
        nombre_archivo=nombre_archivo,
    )
    service = ReporteService(session)
    contenido, media_type, filename = await service.generar(current_user, filtros)
    return Response(
        content=contenido,
        media_type=media_type,
        headers={"Content-Disposition": f'attachment; filename="{filename}"'},
    )


@router.get("/senasa/exportaciones", response_model=StandardResponse)
async def listar_exportaciones_senasa(
    establecimiento_id: UUID = Query(...),
    session: AsyncSession = Depends(get_session),
    current_user: Usuario = Depends(get_current_user),
):
    """Lista los archivos SENASA históricos sin cargar su contenido binario."""
    service = ReporteService(session)
    exportaciones = await service.listar_exportaciones(current_user, establecimiento_id)
    return StandardResponse(
        success=True,
        data=[exportacion.model_dump() for exportacion in exportaciones],
    )


@router.get("/senasa/exportaciones/{exportacion_id}/descarga")
async def descargar_exportacion_senasa(
    exportacion_id: UUID,
    session: AsyncSession = Depends(get_session),
    current_user: Usuario = Depends(get_current_user),
):
    """Descarga nuevamente el archivo original sin recalcular sus datos."""
    service = ReporteService(session)
    contenido, media_type, filename = await service.descargar_exportacion(
        current_user, exportacion_id
    )
    return Response(
        content=contenido,
        media_type=media_type,
        headers={"Content-Disposition": f'attachment; filename="{filename}"'},
    )
