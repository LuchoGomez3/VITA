"""Reglas de negocio del registro atómico de ventas de hacienda."""

from datetime import UTC, datetime
from decimal import ROUND_HALF_UP, Decimal
from uuid import UUID

from sqlalchemy.ext.asyncio import AsyncSession

from api.modules.animales.models import Animal
from api.modules.establecimientos.repository import UsuarioEstablecimientoRepository
from api.modules.usuarios.models import Usuario
from api.modules.ventas.exceptions import (
    AccesoComercialDenegadoError,
    AnimalesNoDisponiblesVentaError,
    VentaIdEnConflictoError,
)
from api.modules.ventas.models import Venta, VentaCobro
from api.modules.ventas.repository import VentaRepository
from api.modules.ventas.schemas import PRECISION_MONETARIA, VentaCreate, VentaRead
from api.shared.enums import EstadoAnimal, EstadoCobro, RolUsuario
from api.shared.exceptions import EstablecimientoNoAutorizadoError
from api.shared.sync import as_utc

ROLES_COMERCIALES = {RolUsuario.admin, RolUsuario.owner}


class VentaService:
    """Coordina autorización, idempotencia y baja de stock de una venta."""

    def __init__(self, session: AsyncSession) -> None:
        self.session = session
        self.repository = VentaRepository(session)
        self.memberships = UsuarioEstablecimientoRepository(session)

    async def exigir_acceso_comercial(
        self, usuario: Usuario, establecimiento_id: UUID
    ) -> None:
        """Exige membresía activa con rol dueño o administrador."""
        membresias = await self.memberships.get_memberships(
            usuario.id, establecimiento_id
        )
        if not membresias:
            raise EstablecimientoNoAutorizadoError()
        if not any(membresia.rol in ROLES_COMERCIALES for membresia in membresias):
            raise AccesoComercialDenegadoError()

    async def resolver_animales(self, datos: VentaCreate) -> list[Animal]:
        """Bloquea y valida la selección completa, preservando su orden."""
        encontrados = await self.repository.list_animales_para_venta(
            datos.establecimiento_id, datos.animal_ids
        )
        por_id = {animal.id: animal for animal in encontrados}
        invalidos = [
            animal_id
            for animal_id in datos.animal_ids
            if (animal := por_id.get(animal_id)) is None
            or animal.estado != EstadoAnimal.activo
        ]
        if invalidos:
            raise AnimalesNoDisponiblesVentaError(invalidos)
        return [por_id[animal_id] for animal_id in datos.animal_ids]

    async def crear(self, usuario: Usuario, datos: VentaCreate) -> VentaRead:
        """Crea venta, detalles, cobro inicial y baja de stock, todo o nada.

        Los repositories solo ejecutan ``flush``. El ``commit`` pertenece a la
        dependencia de sesión al cerrar el request; cualquier excepción provoca
        el rollback conjunto de todo el agregado.
        """
        await self.exigir_acceso_comercial(usuario, datos.establecimiento_id)

        existente = await self.repository.get_including_deleted(datos.id)
        if existente is not None:
            # Se controla también el tenant persistido: un UUID conocido nunca
            # permite usar el establecimiento entrante como vía lateral.
            await self.exigir_acceso_comercial(usuario, existente.establecimiento_id)
            coincide = await self._coincide_con_existente(existente, datos)
            if not coincide or not await self._coincide_cobro_inicial(existente, datos):
                raise VentaIdEnConflictoError()
            return await self._to_read(existente)

        animales = await self.resolver_animales(datos)
        ahora = datetime.now(UTC)
        venta = Venta(
            id=datos.id,
            created_at=as_utc(datos.created_at) or ahora,
            updated_at=as_utc(datos.updated_at) or ahora,
            deleted_at=as_utc(datos.deleted_at),
            establecimiento_id=datos.establecimiento_id,
            fecha_operacion=datos.fecha_operacion,
            tipo_comprador=datos.tipo_comprador,
            nombre_comprador=datos.nombre_comprador,
            es_empresa=datos.es_empresa,
            apellido_comprador=datos.apellido_comprador,
            nro_dte=datos.nro_dte,
            tipo_venta=datos.tipo_venta,
            peso_total_kg=datos.peso_total_kg,
            precio_por_kg=datos.precio_por_kg,
            monto_total=datos.monto_total,
            observaciones=datos.observaciones,
            registrada_por_id=usuario.id,
        )
        await self.repository.save(venta)
        await self.repository.add_detalles(venta.id, datos.animal_ids)
        await self._guardar_cobro_inicial(usuario, venta, datos, ahora)

        for animal in animales:
            animal.estado = EstadoAnimal.vendido
            # La baja debe aparecer en el próximo pull aunque la fecha comercial
            # sea histórica o el cliente haya enviado un updated_at antiguo.
            animal.updated_at = ahora
        await self.repository.save_animales(animales)
        return await self._to_read(venta)

    async def _guardar_cobro_inicial(
        self,
        usuario: Usuario,
        venta: Venta,
        datos: VentaCreate,
        ahora: datetime,
    ) -> None:
        """Materializa el dinero recibido dentro de la transacción de la venta."""
        entrada = datos.cobro_inicial
        if entrada is None:
            return

        cobro = VentaCobro(
            id=entrada.id,
            created_at=as_utc(entrada.created_at) or ahora,
            updated_at=as_utc(entrada.updated_at) or ahora,
            venta_id=venta.id,
            fecha_cobro=entrada.fecha_cobro,
            monto=entrada.monto,
            medio_cobro=entrada.medio_cobro,
            registrado_por_id=usuario.id,
            observaciones=entrada.observaciones,
        )
        await self.repository.save_cobro(cobro)

    async def _coincide_con_existente(
        self, existente: Venta, datos: VentaCreate
    ) -> bool:
        """Compara el contenido comercial; el orden de animales es irrelevante."""
        animal_ids = await self.repository.list_animal_ids(existente.id)
        return (
            existente.establecimiento_id == datos.establecimiento_id
            and existente.fecha_operacion == datos.fecha_operacion
            and existente.tipo_comprador == datos.tipo_comprador
            and existente.nombre_comprador == datos.nombre_comprador
            and existente.es_empresa == datos.es_empresa
            and existente.apellido_comprador == datos.apellido_comprador
            and existente.nro_dte == datos.nro_dte
            and existente.tipo_venta == datos.tipo_venta
            and existente.peso_total_kg == datos.peso_total_kg
            and existente.precio_por_kg == datos.precio_por_kg
            and existente.monto_total == datos.monto_total
            and existente.observaciones == datos.observaciones
            and set(animal_ids) == set(datos.animal_ids)
        )

    async def _coincide_cobro_inicial(
        self, existente: Venta, datos: VentaCreate
    ) -> bool:
        """Comprueba el cobro identificable sin confundir cuotas posteriores.

        Una venta originalmente pendiente puede tener cobros agregados después;
        por eso, si el comando no trae cobro inicial, el reintento se considera
        idéntico sin exigir que la venta siga sin cobros.
        """
        entrada = datos.cobro_inicial
        if entrada is None:
            return True

        cobro = await self.repository.get_cobro_including_deleted(entrada.id)
        return (
            cobro is not None
            and cobro.deleted_at is None
            and cobro.venta_id == existente.id
            and cobro.fecha_cobro == entrada.fecha_cobro
            and cobro.monto == entrada.monto
            and cobro.medio_cobro == entrada.medio_cobro
            and cobro.observaciones == entrada.observaciones
        )

    async def _to_read(self, venta: Venta) -> VentaRead:
        """Construye saldo y estado desde cobros activos, nunca desde un flag."""
        animal_ids = await self.repository.list_animal_ids(venta.id)
        monto_cobrado = (await self.repository.get_monto_cobrado(venta.id)).quantize(
            PRECISION_MONETARIA, rounding=ROUND_HALF_UP
        )
        saldo_pendiente = max(
            venta.monto_total - monto_cobrado,
            Decimal("0.00"),
        ).quantize(PRECISION_MONETARIA, rounding=ROUND_HALF_UP)

        if monto_cobrado == 0:
            estado_cobro = EstadoCobro.pendiente
        elif saldo_pendiente == 0:
            estado_cobro = EstadoCobro.cobrada
        else:
            estado_cobro = EstadoCobro.parcial

        return VentaRead(
            id=venta.id,
            establecimiento_id=venta.establecimiento_id,
            fecha_operacion=venta.fecha_operacion,
            tipo_comprador=venta.tipo_comprador,
            nombre_comprador=venta.nombre_comprador,
            es_empresa=venta.es_empresa,
            apellido_comprador=venta.apellido_comprador,
            nro_dte=venta.nro_dte,
            tipo_venta=venta.tipo_venta,
            peso_total_kg=venta.peso_total_kg,
            precio_por_kg=venta.precio_por_kg,
            monto_total=venta.monto_total,
            observaciones=venta.observaciones,
            registrada_por_id=venta.registrada_por_id,
            animal_ids=animal_ids,
            monto_cobrado=monto_cobrado,
            saldo_pendiente=saldo_pendiente,
            estado_cobro=estado_cobro,
            created_at=venta.created_at,
            updated_at=venta.updated_at,
            deleted_at=venta.deleted_at,
        )
