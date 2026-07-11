"""Lógica de negocio del módulo categorías."""

from datetime import UTC, datetime
from uuid import UUID, uuid4

from sqlalchemy.ext.asyncio import AsyncSession

from api.modules.categorias.exceptions import (
    CategoriaEnUsoError,
    CategoriaGlobalNoEditableError,
    CategoriaNoEncontradaError,
    EstablecimientoNoAutorizadoError,
    NombreCategoriaDuplicadoError,
)
from api.modules.categorias.models import Categoria
from api.modules.categorias.repository import CategoriaRepository
from api.modules.categorias.schemas import (
    CategoriaCreate,
    CategoriaRead,
    CategoriaUpdate,
)
from api.modules.establecimientos.repository import UsuarioEstablecimientoRepository
from api.modules.usuarios.models import Usuario


def _as_utc(dt: datetime | None) -> datetime | None:
    """Normaliza a UTC-aware para comparar timestamps de forma robusta.

    Postgres devuelve datetimes aware; SQLite (tests) puede devolverlos naive.
    Asumimos UTC en los naive para no romper el last-write-wins.
    """
    if dt is None:
        return None
    return dt if dt.tzinfo is not None else dt.replace(tzinfo=UTC)


class CategoriaService:
    def __init__(self, session: AsyncSession) -> None:
        self.session = session
        self.repository = CategoriaRepository(session)
        self.membership_repository = UsuarioEstablecimientoRepository(session)

    async def _exigir_acceso(
        self, current_user: Usuario, establecimiento_id: UUID
    ) -> None:
        membership = await self.membership_repository.get_membership(
            current_user.id, establecimiento_id
        )
        if membership is None:
            raise EstablecimientoNoAutorizadoError()

    async def crear(
        self, current_user: Usuario, data: CategoriaCreate
    ) -> CategoriaRead:
        """Alta de categoría propia del establecimiento.

        Idempotente para offline-first: si el ``id`` (UUID del cliente) ya existe se
        trata como re-sincronización y se aplica last-write-wins en vez de fallar.
        """
        await self._exigir_acceso(current_user, data.establecimiento_id)

        categoria_id = data.id or uuid4()
        existente = await self.repository.get_by_id_including_deleted(categoria_id)
        if existente is not None:
            # No permitir reescribir una categoría del catálogo global.
            if existente.establecimiento_id is None:
                raise CategoriaGlobalNoEditableError()
            await self._exigir_acceso(current_user, existente.establecimiento_id)
            self._merge_alta_lww(existente, data)
            await self.repository.save(existente)
            return CategoriaRead.model_validate(existente)

        if await self.repository.exists_nombre(data.establecimiento_id, data.nombre):
            raise NombreCategoriaDuplicadoError(data.nombre)

        categoria = Categoria(
            id=categoria_id,
            created_at=data.created_at or datetime.now(UTC),
            updated_at=data.updated_at or datetime.now(UTC),
            deleted_at=data.deleted_at,
            establecimiento_id=data.establecimiento_id,
            nombre=data.nombre,
            descripcion=data.descripcion,
        )
        await self.repository.create(categoria)
        return CategoriaRead.model_validate(categoria)

    def _merge_alta_lww(self, existente: Categoria, data: CategoriaCreate) -> None:
        """Aplica un alta reenviada solo si el cliente trae una versión más nueva."""
        entrante = _as_utc(data.updated_at) or datetime.now(UTC)
        if entrante <= _as_utc(existente.updated_at):
            return
        existente.nombre = data.nombre
        existente.descripcion = data.descripcion
        existente.deleted_at = data.deleted_at
        existente.updated_at = entrante

    async def actualizar(
        self, current_user: Usuario, categoria_id: UUID, data: CategoriaUpdate
    ) -> CategoriaRead:
        """Edición idempotente con last-write-wins. No permite tocar el catálogo global."""
        categoria = await self.repository.get_by_id_including_deleted(categoria_id)
        if categoria is None:
            raise CategoriaNoEncontradaError()
        if categoria.establecimiento_id is None:
            raise CategoriaGlobalNoEditableError()
        await self._exigir_acceso(current_user, categoria.establecimiento_id)

        entrante = _as_utc(data.updated_at) or datetime.now(UTC)
        if entrante <= _as_utc(categoria.updated_at):
            # Cambio rancio: gana el servidor.
            return CategoriaRead.model_validate(categoria)

        if data.nombre is not None and data.nombre.lower() != categoria.nombre.lower():
            if await self.repository.exists_nombre(
                categoria.establecimiento_id, data.nombre, exclude_id=categoria.id
            ):
                raise NombreCategoriaDuplicadoError(data.nombre)
            categoria.nombre = data.nombre
        if data.descripcion is not None:
            categoria.descripcion = data.descripcion
        if data.deleted_at is not None:
            categoria.deleted_at = data.deleted_at
        categoria.updated_at = entrante

        await self.repository.save(categoria)
        return CategoriaRead.model_validate(categoria)

    async def borrar(
        self,
        current_user: Usuario,
        categoria_id: UUID,
        *,
        deleted_at: datetime | None = None,
        updated_at: datetime | None = None,
    ) -> CategoriaRead:
        """Soft delete (set ``deleted_at``) para que el borrado se propague en sync.

        Se bloquea si la categoría tiene animales asignados (evita dejar referencias
        colgadas) o si es del catálogo global.
        """
        categoria = await self.repository.get_by_id_including_deleted(categoria_id)
        if categoria is None:
            raise CategoriaNoEncontradaError()
        if categoria.establecimiento_id is None:
            raise CategoriaGlobalNoEditableError()
        await self._exigir_acceso(current_user, categoria.establecimiento_id)

        if await self.repository.tiene_animales(categoria.id):
            raise CategoriaEnUsoError()

        ts = _as_utc(deleted_at) or datetime.now(UTC)
        categoria.deleted_at = ts
        categoria.updated_at = _as_utc(updated_at) or ts
        await self.repository.save(categoria)
        return CategoriaRead.model_validate(categoria)

    async def listar(
        self,
        current_user: Usuario,
        establecimiento_id: UUID,
        *,
        updated_since: datetime | None = None,
        include_deleted: bool = False,
    ) -> list[CategoriaRead]:
        """Catálogo global + categorías propias del establecimiento."""
        await self._exigir_acceso(current_user, establecimiento_id)
        categorias = await self.repository.list_visibles(
            establecimiento_id,
            updated_since=updated_since,
            include_deleted=include_deleted,
        )
        return [CategoriaRead.model_validate(c) for c in categorias]
