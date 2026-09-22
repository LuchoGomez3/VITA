"""Lógica de negocio del módulo calibraciones_ml."""

import logging
from datetime import UTC, datetime
from uuid import UUID, uuid4

from sqlalchemy.ext.asyncio import AsyncSession

from api.modules.animales.repository import AnimalRepository
from api.modules.calibraciones_ml.exceptions import (
    AnimalNoPerteneceAlEstablecimientoError,
    MuestraCalibracionNoEncontradaError,
    SubidaDeImagenFallidaError,
)
from api.modules.calibraciones_ml.imagen import clave_de_imagen, normalizar_jpeg
from api.modules.calibraciones_ml.models import MuestraCalibracion
from api.modules.calibraciones_ml.repository import MuestraCalibracionRepository
from api.modules.calibraciones_ml.schemas import (
    MuestraCalibracionCreate,
    MuestraCalibracionRead,
    MuestraCalibracionUpdate,
)
from api.modules.establecimientos.repository import UsuarioEstablecimientoRepository
from api.modules.usuarios.models import Usuario
from api.shared.enums import EstadoMuestraCalibracion
from api.shared.exceptions import EstablecimientoNoAutorizadoError
from api.shared.sync import as_utc, gana_el_entrante
from core.storage import ObjectStorage, StorageError

logger = logging.getLogger(__name__)


class MuestraCalibracionService:
    def __init__(
        self, session: AsyncSession, storage: ObjectStorage | None = None
    ) -> None:
        self.session = session
        self.repository = MuestraCalibracionRepository(session)
        self.animal_repository = AnimalRepository(session)
        self.membership_repository = UsuarioEstablecimientoRepository(session)
        # Solo el alta de imagen lo necesita; el resto de las operaciones no
        # tocan Storage y pueden construir el service sin él.
        self.storage = storage

    async def _exigir_acceso(
        self, current_user: Usuario, establecimiento_id: UUID
    ) -> None:
        membership = await self.membership_repository.get_membership(
            current_user.id, establecimiento_id
        )
        if membership is None:
            raise EstablecimientoNoAutorizadoError()

    # ------------------------------------------------------------------ alta

    async def crear(
        self, current_user: Usuario, data: MuestraCalibracionCreate
    ) -> MuestraCalibracionRead:
        """Registra la metadata de una muestra; la imagen llega después.

        Idempotente para offline-first: si el ``id`` (UUID del cliente) ya existe
        se trata como re-sincronización y se aplica last-write-wins en vez de
        duplicar.
        """
        await self._exigir_acceso(current_user, data.establecimiento_id)

        muestra_id = data.id or uuid4()
        existente = await self.repository.get_by_id_including_deleted(muestra_id)
        if existente is not None:
            # Un UUID de cliente es adivinable: hay que revalidar contra el
            # tenant persistido, no contra el que viene en el payload.
            await self._exigir_acceso(current_user, existente.establecimiento_id)
            self._merge_alta_lww(existente, data)
            await self.repository.save(existente)
            return MuestraCalibracionRead.model_validate(existente)

        animal = await self.animal_repository.get_by_id(data.animal_id)
        if animal is None or animal.establecimiento_id != data.establecimiento_id:
            raise AnimalNoPerteneceAlEstablecimientoError()

        muestra = MuestraCalibracion(
            id=muestra_id,
            created_at=data.created_at or datetime.now(UTC),
            updated_at=data.updated_at or datetime.now(UTC),
            deleted_at=data.deleted_at,
            establecimiento_id=data.establecimiento_id,
            animal_id=data.animal_id,
            peso_real_kg=data.peso_real_kg,
            peso_estimado_kg=data.peso_estimado_kg,
            fecha_captura=data.fecha_captura or datetime.now(UTC),
            estado=EstadoMuestraCalibracion.pendiente_imagen,
            # La identidad del que carga sale del JWT, nunca del payload.
            responsable_id=current_user.id,
            observaciones=data.observaciones,
        )
        await self.repository.create(muestra)
        return MuestraCalibracionRead.model_validate(muestra)

    def _merge_alta_lww(
        self, existente: MuestraCalibracion, data: MuestraCalibracionCreate
    ) -> None:
        """Aplica un alta reenviada solo si el cliente trae una versión más nueva.

        No toca ``imagen_key`` ni ``estado``: son del backend. Si la foto ya
        subió, reenviar la metadata no puede devolver la muestra a
        ``pendiente_imagen`` y sacarla del dataset.
        """
        entrante = as_utc(data.updated_at) or datetime.now(UTC)
        if not gana_el_entrante(entrante, existente.updated_at):
            return
        existente.peso_real_kg = data.peso_real_kg
        existente.peso_estimado_kg = data.peso_estimado_kg
        if data.fecha_captura is not None:
            existente.fecha_captura = data.fecha_captura
        existente.observaciones = data.observaciones
        existente.deleted_at = data.deleted_at
        existente.updated_at = entrante

    # ---------------------------------------------------------------- imagen

    async def adjuntar_imagen(
        self, current_user: Usuario, muestra_id: UUID, datos: bytes
    ) -> MuestraCalibracionRead:
        """Sube el JPEG de la muestra y la deja lista para entrenar.

        Storage y Postgres no comparten transacción, así que el orden importa:

        1. Se valida y recomprime en memoria. Nada inválido llega a Storage.
        2. Se sube. Si falla, la base no se toca: la muestra sigue
           ``pendiente_imagen`` y el cliente la reintenta.
        3. Se persiste la clave. Si falla, se compensa borrando el objeto recién
           subido para no dejarlo huérfano.
        """
        muestra = await self.repository.get_by_id(muestra_id)
        if muestra is None:
            raise MuestraCalibracionNoEncontradaError()
        # Autorizar ANTES de tocar Storage: un usuario sin acceso no debe poder
        # ni siquiera escribir un objeto en el bucket.
        await self._exigir_acceso(current_user, muestra.establecimiento_id)

        normalizada = normalizar_jpeg(datos)
        clave = clave_de_imagen(muestra.establecimiento_id, muestra.id)

        storage = self._exigir_storage()
        try:
            await storage.subir_jpeg(clave, normalizada)
        except StorageError as exc:
            logger.error(
                "[CALIBRACION] No se pudo subir la imagen de la muestra %s", muestra_id
            )
            raise SubidaDeImagenFallidaError() from exc

        try:
            muestra.imagen_key = clave
            muestra.imagen_bytes = len(normalizada)
            muestra.estado = EstadoMuestraCalibracion.completa
            muestra.updated_at = datetime.now(UTC)
            await self.repository.save(muestra)
            # Commit explícito, a diferencia del resto de los módulos: el commit
            # que hace ``get_session`` ocurre DESPUÉS de que este método retorne,
            # y si fallara ahí ya no habría forma de borrar el objeto. Hay que
            # cerrar la transacción mientras la compensación sigue al alcance.
            await self.session.commit()
        except Exception:
            await self.session.rollback()
            await self._compensar_objeto(clave, muestra_id)
            raise

        return MuestraCalibracionRead.model_validate(muestra)

    def _exigir_storage(self) -> ObjectStorage:
        """El almacén es opcional en el constructor (la mayoría de las
        operaciones no lo usan), pero adjuntar una imagen sin él es un error de
        cableado, no una condición de runtime."""
        if self.storage is None:
            raise RuntimeError(
                "MuestraCalibracionService necesita un ObjectStorage para "
                "adjuntar imágenes"
            )
        return self.storage

    async def _compensar_objeto(self, clave: str, muestra_id: UUID) -> None:
        """Borra el objeto subido cuando la persistencia falló.

        Si la compensación también falla queda un objeto huérfano: se registra
        con su clave para poder limpiarlo a mano, y se deja propagar el error
        original, que es el que el cliente necesita ver.
        """
        try:
            await self._exigir_storage().borrar(clave)
        except Exception:
            logger.exception(
                "[CALIBRACION] Objeto huerfano en Storage: %s (muestra %s). "
                "La persistencia fallo y la compensacion tambien.",
                clave,
                muestra_id,
            )

    # ------------------------------------------------------------ edición

    async def actualizar(
        self, current_user: Usuario, muestra_id: UUID, data: MuestraCalibracionUpdate
    ) -> MuestraCalibracionRead:
        """Edición idempotente con last-write-wins."""
        muestra = await self.repository.get_by_id_including_deleted(muestra_id)
        if muestra is None:
            raise MuestraCalibracionNoEncontradaError()
        await self._exigir_acceso(current_user, muestra.establecimiento_id)

        entrante = as_utc(data.updated_at) or datetime.now(UTC)
        if not gana_el_entrante(entrante, muestra.updated_at):
            # Cambio rancio: gana el servidor.
            return MuestraCalibracionRead.model_validate(muestra)

        if data.peso_real_kg is not None:
            muestra.peso_real_kg = data.peso_real_kg
        if data.peso_estimado_kg is not None:
            muestra.peso_estimado_kg = data.peso_estimado_kg
        if data.fecha_captura is not None:
            muestra.fecha_captura = data.fecha_captura
        if data.estado is not None:
            # El schema ya restringe el valor a ``descartada``.
            muestra.estado = data.estado
        if data.observaciones is not None:
            muestra.observaciones = data.observaciones
        if data.deleted_at is not None:
            muestra.deleted_at = data.deleted_at
        muestra.updated_at = entrante

        await self.repository.save(muestra)
        return MuestraCalibracionRead.model_validate(muestra)

    async def borrar(
        self,
        current_user: Usuario,
        muestra_id: UUID,
        *,
        deleted_at: datetime | None = None,
        updated_at: datetime | None = None,
    ) -> MuestraCalibracionRead:
        """Soft delete (set ``deleted_at``) para que el borrado se propague en sync.

        El objeto en Storage no se toca: el borrado tiene que poder viajar al
        cliente y revertirse, y un objeto que nadie referencia queda fuera de la
        exportación de todas formas.
        """
        muestra = await self.repository.get_by_id_including_deleted(muestra_id)
        if muestra is None:
            raise MuestraCalibracionNoEncontradaError()
        await self._exigir_acceso(current_user, muestra.establecimiento_id)

        ts = as_utc(deleted_at) or datetime.now(UTC)
        muestra.deleted_at = ts
        muestra.updated_at = as_utc(updated_at) or ts
        await self.repository.save(muestra)
        return MuestraCalibracionRead.model_validate(muestra)

    # ------------------------------------------------------------- lectura

    async def listar(
        self,
        current_user: Usuario,
        establecimiento_id: UUID,
        *,
        animal_id: UUID | None = None,
        updated_since: datetime | None = None,
        include_deleted: bool = False,
    ) -> list[MuestraCalibracionRead]:
        await self._exigir_acceso(current_user, establecimiento_id)
        muestras = await self.repository.list_by_establecimiento(
            establecimiento_id,
            animal_id=animal_id,
            updated_since=updated_since,
            include_deleted=include_deleted,
        )
        return [MuestraCalibracionRead.model_validate(m) for m in muestras]

    async def detalle(
        self, current_user: Usuario, muestra_id: UUID
    ) -> MuestraCalibracionRead:
        muestra = await self.repository.get_by_id(muestra_id)
        if muestra is None:
            raise MuestraCalibracionNoEncontradaError()
        # Sin acceso: 404 (no se revela la existencia en otro establecimiento).
        membership = await self.membership_repository.get_membership(
            current_user.id, muestra.establecimiento_id
        )
        if membership is None:
            raise MuestraCalibracionNoEncontradaError()
        return MuestraCalibracionRead.model_validate(muestra)
