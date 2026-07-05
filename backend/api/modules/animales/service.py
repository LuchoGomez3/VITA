"""Lógica de negocio del módulo animales."""

from datetime import UTC, datetime
from uuid import UUID, uuid4

from sqlalchemy.exc import IntegrityError
from sqlalchemy.ext.asyncio import AsyncSession

from api.modules.animales.exceptions import (
    AnimalNoEncontradoError,
    AnimalReferenciaInvalidaError,
    CaravanaDuplicadaError,
    EstablecimientoNoAutorizadoError,
    LoteNoPerteneceAlEstablecimientoError,
)
from api.modules.animales.models import Animal
from api.modules.animales.repository import AnimalRepository
from api.modules.animales.schemas import AnimalCreate, AnimalRead, AnimalUpdate
from api.modules.establecimientos.repository import UsuarioEstablecimientoRepository
from api.modules.pesajes.models import Pesaje
from api.modules.pesajes.repository import PesajeRepository
from api.modules.usuarios.models import Usuario
from api.shared.enums import EstadoAnimal, SexoAnimal


def _as_utc(dt: datetime | None) -> datetime | None:
    """Normaliza a UTC-aware para comparar timestamps de forma robusta.

    Postgres devuelve datetimes aware; SQLite (tests) puede devolverlos naive.
    Asumimos UTC en los naive para no romper la comparación del last-write-wins.
    """
    if dt is None:
        return None
    return dt if dt.tzinfo is not None else dt.replace(tzinfo=UTC)


class AnimalService:
    def __init__(self, session: AsyncSession) -> None:
        self.session = session
        self.repository = AnimalRepository(session)
        self.pesaje_repository = PesajeRepository(session)
        self.membership_repository = UsuarioEstablecimientoRepository(session)

    async def _exigir_acceso(
        self, current_user: Usuario, establecimiento_id: UUID
    ) -> None:
        membership = await self.membership_repository.get_membership(
            current_user.id, establecimiento_id
        )
        if membership is None:
            raise EstablecimientoNoAutorizadoError()

    async def crear(self, current_user: Usuario, data: AnimalCreate) -> AnimalRead:
        """Alta de animal + pesaje inicial en la misma transacción.

        Idempotente para offline-first: si el ``id`` (UUID del cliente) ya existe,
        se trata como re-sincronización del alta y se aplica last-write-wins en vez
        de fallar por caravana duplicada (el pesaje inicial NO se recrea).
        """
        await self._exigir_acceso(current_user, data.establecimiento_id)

        animal_id = data.id or uuid4()
        existente = await self.repository.get_by_id_including_deleted(animal_id)
        if existente is not None:
            # Re-sync de un alta ya registrada: merge con last-write-wins.
            await self._exigir_acceso(current_user, existente.establecimiento_id)
            self._merge_alta_lww(existente, data)
            await self.repository.save(existente)
            return AnimalRead.model_validate(existente)

        # Unicidad GLOBAL de caravana (SENASA 530/2025); excluye el propio id.
        if await self.repository.exists_caravana(
            data.nro_caravana_rfid, exclude_id=animal_id
        ):
            raise CaravanaDuplicadaError(data.nro_caravana_rfid)

        # El lote es obligatorio y debe pertenecer al establecimiento.
        lote = await self.repository.get_lote(data.lote_id)
        if lote is None or lote.establecimiento_id != data.establecimiento_id:
            raise LoteNoPerteneceAlEstablecimientoError()

        # La categoría puede ser global (establecimiento_id None) o del propio.
        if data.categoria_id is not None:
            categoria = await self.repository.get_categoria(data.categoria_id)
            if categoria is None or categoria.establecimiento_id not in (
                None,
                data.establecimiento_id,
            ):
                raise AnimalReferenciaInvalidaError("categoria")

        # Madre/padre deben existir y ser del mismo establecimiento.
        for campo, ref_id in (("madre", data.madre_id), ("padre", data.padre_id)):
            if ref_id is None:
                continue
            ref = await self.repository.get_by_id(ref_id)
            if ref is None or ref.establecimiento_id != data.establecimiento_id:
                raise AnimalReferenciaInvalidaError(campo)

        # Identidad y timestamps los aporta el cliente (offline-first); fallback a
        # los defaults del servidor cuando no vienen.
        animal = Animal(
            id=animal_id,
            created_at=data.created_at or datetime.now(UTC),
            updated_at=data.updated_at or datetime.now(UTC),
            deleted_at=data.deleted_at,
            establecimiento_id=data.establecimiento_id,
            nro_caravana_rfid=data.nro_caravana_rfid,
            caravana_visual=data.caravana_visual,
            sexo=data.sexo,
            raza=data.raza,
            fecha_nacimiento=data.fecha_nacimiento,
            categoria_id=data.categoria_id,
            lote_id=data.lote_id,
            madre_id=data.madre_id,
            padre_id=data.padre_id,
            pelaje=data.pelaje,
            estado=EstadoAnimal.activo,
            observaciones=data.observaciones,
        )

        try:
            await self.repository.create(animal)
            await self.pesaje_repository.create(
                Pesaje(
                    establecimiento_id=data.establecimiento_id,
                    animal_id=animal.id,
                    fecha=data.fecha_pesaje or datetime.now(UTC),
                    peso_kg=data.peso_inicial,
                    metodo=data.metodo_pesaje,
                    responsable_id=current_user.id,
                )
            )
        except IntegrityError as exc:
            await self.session.rollback()
            raise CaravanaDuplicadaError(data.nro_caravana_rfid) from exc

        return AnimalRead.model_validate(animal)

    def _merge_alta_lww(self, existente: Animal, data: AnimalCreate) -> None:
        """Aplica los campos de un alta reenviada solo si el cliente trae una versión
        más nueva (last-write-wins por ``updated_at``). Si es más vieja o igual, se
        conserva la del servidor (no-op)."""
        entrante = _as_utc(data.updated_at) or datetime.now(UTC)
        if entrante <= _as_utc(existente.updated_at):
            return
        existente.nro_caravana_rfid = data.nro_caravana_rfid
        existente.caravana_visual = data.caravana_visual
        existente.sexo = data.sexo
        existente.raza = data.raza
        existente.fecha_nacimiento = data.fecha_nacimiento
        existente.categoria_id = data.categoria_id
        existente.lote_id = data.lote_id
        existente.madre_id = data.madre_id
        existente.padre_id = data.padre_id
        existente.pelaje = data.pelaje
        existente.observaciones = data.observaciones
        existente.deleted_at = data.deleted_at
        # Explícito: queda en el SET del UPDATE y el onupdate=func.now() no lo pisa.
        existente.updated_at = entrante

    async def actualizar(
        self, current_user: Usuario, animal_id: UUID, data: AnimalUpdate
    ) -> AnimalRead:
        """Edición idempotente con last-write-wins. Aplica los campos provistos solo
        si el ``updated_at`` entrante es más nuevo que el persistido."""
        animal = await self.repository.get_by_id_including_deleted(animal_id)
        if animal is None:
            raise AnimalNoEncontradoError()
        await self._exigir_acceso(current_user, animal.establecimiento_id)

        entrante = _as_utc(data.updated_at) or datetime.now(UTC)
        if entrante <= _as_utc(animal.updated_at):
            # Cambio rancio: gana el servidor.
            return AnimalRead.model_validate(animal)

        if data.lote_id is not None:
            lote = await self.repository.get_lote(data.lote_id)
            if lote is None or lote.establecimiento_id != animal.establecimiento_id:
                raise LoteNoPerteneceAlEstablecimientoError()
            animal.lote_id = data.lote_id
        if data.categoria_id is not None:
            categoria = await self.repository.get_categoria(data.categoria_id)
            if categoria is None or categoria.establecimiento_id not in (
                None,
                animal.establecimiento_id,
            ):
                raise AnimalReferenciaInvalidaError("categoria")
            animal.categoria_id = data.categoria_id

        if data.raza is not None:
            animal.raza = data.raza
        if data.fecha_nacimiento is not None:
            animal.fecha_nacimiento = data.fecha_nacimiento
        if data.pelaje is not None:
            animal.pelaje = data.pelaje
        if data.observaciones is not None:
            animal.observaciones = data.observaciones
        if data.estado is not None:
            animal.estado = data.estado
        if data.deleted_at is not None:
            animal.deleted_at = data.deleted_at
        animal.updated_at = entrante

        await self.repository.save(animal)
        return AnimalRead.model_validate(animal)

    async def borrar(
        self,
        current_user: Usuario,
        animal_id: UUID,
        *,
        deleted_at: datetime | None = None,
        updated_at: datetime | None = None,
    ) -> AnimalRead:
        """Soft delete (set ``deleted_at``) para que el borrado se propague en sync.
        Acepta el timestamp local del cliente; si no viene, usa el del servidor."""
        animal = await self.repository.get_by_id_including_deleted(animal_id)
        if animal is None:
            raise AnimalNoEncontradoError()
        await self._exigir_acceso(current_user, animal.establecimiento_id)

        ts = _as_utc(deleted_at) or datetime.now(UTC)
        animal.deleted_at = ts
        animal.updated_at = _as_utc(updated_at) or ts
        await self.repository.save(animal)
        return AnimalRead.model_validate(animal)

    async def listar(
        self,
        current_user: Usuario,
        establecimiento_id: UUID,
        *,
        lote_id: UUID | None = None,
        sexo: SexoAnimal | None = None,
        estado: EstadoAnimal | None = None,
        updated_since: datetime | None = None,
        include_deleted: bool = False,
    ) -> list[AnimalRead]:
        await self._exigir_acceso(current_user, establecimiento_id)
        animales = await self.repository.list_by_establecimiento(
            establecimiento_id,
            lote_id=lote_id,
            sexo=sexo,
            estado=estado,
            updated_since=updated_since,
            include_deleted=include_deleted,
        )
        return [AnimalRead.model_validate(a) for a in animales]

    async def detalle(self, current_user: Usuario, animal_id: UUID) -> AnimalRead:
        animal = await self.repository.get_by_id(animal_id)
        if animal is None:
            raise AnimalNoEncontradoError()
        # Sin acceso: 404 (no se revela la existencia en otro establecimiento).
        membership = await self.membership_repository.get_membership(
            current_user.id, animal.establecimiento_id
        )
        if membership is None:
            raise AnimalNoEncontradoError()
        return AnimalRead.model_validate(animal)
