"""Acceso a datos de ``usuarios``. Único punto de queries; sin reglas de negocio."""

from uuid import UUID

from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from api.modules.usuarios.models import Usuario


class UsuarioRepository:
    def __init__(self, session: AsyncSession) -> None:
        self.session = session

    async def get_by_id(self, usuario_id: UUID) -> Usuario | None:
        return await self.session.get(Usuario, usuario_id)

    async def get_by_email(self, email: str) -> Usuario | None:
        result = await self.session.execute(
            select(Usuario).where(func.lower(Usuario.email) == email.lower())
        )
        return result.scalar_one_or_none()

    async def get_by_cuit(self, cuit: str) -> Usuario | None:
        result = await self.session.execute(select(Usuario).where(Usuario.cuit == cuit))
        return result.scalar_one_or_none()

    async def create(self, usuario: Usuario) -> Usuario:
        self.session.add(usuario)
        await self.session.flush()
        await self.session.refresh(usuario)
        return usuario
