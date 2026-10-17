"""Lógica de negocio del módulo categorías."""

from datetime import datetime

from sqlalchemy.ext.asyncio import AsyncSession

from api.modules.categorias.repository import CategoriaRepository
from api.modules.categorias.schemas import CategoriaRead


class CategoriaService:
    """Lectura del catálogo global de categorías.

    El catálogo es igual para todos los establecimientos y lo administra el
    equipo desde la base: no hay altas, ediciones ni bajas por la API (adr-0010).
    """

    def __init__(self, session: AsyncSession) -> None:
        self.session = session
        self.repository = CategoriaRepository(session)

    async def listar(
        self,
        *,
        updated_since: datetime | None = None,
        include_deleted: bool = False,
    ) -> list[CategoriaRead]:
        categorias = await self.repository.list_catalogo(
            updated_since=updated_since,
            include_deleted=include_deleted,
        )
        return [CategoriaRead.model_validate(c) for c in categorias]
