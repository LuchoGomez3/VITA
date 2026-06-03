"""Lógica de negocio del módulo animales."""

from datetime import UTC, datetime
from uuid import UUID

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
from api.modules.animales.schemas import AnimalCreate, AnimalRead
from api.modules.establecimientos.repository import UsuarioEstablecimientoRepository
from api.modules.pesajes.models import Pesaje
from api.modules.pesajes.repository import PesajeRepository
from api.modules.usuarios.models import Usuario
from api.shared.enums import EstadoAnimal, SexoAnimal


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
        """Alta de animal + pesaje inicial en la misma transacción."""
        await self._exigir_acceso(current_user, data.establecimiento_id)

        # Unicidad GLOBAL de caravana (SENASA 530/2025).
        if await self.repository.exists_caravana(data.nro_caravana_rfid):
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

        animal = Animal(
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

    async def listar(
        self,
        current_user: Usuario,
        establecimiento_id: UUID,
        *,
        lote_id: UUID | None = None,
        sexo: SexoAnimal | None = None,
        estado: EstadoAnimal | None = None,
    ) -> list[AnimalRead]:
        await self._exigir_acceso(current_user, establecimiento_id)
        animales = await self.repository.list_by_establecimiento(
            establecimiento_id, lote_id=lote_id, sexo=sexo, estado=estado
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
