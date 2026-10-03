"""Acceso a datos de observaciones de animales. Sin reglas de negocio."""

from datetime import datetime
from uuid import UUID

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from api.modules.observaciones_animales.models import ObservacionAnimal


class ObservacionAnimalRepository:
    def __init__(self, session: AsyncSession) -> None:
        self.session = session

    async def create(self, observacion: ObservacionAnimal) -> ObservacionAnimal:
        self.session.add(observacion)
        await self.session.flush()
        return observacion

    async def save(self, observacion: ObservacionAnimal) -> ObservacionAnimal:
        """Persiste una observación ya cargada tras mutarla (upsert LWW).

        ``updated_at`` se asigna explícito en el service, por lo que queda en el SET
        del UPDATE y el ``onupdate=func.now()`` del modelo NO lo pisa.
        """
        self.session.add(observacion)
        await self.session.flush()
        return observacion

    async def get_by_id_including_deleted(
        self, observacion_id: UUID
    ) -> ObservacionAnimal | None:
        """Incluye soft-deleted: un alta reenviada o un registro borrado deben
        poder encontrarse para reconciliar en sync."""
        return await self.session.get(ObservacionAnimal, observacion_id)

    async def list_by_establecimiento(
        self,
        establecimiento_id: UUID,
        *,
        animal_id: UUID | None = None,
        updated_since: datetime | None = None,
        include_deleted: bool = False,
    ) -> list[ObservacionAnimal]:
        """Observaciones del establecimiento, de la más reciente a la más vieja.

        ``created_at`` e ``id`` desempatan dos notas con la misma fecha, así el
        orden no cambia entre consultas.
        """
        query = select(ObservacionAnimal).where(
            ObservacionAnimal.establecimiento_id == establecimiento_id
        )
        if not include_deleted:
            query = query.where(ObservacionAnimal.deleted_at.is_(None))
        if animal_id is not None:
            query = query.where(ObservacionAnimal.animal_id == animal_id)
        if updated_since is not None:
            query = query.where(ObservacionAnimal.updated_at >= updated_since)
        result = await self.session.execute(
            query.order_by(
                ObservacionAnimal.fecha.desc(),
                ObservacionAnimal.created_at.desc(),
                ObservacionAnimal.id.desc(),
            )
        )
        return list(result.scalars().all())
