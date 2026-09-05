"""Consultas SQL del módulo de egresos operativos, sin reglas de negocio."""

from datetime import date, datetime
from uuid import UUID

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from api.modules.egresos_operativos.models import (
    CategoriaEgresoPersonalizada,
    EgresoOperativo,
)
from api.modules.usuarios.models import Usuario
from api.shared.enums import TipoEgresoOperativo


class EgresoOperativoRepository:
    """Aísla la persistencia y las consultas multi-tabla del servicio."""

    def __init__(self, session: AsyncSession) -> None:
        self.session = session

    async def save(self, egreso: EgresoOperativo) -> EgresoOperativo:
        """Inserta o actualiza un movimiento y materializa sus valores calculados."""
        self.session.add(egreso)
        await self.session.flush()
        return egreso

    async def get_including_deleted(self, egreso_id: UUID) -> EgresoOperativo | None:
        """Incluye tombstones para reconciliar reintentos de la cola offline."""
        return await self.session.get(EgresoOperativo, egreso_id)

    async def get_usuario(self, usuario_id: UUID) -> Usuario | None:
        """Obtiene los datos públicos de auditoría del usuario cargador."""
        return await self.session.get(Usuario, usuario_id)

    async def save_categoria(
        self, categoria: CategoriaEgresoPersonalizada
    ) -> CategoriaEgresoPersonalizada:
        """Persiste una categoría personalizada creada online u offline."""
        self.session.add(categoria)
        await self.session.flush()
        return categoria

    async def get_categoria_by_id(
        self, categoria_id: UUID
    ) -> CategoriaEgresoPersonalizada | None:
        """Incluye borradas para que un replay offline siga siendo idempotente."""
        return await self.session.get(CategoriaEgresoPersonalizada, categoria_id)

    async def get_categoria_by_valor(
        self, establecimiento_id: UUID, valor: str
    ) -> CategoriaEgresoPersonalizada | None:
        """Busca una categoría activa por su identificador estable y tenant."""
        resultado = await self.session.execute(
            select(CategoriaEgresoPersonalizada).where(
                CategoriaEgresoPersonalizada.establecimiento_id == establecimiento_id,
                CategoriaEgresoPersonalizada.valor == valor,
                CategoriaEgresoPersonalizada.deleted_at.is_(None),
            )
        )
        return resultado.scalar_one_or_none()

    async def list_categorias(
        self, establecimiento_id: UUID
    ) -> list[CategoriaEgresoPersonalizada]:
        """Devuelve el catálogo personalizado activo del establecimiento."""
        resultado = await self.session.execute(
            select(CategoriaEgresoPersonalizada)
            .where(
                CategoriaEgresoPersonalizada.establecimiento_id == establecimiento_id,
                CategoriaEgresoPersonalizada.deleted_at.is_(None),
            )
            .order_by(CategoriaEgresoPersonalizada.nombre)
        )
        return list(resultado.scalars().all())

    async def list_by_establecimiento(
        self,
        establecimiento_id: UUID,
        *,
        updated_since: datetime | None,
        include_deleted: bool,
        fecha_desde: date | None = None,
        fecha_hasta: date | None = None,
        tipo: TipoEgresoOperativo | None = None,
        categoria: str | None = None,
    ) -> list[tuple[EgresoOperativo, Usuario]]:
        """Lista el historial y soporta pull delta mediante ``updated_at``."""
        consulta = (
            select(EgresoOperativo, Usuario)
            .join(Usuario, Usuario.id == EgresoOperativo.cargado_por_id)
            .where(EgresoOperativo.establecimiento_id == establecimiento_id)
        )
        if not include_deleted:
            consulta = consulta.where(EgresoOperativo.deleted_at.is_(None))
        if updated_since is not None:
            consulta = consulta.where(EgresoOperativo.updated_at >= updated_since)
        if fecha_desde is not None:
            consulta = consulta.where(EgresoOperativo.fecha >= fecha_desde)
        if fecha_hasta is not None:
            consulta = consulta.where(EgresoOperativo.fecha <= fecha_hasta)
        if tipo is not None:
            consulta = consulta.where(EgresoOperativo.tipo == tipo)
        if categoria is not None:
            consulta = consulta.where(EgresoOperativo.categoria == categoria)
        resultado = await self.session.execute(
            consulta.order_by(
                EgresoOperativo.fecha.desc(), EgresoOperativo.created_at.desc()
            )
        )
        return list(resultado.tuples().all())
