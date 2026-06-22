"""Endpoints del módulo reportes SENASA (solo lectura)."""

from datetime import datetime
from typing import Literal
from uuid import UUID

from fastapi import APIRouter, Depends, Query, Response
from sqlalchemy.ext.asyncio import AsyncSession

from api.auth.dependencies import get_current_user
from api.modules.usuarios.models import Usuario
from api.reportes.schemas import ReporteSenasaFiltros
from api.reportes.service import ReporteService
from database.database import get_session

router = APIRouter(prefix="/v1/reportes", tags=["reportes"])


@router.get("/senasa")
async def reporte_senasa(
    establecimiento_id: UUID = Query(...),
    formato: Literal["csv", "pdf"] = Query("csv"),
    desde: datetime | None = Query(default=None),
    hasta: datetime | None = Query(default=None),
    lote_id: UUID | None = Query(default=None),
    tipo_evento: str | None = Query(default=None),
    incluir_responsable: bool = Query(default=False),
    responsable_nombre: str | None = Query(default=None),
    responsable_dni: str | None = Query(default=None),
    session: AsyncSession = Depends(get_session),
    current_user: Usuario = Depends(get_current_user),
):
    """Genera el reporte SENASA en CSV o PDF.

    Devuelve el archivo binario (camino feliz); ante datos incompletos responde
    un ``StandardResponse`` de error (422) vía el handler de dominio.
    """
    filtros = ReporteSenasaFiltros(
        establecimiento_id=establecimiento_id,
        formato=formato,
        desde=desde,
        hasta=hasta,
        lote_id=lote_id,
        tipo_evento=tipo_evento,
        incluir_responsable=incluir_responsable,
        responsable_nombre=responsable_nombre,
        responsable_dni=responsable_dni,
    )
    service = ReporteService(session)
    contenido, media_type, filename = await service.generar(current_user, filtros)
    return Response(
        content=contenido,
        media_type=media_type,
        headers={"Content-Disposition": f'attachment; filename="{filename}"'},
    )
