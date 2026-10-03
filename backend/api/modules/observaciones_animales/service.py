"""Lógica de negocio del módulo observaciones de animales."""

from datetime import UTC, datetime
from uuid import UUID, uuid4, uuid5

from sqlalchemy.ext.asyncio import AsyncSession

from api.modules.animales.models import Animal
from api.modules.animales.repository import AnimalRepository
from api.modules.establecimientos.repository import UsuarioEstablecimientoRepository
from api.modules.observaciones_animales.exceptions import (
    AnimalNoPerteneceAlEstablecimientoError,
    ObservacionInmutableError,
    ObservacionNoEncontradaError,
)
from api.modules.observaciones_animales.models import ObservacionAnimal
from api.modules.observaciones_animales.repository import ObservacionAnimalRepository
from api.modules.observaciones_animales.schemas import (
    ObservacionAnimalCreate,
    ObservacionAnimalRead,
    ObservacionAnimalUpdate,
)
from api.modules.usuarios.models import Usuario
from api.shared.exceptions import EstablecimientoNoAutorizadoError
from api.shared.sync import as_utc, gana_el_entrante

# Espacio de nombres de los ids que genera el puente desde
# ``animales.observaciones``. No cambiarlo: es lo que hace idempotentes los
# reintentos.
_NAMESPACE_PUENTE = UUID("6f1d6c2e-3b7a-4d55-9a51-6b0f1c7e2a34")


class ObservacionAnimalService:
    def __init__(self, session: AsyncSession) -> None:
        self.session = session
        self.repository = ObservacionAnimalRepository(session)
        self.animal_repository = AnimalRepository(session)
        self.membership_repository = UsuarioEstablecimientoRepository(session)

    async def _es_miembro(
        self, current_user: Usuario, establecimiento_id: UUID
    ) -> bool:
        membership = await self.membership_repository.get_membership(
            current_user.id, establecimiento_id
        )
        return membership is not None

    async def _exigir_acceso(
        self, current_user: Usuario, establecimiento_id: UUID
    ) -> None:
        if not await self._es_miembro(current_user, establecimiento_id):
            raise EstablecimientoNoAutorizadoError()

    async def _observacion_accesible(
        self, current_user: Usuario, observacion_id: UUID
    ) -> ObservacionAnimal:
        """Observación existente (incluso borrada) de un establecimiento del usuario.

        Sin acceso responde 404, igual que si no existiera: no revela que la
        observación existe en otro establecimiento.
        """
        observacion = await self.repository.get_by_id_including_deleted(observacion_id)
        if observacion is None or not await self._es_miembro(
            current_user, observacion.establecimiento_id
        ):
            raise ObservacionNoEncontradaError()
        return observacion

    async def crear(
        self, current_user: Usuario, data: ObservacionAnimalCreate
    ) -> ObservacionAnimalRead:
        """Agrega una observación sin tocar las demás.

        Idempotente para offline-first: si el ``id`` (UUID del cliente) ya existe se
        trata como reenvío y se aplica last-write-wins en vez de duplicar.
        """
        await self._exigir_acceso(current_user, data.establecimiento_id)

        observacion_id = data.id or uuid4()
        existente = await self.repository.get_by_id_including_deleted(observacion_id)
        if existente is not None:
            if not await self._es_miembro(current_user, existente.establecimiento_id):
                raise ObservacionNoEncontradaError()
            if (
                existente.animal_id != data.animal_id
                or existente.establecimiento_id != data.establecimiento_id
            ):
                raise ObservacionInmutableError()
            self._merge_alta_lww(existente, data)
            await self.repository.save(existente)
            return ObservacionAnimalRead.model_validate(existente)

        animal = await self.animal_repository.get_by_id(data.animal_id)
        if animal is None or animal.establecimiento_id != data.establecimiento_id:
            raise AnimalNoPerteneceAlEstablecimientoError()

        ahora = datetime.now(UTC)
        observacion = ObservacionAnimal(
            id=observacion_id,
            created_at=data.created_at or ahora,
            updated_at=data.updated_at or ahora,
            deleted_at=data.deleted_at,
            establecimiento_id=data.establecimiento_id,
            animal_id=data.animal_id,
            texto=data.texto,
            fecha=data.fecha or data.created_at or ahora,
            autor_id=current_user.id,
        )
        await self.repository.create(observacion)
        return ObservacionAnimalRead.model_validate(observacion)

    def _merge_alta_lww(
        self, existente: ObservacionAnimal, data: ObservacionAnimalCreate
    ) -> None:
        """Aplica un alta reenviada solo si el cliente trae una versión más nueva."""
        if not gana_el_entrante(data.updated_at, existente.updated_at):
            return
        existente.texto = data.texto
        if data.fecha is not None:
            existente.fecha = data.fecha
        existente.deleted_at = data.deleted_at
        existente.updated_at = as_utc(data.updated_at)

    async def actualizar(
        self,
        current_user: Usuario,
        observacion_id: UUID,
        data: ObservacionAnimalUpdate,
    ) -> ObservacionAnimalRead:
        """Edita solo la observación indicada, con last-write-wins."""
        observacion = await self._observacion_accesible(current_user, observacion_id)

        entrante = as_utc(data.updated_at) or datetime.now(UTC)
        if not gana_el_entrante(entrante, observacion.updated_at):
            # Cambio rancio: gana el servidor.
            return ObservacionAnimalRead.model_validate(observacion)

        if data.texto is not None:
            observacion.texto = data.texto
        if data.fecha is not None:
            observacion.fecha = data.fecha
        if data.deleted_at is not None:
            observacion.deleted_at = data.deleted_at
        observacion.updated_at = entrante

        await self.repository.save(observacion)
        return ObservacionAnimalRead.model_validate(observacion)

    async def borrar(
        self,
        current_user: Usuario,
        observacion_id: UUID,
        *,
        deleted_at: datetime | None = None,
        updated_at: datetime | None = None,
    ) -> ObservacionAnimalRead:
        """Soft delete (set ``deleted_at``) para que el borrado se propague en sync.
        Acepta el timestamp local del cliente; si no viene, usa el del servidor."""
        observacion = await self._observacion_accesible(current_user, observacion_id)

        ts = as_utc(deleted_at) or datetime.now(UTC)
        observacion.deleted_at = ts
        observacion.updated_at = as_utc(updated_at) or ts
        await self.repository.save(observacion)
        return ObservacionAnimalRead.model_validate(observacion)

    async def listar(
        self,
        current_user: Usuario,
        establecimiento_id: UUID,
        *,
        animal_id: UUID | None = None,
        updated_since: datetime | None = None,
        include_deleted: bool = False,
    ) -> list[ObservacionAnimalRead]:
        """Observaciones del establecimiento, o de un animal con ``animal_id``."""
        await self._exigir_acceso(current_user, establecimiento_id)
        observaciones = await self.repository.list_by_establecimiento(
            establecimiento_id,
            animal_id=animal_id,
            updated_since=updated_since,
            include_deleted=include_deleted,
        )
        return [ObservacionAnimalRead.model_validate(o) for o in observaciones]

    async def registrar_desde_columna_legacy(
        self,
        current_user: Usuario,
        animal: Animal,
        texto: str | None,
        *,
        texto_guardado: str | None,
        fecha: datetime | None,
    ) -> None:
        """Puente de transición: una nota que llega por ``animales.observaciones``
        se registra también como entrada (ver adr-0007).

        Los clientes anteriores a ``observaciones_animales`` todavía escriben la
        columna, y pueden tener escrituras encoladas offline. Para no perder esas
        notas, cada texto nuevo —no vacío y distinto del guardado— genera una
        entrada. El id se deriva del animal y del texto, así que reintentar la
        misma escritura no la duplica. Se registra aunque la escritura del animal
        pierda por last-write-wins: agregar una nota nunca pisa otra.
        """
        if texto is None or not texto.strip() or texto == texto_guardado:
            return
        observacion_id = uuid5(_NAMESPACE_PUENTE, f"{animal.id}:{texto}")
        if await self.repository.get_by_id_including_deleted(observacion_id):
            return
        ahora = datetime.now(UTC)
        await self.repository.create(
            ObservacionAnimal(
                id=observacion_id,
                # Momento de registro en el servidor: así la baja el pull delta
                # de los demás clientes aunque el reloj del emisor esté atrasado.
                created_at=ahora,
                updated_at=ahora,
                animal_id=animal.id,
                establecimiento_id=animal.establecimiento_id,
                texto=texto,
                fecha=as_utc(fecha) or ahora,
                autor_id=current_user.id,
            )
        )
