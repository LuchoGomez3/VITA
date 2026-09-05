"""Acceso a datos de movimientos entre lotes. Sin reglas de negocio."""

from datetime import datetime
from uuid import UUID

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from api.modules.animales.models import Animal
from api.modules.movimientos.models import MovimientoLote, MovimientoLoteAnimal


class MovimientoLoteRepository:
    def __init__(self, session: AsyncSession) -> None:
        self.session = session

    async def create(self, movimiento: MovimientoLote) -> MovimientoLote:
        self.session.add(movimiento)
        await self.session.flush()
        return movimiento

    async def save(self, movimiento: MovimientoLote) -> MovimientoLote:
        self.session.add(movimiento)
        await self.session.flush()
        return movimiento

    async def add_detalles(self, movimiento_id: UUID, animal_ids: list[UUID]) -> None:
        """Registra los animales que componen el movimiento.

        No hace ``flush``: el service agrega también los animales mutados y todo
        se emite junto, para que un fallo posterior no deje el detalle escrito.
        """
        self.session.add_all(
            [
                MovimientoLoteAnimal(movimiento_lote_id=movimiento_id, animal_id=aid)
                for aid in animal_ids
            ]
        )

    async def get_by_id_including_deleted(
        self, movimiento_id: UUID
    ) -> MovimientoLote | None:
        """Incluye tombstones: necesario para reconciliar un replay."""
        return await self.session.get(MovimientoLote, movimiento_id)

    async def list_animal_ids(self, movimiento_id: UUID) -> list[UUID]:
        query = (
            select(MovimientoLoteAnimal.animal_id)
            .where(MovimientoLoteAnimal.movimiento_lote_id == movimiento_id)
            .order_by(MovimientoLoteAnimal.created_at, MovimientoLoteAnimal.animal_id)
        )
        result = await self.session.execute(query)
        return list(result.scalars().all())

    async def map_animal_ids(
        self, movimiento_ids: list[UUID]
    ) -> dict[UUID, list[UUID]]:
        """Detalle de varios movimientos en una sola consulta (evita N+1)."""
        if not movimiento_ids:
            return {}
        query = (
            select(
                MovimientoLoteAnimal.movimiento_lote_id, MovimientoLoteAnimal.animal_id
            )
            .where(MovimientoLoteAnimal.movimiento_lote_id.in_(movimiento_ids))
            .order_by(MovimientoLoteAnimal.created_at, MovimientoLoteAnimal.animal_id)
        )
        result = await self.session.execute(query)
        agrupado: dict[UUID, list[UUID]] = {mid: [] for mid in movimiento_ids}
        for movimiento_id, animal_id in result.all():
            agrupado[movimiento_id].append(animal_id)
        return agrupado

    async def list_animales_por_ids(self, animal_ids: list[UUID]) -> list[Animal]:
        """Carga los animales del movimiento en una sola consulta."""
        if not animal_ids:
            return []
        query = select(Animal).where(Animal.id.in_(animal_ids))
        result = await self.session.execute(query)
        return list(result.scalars().all())

    async def list_by_establecimiento(
        self,
        establecimiento_id: UUID,
        *,
        updated_since: datetime | None = None,
        include_deleted: bool = False,
    ) -> list[MovimientoLote]:
        query = select(MovimientoLote).where(
            MovimientoLote.establecimiento_id == establecimiento_id
        )
        if not include_deleted:
            query = query.where(MovimientoLote.deleted_at.is_(None))
        # Cursor inclusivo (>=), igual que animales y lotes.
        if updated_since is not None:
            query = query.where(MovimientoLote.updated_at >= updated_since)
        result = await self.session.execute(query.order_by(MovimientoLote.updated_at))
        return list(result.scalars().all())
