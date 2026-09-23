"""Reglas de negocio del agregado base de ventas de hacienda.

La operación pública se completará al incorporar la persistencia de cobros. Por
ahora este service concentra las reglas independientes de esa tabla: permisos,
idempotencia comercial, disponibilidad de animales y actualización atómica del
stock. No debe conectarse a un router hasta integrar el cobro inicial.
"""

from datetime import UTC, datetime
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
from api.modules.ventas.models import Venta
from api.modules.ventas.repository import VentaRepository
from api.modules.ventas.schemas import VentaCreate
from api.shared.enums import EstadoAnimal, RolUsuario
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

    async def crear_base(self, usuario: Usuario, datos: VentaCreate) -> Venta:
        """Crea venta, detalles y baja de stock, todavía sin persistir cobros.

        Este método es una etapa interna del desarrollo: deliberadamente no
        devuelve ``VentaRead`` ni se publica por HTTP. El futuro método público
        incorporará el cobro inicial en esta misma transacción antes de responder.
        """
        await self.exigir_acceso_comercial(usuario, datos.establecimiento_id)

        existente = await self.repository.get_including_deleted(datos.id)
        if existente is not None:
            # Se controla también el tenant persistido: un UUID conocido nunca
            # permite usar el establecimiento entrante como vía lateral.
            await self.exigir_acceso_comercial(usuario, existente.establecimiento_id)
            if not await self._coincide_con_existente(existente, datos):
                raise VentaIdEnConflictoError()
            return existente

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

        for animal in animales:
            animal.estado = EstadoAnimal.vendido
            # La baja debe aparecer en el próximo pull aunque la fecha comercial
            # sea histórica o el cliente haya enviado un updated_at antiguo.
            animal.updated_at = ahora
        await self.repository.save_animales(animales)
        return venta

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
