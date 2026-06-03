"""Lógica de negocio del módulo establecimientos."""

from uuid import UUID

from sqlalchemy.exc import IntegrityError
from sqlalchemy.ext.asyncio import AsyncSession

from api.modules.establecimientos.exceptions import (
    EstablecimientoNoEncontradoError,
    RenspaDuplicadoError,
    RenspaVacioError,
)
from api.modules.establecimientos.models import (
    Establecimiento,
    UsuarioEstablecimiento,
)
from api.modules.establecimientos.repository import (
    EstablecimientoRepository,
    UsuarioEstablecimientoRepository,
)
from api.modules.establecimientos.schemas import (
    EstablecimientoCreate,
    EstablecimientoRead,
)
from api.modules.usuarios.models import Usuario
from api.shared.enums import RolUsuario


class EstablecimientoService:
    def __init__(self, session: AsyncSession) -> None:
        self.session = session
        self.repository = EstablecimientoRepository(session)
        self.membership_repository = UsuarioEstablecimientoRepository(session)

    async def crear(
        self, current_user: Usuario, data: EstablecimientoCreate
    ) -> EstablecimientoRead:
        """Crea el establecimiento y la membresía owner en la misma transacción."""
        nro_renspa = data.nro_renspa.strip()
        if not nro_renspa:
            raise RenspaVacioError()

        # Pre-chequeo de unicidad para un error de dominio claro; la constraint
        # de la DB es la garantía final (manejada abajo ante carreras).
        if await self.repository.get_by_renspa(nro_renspa) is not None:
            raise RenspaDuplicadoError(nro_renspa)

        establecimiento = Establecimiento(
            owner_id=current_user.id,
            nombre=data.nombre,
            nro_renspa=nro_renspa,
            cuit=data.cuit,
            superficie_ha=data.superficie_ha,
            provincia=data.provincia,
            departamento=data.departamento,
            localidad=data.localidad,
        )

        try:
            await self.repository.create(establecimiento)
            await self.membership_repository.create_membership(
                UsuarioEstablecimiento(
                    usuario_id=current_user.id,
                    establecimiento_id=establecimiento.id,
                    rol=RolUsuario.owner,
                    activo=True,
                )
            )
        except IntegrityError as exc:
            await self.session.rollback()
            raise RenspaDuplicadoError(nro_renspa) from exc

        return EstablecimientoRead.model_validate(establecimiento)

    async def listar(self, current_user: Usuario) -> list[EstablecimientoRead]:
        establecimientos = await self.repository.list_by_usuario(current_user.id)
        return [EstablecimientoRead.model_validate(e) for e in establecimientos]

    async def detalle(
        self, current_user: Usuario, establecimiento_id: UUID
    ) -> EstablecimientoRead:
        establecimiento = await self.repository.get_by_id(establecimiento_id)
        if establecimiento is None:
            raise EstablecimientoNoEncontradoError()

        # Multi-tenant: el usuario debe tener una membresía activa.
        membership = await self.membership_repository.get_membership(
            current_user.id, establecimiento_id
        )
        if membership is None:
            raise EstablecimientoNoEncontradoError()

        return EstablecimientoRead.model_validate(establecimiento)
