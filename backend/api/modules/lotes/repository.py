"""Acceso a datos de lotes. Sin reglas de negocio."""

from datetime import datetime
from uuid import UUID

from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from api.modules.animales.models import Animal
from api.modules.lotes.models import Lote
from api.shared.enums import EstadoLote


def normalizar_nombre(nombre: str) -> str:
    """Forma canónica del nombre para comparar unicidad.

    Debe coincidir con la expresión del índice único parcial
    ``uq_lotes_nombre_establecimiento`` (``lower(btrim(nombre))``), o el service y
    la base discreparían sobre qué es un duplicado.
    """
    return nombre.strip().lower()


class LoteRepository:
    def __init__(self, session: AsyncSession) -> None:
        self.session = session

    async def create(self, lote: Lote) -> Lote:
        self.session.add(lote)
        await self.session.flush()
        return lote

    async def save(self, lote: Lote) -> Lote:
        """Persiste un lote ya cargado en la sesión tras mutarlo (upsert LWW).

        Como ``updated_at`` se asigna explícitamente en el service, queda en el SET
        de la sentencia y el ``onupdate=func.now()`` del modelo NO lo pisa.
        """
        self.session.add(lote)
        await self.session.flush()
        return lote

    async def get_by_id(self, lote_id: UUID) -> Lote | None:
        lote = await self.session.get(Lote, lote_id)
        if lote is None or lote.deleted_at is not None:
            return None
        return lote

    async def get_by_id_including_deleted(self, lote_id: UUID) -> Lote | None:
        """Como ``get_by_id`` pero incluye tombstones: necesario para reconciliar
        en sync (un alta reenviada o un lote borrado deben poder encontrarse)."""
        return await self.session.get(Lote, lote_id)

    async def exists_nombre(
        self, establecimiento_id: UUID, nombre: str, *, exclude_id: UUID
    ) -> bool:
        """¿Hay otro lote vigente con el mismo nombre normalizado en el tenant?

        Los tombstones no cuentan: borrar un lote libera su nombre.
        """
        query = select(Lote.id).where(
            Lote.establecimiento_id == establecimiento_id,
            Lote.deleted_at.is_(None),
            Lote.id != exclude_id,
            func.lower(func.trim(Lote.nombre)) == normalizar_nombre(nombre),
        )
        result = await self.session.execute(query.limit(1))
        return result.scalars().first() is not None

    async def list_vigentes_para_geometria(
        self, establecimiento_id: UUID, *, exclude_id: UUID
    ) -> list[Lote]:
        """Lotes que ocupan espacio en el lienzo, para validar superposición.

        Los cuatro estados ocupan espacio; solo el tombstone lo libera.
        """
        query = select(Lote).where(
            Lote.establecimiento_id == establecimiento_id,
            Lote.deleted_at.is_(None),
            Lote.id != exclude_id,
        )
        result = await self.session.execute(query)
        return list(result.scalars().all())

    async def contar_animales_vigentes(self, lote_id: UUID) -> int:
        """Animales no borrados que hoy están en el lote."""
        query = select(func.count()).where(
            Animal.lote_id == lote_id, Animal.deleted_at.is_(None)
        )
        result = await self.session.execute(query)
        return int(result.scalar_one())

    async def list_by_establecimiento(
        self,
        establecimiento_id: UUID,
        *,
        estado: EstadoLote | None = None,
        updated_since: datetime | None = None,
        include_deleted: bool = False,
    ) -> list[Lote]:
        query = select(Lote).where(Lote.establecimiento_id == establecimiento_id)
        # Pull delta: el cliente baja borrados para replicarlos local; el listado
        # normal de UI los oculta.
        if not include_deleted:
            query = query.where(Lote.deleted_at.is_(None))
        # Cursor inclusivo (>=), igual que animales: perder un registro cuyo
        # timestamp empata con el cursor es peor que reenviarlo, porque el upsert
        # es idempotente pero la pérdida es silenciosa.
        if updated_since is not None:
            query = query.where(Lote.updated_at >= updated_since)
        if estado is not None:
            query = query.where(Lote.estado == estado)
        result = await self.session.execute(query.order_by(Lote.updated_at))
        return list(result.scalars().all())
