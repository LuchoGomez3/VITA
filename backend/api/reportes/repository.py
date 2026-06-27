"""Acceso a datos para los reportes SENASA (solo lectura)."""

from datetime import datetime
from uuid import UUID

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from api.modules.animales.models import Animal
from api.modules.egresos.models import Egreso, EgresoDetalle
from api.modules.eventos_sanitarios.models import EventoSanitario
from api.modules.movimientos.models import MovimientoLote


class EventoReporte:
    """Fila cruda de evento (antes de armar el DTO con el RENSPA)."""

    def __init__(self, caravana: str | None, fecha: datetime, tipo: str) -> None:
        self.caravana = caravana
        self.fecha = fecha
        self.tipo = tipo


class ReporteRepository:
    def __init__(self, session: AsyncSession) -> None:
        self.session = session

    async def animales_incompletos(
        self, establecimiento_id: UUID, lote_id: UUID | None = None
    ) -> list[Animal]:
        """Animales sin RFID de 15 dígitos o sin categoría definida."""
        query = select(Animal).where(
            Animal.establecimiento_id == establecimiento_id,
            Animal.deleted_at.is_(None),
        )
        if lote_id is not None:
            query = query.where(Animal.lote_id == lote_id)
        result = await self.session.execute(query)
        animales = result.scalars().all()
        return [
            a
            for a in animales
            if a.nro_caravana_rfid is None
            or len(a.nro_caravana_rfid) != 15
            or a.categoria_id is None
        ]

    async def eventos(
        self,
        establecimiento_id: UUID,
        *,
        desde: datetime | None = None,
        hasta: datetime | None = None,
        lote_id: UUID | None = None,
    ) -> list[EventoReporte]:
        """Eventos reportables a partir de las fuentes disponibles.

        Tipos de evento cubiertos: vacunación (y demás eventos sanitarios),
        egreso e ingreso/movimiento de lote.

        TODO(PO): "cambio de categoría" no está modelado (no hay historial de
        categoría); queda pendiente de confirmar con el Product Owner.
        """
        eventos: list[EventoReporte] = []
        eventos += await self._eventos_sanitarios(
            establecimiento_id, desde, hasta, lote_id
        )
        eventos += await self._egresos(establecimiento_id, desde, hasta, lote_id)
        eventos += await self._movimientos(establecimiento_id, desde, hasta, lote_id)
        eventos.sort(key=lambda e: e.fecha)
        return eventos

    async def _eventos_sanitarios(
        self,
        establecimiento_id: UUID,
        desde: datetime | None,
        hasta: datetime | None,
        lote_id: UUID | None,
    ) -> list[EventoReporte]:
        query = (
            select(
                Animal.nro_caravana_rfid,
                EventoSanitario.fecha_aplicacion,
                EventoSanitario.tipo,
            )
            .join(Animal, Animal.id == EventoSanitario.animal_id)
            .where(
                EventoSanitario.establecimiento_id == establecimiento_id,
                EventoSanitario.deleted_at.is_(None),
            )
        )
        if desde is not None:
            query = query.where(EventoSanitario.fecha_aplicacion >= desde)
        if hasta is not None:
            query = query.where(EventoSanitario.fecha_aplicacion <= hasta)
        if lote_id is not None:
            query = query.where(Animal.lote_id == lote_id)
        result = await self.session.execute(query)
        return [
            EventoReporte(
                caravana, fecha, str(tipo.value if hasattr(tipo, "value") else tipo)
            )
            for caravana, fecha, tipo in result.all()
        ]

    async def _egresos(
        self,
        establecimiento_id: UUID,
        desde: datetime | None,
        hasta: datetime | None,
        lote_id: UUID | None,
    ) -> list[EventoReporte]:
        query = (
            select(Animal.nro_caravana_rfid, Egreso.fecha)
            .join(EgresoDetalle, EgresoDetalle.egreso_id == Egreso.id)
            .join(Animal, Animal.id == EgresoDetalle.animal_id)
            .where(
                Egreso.establecimiento_id == establecimiento_id,
                Egreso.deleted_at.is_(None),
            )
        )
        if desde is not None:
            query = query.where(Egreso.fecha >= desde)
        if hasta is not None:
            query = query.where(Egreso.fecha <= hasta)
        if lote_id is not None:
            query = query.where(Animal.lote_id == lote_id)
        result = await self.session.execute(query)
        return [
            EventoReporte(caravana, fecha, "egreso") for caravana, fecha in result.all()
        ]

    async def _movimientos(
        self,
        establecimiento_id: UUID,
        desde: datetime | None,
        hasta: datetime | None,
        lote_id: UUID | None,
    ) -> list[EventoReporte]:
        query = (
            select(
                Animal.nro_caravana_rfid,
                MovimientoLote.fecha,
                MovimientoLote.lote_origen_id,
            )
            .join(Animal, Animal.id == MovimientoLote.animal_id)
            .where(MovimientoLote.establecimiento_id == establecimiento_id)
        )
        if desde is not None:
            query = query.where(MovimientoLote.fecha >= desde)
        if hasta is not None:
            query = query.where(MovimientoLote.fecha <= hasta)
        if lote_id is not None:
            query = query.where(MovimientoLote.lote_destino_id == lote_id)
        result = await self.session.execute(query)
        return [
            EventoReporte(
                caravana, fecha, "ingreso" if origen is None else "movimiento"
            )
            for caravana, fecha, origen in result.all()
        ]
