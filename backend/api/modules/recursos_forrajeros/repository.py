"""Acceso a datos del historial de recursos forrajeros. Sin reglas de negocio."""

from datetime import date, datetime
from uuid import UUID

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from api.modules.recursos_forrajeros.models import PeriodoRecursoForrajero


class PeriodoRecursoForrajeroRepository:
    def __init__(self, session: AsyncSession) -> None:
        self.session = session

    async def save(self, periodo: PeriodoRecursoForrajero) -> PeriodoRecursoForrajero:
        self.session.add(periodo)
        await self.session.flush()
        return periodo

    async def get_by_id_including_deleted(
        self, periodo_id: UUID
    ) -> PeriodoRecursoForrajero | None:
        return await self.session.get(PeriodoRecursoForrajero, periodo_id)

    async def exists_vigente_desde(
        self, lote_id: UUID, fecha_desde: date, *, excluir_id: UUID | None = None
    ) -> bool:
        query = select(PeriodoRecursoForrajero.id).where(
            PeriodoRecursoForrajero.lote_id == lote_id,
            PeriodoRecursoForrajero.fecha_desde == fecha_desde,
            PeriodoRecursoForrajero.deleted_at.is_(None),
        )
        if excluir_id is not None:
            query = query.where(PeriodoRecursoForrajero.id != excluir_id)
        result = await self.session.execute(query.limit(1))
        return result.first() is not None

    async def get_vigente_desde(
        self, lote_id: UUID, fecha_desde: date
    ) -> PeriodoRecursoForrajero | None:
        result = await self.session.execute(
            select(PeriodoRecursoForrajero).where(
                PeriodoRecursoForrajero.lote_id == lote_id,
                PeriodoRecursoForrajero.fecha_desde == fecha_desde,
                PeriodoRecursoForrajero.deleted_at.is_(None),
            )
        )
        return result.scalars().first()

    async def get_ultimo_vigente(self, lote_id: UUID) -> PeriodoRecursoForrajero | None:
        result = await self.session.execute(
            select(PeriodoRecursoForrajero)
            .where(
                PeriodoRecursoForrajero.lote_id == lote_id,
                PeriodoRecursoForrajero.deleted_at.is_(None),
            )
            .order_by(PeriodoRecursoForrajero.fecha_desde.desc())
            .limit(1)
        )
        return result.scalars().first()

    async def list_by_establecimiento(
        self,
        establecimiento_id: UUID,
        *,
        lote_id: UUID | None = None,
        updated_since: datetime | None = None,
        include_deleted: bool = False,
    ) -> list[PeriodoRecursoForrajero]:
        query = select(PeriodoRecursoForrajero).where(
            PeriodoRecursoForrajero.establecimiento_id == establecimiento_id
        )
        if not include_deleted:
            query = query.where(PeriodoRecursoForrajero.deleted_at.is_(None))
        if lote_id is not None:
            query = query.where(PeriodoRecursoForrajero.lote_id == lote_id)
        if updated_since is not None:
            query = query.where(PeriodoRecursoForrajero.updated_at >= updated_since)
        result = await self.session.execute(
            query.order_by(
                PeriodoRecursoForrajero.lote_id, PeriodoRecursoForrajero.fecha_desde
            )
        )
        return list(result.scalars().all())
