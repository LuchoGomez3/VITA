"""Acceso a datos de pesajes. Sin reglas de negocio."""

from datetime import datetime
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

    async def save(self, pesaje: Pesaje) -> Pesaje:
        """Persiste un pesaje ya cargado tras mutarlo (upsert LWW).

        ``updated_at`` se asigna explícito en el service, por lo que queda en el SET
        del UPDATE y el ``onupdate=func.now()`` del modelo NO lo pisa.
        """
        self.session.add(pesaje)
        await self.session.flush()
        return pesaje

    async def get_by_id(self, pesaje_id: UUID) -> Pesaje | None:
        pesaje = await self.session.get(Pesaje, pesaje_id)
        if pesaje is None or pesaje.deleted_at is not None:
            return None
        return pesaje

    async def get_by_id_including_deleted(self, pesaje_id: UUID) -> Pesaje | None:
        """Incluye soft-deleted: necesario para reconciliar en sync (un alta reenviada
        o un registro borrado deben poder encontrarse)."""
        return await self.session.get(Pesaje, pesaje_id)

    async def list_by_animal(self, animal_id: UUID) -> list[Pesaje]:
        result = await self.session.execute(
            select(Pesaje)
            .where(Pesaje.animal_id == animal_id, Pesaje.deleted_at.is_(None))
            .order_by(Pesaje.fecha)
        )
        return list(result.scalars().all())

    async def list_by_establecimiento(
        self,
        establecimiento_id: UUID,
        *,
        animal_id: UUID | None = None,
        updated_since: datetime | None = None,
        include_deleted: bool = False,
    ) -> list[Pesaje]:
        """Pesajes del establecimiento. Filtra por animal para el historial de un
        animal (evolución de peso / GPD) y soporta la descarga delta del sync
        offline-first (``updated_since`` + ``include_deleted``)."""
        query = select(Pesaje).where(Pesaje.establecimiento_id == establecimiento_id)
        if not include_deleted:
            query = query.where(Pesaje.deleted_at.is_(None))
        if animal_id is not None:
            query = query.where(Pesaje.animal_id == animal_id)
        if updated_since is not None:
            query = query.where(Pesaje.updated_at >= updated_since)
        result = await self.session.execute(query.order_by(Pesaje.fecha))
        return list(result.scalars().all())
