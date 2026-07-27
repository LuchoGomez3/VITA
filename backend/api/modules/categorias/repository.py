"""Acceso a datos de categorías. Sin reglas de negocio."""

from datetime import datetime
from uuid import UUID

from sqlalchemy import func, or_, select
from sqlalchemy.ext.asyncio import AsyncSession

from api.modules.animales.models import Animal
from api.modules.categorias.models import Categoria


class CategoriaRepository:
    def __init__(self, session: AsyncSession) -> None:
        self.session = session

    async def create(self, categoria: Categoria) -> Categoria:
        self.session.add(categoria)
        await self.session.flush()
        return categoria

    async def save(self, categoria: Categoria) -> Categoria:
        """Persiste una categoría ya cargada tras mutarla (upsert LWW).

        ``updated_at`` se asigna explícito en el service, por lo que queda en el SET
        del UPDATE y el ``onupdate=func.now()`` del modelo NO lo pisa.
        """
        self.session.add(categoria)
        await self.session.flush()
        return categoria

    async def get_by_id(self, categoria_id: UUID) -> Categoria | None:
        categoria = await self.session.get(Categoria, categoria_id)
        if categoria is None or categoria.deleted_at is not None:
            return None
        return categoria

    async def get_by_id_including_deleted(self, categoria_id: UUID) -> Categoria | None:
        """Incluye soft-deleted: necesario para reconciliar en sync (un alta reenviada
        o un registro borrado deben poder encontrarse)."""
        return await self.session.get(Categoria, categoria_id)

    async def exists_nombre(
        self, establecimiento_id: UUID, nombre: str, *, exclude_id: UUID | None = None
    ) -> bool:
        """Unicidad del nombre dentro del establecimiento (case-insensitive)."""
        query = select(Categoria.id).where(
            Categoria.establecimiento_id == establecimiento_id,
            func.lower(Categoria.nombre) == nombre.lower(),
            Categoria.deleted_at.is_(None),
        )
        if exclude_id is not None:
            query = query.where(Categoria.id != exclude_id)
        result = await self.session.execute(query)
        return result.first() is not None

    async def tiene_animales(self, categoria_id: UUID) -> bool:
        """True si hay algún animal activo asignado a la categoría."""
        result = await self.session.execute(
            select(Animal.id).where(
                Animal.categoria_id == categoria_id,
                Animal.deleted_at.is_(None),
            )
        )
        return result.first() is not None

    async def list_visibles(
        self,
        establecimiento_id: UUID,
        *,
        updated_since: datetime | None = None,
        include_deleted: bool = False,
    ) -> list[Categoria]:
        """Categorías visibles para el establecimiento: el catálogo global
        (``establecimiento_id`` null) más las propias.

        Sirve para poblar el selector del alta/edición de animal en la UI y para la
        descarga delta del sync offline-first (``updated_since`` + ``include_deleted``).
        """
        query = select(Categoria).where(
            or_(
                Categoria.establecimiento_id.is_(None),
                Categoria.establecimiento_id == establecimiento_id,
            )
        )
        if not include_deleted:
            query = query.where(Categoria.deleted_at.is_(None))
        if updated_since is not None:
            query = query.where(Categoria.updated_at >= updated_since)
        result = await self.session.execute(query.order_by(Categoria.nombre))
        return list(result.scalars().all())
