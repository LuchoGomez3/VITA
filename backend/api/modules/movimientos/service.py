"""Lógica de negocio del movimiento de animales entre lotes.

Dos propiedades gobiernan este módulo:

**Atomicidad.** O se mueven todos los animales y queda registrado el movimiento,
o no se modifica ninguno. No hace falta abrir una transacción explícita: los
repositories solo hacen ``flush`` y el ``commit`` lo emite ``get_session()`` al
cerrar el request, con ``rollback`` ante cualquier excepción. Por eso este
service nunca debe llamar a ``session.commit()``.

**Idempotencia.** El cliente reintenta desde una cola offline. Reproducir el
mismo UUID no puede mover los animales dos veces ni duplicar el historial.
"""

from datetime import UTC, datetime
from uuid import UUID, uuid4

from sqlalchemy.ext.asyncio import AsyncSession

from api.modules.animales.models import Animal
from api.modules.establecimientos.repository import UsuarioEstablecimientoRepository
from api.modules.lotes.models import Lote
from api.modules.lotes.repository import LoteRepository
from api.modules.movimientos.exceptions import (
    AnimalesNoPertenecenAlLoteOrigenError,
    LoteDestinoNoDisponibleError,
    LoteOrigenNoDisponibleError,
    MovimientoLoteInvalidoError,
)
from api.modules.movimientos.models import MovimientoLote
from api.modules.movimientos.repository import MovimientoLoteRepository
from api.modules.movimientos.schemas import MovimientoLoteCreate, MovimientoLoteRead
from api.modules.usuarios.models import Usuario
from api.shared.enums import EstadoLote
from api.shared.exceptions import EstablecimientoNoAutorizadoError
from api.shared.sync import as_utc


class MovimientoLoteService:
    def __init__(self, session: AsyncSession) -> None:
        self.session = session
        self.repository = MovimientoLoteRepository(session)
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

    async def _resolver_lote(
        self, lote_id: UUID, establecimiento_id: UUID
    ) -> Lote | None:
        """Devuelve el lote solo si es vigente y del mismo establecimiento."""
        lote = await self.lote_repository.get_by_id(lote_id)
        if lote is None or lote.establecimiento_id != establecimiento_id:
            return None
        return lote

    async def _validar_lotes(self, data: MovimientoLoteCreate) -> None:
        if data.lote_origen_id == data.lote_destino_id:
            raise MovimientoLoteInvalidoError(
                "El lote de origen y el de destino deben ser distintos"
            )

        origen = await self._resolver_lote(data.lote_origen_id, data.establecimiento_id)
        if origen is None:
            raise LoteOrigenNoDisponibleError(
                "El lote de origen no existe, fue borrado o es de otro establecimiento"
            )

        destino = await self._resolver_lote(
            data.lote_destino_id, data.establecimiento_id
        )
        if destino is None:
            raise LoteDestinoNoDisponibleError(
                "El lote de destino no existe, fue borrado o es de otro establecimiento"
            )
        if destino.estado != EstadoLote.activo:
            # La columna es VARCHAR, así que al leerla vuelve como ``str``: la
            # comparación con el enum funciona (hereda de ``str``) pero el valor
            # no tiene ``.value``.
            raise LoteDestinoNoDisponibleError(
                f"El lote de destino está en estado '{destino.estado}' "
                "y no admite el ingreso de animales"
            )

    async def _resolver_animales(self, data: MovimientoLoteCreate) -> list[Animal]:
        """Carga y valida los animales del movimiento en una sola consulta.

        Todos deben existir, estar vigentes, ser del establecimiento y estar hoy
        en el lote de origen. Cualquier desvío rechaza la operación entera: mover
        "los que se pueda" dejaría al cliente y al servidor con estados distintos
        sin que nadie se entere.
        """
        animales = await self.repository.list_animales_por_ids(data.animal_ids)
        por_id = {animal.id: animal for animal in animales}

        invalidos = [
            animal_id
            for animal_id in data.animal_ids
            if (animal := por_id.get(animal_id)) is None
            or animal.deleted_at is not None
            or animal.establecimiento_id != data.establecimiento_id
            or animal.lote_id != data.lote_origen_id
        ]
        if invalidos:
            raise AnimalesNoPertenecenAlLoteOrigenError(invalidos)

        return [por_id[animal_id] for animal_id in data.animal_ids]

    # ------------------------------------------------------------- operaciones

    async def crear(
        self, current_user: Usuario, data: MovimientoLoteCreate
    ) -> MovimientoLoteRead:
        """Registra el movimiento y reubica los animales, todo o nada."""
        await self._exigir_acceso(current_user, data.establecimiento_id)

        movimiento_id = data.id or uuid4()
        existente = await self.repository.get_by_id_including_deleted(movimiento_id)
        if existente is not None:
            await self._exigir_acceso(current_user, existente.establecimiento_id)
            return await self._reproducir(existente, data)

        await self._validar_lotes(data)
        animales = await self._resolver_animales(data)

        ahora = datetime.now(UTC)
        fecha = as_utc(data.fecha_movimiento)
        movimiento = MovimientoLote(
            id=movimiento_id,
            created_at=data.created_at or ahora,
            updated_at=data.updated_at or ahora,
            deleted_at=data.deleted_at,
            establecimiento_id=data.establecimiento_id,
            lote_origen_id=data.lote_origen_id,
            lote_destino_id=data.lote_destino_id,
            fecha_movimiento=fecha,
            motivo=data.motivo,
            # El responsable sale del JWT: aceptar el del cliente permitiría
            # imputarle el movimiento a cualquier otro usuario.
            responsable_id=current_user.id,
        )
        self.session.add(movimiento)
        await self.repository.add_detalles(movimiento_id, data.animal_ids)

        for animal in animales:
            animal.lote_id = data.lote_destino_id
            # Explícito para escapar del ``onupdate=func.now()``. Además hace que
            # estos animales bajen en el pull delta de /api/v1/animales, que es
            # como los otros dispositivos ven el lote nuevo.
            animal.updated_at = fecha
            self.session.add(animal)

        await self.session.flush()
        return self._to_read(movimiento, data.animal_ids)

    async def _reproducir(
        self, existente: MovimientoLote, data: MovimientoLoteCreate
    ) -> MovimientoLoteRead:
        """Resuelve el reenvío de un movimiento ya registrado.

        No se vuelve a mover a nadie ni se toca el detalle: el movimiento es un
        hecho histórico, no un estado que se recalcula. Lo único que se propaga es
        el tombstone, y sin revertir la ubicación de los animales — deshacer un
        traslado es una operación distinta que este contrato no modela.
        """
        if data.deleted_at is not None and existente.deleted_at is None:
            existente.deleted_at = as_utc(data.deleted_at)
            existente.updated_at = as_utc(data.updated_at) or existente.deleted_at
            await self.repository.save(existente)

        animal_ids = await self.repository.list_animal_ids(existente.id)
        return self._to_read(existente, animal_ids)

    async def listar(
        self,
        current_user: Usuario,
        establecimiento_id: UUID,
        *,
        updated_since: datetime | None = None,
        include_deleted: bool = False,
    ) -> list[MovimientoLoteRead]:
        await self._exigir_acceso(current_user, establecimiento_id)
        movimientos = await self.repository.list_by_establecimiento(
            establecimiento_id,
            updated_since=updated_since,
            include_deleted=include_deleted,
        )
        detalle = await self.repository.map_animal_ids([m.id for m in movimientos])
        return [
            self._to_read(movimiento, detalle.get(movimiento.id, []))
            for movimiento in movimientos
        ]

    def _to_read(
        self, movimiento: MovimientoLote, animal_ids: list[UUID]
    ) -> MovimientoLoteRead:
        return MovimientoLoteRead(
            id=movimiento.id,
            establecimiento_id=movimiento.establecimiento_id,
            lote_origen_id=movimiento.lote_origen_id,
            lote_destino_id=movimiento.lote_destino_id,
            animal_ids=animal_ids,
            fecha_movimiento=movimiento.fecha_movimiento,
            # El cliente castea ``motivo`` de forma estricta: nunca debe ser null.
            motivo=movimiento.motivo or "",
            responsable_id=movimiento.responsable_id,
            created_at=movimiento.created_at,
            updated_at=movimiento.updated_at,
            deleted_at=movimiento.deleted_at,
        )
