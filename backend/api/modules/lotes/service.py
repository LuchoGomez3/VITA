"""Lógica de negocio del módulo lotes.

El cliente valida primero para poder trabajar sin conexión y dar feedback en la
manga, pero las reglas de acá son las autoritativas: dos dispositivos offline
pueden generar estados que individualmente son válidos y juntos no (dos lotes
con el mismo nombre, o polígonos que se pisan), y eso solo se detecta al
sincronizar.
"""

from datetime import UTC, datetime
from uuid import UUID, uuid4

from shapely.geometry import Polygon
from sqlalchemy.exc import IntegrityError
from sqlalchemy.ext.asyncio import AsyncSession

from api.modules.establecimientos.repository import UsuarioEstablecimientoRepository
from api.modules.lotes import geometria as geo
from api.modules.lotes.exceptions import (
    GeometriaLoteInvalidaError,
    LoteConAnimalesError,
    LoteNoEncontradoError,
    LotesSuperpuestosError,
    NombreLoteDuplicadoError,
)
from api.modules.lotes.models import Lote
from api.modules.lotes.repository import LoteRepository
from api.modules.lotes.schemas import LoteCreate, LoteRead, LoteUpdate
from api.modules.usuarios.models import Usuario
from api.shared.enums import EstadoLote
from api.shared.exceptions import EstablecimientoNoAutorizadoError
from api.shared.sync import as_utc, gana_el_entrante

# Estados que impiden que el lote siga alojando animales. El resto (descanso,
# mantenimiento) sí puede tener hacienda: lo que no admite es el ingreso de
# animales nuevos, y eso lo controla el movimiento, no el lote.
ESTADOS_SIN_ANIMALES = (EstadoLote.inactivo,)


class LoteService:
    def __init__(self, session: AsyncSession) -> None:
        self.session = session
        self.repository = LoteRepository(session)
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

    async def _exigir_nombre_libre(
        self, establecimiento_id: UUID, nombre: str, *, lote_id: UUID
    ) -> None:
        if await self.repository.exists_nombre(
            establecimiento_id, nombre, exclude_id=lote_id
        ):
            raise NombreLoteDuplicadoError(nombre)

    def _validar_geometria(self, geometria: dict) -> tuple[geo.PoligonoLocal, Polygon]:
        try:
            poligono = geo.parsear(geometria)
            forma = geo.validar_forma(poligono)
        except geo.GeometriaInvalidaError as exc:
            raise GeometriaLoteInvalidaError(str(exc)) from exc
        return poligono, forma

    async def _exigir_sin_superposicion(
        self, establecimiento_id: UUID, forma: Polygon, *, lote_id: UUID
    ) -> None:
        """Ningún otro lote vigente puede pisar esta geometría con área positiva.

        Compartir vértice, borde o adyacencia es válido: un campo dividido en
        potreros es exactamente eso.
        """
        vecinos = await self.repository.list_vigentes_para_geometria(
            establecimiento_id, exclude_id=lote_id
        )
        for vecino in vecinos:
            try:
                otra = geo.a_shapely(geo.parsear(vecino.geometria_local))
            except geo.GeometriaInvalidaError:
                # Un lote heredado con geometría ilegible no puede bloquear un
                # alta nueva; se ignora en vez de romper la sincronización.
                continue
            if geo.hay_superposicion(forma, otra):
                raise LotesSuperpuestosError(vecino.id, vecino.nombre)

    async def _exigir_lote_vaciable(self, lote_id: UUID) -> None:
        cantidad = await self.repository.contar_animales_vigentes(lote_id)
        if cantidad > 0:
            raise LoteConAnimalesError(cantidad)

    # ------------------------------------------------------------- operaciones

    async def crear(self, current_user: Usuario, data: LoteCreate) -> LoteRead:
        """Alta de lote, idempotente para offline-first.

        Si el ``id`` (UUID del cliente) ya existe, no es un conflicto: es la
        re-sincronización de un alta que ya se había reproducido, y se resuelve
        con last-write-wins en vez de rechazarla.
        """
        await self._exigir_acceso(current_user, data.establecimiento_id)

        lote_id = data.id or uuid4()
        existente = await self.repository.get_by_id_including_deleted(lote_id)
        if existente is not None:
            await self._exigir_acceso(current_user, existente.establecimiento_id)
            await self._merge_alta_lww(existente, data)
            await self.repository.save(existente)
            return LoteRead.model_validate(existente)

        await self._exigir_nombre_libre(
            data.establecimiento_id, data.nombre, lote_id=lote_id
        )
        _, forma = self._validar_geometria(data.geometria_local)
        await self._exigir_sin_superposicion(
            data.establecimiento_id, forma, lote_id=lote_id
        )

        ahora = datetime.now(UTC)
        lote = Lote(
            id=lote_id,
            created_at=data.created_at or ahora,
            updated_at=data.updated_at or ahora,
            deleted_at=data.deleted_at,
            establecimiento_id=data.establecimiento_id,
            nombre=data.nombre,
            geometria_local=data.geometria_local,
            modo_geometria=data.modo_geometria,
            superficie_ha=data.superficie_ha,
            recurso_forrajero_codigo=data.recurso_forrajero_codigo,
            tiene_agua=data.tiene_agua,
            estado=data.estado,
        )

        try:
            await self.repository.create(lote)
        except IntegrityError as exc:
            # El índice único parcial es la última línea de defensa contra dos
            # dispositivos que crean el mismo nombre a la vez.
            await self.session.rollback()
            raise NombreLoteDuplicadoError(data.nombre) from exc

        return LoteRead.model_validate(lote)

    async def _merge_alta_lww(self, existente: Lote, data: LoteCreate) -> None:
        """Aplica un alta reenviada solo si el cliente trae una versión más nueva.

        La geometría se ignora a propósito: queda bloqueada después del alta en
        esta versión, y Brick reenvía el registro completo en cada replay. Fallar
        acá convertiría un reintento legítimo en un rechazo definitivo.
        """
        if not gana_el_entrante(data.updated_at, existente.updated_at):
            return

        if data.nombre != existente.nombre:
            await self._exigir_nombre_libre(
                existente.establecimiento_id, data.nombre, lote_id=existente.id
            )
        if data.estado in ESTADOS_SIN_ANIMALES and existente.estado != data.estado:
            await self._exigir_lote_vaciable(existente.id)

        existente.nombre = data.nombre
        existente.superficie_ha = data.superficie_ha
        existente.recurso_forrajero_codigo = data.recurso_forrajero_codigo
        existente.tiene_agua = data.tiene_agua
        existente.estado = data.estado
        existente.deleted_at = data.deleted_at
        # Explícito: queda en el SET del UPDATE y el onupdate=func.now() no lo pisa.
        existente.updated_at = as_utc(data.updated_at)

    async def actualizar(
        self, current_user: Usuario, lote_id: UUID, data: LoteUpdate
    ) -> LoteRead:
        """Edición idempotente con last-write-wins."""
        lote = await self.repository.get_by_id_including_deleted(lote_id)
        if lote is None:
            raise LoteNoEncontradoError()
        await self._exigir_acceso(current_user, lote.establecimiento_id)

        if not gana_el_entrante(data.updated_at, lote.updated_at):
            # Cambio rancio: gana el servidor.
            return LoteRead.model_validate(lote)

        if data.nombre is not None and data.nombre != lote.nombre:
            await self._exigir_nombre_libre(
                lote.establecimiento_id, data.nombre, lote_id=lote.id
            )
            lote.nombre = data.nombre
        if data.estado is not None and data.estado != lote.estado:
            if data.estado in ESTADOS_SIN_ANIMALES:
                await self._exigir_lote_vaciable(lote.id)
            lote.estado = data.estado
        if data.superficie_ha is not None:
            lote.superficie_ha = data.superficie_ha
        if data.recurso_forrajero_codigo is not None:
            lote.recurso_forrajero_codigo = data.recurso_forrajero_codigo
        if data.tiene_agua is not None:
            lote.tiene_agua = data.tiene_agua
        if data.deleted_at is not None:
            await self._exigir_lote_vaciable(lote.id)
            lote.deleted_at = data.deleted_at
        lote.updated_at = as_utc(data.updated_at)

        await self.repository.save(lote)
        return LoteRead.model_validate(lote)

    async def borrar(
        self,
        current_user: Usuario,
        lote_id: UUID,
        *,
        deleted_at: datetime | None = None,
        updated_at: datetime | None = None,
    ) -> LoteRead:
        """Soft delete: marca ``deleted_at`` para que el borrado se sincronice.

        El tombstone libera el nombre y deja de ocupar espacio en el lienzo, así
        que solo se permite sobre un lote sin animales vigentes.
        """
        lote = await self.repository.get_by_id_including_deleted(lote_id)
        if lote is None:
            raise LoteNoEncontradoError()
        await self._exigir_acceso(current_user, lote.establecimiento_id)
        await self._exigir_lote_vaciable(lote.id)

        ts = as_utc(deleted_at) or datetime.now(UTC)
        lote.deleted_at = ts
        lote.updated_at = as_utc(updated_at) or ts
        await self.repository.save(lote)
        return LoteRead.model_validate(lote)

    async def listar(
        self,
        current_user: Usuario,
        establecimiento_id: UUID,
        *,
        estado: EstadoLote | None = None,
        updated_since: datetime | None = None,
        include_deleted: bool = False,
    ) -> list[LoteRead]:
        await self._exigir_acceso(current_user, establecimiento_id)
        lotes = await self.repository.list_by_establecimiento(
            establecimiento_id,
            estado=estado,
            updated_since=updated_since,
            include_deleted=include_deleted,
        )
        return [LoteRead.model_validate(lote) for lote in lotes]

    async def detalle(self, current_user: Usuario, lote_id: UUID) -> LoteRead:
        lote = await self.repository.get_by_id(lote_id)
        if lote is None:
            raise LoteNoEncontradoError()
        # Sin acceso: 404 (no se revela la existencia en otro establecimiento).
        membership = await self.membership_repository.get_membership(
            current_user.id, lote.establecimiento_id
        )
        if membership is None:
            raise LoteNoEncontradoError()
        return LoteRead.model_validate(lote)
