"""Acceso a datos de categorías. Sin reglas de negocio."""

from datetime import datetime

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from api.modules.categorias.models import Categoria


class CategoriaRepository:
    def __init__(self, session: AsyncSession) -> None:
        self.session = session

    async def list_catalogo(
        self,
        *,
        updated_since: datetime | None = None,
        include_deleted: bool = False,
    ) -> list[Categoria]:
        """Catálogo global completo, ordenado por nombre.

        Sirve para el selector del alta de animal y para la descarga delta del
        sync offline-first (``updated_since`` + ``include_deleted``).
        """
        query = select(Categoria)
        if not include_deleted:
            query = query.where(Categoria.deleted_at.is_(None))
        if updated_since is not None:
            query = query.where(Categoria.updated_at >= updated_since)
        result = await self.session.execute(query.order_by(Categoria.nombre))
        return list(result.scalars().all())
