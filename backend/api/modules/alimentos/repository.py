"""Acceso a datos del catálogo de alimentos. Sin reglas de negocio."""

from datetime import datetime
from uuid import UUID

from sqlalchemy import or_, select
from sqlalchemy.ext.asyncio import AsyncSession

from api.modules.alimentos.models import Alimento


class AlimentoRepository:
    def __init__(self, session: AsyncSession) -> None:
        self.session = session

    async def save(self, alimento: Alimento) -> Alimento:
        self.session.add(alimento)
        await self.session.flush()
        return alimento

    async def get_by_id_including_deleted(self, alimento_id: UUID) -> Alimento | None:
        return await self.session.get(Alimento, alimento_id)

    async def list_by_establecimiento(
        self,
        establecimiento_id: UUID,
        *,
        updated_since: datetime | None = None,
        include_deleted: bool = False,
    ) -> list[Alimento]:
        """Alimentos del establecimiento más los del catálogo global."""
        query = select(Alimento).where(
            or_(
                Alimento.establecimiento_id == establecimiento_id,
                Alimento.establecimiento_id.is_(None),
            )
        )
        if not include_deleted:
            query = query.where(Alimento.deleted_at.is_(None))
        if updated_since is not None:
            query = query.where(Alimento.updated_at >= updated_since)
        result = await self.session.execute(query.order_by(Alimento.nombre))
        return list(result.scalars().all())
