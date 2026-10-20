"""Acceso a datos del equipo: membresías e invitaciones. Sin reglas de negocio."""

from datetime import datetime
from uuid import UUID

from sqlalchemy import select, update
from sqlalchemy.ext.asyncio import AsyncSession

from api.modules.equipo.models import InvitacionEstablecimiento
from api.modules.establecimientos.models import UsuarioEstablecimiento
from api.modules.usuarios.models import Usuario
from api.shared.enums import EstadoInvitacion


class MiembroRepository:
    def __init__(self, session: AsyncSession) -> None:
        self.session = session

    async def list_activos(
        self, establecimiento_id: UUID
    ) -> list[tuple[Usuario, UsuarioEstablecimiento]]:
        """Membresías activas con su usuario, de la más vieja a la más nueva."""
        result = await self.session.execute(
            select(Usuario, UsuarioEstablecimiento)
            .join(
                UsuarioEstablecimiento, UsuarioEstablecimiento.usuario_id == Usuario.id
            )
            .where(
                UsuarioEstablecimiento.establecimiento_id == establecimiento_id,
                UsuarioEstablecimiento.activo.is_(True),
            )
            .order_by(UsuarioEstablecimiento.created_at)
        )
        return [(usuario, membresia) for usuario, membresia in result.all()]

    async def list_de_usuario(
        self, usuario_id: UUID, establecimiento_id: UUID
    ) -> list[UsuarioEstablecimiento]:
        """Todas las membresías (activas e inactivas) del usuario en el campo."""
        result = await self.session.execute(
            select(UsuarioEstablecimiento).where(
                UsuarioEstablecimiento.usuario_id == usuario_id,
                UsuarioEstablecimiento.establecimiento_id == establecimiento_id,
            )
        )
        return list(result.scalars().all())

    async def guardar(
        self, membresia: UsuarioEstablecimiento
    ) -> UsuarioEstablecimiento:
        self.session.add(membresia)
        await self.session.flush()
        return membresia


class InvitacionRepository:
    def __init__(self, session: AsyncSession) -> None:
        self.session = session

    async def get(
        self, invitacion_id: UUID, establecimiento_id: UUID
    ) -> InvitacionEstablecimiento | None:
        result = await self.session.execute(
            select(InvitacionEstablecimiento).where(
                InvitacionEstablecimiento.id == invitacion_id,
                InvitacionEstablecimiento.establecimiento_id == establecimiento_id,
            )
        )
        return result.scalar_one_or_none()

    async def get_por_codigo_hash(
        self, codigo_hash: str
    ) -> InvitacionEstablecimiento | None:
        result = await self.session.execute(
            select(InvitacionEstablecimiento).where(
                InvitacionEstablecimiento.codigo_hash == codigo_hash
            )
        )
        return result.scalars().first()

    async def get_pendiente(
        self, establecimiento_id: UUID, email: str
    ) -> InvitacionEstablecimiento | None:
        result = await self.session.execute(
            select(InvitacionEstablecimiento).where(
                InvitacionEstablecimiento.establecimiento_id == establecimiento_id,
                InvitacionEstablecimiento.email == email,
                InvitacionEstablecimiento.estado == EstadoInvitacion.pendiente,
            )
        )
        return result.scalar_one_or_none()

    async def list_pendientes(
        self, establecimiento_id: UUID
    ) -> list[InvitacionEstablecimiento]:
        result = await self.session.execute(
            select(InvitacionEstablecimiento)
            .where(
                InvitacionEstablecimiento.establecimiento_id == establecimiento_id,
                InvitacionEstablecimiento.estado == EstadoInvitacion.pendiente,
            )
            .order_by(InvitacionEstablecimiento.created_at)
        )
        return list(result.scalars().all())

    async def guardar(
        self, invitacion: InvitacionEstablecimiento
    ) -> InvitacionEstablecimiento:
        self.session.add(invitacion)
        await self.session.flush()
        return invitacion

    async def marcar_aceptada(
        self, invitacion_id: UUID, *, usuario_id: UUID, ahora: datetime
    ) -> bool:
        """Pasa la invitación a aceptada solo si sigue pendiente.

        Es un UPDATE condicional y no un read-modify-write: si dos requests
        canjean el mismo código a la vez (doble toque, reintento), solo uno
        cambia la fila y el otro recibe ``False``.
        """
        result = await self.session.execute(
            update(InvitacionEstablecimiento)
            .where(
                InvitacionEstablecimiento.id == invitacion_id,
                InvitacionEstablecimiento.estado == EstadoInvitacion.pendiente,
            )
            .values(
                estado=EstadoInvitacion.aceptada,
                aceptada_por_id=usuario_id,
                aceptada_en=ahora,
                updated_at=ahora,
            )
            .execution_options(synchronize_session=False)
        )
        return result.rowcount == 1
