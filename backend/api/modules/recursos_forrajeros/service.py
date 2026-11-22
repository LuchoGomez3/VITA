"""Lógica de negocio del historial de recursos forrajeros.

``lotes.recurso_forrajero_codigo`` deja de escribirse directo: es el recurso del
período más reciente del lote (o null si ese período está cerrado) y lo recalcula
este service en la misma transacción que cambia el historial. Así los clientes
que todavía leen el campo del lote siguen viendo el recurso vigente.
"""

from datetime import UTC, date, datetime, timedelta
from uuid import UUID, uuid4

from sqlalchemy.ext.asyncio import AsyncSession

from api.modules.establecimientos.repository import UsuarioEstablecimientoRepository
from api.modules.lotes.models import Lote
from api.modules.lotes.repository import LoteRepository
from api.modules.recursos_forrajeros.exceptions import (
    FechaFuturaError,
    LoteNoDisponibleError,
    PeriodoRecursoDuplicadoError,
    PeriodoRecursoIdEnConflictoError,
)
from api.modules.recursos_forrajeros.models import PeriodoRecursoForrajero
from api.modules.recursos_forrajeros.repository import (
    PeriodoRecursoForrajeroRepository,
)
from api.modules.recursos_forrajeros.schemas import (
    PeriodoRecursoForrajeroCreate,
    PeriodoRecursoForrajeroRead,
)
from api.modules.usuarios.models import Usuario
from api.shared.enums import RecursoForrajero
from api.shared.exceptions import EstablecimientoNoAutorizadoError
from api.shared.sync import as_utc, gana_el_entrante

# Un día de tolerancia: el cliente manda su fecha local (UTC-3) y el servidor
# compara contra la suya.
_TOLERANCIA_FUTURO = timedelta(days=1)


class RecursoForrajeroService:
    def __init__(self, session: AsyncSession) -> None:
        self.session = session
        self.repository = PeriodoRecursoForrajeroRepository(session)
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

    async def _exigir_fecha_libre(
        self, lote_id: UUID, fecha_desde: date, *, periodo_id: UUID
    ) -> None:
        if await self.repository.exists_vigente_desde(
            lote_id, fecha_desde, excluir_id=periodo_id
        ):
            raise PeriodoRecursoDuplicadoError()

    async def crear(
        self, current_user: Usuario, data: PeriodoRecursoForrajeroCreate
    ) -> PeriodoRecursoForrajeroRead:
        """Alta idempotente. Un reenvío del mismo UUID aplica last-write-wins sobre
        recurso, descripción y fechas; cambiar de lote es un 409."""
        await self._exigir_acceso(current_user, data.establecimiento_id)

        periodo_id = data.id or uuid4()
        existente = await self.repository.get_by_id_including_deleted(periodo_id)
        if existente is not None:
            return await self._reproducir(existente, data)

        lote = await self.lote_repository.get_by_id(data.lote_id)
        if lote is None or lote.establecimiento_id != data.establecimiento_id:
            raise LoteNoDisponibleError()
        if data.fecha_desde > date.today() + _TOLERANCIA_FUTURO:
            raise FechaFuturaError()
        if data.deleted_at is None:
            await self._exigir_fecha_libre(
                data.lote_id, data.fecha_desde, periodo_id=periodo_id
            )

        ahora = datetime.now(UTC)
        periodo = PeriodoRecursoForrajero(
            id=periodo_id,
            created_at=data.created_at or ahora,
            updated_at=data.updated_at or ahora,
            deleted_at=data.deleted_at,
            establecimiento_id=data.establecimiento_id,
            lote_id=data.lote_id,
            recurso_forrajero_codigo=data.recurso_forrajero_codigo,
            descripcion=data.descripcion,
            fecha_desde=data.fecha_desde,
            fecha_hasta=data.fecha_hasta,
            registrado_por_id=current_user.id,
        )
        await self.repository.save(periodo)
        await self.recalcular_recurso_vigente(lote)
        return PeriodoRecursoForrajeroRead.model_validate(periodo)

    async def _reproducir(
        self, existente: PeriodoRecursoForrajero, data: PeriodoRecursoForrajeroCreate
    ) -> PeriodoRecursoForrajeroRead:
        if (
            existente.establecimiento_id != data.establecimiento_id
            or existente.lote_id != data.lote_id
        ):
            raise PeriodoRecursoIdEnConflictoError()
        if not gana_el_entrante(data.updated_at, existente.updated_at):
            return PeriodoRecursoForrajeroRead.model_validate(existente)

        if data.deleted_at is None and (
            existente.deleted_at is not None
            or data.fecha_desde != existente.fecha_desde
        ):
            await self._exigir_fecha_libre(
                existente.lote_id, data.fecha_desde, periodo_id=existente.id
            )

        existente.recurso_forrajero_codigo = data.recurso_forrajero_codigo
        existente.descripcion = data.descripcion
        existente.fecha_desde = data.fecha_desde
        existente.fecha_hasta = data.fecha_hasta
        existente.deleted_at = as_utc(data.deleted_at)
        existente.updated_at = as_utc(data.updated_at)
        await self.repository.save(existente)

        lote = await self.lote_repository.get_by_id_including_deleted(existente.lote_id)
        if lote is not None:
            await self.recalcular_recurso_vigente(lote)
        return PeriodoRecursoForrajeroRead.model_validate(existente)

    async def recalcular_recurso_vigente(self, lote: Lote) -> None:
        """Deja en el lote el recurso de su período más reciente.

        Solo toca el lote si el valor cambia; en ese caso también ``updated_at``,
        para que el lote baje en el pull delta de los otros dispositivos.
        """
        ultimo = await self.repository.get_ultimo_vigente(lote.id)
        vigente = (
            ultimo.recurso_forrajero_codigo
            if ultimo is not None and ultimo.fecha_hasta is None
            else None
        )
        if lote.recurso_forrajero_codigo == vigente:
            return
        lote.recurso_forrajero_codigo = vigente
        lote.updated_at = datetime.now(UTC)
        await self.lote_repository.save(lote)

    async def adoptar_recurso_del_lote(
        self,
        current_user: Usuario,
        lote: Lote,
        codigo: RecursoForrajero | None,
        *,
        fecha_desde: date,
        lote_nuevo: bool = False,
    ) -> None:
        """Compatibilidad con clientes que todavía editan el recurso en el lote.

        Un recurso distinto del vigente se registra como un período que empieza
        en ``fecha_desde`` (si ya hay uno ese día, se corrige). Null no borra
        nada: igual que antes, un PUT sin recurso no lo modifica. Los clientes
        nuevos no mandan el campo, así que nunca pasan por acá.

        No guarda el lote: lo hace quien llama, con el ``updated_at`` del cliente
        (un flush acá dejaría que el ``onupdate`` del modelo lo pise). Por lo
        mismo, un lote nuevo ya trae el recurso en su INSERT (``lote_nuevo``) y
        acá solo se abre su primer período.
        """
        if codigo is None:
            return
        if not lote_nuevo and codigo == lote.recurso_forrajero_codigo:
            return
        # El cliente viejo quiere decir "desde ahora el recurso es este": el
        # período nunca puede quedar antes del último, o no sería el vigente.
        ultimo = await self.repository.get_ultimo_vigente(lote.id)
        if ultimo is not None and ultimo.fecha_desde > fecha_desde:
            fecha_desde = ultimo.fecha_desde
        ahora = datetime.now(UTC)
        mismo_dia = await self.repository.get_vigente_desde(lote.id, fecha_desde)
        if mismo_dia is not None:
            mismo_dia.recurso_forrajero_codigo = codigo
            mismo_dia.descripcion = None
            mismo_dia.updated_at = ahora
            await self.repository.save(mismo_dia)
        else:
            await self.repository.save(
                PeriodoRecursoForrajero(
                    id=uuid4(),
                    created_at=ahora,
                    updated_at=ahora,
                    establecimiento_id=lote.establecimiento_id,
                    lote_id=lote.id,
                    recurso_forrajero_codigo=codigo,
                    descripcion=None,
                    fecha_desde=fecha_desde,
                    fecha_hasta=None,
                    registrado_por_id=current_user.id,
                )
            )
        lote.recurso_forrajero_codigo = codigo

    async def listar(
        self,
        current_user: Usuario,
        establecimiento_id: UUID,
        *,
        lote_id: UUID | None = None,
        updated_since: datetime | None = None,
        include_deleted: bool = False,
    ) -> list[PeriodoRecursoForrajeroRead]:
        await self._exigir_acceso(current_user, establecimiento_id)
        periodos = await self.repository.list_by_establecimiento(
            establecimiento_id,
            lote_id=lote_id,
            updated_since=updated_since,
            include_deleted=include_deleted,
        )
        return [PeriodoRecursoForrajeroRead.model_validate(p) for p in periodos]
