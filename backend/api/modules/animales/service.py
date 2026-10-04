"""Lógica de negocio del módulo animales."""

from datetime import UTC, datetime
from typing import NoReturn
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
from api.modules.animales.rechazos import traducir_rechazo
from api.modules.animales.reglas_reproductivas import validar_combinacion
from api.modules.animales.repository import AnimalRepository
from api.modules.animales.schemas import AnimalCreate, AnimalRead, AnimalUpdate
from api.modules.categorias.models import Categoria
from api.modules.establecimientos.repository import UsuarioEstablecimientoRepository
from api.modules.pesajes.models import Pesaje
from api.modules.pesajes.repository import PesajeRepository
from api.modules.usuarios.models import Usuario
from api.shared.enums import EstadoAnimal, SexoAnimal
from api.shared.sync import as_utc


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

    async def _rechazar(
        self, exc: IntegrityError, nro_caravana: str | None
    ) -> NoReturn:
        """Revierte y traduce un rechazo de la base a su error de dominio.

        Un rechazo que no se reconoce se propaga tal cual: disfrazarlo de otro
        error escondería un bug.
        """
        await self.session.rollback()
        error = traducir_rechazo(exc, nro_caravana)
        if error is None:
            raise exc
        raise error from exc

    async def _categoria_asignable(
        self, categoria_id: UUID, establecimiento_id: UUID
    ) -> Categoria:
        """Categoría que se le puede asignar a un animal del establecimiento.

        Puede ser global (``establecimiento_id`` null) o propia; nunca de otro
        establecimiento ni borrada lógicamente.
        """
        categoria = await self.repository.get_categoria(categoria_id)
        if (
            categoria is None
            or categoria.deleted_at is not None
            or categoria.establecimiento_id not in (None, establecimiento_id)
        ):
            raise AnimalReferenciaInvalidaError("categoria")
        return categoria

    async def _categoria_final(
        self, animal: Animal, categoria_id: UUID | None
    ) -> Categoria | None:
        """Categoría con la que quedaría el animal tras aplicar un cambio.

        Si no cambia, se acepta la actual tal como está: una categoría que se
        borró después de asignarse no debe trabar la edición de otros campos.
        """
        if categoria_id is None:
            return None
        if categoria_id == animal.categoria_id:
            return await self.repository.get_categoria(categoria_id)
        return await self._categoria_asignable(categoria_id, animal.establecimiento_id)

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
            await self._merge_alta_lww(existente, data)
            try:
                await self.repository.save(existente)
            except IntegrityError as exc:
                await self._rechazar(exc, data.nro_caravana_rfid)
            return AnimalRead.model_validate(existente)

        # Unicidad GLOBAL de caravana (SENASA 530/2025); excluye el propio id.
        if await self.repository.exists_caravana(
            data.nro_caravana_rfid, exclude_id=animal_id
        ):
            raise CaravanaDuplicadaError(data.nro_caravana_rfid)

        # El lote es opcional —el animal puede entrar sin asignar—, pero si se
        # informa tiene que existir y ser del establecimiento.
        if data.lote_id is not None:
            lote = await self.repository.get_lote(data.lote_id)
            if lote is None or lote.establecimiento_id != data.establecimiento_id:
                raise LoteNoPerteneceAlEstablecimientoError()

        categoria = None
        if data.categoria_id is not None:
            categoria = await self._categoria_asignable(
                data.categoria_id, data.establecimiento_id
            )
        # Un alta que llega ya borrada (se creó y se borró offline) no se valida
        # contra su categoría: la compatibilidad se exige a los animales vivos.
        if data.deleted_at is None:
            validar_combinacion(data.sexo, categoria, data.estado_reproductivo)

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
            estado_reproductivo=data.estado_reproductivo,
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
            await self._rechazar(exc, data.nro_caravana_rfid)

        return AnimalRead.model_validate(animal)

    async def _merge_alta_lww(self, existente: Animal, data: AnimalCreate) -> None:
        """Aplica los campos de un alta reenviada solo si el cliente trae una versión
        más nueva (last-write-wins por ``updated_at``). Si es más vieja o igual, se
        conserva la del servidor (no-op).

        El reenvío puede cambiar sexo y categoría, así que valida la combinación
        final antes de tocar nada: si es inválida, el registro queda como estaba.
        Solo se valida si el animal queda vivo: reenviar un borrado no puede
        fallar porque la categoría cambió después, y restaurarlo sí revalida.
        """
        entrante = as_utc(data.updated_at) or datetime.now(UTC)
        if entrante <= as_utc(existente.updated_at):
            return

        # Un cliente anterior a este campo no lo envía: omitirlo no lo borra.
        estado_reproductivo = (
            data.estado_reproductivo
            if "estado_reproductivo" in data.model_fields_set
            else existente.estado_reproductivo
        )
        categoria = await self._categoria_final(existente, data.categoria_id)
        if data.deleted_at is None:
            validar_combinacion(data.sexo, categoria, estado_reproductivo)

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
        existente.estado_reproductivo = estado_reproductivo
        existente.observaciones = data.observaciones
        existente.deleted_at = data.deleted_at
        # Explícito: queda en el SET del UPDATE y el onupdate=func.now() no lo pisa.
        existente.updated_at = entrante

    async def actualizar(
        self, current_user: Usuario, animal_id: UUID, data: AnimalUpdate
    ) -> AnimalRead:
        """Edición idempotente con last-write-wins. Aplica los campos provistos solo
        si el ``updated_at`` entrante es más nuevo que el persistido.

        Valida todo antes de mutar: una combinación inválida rechaza la operación
        completa sin cambios parciales.
        """
        animal = await self.repository.get_by_id_including_deleted(animal_id)
        if animal is None:
            raise AnimalNoEncontradoError()
        await self._exigir_acceso(current_user, animal.establecimiento_id)

        entrante = as_utc(data.updated_at) or datetime.now(UTC)
        if entrante <= as_utc(animal.updated_at):
            # Cambio rancio: gana el servidor.
            return AnimalRead.model_validate(animal)

        if data.lote_id is not None:
            lote = await self.repository.get_lote(data.lote_id)
            if lote is None or lote.establecimiento_id != animal.establecimiento_id:
                raise LoteNoPerteneceAlEstablecimientoError()

        # ``None`` en categoría significa "sin cambios"; en la condición
        # reproductiva, un ``null`` explícito la limpia.
        categoria_id = (
            data.categoria_id if data.categoria_id is not None else animal.categoria_id
        )
        estado_reproductivo = (
            data.estado_reproductivo
            if "estado_reproductivo" in data.model_fields_set
            else animal.estado_reproductivo
        )
        categoria = await self._categoria_final(animal, categoria_id)
        # ``deleted_at`` en None significa "sin cambios", así que esta vía no
        # restaura: solo valida si el animal sigue vivo.
        deleted_at_final = (
            data.deleted_at if data.deleted_at is not None else animal.deleted_at
        )
        if deleted_at_final is None:
            validar_combinacion(SexoAnimal(animal.sexo), categoria, estado_reproductivo)

        if data.lote_id is not None:
            animal.lote_id = data.lote_id
        animal.categoria_id = categoria_id
        animal.estado_reproductivo = estado_reproductivo
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

        # Se lee antes del flush: si falla, tocar el objeto dispara otro flush.
        nro_caravana = animal.nro_caravana_rfid
        try:
            await self.repository.save(animal)
        except IntegrityError as exc:
            await self._rechazar(exc, nro_caravana)
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

        ts = as_utc(deleted_at) or datetime.now(UTC)
        animal.deleted_at = ts
        animal.updated_at = as_utc(updated_at) or ts
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
