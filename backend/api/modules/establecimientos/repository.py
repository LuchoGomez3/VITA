"""Acceso a datos de establecimientos y membresías. Sin reglas de negocio."""

from uuid import UUID

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from api.modules.establecimientos.models import (
    Establecimiento,
    UsuarioEstablecimiento,
)


class EstablecimientoRepository:
    def __init__(self, session: AsyncSession) -> None:
        self.session = session

    async def create(self, establecimiento: Establecimiento) -> Establecimiento:
        self.session.add(establecimiento)
        await self.session.flush()
        return establecimiento

    async def get_by_id(self, establecimiento_id: UUID) -> Establecimiento | None:
        est = await self.session.get(Establecimiento, establecimiento_id)
        if est is None or est.deleted_at is not None:
            return None
        return est

    async def get_by_renspa(self, nro_renspa: str) -> Establecimiento | None:
        result = await self.session.execute(
            select(Establecimiento).where(Establecimiento.nro_renspa == nro_renspa)
        )
        return result.scalar_one_or_none()

    async def list_by_usuario(self, usuario_id: UUID) -> list[Establecimiento]:
        """Establecimientos a los que el usuario tiene acceso (membresía activa)."""
        result = await self.session.execute(
            select(Establecimiento)
            .join(
                UsuarioEstablecimiento,
                UsuarioEstablecimiento.establecimiento_id == Establecimiento.id,
            )
            .where(
                UsuarioEstablecimiento.usuario_id == usuario_id,
                UsuarioEstablecimiento.activo.is_(True),
                Establecimiento.deleted_at.is_(None),
            )
            .order_by(Establecimiento.created_at)
        )
        return list(result.scalars().all())


class UsuarioEstablecimientoRepository:
    def __init__(self, session: AsyncSession) -> None:
        self.session = session

    async def create_membership(
        self, membership: UsuarioEstablecimiento
    ) -> UsuarioEstablecimiento:
        self.session.add(membership)
        await self.session.flush()
        return membership

    async def get_membership(
        self, usuario_id: UUID, establecimiento_id: UUID
    ) -> UsuarioEstablecimiento | None:
        result = await self.session.execute(
            select(UsuarioEstablecimiento).where(
                UsuarioEstablecimiento.usuario_id == usuario_id,
                UsuarioEstablecimiento.establecimiento_id == establecimiento_id,
                UsuarioEstablecimiento.activo.is_(True),
            )
        )
        return result.scalars().first()
