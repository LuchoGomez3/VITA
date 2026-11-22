"""Lógica de negocio de los registros de alimentación.

**Atomicidad.** La cabecera y su detalle se escriben juntos o no se escribe nada:
los repositories solo hacen ``flush`` y el ``commit`` lo emite ``get_session()``
al cerrar el request.

**Idempotencia.** El UUID del cliente identifica el registro. Un reenvío aplica
last-write-wins sobre lo editable (cerrar una dieta en curso, corregir cantidad,
potrero o motivo). Si cambia lo que lo identifica —establecimiento, alimento,
tipo o animales— es otro registro con el mismo UUID: 409.
"""

from datetime import UTC, date, datetime, timedelta
from uuid import UUID, uuid4

from sqlalchemy.ext.asyncio import AsyncSession

from api.modules.alimentacion.exceptions import (
    AlimentoNoDisponibleError,
    AnimalesNoDisponiblesError,
    FechaFuturaError,
    LoteNoDisponibleError,
    RegistroAlimentacionIdEnConflictoError,
)
from api.modules.alimentacion.models import RegistroAlimentacion
from api.modules.alimentacion.repository import RegistroAlimentacionRepository
from api.modules.alimentacion.schemas import (
    RegistroAlimentacionCreate,
    RegistroAlimentacionRead,
)
from api.modules.alimentos.repository import AlimentoRepository
from api.modules.establecimientos.repository import UsuarioEstablecimientoRepository
from api.modules.lotes.repository import LoteRepository
from api.modules.usuarios.models import Usuario
from api.shared.exceptions import EstablecimientoNoAutorizadoError
from api.shared.sync import as_utc, gana_el_entrante

# Un día de tolerancia: el cliente manda su fecha local (UTC-3).
_TOLERANCIA_FUTURO = timedelta(days=1)


class RegistroAlimentacionService:
    def __init__(self, session: AsyncSession) -> None:
        self.session = session
        self.repository = RegistroAlimentacionRepository(session)
        self.alimento_repository = AlimentoRepository(session)
        self.lote_repository = LoteRepository(session)
        self.membership_repository = UsuarioEstablecimientoRepository(session)

    async def _exigir_acceso(
        self, current_user: Usuario, establecimiento_id: UUID
    ) -> None:
        membership = await self.membership_repository.get_membership(
            current_user.id, establecimiento_id
        )
        if membership is None:
            raise EstablecimientoNoAutorizadoError()

    # ------------------------------------------------------------------ reglas

    async def _validar_alimento(
        self, alimento_id: UUID, establecimiento_id: UUID
    ) -> None:
        alimento = await self.alimento_repository.get_by_id_including_deleted(
            alimento_id
        )
        if (
            alimento is None
            or alimento.deleted_at is not None
            or alimento.establecimiento_id not in (None, establecimiento_id)
        ):
            raise AlimentoNoDisponibleError()

    async def _validar_lote(
        self, lote_id: UUID | None, establecimiento_id: UUID
    ) -> None:
        """El lote es un hecho histórico: se acepta aunque hoy esté borrado."""
        if lote_id is None:
            return
        lote = await self.lote_repository.get_by_id_including_deleted(lote_id)
        if lote is None or lote.establecimiento_id != establecimiento_id:
            raise LoteNoDisponibleError()

    async def _validar_animales(
        self, animal_ids: list[UUID], establecimiento_id: UUID
    ) -> None:
        """No se exige que estén activos: se puede registrar retroactivamente lo
        que comió un animal que después se vendió."""
        animales = await self.repository.list_animales_por_ids(animal_ids)
        por_id = {animal.id: animal for animal in animales}
        invalidos = [
            animal_id
            for animal_id in animal_ids
            if (animal := por_id.get(animal_id)) is None
            or animal.deleted_at is not None
            or animal.establecimiento_id != establecimiento_id
        ]
        if invalidos:
            raise AnimalesNoDisponiblesError(invalidos)

    # ------------------------------------------------------------- operaciones

    async def crear(
        self, current_user: Usuario, data: RegistroAlimentacionCreate
    ) -> RegistroAlimentacionRead:
        await self._exigir_acceso(current_user, data.establecimiento_id)

        registro_id = data.id or uuid4()
        existente = await self.repository.get_by_id_including_deleted(registro_id)
        if existente is not None:
            return await self._reproducir(existente, data)

        await self._validar_alimento(data.alimento_id, data.establecimiento_id)
        await self._validar_lote(data.lote_id, data.establecimiento_id)
        await self._validar_animales(data.animal_ids, data.establecimiento_id)
        if data.fecha_desde > date.today() + _TOLERANCIA_FUTURO:
            raise FechaFuturaError()

        ahora = datetime.now(UTC)
        registro = RegistroAlimentacion(
            id=registro_id,
            created_at=data.created_at or ahora,
            updated_at=data.updated_at or ahora,
            deleted_at=data.deleted_at,
            establecimiento_id=data.establecimiento_id,
            tipo=data.tipo,
            alimento_id=data.alimento_id,
            lote_id=data.lote_id,
            fecha_desde=data.fecha_desde,
            fecha_hasta=data.fecha_hasta,
            cantidad=data.cantidad,
            unidad=data.unidad,
            base_cantidad=data.base_cantidad,
            motivo=data.motivo,
            # El responsable sale del JWT: aceptar el del cliente permitiría
            # imputarle el registro a cualquier otro usuario.
            responsable_id=current_user.id,
        )
        self.session.add(registro)
        self.repository.add_detalles(registro_id, data.animal_ids)
        await self.session.flush()
        return self._to_read(registro, data.animal_ids)

    async def _reproducir(
        self, existente: RegistroAlimentacion, data: RegistroAlimentacionCreate
    ) -> RegistroAlimentacionRead:
        animal_ids = await self.repository.list_animal_ids(existente.id)
        if (
            existente.establecimiento_id != data.establecimiento_id
            or existente.alimento_id != data.alimento_id
            or existente.tipo != data.tipo
            or set(animal_ids) != set(data.animal_ids)
        ):
            raise RegistroAlimentacionIdEnConflictoError()

        if gana_el_entrante(data.updated_at, existente.updated_at):
            if data.lote_id != existente.lote_id:
                await self._validar_lote(data.lote_id, existente.establecimiento_id)
            existente.lote_id = data.lote_id
            existente.fecha_desde = data.fecha_desde
            existente.fecha_hasta = data.fecha_hasta
            existente.cantidad = data.cantidad
            existente.unidad = data.unidad
            existente.base_cantidad = data.base_cantidad
            existente.motivo = data.motivo
            existente.deleted_at = as_utc(data.deleted_at)
            existente.updated_at = as_utc(data.updated_at)
            await self.repository.save(existente)
        return self._to_read(existente, animal_ids)

    async def listar(
        self,
        current_user: Usuario,
        establecimiento_id: UUID,
        *,
        animal_id: UUID | None = None,
        updated_since: datetime | None = None,
        include_deleted: bool = False,
    ) -> list[RegistroAlimentacionRead]:
        await self._exigir_acceso(current_user, establecimiento_id)
        registros = await self.repository.list_by_establecimiento(
            establecimiento_id,
            animal_id=animal_id,
            updated_since=updated_since,
            include_deleted=include_deleted,
        )
        detalle = await self.repository.map_animal_ids([r.id for r in registros])
        return [self._to_read(r, detalle.get(r.id, [])) for r in registros]

    def _to_read(
        self, registro: RegistroAlimentacion, animal_ids: list[UUID]
    ) -> RegistroAlimentacionRead:
        return RegistroAlimentacionRead(
            id=registro.id,
            establecimiento_id=registro.establecimiento_id,
            tipo=registro.tipo,
            alimento_id=registro.alimento_id,
            lote_id=registro.lote_id,
            fecha_desde=registro.fecha_desde,
            fecha_hasta=registro.fecha_hasta,
            cantidad=registro.cantidad,
            unidad=registro.unidad,
            base_cantidad=registro.base_cantidad,
            motivo=registro.motivo,
            animal_ids=animal_ids,
            responsable_id=registro.responsable_id,
            created_at=registro.created_at,
            updated_at=registro.updated_at,
            deleted_at=registro.deleted_at,
        )
