"""Acceso a datos de los registros de alimentación. Sin reglas de negocio."""

from datetime import datetime
from uuid import UUID

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from api.modules.alimentacion.models import (
    RegistroAlimentacion,
    RegistroAlimentacionAnimal,
)
from api.modules.animales.models import Animal


class RegistroAlimentacionRepository:
    def __init__(self, session: AsyncSession) -> None:
        self.session = session

    async def save(self, registro: RegistroAlimentacion) -> RegistroAlimentacion:
        self.session.add(registro)
        await self.session.flush()
        return registro

    def add_detalles(self, registro_id: UUID, animal_ids: list[UUID]) -> None:
        """Agrega el detalle sin ``flush``: se emite junto con la cabecera."""
        self.session.add_all(
            [
                RegistroAlimentacionAnimal(
                    registro_alimentacion_id=registro_id, animal_id=animal_id
                )
                for animal_id in animal_ids
            ]
        )

    async def get_by_id_including_deleted(
        self, registro_id: UUID
    ) -> RegistroAlimentacion | None:
        return await self.session.get(RegistroAlimentacion, registro_id)

    async def list_animal_ids(self, registro_id: UUID) -> list[UUID]:
        mapa = await self.map_animal_ids([registro_id])
        return mapa[registro_id]

    async def map_animal_ids(self, registro_ids: list[UUID]) -> dict[UUID, list[UUID]]:
        """Detalle de varios registros en una sola consulta (evita N+1)."""
        if not registro_ids:
            return {}
        result = await self.session.execute(
            select(
                RegistroAlimentacionAnimal.registro_alimentacion_id,
                RegistroAlimentacionAnimal.animal_id,
            )
            .where(
                RegistroAlimentacionAnimal.registro_alimentacion_id.in_(registro_ids)
            )
            .order_by(
                RegistroAlimentacionAnimal.created_at,
                RegistroAlimentacionAnimal.animal_id,
            )
        )
        agrupado: dict[UUID, list[UUID]] = {rid: [] for rid in registro_ids}
        for registro_id, animal_id in result.all():
            agrupado[registro_id].append(animal_id)
        return agrupado

    async def list_animales_por_ids(self, animal_ids: list[UUID]) -> list[Animal]:
        result = await self.session.execute(
            select(Animal).where(Animal.id.in_(animal_ids))
        )
        return list(result.scalars().all())

    async def list_by_establecimiento(
        self,
        establecimiento_id: UUID,
        *,
        animal_id: UUID | None = None,
        updated_since: datetime | None = None,
        include_deleted: bool = False,
    ) -> list[RegistroAlimentacion]:
        query = select(RegistroAlimentacion).where(
            RegistroAlimentacion.establecimiento_id == establecimiento_id
        )
        if not include_deleted:
            query = query.where(RegistroAlimentacion.deleted_at.is_(None))
        if animal_id is not None:
            query = query.where(
                RegistroAlimentacion.id.in_(
                    select(RegistroAlimentacionAnimal.registro_alimentacion_id).where(
                        RegistroAlimentacionAnimal.animal_id == animal_id
                    )
                )
            )
        if updated_since is not None:
            query = query.where(RegistroAlimentacion.updated_at >= updated_since)
        result = await self.session.execute(
            query.order_by(RegistroAlimentacion.fecha_desde)
        )
        return list(result.scalars().all())
