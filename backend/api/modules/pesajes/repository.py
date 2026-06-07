"""Acceso a datos de pesajes. Sin reglas de negocio."""

from uuid import UUID

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from api.modules.pesajes.models import Pesaje


class PesajeRepository:
    def __init__(self, session: AsyncSession) -> None:
        self.session = session

    async def create(self, pesaje: Pesaje) -> Pesaje:
        self.session.add(pesaje)
        await self.session.flush()
        return pesaje

    async def list_by_animal(self, animal_id: UUID) -> list[Pesaje]:
        result = await self.session.execute(
            select(Pesaje)
            .where(Pesaje.animal_id == animal_id, Pesaje.deleted_at.is_(None))
            .order_by(Pesaje.fecha)
        )
        return list(result.scalars().all())
