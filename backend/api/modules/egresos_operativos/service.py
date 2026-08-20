"""Reglas de negocio, auditoría y reconciliación de egresos operativos."""

from datetime import UTC, datetime
import re
import unicodedata
from uuid import UUID, uuid4

from sqlalchemy.ext.asyncio import AsyncSession

from api.modules.egresos_operativos.exceptions import (
    CategoriaEgresoDuplicadaError,
    CategoriaEgresoIdEnConflictoError,
    CategoriaEgresoInvalidaError,
    EgresoOperativoNoEncontradoError,
    EstablecimientoNoAutorizadoError,
)
from api.modules.egresos_operativos.models import (
    CategoriaEgresoPersonalizada,
    EgresoOperativo,
)
from api.modules.egresos_operativos.repository import EgresoOperativoRepository
from api.modules.egresos_operativos.schemas import (
    CATEGORIAS_POR_TIPO,
    CategoriaEgresoCreate,
    CategoriaEgresoPersonalizadaRead,
    CategoriaEgresoRead,
    EgresoOperativoCreate,
    EgresoOperativoRead,
    TipoEgresoRead,
    UsuarioAuditoriaRead,
)
from api.modules.establecimientos.repository import UsuarioEstablecimientoRepository
from api.modules.usuarios.models import Usuario
from api.shared.enums import CategoriaEgresoOperativo, TipoEgresoOperativo


def normalizar_utc(instante: datetime | None) -> datetime | None:
    """Interpreta marcas sin zona como UTC para comparar SQLite y PostgreSQL."""
    if instante is None:
        return None
    return instante if instante.tzinfo is not None else instante.replace(tzinfo=UTC)


class EgresoOperativoService:
    """Coordina autorización tenant, auditoría y last-write-wins."""

    def __init__(self, session: AsyncSession) -> None:
        self.repository = EgresoOperativoRepository(session)
        self.memberships = UsuarioEstablecimientoRepository(session)

    async def exigir_acceso(self, usuario: Usuario, establecimiento_id: UUID) -> None:
        """Impide leer o escribir movimientos de establecimientos ajenos."""
        membresia = await self.memberships.get_membership(
            usuario.id, establecimiento_id
        )
        if membresia is None:
            raise EstablecimientoNoAutorizadoError()

    @staticmethod
    def representar(egreso: EgresoOperativo, usuario: Usuario) -> EgresoOperativoRead:
        """Compone el movimiento con la identidad necesaria para auditoría."""
        datos = {
            "id": egreso.id,
            "establecimiento_id": egreso.establecimiento_id,
            "monto": egreso.monto,
            "tipo": egreso.tipo,
            "categoria": egreso.categoria,
            "insumo": egreso.insumo,
            "fecha": egreso.fecha,
            "descripcion": egreso.descripcion,
            "numero_comprobante": egreso.numero_comprobante,
            "cargado_por_id": egreso.cargado_por_id,
            "cargado_por": UsuarioAuditoriaRead.model_validate(
                usuario, from_attributes=True
            ),
            "created_at": egreso.created_at,
            "updated_at": egreso.updated_at,
            "deleted_at": egreso.deleted_at,
        }
        return EgresoOperativoRead.model_validate(datos)

    async def crear(
        self, usuario: Usuario, datos: EgresoOperativoCreate
    ) -> EgresoOperativoRead:
        """Crea o reconcilia un alta offline usando UUID idempotente y LWW."""
        await self.exigir_acceso(usuario, datos.establecimiento_id)
        await self.exigir_categoria_valida(
            datos.establecimiento_id, datos.tipo, datos.categoria
        )
        egreso_id = datos.id or uuid4()
        existente = await self.repository.get_including_deleted(egreso_id)
        if existente is not None:
            # También se controla el tenant persistido ante un UUID malicioso.
            await self.exigir_acceso(usuario, existente.establecimiento_id)
            self.aplicar_alta_lww(existente, datos)
            await self.repository.save(existente)
            cargador = await self.repository.get_usuario(existente.cargado_por_id)
            if cargador is None:
                raise EgresoOperativoNoEncontradoError()
            return self.representar(existente, cargador)

        ahora = datetime.now(UTC)
        egreso = EgresoOperativo(
            id=egreso_id,
            created_at=datos.created_at or ahora,
            updated_at=datos.updated_at or ahora,
            deleted_at=datos.deleted_at,
            establecimiento_id=datos.establecimiento_id,
            monto=datos.monto,
            tipo=datos.tipo,
            categoria=datos.categoria,
            insumo=datos.insumo,
            fecha=datos.fecha,
            descripcion=datos.descripcion,
            numero_comprobante=datos.numero_comprobante,
            cargado_por_id=usuario.id,
        )
        await self.repository.save(egreso)
        return self.representar(egreso, usuario)

    async def exigir_categoria_valida(
        self,
        establecimiento_id: UUID,
        tipo: TipoEgresoOperativo,
        valor: str,
    ) -> None:
        """Acepta categorías base o una categoría activa del mismo tenant y tipo."""
        if valor in CATEGORIAS_POR_TIPO[tipo]:
            return
        personalizada = await self.repository.get_categoria_by_valor(
            establecimiento_id, valor
        )
        if personalizada is None or personalizada.tipo != tipo:
            raise CategoriaEgresoInvalidaError()

    @staticmethod
    def aplicar_alta_lww(
        existente: EgresoOperativo, datos: EgresoOperativoCreate
    ) -> None:
        """Actualiza solo si la mutación offline es posterior a la versión central."""
        entrante = normalizar_utc(datos.updated_at) or datetime.now(UTC)
        if entrante <= normalizar_utc(existente.updated_at):
            return
        existente.monto = datos.monto
        existente.tipo = datos.tipo
        existente.categoria = datos.categoria
        existente.insumo = datos.insumo
        existente.fecha = datos.fecha
        existente.descripcion = datos.descripcion
        existente.numero_comprobante = datos.numero_comprobante
        existente.deleted_at = datos.deleted_at
        existente.updated_at = entrante

    async def listar(
        self,
        usuario: Usuario,
        establecimiento_id: UUID,
        *,
        updated_since: datetime | None,
        include_deleted: bool,
    ) -> list[EgresoOperativoRead]:
        """Entrega historial auditable o cambios incrementales para SQLite."""
        await self.exigir_acceso(usuario, establecimiento_id)
        filas = await self.repository.list_by_establecimiento(
            establecimiento_id,
            updated_since=updated_since,
            include_deleted=include_deleted,
        )
        return [self.representar(egreso, cargador) for egreso, cargador in filas]

    async def catalogo(
        self, usuario: Usuario, establecimiento_id: UUID
    ) -> list[TipoEgresoRead]:
        """Combina las categorías base con las creadas específicamente para el campo."""
        await self.exigir_acceso(usuario, establecimiento_id)
        personalizadas = await self.repository.list_categorias(establecimiento_id)
        etiquetas_tipo = {
            TipoEgresoOperativo.costo_produccion: "Costo de Producción",
            TipoEgresoOperativo.gasto_administrativo: "Gasto Administrativo",
        }
        etiquetas_categoria = {
            CategoriaEgresoOperativo.sanidad: "Sanidad",
            CategoriaEgresoOperativo.alimentacion: "Alimentación",
            CategoriaEgresoOperativo.identificacion: "Identificación",
            CategoriaEgresoOperativo.combustible: "Combustible",
            CategoriaEgresoOperativo.estructura: "Estructura",
            CategoriaEgresoOperativo.honorarios: "Honorarios",
        }
        catalogo = [
            TipoEgresoRead(
                valor=tipo,
                etiqueta=etiquetas_tipo[tipo],
                categorias=[
                    CategoriaEgresoRead(
                        valor=categoria.value,
                        etiqueta=etiquetas_categoria[categoria],
                    )
                    for categoria in sorted(
                        CATEGORIAS_POR_TIPO[tipo], key=lambda item: item.value
                    )
                ],
            )
            for tipo in TipoEgresoOperativo
        ]
        por_tipo = {item.valor: item for item in catalogo}
        for categoria in personalizadas:
            por_tipo[categoria.tipo].categorias.append(
                CategoriaEgresoRead(
                    valor=categoria.valor,
                    etiqueta=categoria.nombre,
                    personalizada=True,
                )
            )
        return catalogo

    async def crear_categoria(
        self, usuario: Usuario, datos: CategoriaEgresoCreate
    ) -> CategoriaEgresoPersonalizadaRead:
        """Crea una opción tenant-aware y admite reintentos desde la cola offline."""
        await self.exigir_acceso(usuario, datos.establecimiento_id)
        categoria_id = datos.id or uuid4()
        existente_id = await self.repository.get_categoria_by_id(categoria_id)
        if existente_id is not None:
            if (
                existente_id.establecimiento_id != datos.establecimiento_id
                or existente_id.tipo != datos.tipo
                or existente_id.nombre != datos.nombre
            ):
                raise CategoriaEgresoIdEnConflictoError()
            return CategoriaEgresoPersonalizadaRead.model_validate(existente_id)

        valor = self.normalizar_valor_categoria(datos.nombre)
        if any(valor in categorias for categorias in CATEGORIAS_POR_TIPO.values()):
            raise CategoriaEgresoDuplicadaError()
        if await self.repository.get_categoria_by_valor(
            datos.establecimiento_id, valor
        ):
            raise CategoriaEgresoDuplicadaError()

        ahora = datetime.now(UTC)
        categoria = CategoriaEgresoPersonalizada(
            id=categoria_id,
            establecimiento_id=datos.establecimiento_id,
            tipo=datos.tipo,
            nombre=datos.nombre,
            valor=valor,
            creado_por_id=usuario.id,
            created_at=datos.created_at or ahora,
            updated_at=datos.updated_at or ahora,
            deleted_at=datos.deleted_at,
        )
        await self.repository.save_categoria(categoria)
        return CategoriaEgresoPersonalizadaRead.model_validate(categoria)

    @staticmethod
    def normalizar_valor_categoria(nombre: str) -> str:
        """Genera un slug legible y estable, eliminando tildes y símbolos."""
        sin_tildes = "".join(
            caracter
            for caracter in unicodedata.normalize("NFKD", nombre.lower())
            if not unicodedata.combining(caracter)
        )
        return re.sub(r"[^a-z0-9]+", "_", sin_tildes).strip("_")
