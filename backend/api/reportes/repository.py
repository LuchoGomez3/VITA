"""Acceso a datos para los reportes SENASA (solo lectura)."""

from datetime import datetime
from uuid import UUID

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from api.modules.animales.models import Animal
from api.reportes.models import ExportacionSenasa, ExportacionSenasaAnimal


class ReporteRepository:
    def __init__(self, session: AsyncSession) -> None:
        self.session = session

    async def animales_para_declaracion(
        self,
        establecimiento_id: UUID,
        *,
        desde: datetime | None,
        hasta: datetime | None,
    ) -> list[Animal]:
        """Selecciona animales caravaneados durante el período solicitado.

        VITA crea el registro del animal al aplicar la caravana. Por eso el filtro
        usa ``created_at`` y no la fecha de nacimiento, que puede ser antigua.
        """
        query = select(Animal).where(
            Animal.establecimiento_id == establecimiento_id,
            Animal.deleted_at.is_(None),
        )
        if desde is not None:
            query = query.where(Animal.created_at >= desde)
        if hasta is not None:
            query = query.where(Animal.created_at <= hasta)

        result = await self.session.execute(query.order_by(Animal.nro_caravana_rfid))
        return list(result.scalars().all())

    async def crear_exportacion(
        self,
        exportacion: ExportacionSenasa,
        animales: list[Animal],
    ) -> ExportacionSenasa:
        """Guarda el archivo y su composición antes de entregarlo al usuario."""
        self.session.add(exportacion)
        await self.session.flush()
        self.session.add_all(
            [
                ExportacionSenasaAnimal(
                    exportacion_senasa_id=exportacion.id,
                    animal_id=animal.id,
                )
                for animal in animales
            ]
        )
        await self.session.flush()
        return exportacion

    async def listar_exportaciones(
        self, establecimiento_id: UUID
    ) -> list[ExportacionSenasa]:
        """Lista el historial del establecimiento, primero el más reciente."""
        resultado = await self.session.execute(
            select(ExportacionSenasa)
            .where(ExportacionSenasa.establecimiento_id == establecimiento_id)
            .order_by(ExportacionSenasa.created_at.desc())
        )
        return list(resultado.scalars().all())

    async def obtener_exportacion(
        self, exportacion_id: UUID
    ) -> ExportacionSenasa | None:
        """Obtiene el archivo persistido por su identificador."""
        return await self.session.get(ExportacionSenasa, exportacion_id)
