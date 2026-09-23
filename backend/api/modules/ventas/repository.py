"""Acceso a datos de ventas de hacienda, sin reglas de negocio."""

from uuid import UUID

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from api.modules.animales.models import Animal
from api.modules.ventas.models import Venta, VentaDetalle


class VentaRepository:
    """Aísla las consultas y escrituras que componen una venta atómica."""

    def __init__(self, session: AsyncSession) -> None:
        self.session = session

    async def save(self, venta: Venta) -> Venta:
        """Inserta la cabecera sin confirmar la transacción del request."""
        self.session.add(venta)
        await self.session.flush()
        return venta

    async def get_including_deleted(self, venta_id: UUID) -> Venta | None:
        """Incluye tombstones para resolver correctamente un reintento offline."""
        return await self.session.get(Venta, venta_id)

    async def add_detalles(self, venta_id: UUID, animal_ids: list[UUID]) -> None:
        """Agrega todos los animales de la venta sin ejecutar un commit."""
        self.session.add_all(
            [
                VentaDetalle(venta_id=venta_id, animal_id=animal_id)
                for animal_id in animal_ids
            ]
        )

    async def list_animal_ids(self, venta_id: UUID) -> list[UUID]:
        """Reconstruye la selección para respuestas e idempotencia."""
        consulta = (
            select(VentaDetalle.animal_id)
            .where(VentaDetalle.venta_id == venta_id)
            .order_by(VentaDetalle.created_at, VentaDetalle.animal_id)
        )
        resultado = await self.session.execute(consulta)
        return list(resultado.scalars().all())

    async def list_animales_para_venta(
        self, establecimiento_id: UUID, animal_ids: list[UUID]
    ) -> list[Animal]:
        """Carga y bloquea los animales vigentes del tenant durante la venta.

        ``FOR UPDATE`` serializa dos intentos simultáneos sobre la misma
        caravana. El service revisará el estado después de adquirir el bloqueo;
        así el segundo intento observa ``vendido`` y rechaza toda su operación.
        """
        if not animal_ids:
            return []
        consulta = (
            select(Animal)
            .where(
                Animal.id.in_(animal_ids),
                Animal.establecimiento_id == establecimiento_id,
                Animal.deleted_at.is_(None),
            )
            .with_for_update()
        )
        resultado = await self.session.execute(consulta)
        return list(resultado.scalars().all())

    async def save_animales(self, animales: list[Animal]) -> None:
        """Materializa cambios de stock sin cerrar la transacción externa."""
        self.session.add_all(animales)
        await self.session.flush()
