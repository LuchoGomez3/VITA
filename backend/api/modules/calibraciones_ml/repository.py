"""Acceso a datos de muestras de calibración. Sin reglas de negocio."""

from datetime import datetime
from uuid import UUID

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from api.modules.calibraciones_ml.models import MuestraCalibracion
from api.shared.enums import EstadoMuestraCalibracion


class MuestraCalibracionRepository:
    def __init__(self, session: AsyncSession) -> None:
        self.session = session

    async def create(self, muestra: MuestraCalibracion) -> MuestraCalibracion:
        self.session.add(muestra)
        await self.session.flush()
        return muestra

    async def save(self, muestra: MuestraCalibracion) -> MuestraCalibracion:
        """Persiste una muestra ya cargada tras mutarla (upsert LWW).

        ``updated_at`` se asigna explícito en el service, por lo que queda en el
        SET del UPDATE y el ``onupdate=func.now()`` del modelo NO lo pisa.
        """
        self.session.add(muestra)
        await self.session.flush()
        return muestra

    async def get_by_id(self, muestra_id: UUID) -> MuestraCalibracion | None:
        muestra = await self.session.get(MuestraCalibracion, muestra_id)
        if muestra is None or muestra.deleted_at is not None:
            return None
        return muestra

    async def get_by_id_including_deleted(
        self, muestra_id: UUID
    ) -> MuestraCalibracion | None:
        """Incluye soft-deleted: necesario para reconciliar en sync (un alta
        reenviada o un registro borrado deben poder encontrarse)."""
        return await self.session.get(MuestraCalibracion, muestra_id)

    async def list_by_establecimiento(
        self,
        establecimiento_id: UUID,
        *,
        animal_id: UUID | None = None,
        updated_since: datetime | None = None,
        include_deleted: bool = False,
    ) -> list[MuestraCalibracion]:
        """Muestras del establecimiento. Soporta la descarga delta del sync
        offline-first (``updated_since`` + ``include_deleted``)."""
        query = select(MuestraCalibracion).where(
            MuestraCalibracion.establecimiento_id == establecimiento_id
        )
        if not include_deleted:
            query = query.where(MuestraCalibracion.deleted_at.is_(None))
        if animal_id is not None:
            query = query.where(MuestraCalibracion.animal_id == animal_id)
        if updated_since is not None:
            query = query.where(MuestraCalibracion.updated_at >= updated_since)
        result = await self.session.execute(
            query.order_by(MuestraCalibracion.fecha_captura)
        )
        return list(result.scalars().all())

    async def list_exportables(
        self,
        establecimiento_id: UUID,
        *,
        desde: datetime | None = None,
        hasta: datetime | None = None,
    ) -> list[MuestraCalibracion]:
        """Muestras que pueden entrenar: vivas, completas y con objeto en Storage.

        El filtro por ``establecimiento_id`` es obligatorio (no tiene default):
        es lo que hace imposible que un dataset mezcle dos tenants.
        """
        query = select(MuestraCalibracion).where(
            MuestraCalibracion.establecimiento_id == establecimiento_id,
            MuestraCalibracion.deleted_at.is_(None),
            MuestraCalibracion.estado == EstadoMuestraCalibracion.completa,
            MuestraCalibracion.imagen_key.is_not(None),
        )
        if desde is not None:
            query = query.where(MuestraCalibracion.fecha_captura >= desde)
        if hasta is not None:
            query = query.where(MuestraCalibracion.fecha_captura <= hasta)
        result = await self.session.execute(
            # Orden estable por animal: el CSV resultante es reproducible entre
            # corridas, lo que hace comparables dos entrenamientos.
            query.order_by(
                MuestraCalibracion.animal_id,
                MuestraCalibracion.fecha_captura,
                MuestraCalibracion.id,
            )
        )
        return list(result.scalars().all())
