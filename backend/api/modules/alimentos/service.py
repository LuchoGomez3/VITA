"""Lógica de negocio del catálogo de alimentos.

Los nombres repetidos se toleran a propósito: dos dispositivos sin señal pueden
dar de alta "Maíz partido" a la vez, y rechazar uno con un 409 dejaría rechazados
también todos los registros de alimentación que lo usan. El cliente evita el
duplicado mostrando coincidencias mientras se escribe (ver adr-0015).
"""

from datetime import UTC, datetime
from uuid import UUID, uuid4

from sqlalchemy.ext.asyncio import AsyncSession

from api.modules.alimentos.exceptions import AlimentoIdEnConflictoError
from api.modules.alimentos.models import Alimento
from api.modules.alimentos.repository import AlimentoRepository
from api.modules.alimentos.schemas import AlimentoCreate, AlimentoRead
from api.modules.establecimientos.repository import UsuarioEstablecimientoRepository
from api.modules.usuarios.models import Usuario
from api.shared.exceptions import EstablecimientoNoAutorizadoError
from api.shared.sync import as_utc, gana_el_entrante


class AlimentoService:
    def __init__(self, session: AsyncSession) -> None:
        self.session = session
        self.repository = AlimentoRepository(session)
        self.membership_repository = UsuarioEstablecimientoRepository(session)

    async def _exigir_acceso(
        self, current_user: Usuario, establecimiento_id: UUID
    ) -> None:
        membership = await self.membership_repository.get_membership(
            current_user.id, establecimiento_id
        )
        if membership is None:
            raise EstablecimientoNoAutorizadoError()

    async def crear(self, current_user: Usuario, data: AlimentoCreate) -> AlimentoRead:
        """Alta idempotente: un reenvío del mismo UUID aplica last-write-wins."""
        await self._exigir_acceso(current_user, data.establecimiento_id)

        alimento_id = data.id or uuid4()
        existente = await self.repository.get_by_id_including_deleted(alimento_id)
        if existente is not None:
            # Un alimento global o de otro campo no se edita por esta vía.
            if existente.establecimiento_id != data.establecimiento_id:
                raise AlimentoIdEnConflictoError()
            if gana_el_entrante(data.updated_at, existente.updated_at):
                existente.nombre = data.nombre
                existente.categoria = data.categoria
                existente.unidad = data.unidad
                existente.deleted_at = as_utc(data.deleted_at)
                existente.updated_at = as_utc(data.updated_at)
                await self.repository.save(existente)
            return AlimentoRead.model_validate(existente)

        ahora = datetime.now(UTC)
        alimento = Alimento(
            id=alimento_id,
            created_at=data.created_at or ahora,
            updated_at=data.updated_at or ahora,
            deleted_at=data.deleted_at,
            establecimiento_id=data.establecimiento_id,
            nombre=data.nombre,
            categoria=data.categoria,
            unidad=data.unidad,
            creado_por_id=current_user.id,
        )
        await self.repository.save(alimento)
        return AlimentoRead.model_validate(alimento)

    async def listar(
        self,
        current_user: Usuario,
        establecimiento_id: UUID,
        *,
        updated_since: datetime | None = None,
        include_deleted: bool = False,
    ) -> list[AlimentoRead]:
        await self._exigir_acceso(current_user, establecimiento_id)
        alimentos = await self.repository.list_by_establecimiento(
            establecimiento_id,
            updated_since=updated_since,
            include_deleted=include_deleted,
        )
        return [AlimentoRead.model_validate(a) for a in alimentos]
