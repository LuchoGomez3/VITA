"""Lógica de negocio del módulo establecimientos."""

import re
from uuid import UUID

from sqlalchemy.exc import IntegrityError
from sqlalchemy.ext.asyncio import AsyncSession

from api.modules.establecimientos.exceptions import (
    EstablecimientoNoEncontradoError,
    RenspaDuplicadoError,
    RenspaFormatoInvalidoError,
    RenspaVacioError,
    SuperficieInvalidaError,
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
    EstablecimientoConRolRead,
    EstablecimientoCreate,
    EstablecimientoRead,
    EstablecimientoUpdate,
)
from api.modules.usuarios.models import Usuario
from api.shared.cuit import CuitInvalidoError, normalizar_cuit, validar_cuit
from api.shared.enums import RolUsuario

# Formato oficial del RENSPA en esta iniciativa: NN.NNN.N.NNNNN/NN (13 dígitos,
# sin dígito verificador). Ver .claude/specs/registrar-establecimiento.md.
_RENSPA_PATTERN = re.compile(r"^\d{2}\.\d{3}\.\d\.\d{5}/\d{2}$")


class EstablecimientoService:
    def __init__(self, session: AsyncSession) -> None:
        self.session = session
        self.repository = EstablecimientoRepository(session)
        self.membership_repository = UsuarioEstablecimientoRepository(session)

    async def crear(
        self, current_user: Usuario, data: EstablecimientoCreate
    ) -> EstablecimientoConRolRead:
        """Crea el establecimiento y la membresía owner en la misma transacción."""
        nro_renspa = data.nro_renspa.strip()
        if not nro_renspa:
            raise RenspaVacioError()
        if not _RENSPA_PATTERN.fullmatch(nro_renspa):
            raise RenspaFormatoInvalidoError(nro_renspa)

        cuit_normalizado = self._validar_cuit_opcional(data.cuit)

        if data.superficie_ha is not None and data.superficie_ha <= 0:
            raise SuperficieInvalidaError()

        # Pre-chequeo de unicidad para un error de dominio claro; la constraint
        # de la DB es la garantía final (manejada abajo ante carreras).
        if await self.repository.get_by_renspa(nro_renspa) is not None:
            raise RenspaDuplicadoError(nro_renspa)

        establecimiento = Establecimiento(
            owner_id=current_user.id,
            nombre=data.nombre,
            descripcion=data.descripcion,
            tipo_produccion=data.tipo_produccion,
            nro_renspa=nro_renspa,
            cuit=cuit_normalizado,
            superficie_ha=data.superficie_ha,
            provincia=data.provincia,
            departamento=data.departamento,
            localidad=data.localidad,
            latitud=data.latitud,
            longitud=data.longitud,
            poligono=_poligono_a_dicts(data.poligono),
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

        return self._representar_con_rol(establecimiento, RolUsuario.owner)

    async def listar(self, current_user: Usuario) -> list[EstablecimientoConRolRead]:
        establecimientos = await self.repository.list_by_usuario(current_user.id)
        return [
            self._representar_con_rol(establecimiento, rol)
            for establecimiento, rol in establecimientos
        ]

    async def detalle(
        self, current_user: Usuario, establecimiento_id: UUID
    ) -> EstablecimientoConRolRead:
        establecimiento, membership = await self._obtener_con_acceso(
            current_user, establecimiento_id
        )
        return self._representar_con_rol(establecimiento, membership.rol)

    async def actualizar(
        self,
        current_user: Usuario,
        establecimiento_id: UUID,
        data: EstablecimientoUpdate,
    ) -> EstablecimientoConRolRead:
        """Actualiza los campos provistos, re-validando cada uno igual que en `crear`."""
        establecimiento, membership = await self._obtener_con_acceso(
            current_user, establecimiento_id
        )

        nro_renspa = establecimiento.nro_renspa
        if data.nro_renspa is not None:
            nro_renspa = data.nro_renspa.strip()
            if not nro_renspa:
                raise RenspaVacioError()
            if not _RENSPA_PATTERN.fullmatch(nro_renspa):
                raise RenspaFormatoInvalidoError(nro_renspa)
            if (
                await self.repository.get_by_renspa(
                    nro_renspa, exclude_id=establecimiento_id
                )
                is not None
            ):
                raise RenspaDuplicadoError(nro_renspa)
            establecimiento.nro_renspa = nro_renspa

        if data.cuit is not None:
            establecimiento.cuit = self._validar_cuit_opcional(data.cuit)

        if data.superficie_ha is not None:
            if data.superficie_ha <= 0:
                raise SuperficieInvalidaError()
            establecimiento.superficie_ha = data.superficie_ha

        for campo in (
            "nombre",
            "descripcion",
            "tipo_produccion",
            "provincia",
            "departamento",
            "localidad",
            "latitud",
            "longitud",
        ):
            valor = getattr(data, campo)
            if valor is not None:
                setattr(establecimiento, campo, valor)

        if data.poligono is not None:
            establecimiento.poligono = _poligono_a_dicts(data.poligono)

        try:
            await self.repository.update(establecimiento)
        except IntegrityError as exc:
            await self.session.rollback()
            raise RenspaDuplicadoError(nro_renspa) from exc

        return self._representar_con_rol(establecimiento, membership.rol)

    async def _obtener_con_acceso(
        self, current_user: Usuario, establecimiento_id: UUID
    ) -> tuple[Establecimiento, UsuarioEstablecimiento]:
        establecimiento = await self.repository.get_by_id(establecimiento_id)
        if establecimiento is None:
            raise EstablecimientoNoEncontradoError()

        # Multi-tenant: el usuario debe tener una membresía activa.
        membership = await self.membership_repository.get_membership(
            current_user.id, establecimiento_id
        )
        if membership is None:
            raise EstablecimientoNoEncontradoError()

        return establecimiento, membership

    @staticmethod
    def _representar_con_rol(
        establecimiento: Establecimiento, rol: RolUsuario
    ) -> EstablecimientoConRolRead:
        datos = EstablecimientoRead.model_validate(establecimiento).model_dump()
        return EstablecimientoConRolRead(**datos, rol=rol)

    def _validar_cuit_opcional(self, cuit: str | None) -> str | None:
        if cuit is None:
            return None

        try:
            cuit_normalizado = normalizar_cuit(cuit)
        except ValueError as exc:
            raise CuitInvalidoError(cuit) from exc

        if not validar_cuit(cuit_normalizado):
            raise CuitInvalidoError(cuit)

        return cuit_normalizado


def _poligono_a_dicts(vertices) -> list[dict] | None:
    if vertices is None:
        return None
    return [v.model_dump() for v in vertices]
