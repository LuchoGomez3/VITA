"""Acceso a datos del módulo eventos sanitarios."""

from collections.abc import Iterable, Sequence
from uuid import UUID

from sqlalchemy import func, or_, select, text
from sqlalchemy.ext.asyncio import AsyncSession

from api.modules.animales.models import Animal
from api.modules.eventos_sanitarios.models import EventoSanitario, OperacionSanitaria
from api.modules.lotes.models import Lote
from api.modules.productos_sanitarios.models import ProductoSanitario


class EventoSanitarioRepository:
    def __init__(self, session: AsyncSession) -> None:
        self.session = session

    async def bloquear_establecimiento(self, establecimiento_id: UUID) -> None:
        """Serializa las escrituras sanitarias de un establecimiento.

        El lock dura hasta el commit. Así ``version`` crece en el mismo orden en
        que se confirman los cambios, y un lector que ya vio la versión N no
        puede encontrarse después con una N-1 nueva: el cursor del historial no
        se saltea nada. SQLite (tests) no tiene advisory locks ni concurrencia.
        """
        if self.session.bind.dialect.name != "postgresql":
            return
        await self.session.execute(
            text("select pg_advisory_xact_lock(hashtextextended(:clave, 0))"),
            {"clave": f"eventos_sanitarios:{establecimiento_id}"},
        )

    async def siguiente_version(self, establecimiento_id: UUID) -> int:
        """Próxima versión del feed. Llamar con el establecimiento bloqueado."""
        maxima = await self.session.scalar(
            select(func.max(EventoSanitario.version)).where(
                EventoSanitario.establecimiento_id == establecimiento_id
            )
        )
        return (maxima or 0) + 1

    async def get_operacion(self, operacion_id: UUID) -> OperacionSanitaria | None:
        return await self.session.get(OperacionSanitaria, operacion_id)

    async def get_evento(self, evento_id: UUID) -> EventoSanitario | None:
        return await self.session.get(EventoSanitario, evento_id)

    async def eventos_por_ids(self, ids: Iterable[UUID]) -> list[EventoSanitario]:
        ids = list(ids)
        if not ids:
            return []
        result = await self.session.execute(
            select(EventoSanitario).where(EventoSanitario.id.in_(ids))
        )
        return list(result.scalars().all())

    async def eventos_de_operacion(self, operacion_id: UUID) -> list[EventoSanitario]:
        result = await self.session.execute(
            select(EventoSanitario).where(EventoSanitario.operacion_id == operacion_id)
        )
        return list(result.scalars().all())

    async def animales_por_ids(self, ids: Iterable[UUID]) -> dict[UUID, Animal]:
        ids = list(ids)
        if not ids:
            return {}
        result = await self.session.execute(select(Animal).where(Animal.id.in_(ids)))
        return {animal.id: animal for animal in result.scalars().all()}

    async def lotes_por_ids(self, ids: Iterable[UUID]) -> dict[UUID, Lote]:
        ids = list(ids)
        if not ids:
            return {}
        result = await self.session.execute(select(Lote).where(Lote.id.in_(ids)))
        return {lote.id: lote for lote in result.scalars().all()}

    async def productos_vigentes(
        self, establecimiento_id: UUID
    ) -> list[ProductoSanitario]:
        """Productos globales y propios del campo que no fueron retirados."""
        result = await self.session.execute(
            select(ProductoSanitario)
            .where(
                or_(
                    ProductoSanitario.establecimiento_id.is_(None),
                    ProductoSanitario.establecimiento_id == establecimiento_id,
                ),
                ProductoSanitario.deleted_at.is_(None),
            )
            .order_by(ProductoSanitario.nombre, ProductoSanitario.id)
        )
        return list(result.scalars().all())

    async def historial(
        self, establecimiento_id: UUID, desde_version: int, limite: int
    ) -> list[EventoSanitario]:
        """Cambios posteriores a ``desde_version``, incluidas las bajas lógicas.

        Las filas anteriores a VITA-20 no tienen versión y quedan afuera: no
        tienen práctica ni datos en el formato que lee el celular.
        """
        result = await self.session.execute(
            select(EventoSanitario)
            .where(
                EventoSanitario.establecimiento_id == establecimiento_id,
                EventoSanitario.version > desde_version,
            )
            .order_by(EventoSanitario.version)
            .limit(limite)
        )
        return list(result.scalars().all())

    def agregar(self, filas: Sequence[object]) -> None:
        self.session.add_all(filas)

    async def flush(self) -> None:
        await self.session.flush()
