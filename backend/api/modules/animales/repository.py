"""Acceso a datos de animales y entidades referenciadas. Sin reglas de negocio."""

from uuid import UUID

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from api.modules.animales.models import Animal
from api.modules.categorias.models import Categoria
from api.modules.lotes.models import Lote
from api.shared.enums import EstadoAnimal, SexoAnimal


class AnimalRepository:
    def __init__(self, session: AsyncSession) -> None:
        self.session = session

    async def create(self, animal: Animal) -> Animal:
        self.session.add(animal)
        await self.session.flush()
        return animal

    async def get_by_id(self, animal_id: UUID) -> Animal | None:
        animal = await self.session.get(Animal, animal_id)
        if animal is None or animal.deleted_at is not None:
            return None
        return animal

    async def exists_caravana(self, nro_caravana_rfid: str) -> bool:
        """Unicidad GLOBAL de la caravana RFID (SENASA 530/2025: ID nacional único).

        Nota: la historia mencionaba 'único por establecimiento', pero se mantiene
        global por la normativa y la constraint del modelo.
        """
        result = await self.session.execute(
            select(Animal.id).where(
                Animal.nro_caravana_rfid == nro_caravana_rfid,
                Animal.deleted_at.is_(None),
            )
        )
        return result.first() is not None

    async def get_lote(self, lote_id: UUID) -> Lote | None:
        lote = await self.session.get(Lote, lote_id)
        if lote is None or lote.deleted_at is not None:
            return None
        return lote

    async def get_categoria(self, categoria_id: UUID) -> Categoria | None:
        return await self.session.get(Categoria, categoria_id)

    async def list_by_establecimiento(
        self,
        establecimiento_id: UUID,
        *,
        lote_id: UUID | None = None,
        sexo: SexoAnimal | None = None,
        estado: EstadoAnimal | None = None,
    ) -> list[Animal]:
        query = select(Animal).where(
            Animal.establecimiento_id == establecimiento_id,
            Animal.deleted_at.is_(None),
        )
        if lote_id is not None:
            query = query.where(Animal.lote_id == lote_id)
        if sexo is not None:
            query = query.where(Animal.sexo == sexo)
        if estado is not None:
            query = query.where(Animal.estado == estado)
        result = await self.session.execute(query.order_by(Animal.created_at))
        return list(result.scalars().all())
