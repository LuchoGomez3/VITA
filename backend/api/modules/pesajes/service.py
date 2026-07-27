"""Lógica de negocio del módulo pesajes."""

from datetime import UTC, datetime
from uuid import UUID, uuid4

from sqlalchemy.ext.asyncio import AsyncSession

from api.modules.animales.repository import AnimalRepository
from api.modules.establecimientos.repository import UsuarioEstablecimientoRepository
from api.modules.pesajes.exceptions import (
    AnimalNoPerteneceAlEstablecimientoError,
    EstablecimientoNoAutorizadoError,
    PesajeNoEncontradoError,
)
from api.modules.pesajes.models import Pesaje
from api.modules.pesajes.repository import PesajeRepository
from api.modules.pesajes.schemas import PesajeCreate, PesajeRead, PesajeUpdate
from api.modules.usuarios.models import Usuario


def _as_utc(dt: datetime | None) -> datetime | None:
    """Normaliza a UTC-aware para comparar timestamps de forma robusta.

    Postgres devuelve datetimes aware; SQLite (tests) puede devolverlos naive.
    Asumimos UTC en los naive para no romper el last-write-wins.
    """
    if dt is None:
        return None
    return dt if dt.tzinfo is not None else dt.replace(tzinfo=UTC)


class PesajeService:
    def __init__(self, session: AsyncSession) -> None:
        self.session = session
        self.repository = PesajeRepository(session)
        self.animal_repository = AnimalRepository(session)
        self.membership_repository = UsuarioEstablecimientoRepository(session)

    async def _exigir_acceso(
        self, current_user: Usuario, establecimiento_id: UUID
    ) -> None:
        membership = await self.membership_repository.get_membership(
            current_user.id, establecimiento_id
        )
        if membership is None:
            raise EstablecimientoNoAutorizadoError()

    async def crear(self, current_user: Usuario, data: PesajeCreate) -> PesajeRead:
        """Registra una pesada de un animal.

        Idempotente para offline-first: si el ``id`` (UUID del cliente) ya existe se
        trata como re-sincronización y se aplica last-write-wins en vez de duplicar.
        """
        await self._exigir_acceso(current_user, data.establecimiento_id)

        pesaje_id = data.id or uuid4()
        existente = await self.repository.get_by_id_including_deleted(pesaje_id)
        if existente is not None:
            await self._exigir_acceso(current_user, existente.establecimiento_id)
            self._merge_alta_lww(existente, data)
            await self.repository.save(existente)
            return PesajeRead.model_validate(existente)

        # El animal debe existir y pertenecer al establecimiento indicado.
        animal = await self.animal_repository.get_by_id(data.animal_id)
        if animal is None or animal.establecimiento_id != data.establecimiento_id:
            raise AnimalNoPerteneceAlEstablecimientoError()

        pesaje = Pesaje(
            id=pesaje_id,
            created_at=data.created_at or datetime.now(UTC),
            updated_at=data.updated_at or datetime.now(UTC),
            deleted_at=data.deleted_at,
            establecimiento_id=data.establecimiento_id,
            animal_id=data.animal_id,
            fecha=data.fecha or datetime.now(UTC),
            peso_kg=data.peso_kg,
            metodo=data.metodo,
            es_estimado=data.es_estimado,
            condicion_corporal=data.condicion_corporal,
            foto_url=data.foto_url,
            responsable_id=data.responsable_id or current_user.id,
            observaciones=data.observaciones,
        )
        await self.repository.create(pesaje)
        return PesajeRead.model_validate(pesaje)

    def _merge_alta_lww(self, existente: Pesaje, data: PesajeCreate) -> None:
        """Aplica un alta reenviada solo si el cliente trae una versión más nueva."""
        entrante = _as_utc(data.updated_at) or datetime.now(UTC)
        if entrante <= _as_utc(existente.updated_at):
            return
        existente.peso_kg = data.peso_kg
        if data.fecha is not None:
            existente.fecha = data.fecha
        existente.metodo = data.metodo
        existente.es_estimado = data.es_estimado
        existente.condicion_corporal = data.condicion_corporal
        existente.foto_url = data.foto_url
        existente.observaciones = data.observaciones
        existente.deleted_at = data.deleted_at
        existente.updated_at = entrante

    async def actualizar(
        self, current_user: Usuario, pesaje_id: UUID, data: PesajeUpdate
    ) -> PesajeRead:
        """Edición idempotente con last-write-wins. Aplica los campos provistos solo
        si el ``updated_at`` entrante es más nuevo que el persistido."""
        pesaje = await self.repository.get_by_id_including_deleted(pesaje_id)
        if pesaje is None:
            raise PesajeNoEncontradoError()
        await self._exigir_acceso(current_user, pesaje.establecimiento_id)

        entrante = _as_utc(data.updated_at) or datetime.now(UTC)
        if entrante <= _as_utc(pesaje.updated_at):
            # Cambio rancio: gana el servidor.
            return PesajeRead.model_validate(pesaje)

        if data.peso_kg is not None:
            pesaje.peso_kg = data.peso_kg
        if data.fecha is not None:
            pesaje.fecha = data.fecha
        if data.metodo is not None:
            pesaje.metodo = data.metodo
        if data.es_estimado is not None:
            pesaje.es_estimado = data.es_estimado
        if data.condicion_corporal is not None:
            pesaje.condicion_corporal = data.condicion_corporal
        if data.foto_url is not None:
            pesaje.foto_url = data.foto_url
        if data.observaciones is not None:
            pesaje.observaciones = data.observaciones
        if data.deleted_at is not None:
            pesaje.deleted_at = data.deleted_at
        pesaje.updated_at = entrante

        await self.repository.save(pesaje)
        return PesajeRead.model_validate(pesaje)

    async def borrar(
        self,
        current_user: Usuario,
        pesaje_id: UUID,
        *,
        deleted_at: datetime | None = None,
        updated_at: datetime | None = None,
    ) -> PesajeRead:
        """Soft delete (set ``deleted_at``) para que el borrado se propague en sync."""
        pesaje = await self.repository.get_by_id_including_deleted(pesaje_id)
        if pesaje is None:
            raise PesajeNoEncontradoError()
        await self._exigir_acceso(current_user, pesaje.establecimiento_id)

        ts = _as_utc(deleted_at) or datetime.now(UTC)
        pesaje.deleted_at = ts
        pesaje.updated_at = _as_utc(updated_at) or ts
        await self.repository.save(pesaje)
        return PesajeRead.model_validate(pesaje)

    async def listar(
        self,
        current_user: Usuario,
        establecimiento_id: UUID,
        *,
        animal_id: UUID | None = None,
        updated_since: datetime | None = None,
        include_deleted: bool = False,
    ) -> list[PesajeRead]:
        """Historial de pesajes del establecimiento, opcionalmente de un solo animal."""
        await self._exigir_acceso(current_user, establecimiento_id)
        pesajes = await self.repository.list_by_establecimiento(
            establecimiento_id,
            animal_id=animal_id,
            updated_since=updated_since,
            include_deleted=include_deleted,
        )
        return [PesajeRead.model_validate(p) for p in pesajes]

    async def detalle(self, current_user: Usuario, pesaje_id: UUID) -> PesajeRead:
        pesaje = await self.repository.get_by_id(pesaje_id)
        if pesaje is None:
            raise PesajeNoEncontradoError()
        # Sin acceso: 404 (no se revela la existencia en otro establecimiento).
        membership = await self.membership_repository.get_membership(
            current_user.id, pesaje.establecimiento_id
        )
        if membership is None:
            raise PesajeNoEncontradoError()
        return PesajeRead.model_validate(pesaje)
