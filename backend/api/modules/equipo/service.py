"""Reglas del equipo de un establecimiento: miembros e invitaciones (adr-0012).

Quién puede qué:

- Ver el equipo: cualquier miembro activo.
- Invitar, reenviar, cancelar y quitar: ``owner`` y ``admin``.
- El ``owner`` asigna cualquier rol. El ``admin`` no puede invitar ni gestionar
  a un ``owner``, y solo quita a ``employee`` o ``veterinarian``.
- Nadie se quita a sí mismo y el titular (``owner_id``) no se quita. Como a un
  ``owner`` solo lo quita otro ``owner``, el campo nunca queda sin dueño.

El canje exige el código del email *y* una sesión con ese mismo email: el
registro no verifica la casilla, así que el código es la prueba de que la
persona la controla.
"""

import logging
from collections.abc import Callable
from datetime import UTC, datetime, timedelta
from uuid import UUID

import anyio
from sqlalchemy.exc import IntegrityError
from sqlalchemy.ext.asyncio import AsyncSession

from api.modules.equipo import codigos
from api.modules.equipo.email_templates import email_aceptacion, email_invitacion
from api.modules.equipo.exceptions import (
    CodigoDeOtroEmailError,
    CodigoInvalidoError,
    CodigoRevocadoError,
    CodigoUsadoError,
    CodigoVencidoError,
    GestionEquipoNoPermitidaError,
    InvitacionNoEncontradaError,
    InvitacionNoPendienteError,
    InvitacionPendienteDuplicadaError,
    MiembroNoEncontradoError,
    NoPodesQuitarteError,
    RolNoAsignableError,
    TitularNoRemovibleError,
    YaEsMiembroError,
)
from api.modules.equipo.models import InvitacionEstablecimiento
from api.modules.equipo.repository import InvitacionRepository, MiembroRepository
from api.modules.equipo.schemas import (
    InvitacionCreada,
    InvitacionCreate,
    InvitacionPrevia,
    InvitacionRead,
    MiembroEquipoRead,
)
from api.modules.establecimientos.exceptions import EstablecimientoNoEncontradoError
from api.modules.establecimientos.models import Establecimiento, UsuarioEstablecimiento
from api.modules.establecimientos.repository import (
    EstablecimientoRepository,
    UsuarioEstablecimientoRepository,
)
from api.modules.establecimientos.schemas import (
    EstablecimientoConRolRead,
    EstablecimientoRead,
)
from api.modules.usuarios.models import Usuario
from api.modules.usuarios.repository import UsuarioRepository
from api.shared.enums import EstadoInvitacion, RolUsuario
from api.shared.sync import as_utc
from core.config import settings
from core.email import EmailEnvioError, EmailSender

logger = logging.getLogger(__name__)

ROLES_QUE_GESTIONAN = {RolUsuario.owner, RolUsuario.admin}

# Qué roles puede asignar o gestionar cada rol gestor.
_ROLES_GESTIONABLES: dict[RolUsuario, set[RolUsuario]] = {
    RolUsuario.owner: set(RolUsuario),
    RolUsuario.admin: {RolUsuario.admin, RolUsuario.employee, RolUsuario.veterinarian},
}
# Quitar es más estricto que invitar: un admin no saca a otro admin.
_ROLES_REMOVIBLES: dict[RolUsuario, set[RolUsuario]] = {
    RolUsuario.owner: set(RolUsuario),
    RolUsuario.admin: {RolUsuario.employee, RolUsuario.veterinarian},
}
# Si alguien tiene más de un rol en el campo, se muestra el de mayor jerarquía.
_JERARQUIA = [
    RolUsuario.owner,
    RolUsuario.admin,
    RolUsuario.veterinarian,
    RolUsuario.employee,
]


def _rol_principal(roles: set[RolUsuario]) -> RolUsuario:
    return next(rol for rol in _JERARQUIA if rol in roles)


def _ahora() -> datetime:
    return datetime.now(UTC)


class EquipoService:
    def __init__(
        self,
        session: AsyncSession,
        *,
        email_sender: EmailSender | None = None,
        reloj: Callable[[], datetime] = _ahora,
    ) -> None:
        self.session = session
        self.email_sender = email_sender
        self.reloj = reloj
        self.establecimientos = EstablecimientoRepository(session)
        self.membresias = UsuarioEstablecimientoRepository(session)
        self.miembros = MiembroRepository(session)
        self.invitaciones = InvitacionRepository(session)
        self.usuarios = UsuarioRepository(session)

    # ─── Miembros ──────────────────────────────────────────────────────────

    async def listar_miembros(
        self, current_user: Usuario, establecimiento_id: UUID
    ) -> list[MiembroEquipoRead]:
        establecimiento, _ = await self._acceso(current_user, establecimiento_id)
        agrupados: dict[UUID, tuple[Usuario, set[RolUsuario], datetime]] = {}
        for usuario, membresia in await self.miembros.list_activos(establecimiento_id):
            rol = RolUsuario(membresia.rol)
            if usuario.id in agrupados:
                agrupados[usuario.id][1].add(rol)
            else:
                agrupados[usuario.id] = (usuario, {rol}, membresia.created_at)
        return [
            MiembroEquipoRead(
                usuario_id=usuario.id,
                nombre=usuario.nombre,
                apellido=usuario.apellido,
                email=usuario.email,
                rol=_rol_principal(roles),
                es_titular=usuario.id == establecimiento.owner_id,
                color_cabecera=usuario.color_cabecera,
                miembro_desde=desde,
            )
            for usuario, roles, desde in agrupados.values()
        ]

    async def quitar_miembro(
        self, current_user: Usuario, establecimiento_id: UUID, usuario_id: UUID
    ) -> None:
        establecimiento, mis_roles = await self._acceso(
            current_user, establecimiento_id
        )
        rol_gestor = self._rol_gestor(mis_roles)

        if usuario_id == current_user.id:
            raise NoPodesQuitarteError()
        if usuario_id == establecimiento.owner_id:
            raise TitularNoRemovibleError()

        activas = [
            m
            for m in await self.miembros.list_de_usuario(usuario_id, establecimiento_id)
            if m.activo
        ]
        if not activas:
            raise MiembroNoEncontradoError()

        roles_objetivo = {RolUsuario(m.rol) for m in activas}
        # Esto también garantiza que el campo no se queda sin dueño: a un owner
        # solo lo quita otro owner, y nadie se quita a sí mismo.
        if not roles_objetivo <= _ROLES_REMOVIBLES[rol_gestor]:
            raise RolNoAsignableError()

        for membresia in activas:
            membresia.activo = False
            await self.miembros.guardar(membresia)
        logger.info(
            "[EQUIPO] %s quitó a %s del establecimiento %s",
            current_user.id,
            usuario_id,
            establecimiento_id,
        )

    # ─── Invitaciones ──────────────────────────────────────────────────────

    async def listar_invitaciones(
        self, current_user: Usuario, establecimiento_id: UUID
    ) -> list[InvitacionRead]:
        await self._acceso(current_user, establecimiento_id)
        return [
            self._representar(invitacion)
            for invitacion in await self.invitaciones.list_pendientes(
                establecimiento_id
            )
        ]

    async def invitar(
        self, current_user: Usuario, establecimiento_id: UUID, data: InvitacionCreate
    ) -> InvitacionCreada:
        establecimiento, mis_roles = await self._acceso(
            current_user, establecimiento_id
        )
        self._exigir_gestion_de_rol(mis_roles, data.rol)

        invitado = await self.usuarios.get_by_email(data.email)
        if invitado is not None and await self.membresias.get_membership(
            invitado.id, establecimiento_id
        ):
            raise YaEsMiembroError()

        codigo = codigos.generar_codigo()
        existente = await self.invitaciones.get_pendiente(
            establecimiento_id, data.email
        )
        if existente is not None:
            if not self._vencida(existente):
                raise InvitacionPendienteDuplicadaError()
            # Una pendiente vencida se recicla: misma fila, código y rol nuevos.
            invitacion = existente
            invitacion.rol = data.rol
            invitacion.invitado_por_id = current_user.id
        else:
            invitacion = InvitacionEstablecimiento(
                establecimiento_id=establecimiento_id,
                email=data.email,
                rol=data.rol,
                codigo_hash="",
                expira_en=self.reloj(),
                invitado_por_id=current_user.id,
            )
        self._renovar_codigo(invitacion, codigo)

        try:
            await self.invitaciones.guardar(invitacion)
        except IntegrityError as exc:
            # Carrera con otra invitación al mismo email: la constraint parcial
            # es la garantía final.
            await self.session.rollback()
            raise InvitacionPendienteDuplicadaError() from exc

        await self._enviar(invitacion, codigo, establecimiento, current_user)
        return self._representar_creada(invitacion, codigo)

    async def reenviar(
        self, current_user: Usuario, establecimiento_id: UUID, invitacion_id: UUID
    ) -> InvitacionCreada:
        establecimiento, mis_roles = await self._acceso(
            current_user, establecimiento_id
        )
        invitacion = await self._invitacion_pendiente(establecimiento_id, invitacion_id)
        self._exigir_gestion_de_rol(mis_roles, RolUsuario(invitacion.rol))

        codigo = codigos.generar_codigo()
        self._renovar_codigo(invitacion, codigo)
        await self.invitaciones.guardar(invitacion)
        await self._enviar(invitacion, codigo, establecimiento, current_user)
        return self._representar_creada(invitacion, codigo)

    async def cancelar(
        self, current_user: Usuario, establecimiento_id: UUID, invitacion_id: UUID
    ) -> None:
        _, mis_roles = await self._acceso(current_user, establecimiento_id)
        invitacion = await self._invitacion_pendiente(establecimiento_id, invitacion_id)
        self._exigir_gestion_de_rol(mis_roles, RolUsuario(invitacion.rol))
        invitacion.estado = EstadoInvitacion.cancelada
        await self.invitaciones.guardar(invitacion)

    # ─── Canje ─────────────────────────────────────────────────────────────

    async def previsualizar(
        self, current_user: Usuario, codigo: str
    ) -> InvitacionPrevia:
        invitacion, establecimiento = await self._invitacion_canjeable(
            current_user, codigo
        )
        invitado_por = await self.usuarios.get_by_id(invitacion.invitado_por_id)
        roles_de_quien_invita = {
            RolUsuario(m.rol)
            for m in await self.membresias.get_memberships(
                invitacion.invitado_por_id, establecimiento.id
            )
        }
        role = RolUsuario(invitacion.rol)
        if invitacion.estado == EstadoInvitacion.aceptada:
            memberships = await self.membresias.get_memberships(
                current_user.id, establecimiento.id
            )
            if not memberships:
                raise CodigoUsadoError()
            role = _rol_principal({RolUsuario(m.rol) for m in memberships})
        return InvitacionPrevia(
            establecimiento_id=establecimiento.id,
            establecimiento_nombre=establecimiento.nombre,
            establecimiento_renspa=establecimiento.nro_renspa,
            establecimiento_localidad=establecimiento.localidad,
            establecimiento_provincia=establecimiento.provincia,
            rol=role,
            email=invitacion.email,
            invitado_por=(
                f"{invitado_por.nombre} {invitado_por.apellido}"
                if invitado_por is not None
                else ""
            ),
            # Puede haber dejado el campo después de invitar: entonces no hay rol.
            invitado_por_rol=(
                _rol_principal(roles_de_quien_invita) if roles_de_quien_invita else None
            ),
            expira_en=as_utc(invitacion.expira_en),
        )

    async def aceptar(
        self, current_user: Usuario, codigo: str
    ) -> EstablecimientoConRolRead:
        invitacion, establecimiento = await self._invitacion_canjeable(
            current_user, codigo
        )
        rol = RolUsuario(invitacion.rol)

        if invitacion.estado == EstadoInvitacion.aceptada:
            # Recuperar una respuesta perdida solo consulta el acceso vigente.
            # No reactiva filas, no restaura el rol invitado ni repite el aviso.
            roles = await self.membresias.get_memberships(
                current_user.id, establecimiento.id
            )
            if not roles:
                raise CodigoUsadoError()
            datos = EstablecimientoRead.model_validate(establecimiento).model_dump()
            return EstablecimientoConRolRead(
                **datos, rol=_rol_principal({RolUsuario(m.rol) for m in roles})
            )

        if not await self.invitaciones.marcar_aceptada(
            invitacion.id, usuario_id=current_user.id, ahora=self.reloj()
        ):
            raise CodigoUsadoError()

        # Si lo habían quitado antes con el mismo rol, se reactiva esa fila: la
        # unicidad (usuario, establecimiento, rol) no admite una segunda.
        previas = await self.miembros.list_de_usuario(
            current_user.id, establecimiento.id
        )
        misma = next((m for m in previas if RolUsuario(m.rol) == rol), None)
        if misma is not None:
            misma.activo = True
            await self.miembros.guardar(misma)
        else:
            await self.miembros.guardar(
                UsuarioEstablecimiento(
                    usuario_id=current_user.id,
                    establecimiento_id=establecimiento.id,
                    rol=rol,
                    activo=True,
                )
            )
        logger.info(
            "[EQUIPO] %s se sumó al establecimiento %s como %s",
            current_user.id,
            establecimiento.id,
            rol.value,
        )
        await self._avisar_aceptacion(invitacion, establecimiento, current_user, rol)
        datos = EstablecimientoRead.model_validate(establecimiento).model_dump()
        return EstablecimientoConRolRead(**datos, rol=rol)

    # ─── Helpers ───────────────────────────────────────────────────────────

    async def _acceso(
        self, current_user: Usuario, establecimiento_id: UUID
    ) -> tuple[Establecimiento, set[RolUsuario]]:
        """Establecimiento + roles activos del usuario; 404 si no es miembro.

        404 y no 403, igual que ``EstablecimientoService``: no se revela que el
        establecimiento existe a quien no tiene acceso.
        """
        establecimiento = await self.establecimientos.get_by_id(establecimiento_id)
        if establecimiento is None:
            raise EstablecimientoNoEncontradoError()
        membresias = await self.membresias.get_memberships(
            current_user.id, establecimiento_id
        )
        if not membresias:
            raise EstablecimientoNoEncontradoError()
        return establecimiento, {RolUsuario(m.rol) for m in membresias}

    @staticmethod
    def _rol_gestor(mis_roles: set[RolUsuario]) -> RolUsuario:
        if RolUsuario.owner in mis_roles:
            return RolUsuario.owner
        if RolUsuario.admin in mis_roles:
            return RolUsuario.admin
        raise GestionEquipoNoPermitidaError()

    def _exigir_gestion_de_rol(
        self, mis_roles: set[RolUsuario], rol: RolUsuario
    ) -> None:
        if rol not in _ROLES_GESTIONABLES[self._rol_gestor(mis_roles)]:
            raise RolNoAsignableError()

    async def _invitacion_pendiente(
        self, establecimiento_id: UUID, invitacion_id: UUID
    ) -> InvitacionEstablecimiento:
        invitacion = await self.invitaciones.get(invitacion_id, establecimiento_id)
        if invitacion is None:
            raise InvitacionNoEncontradaError()
        if invitacion.estado != EstadoInvitacion.pendiente:
            raise InvitacionNoPendienteError()
        return invitacion

    async def _invitacion_canjeable(
        self, current_user: Usuario, codigo: str
    ) -> tuple[InvitacionEstablecimiento, Establecimiento]:
        if not codigos.tiene_formato_valido(codigo):
            raise CodigoInvalidoError()
        invitacion = await self.invitaciones.get_por_codigo_hash(
            codigos.hashear_codigo(codigo, settings.INVITACION_CODIGO_SECRETO)
        )
        if invitacion is None:
            raise CodigoInvalidoError()
        if invitacion.estado == EstadoInvitacion.aceptada:
            if (
                invitacion.aceptada_por_id != current_user.id
                or current_user.email.strip().lower() != invitacion.email
            ):
                raise CodigoUsadoError()
            establecimiento = await self.establecimientos.get_by_id(
                invitacion.establecimiento_id
            )
            if establecimiento is None or not await self.membresias.get_memberships(
                current_user.id, invitacion.establecimiento_id
            ):
                raise CodigoUsadoError()
            return invitacion, establecimiento
        if invitacion.estado == EstadoInvitacion.cancelada:
            raise CodigoRevocadoError()
        if self._vencida(invitacion):
            raise CodigoVencidoError()
        if current_user.email.strip().lower() != invitacion.email:
            raise CodigoDeOtroEmailError()

        establecimiento = await self.establecimientos.get_by_id(
            invitacion.establecimiento_id
        )
        if establecimiento is None:
            raise CodigoInvalidoError()
        if await self.membresias.get_membership(current_user.id, establecimiento.id):
            raise YaEsMiembroError()
        return invitacion, establecimiento

    def _vencida(self, invitacion: InvitacionEstablecimiento) -> bool:
        return as_utc(invitacion.expira_en) <= self.reloj()

    def _renovar_codigo(
        self, invitacion: InvitacionEstablecimiento, codigo: str
    ) -> None:
        invitacion.codigo_hash = codigos.hashear_codigo(
            codigo, settings.INVITACION_CODIGO_SECRETO
        )
        invitacion.expira_en = self.reloj() + timedelta(
            days=settings.INVITACION_VIGENCIA_DIAS
        )
        invitacion.email_enviado_en = None

    async def _enviar(
        self,
        invitacion: InvitacionEstablecimiento,
        codigo: str,
        establecimiento: Establecimiento,
        current_user: Usuario,
    ) -> None:
        """Manda el email; si falla, la invitación queda y se puede reenviar.

        No se propaga el error: el owner ve ``email_enviado=False`` y la app le
        ofrece reenviar. Así una caída del SMTP no le pierde lo que cargó.
        """
        if self.email_sender is None:
            raise RuntimeError("EquipoService necesita un EmailSender para invitar")
        email = email_invitacion(
            destinatario=invitacion.email,
            establecimiento=establecimiento.nombre,
            invitado_por=f"{current_user.nombre} {current_user.apellido}",
            rol=RolUsuario(invitacion.rol),
            codigo_formateado=codigos.formatear_codigo(codigo),
            expira_en=as_utc(invitacion.expira_en),
        )
        try:
            with anyio.fail_after(settings.EMAIL_TIMEOUT_SECONDS):
                await self.email_sender.enviar(email)
        except (EmailEnvioError, TimeoutError):
            logger.warning(
                "[EQUIPO] La invitación %s quedó creada pero el email no salió",
                invitacion.id,
            )
            return
        invitacion.email_enviado_en = self.reloj()
        await self.invitaciones.guardar(invitacion)

    async def _avisar_aceptacion(
        self,
        invitacion: InvitacionEstablecimiento,
        establecimiento: Establecimiento,
        nuevo: Usuario,
        rol: RolUsuario,
    ) -> None:
        """Le avisa por email a quien invitó. Nunca bloquea el canje.

        Sin ``email_sender`` (o si el envío falla) el canje sigue igual: el
        aviso es una cortesía y quien invitó lo ve igual en Equipo.
        """
        invitado_por = await self.usuarios.get_by_id(invitacion.invitado_por_id)
        if self.email_sender is None or invitado_por is None:
            return
        email = email_aceptacion(
            destinatario=invitado_por.email,
            establecimiento=establecimiento.nombre,
            nuevo_miembro=f"{nuevo.nombre} {nuevo.apellido}",
            rol=rol,
        )
        try:
            with anyio.fail_after(settings.EMAIL_TIMEOUT_SECONDS):
                await self.email_sender.enviar(email)
        except (EmailEnvioError, TimeoutError):
            logger.warning(
                "[EQUIPO] No salió el aviso de aceptación de la invitación %s",
                invitacion.id,
            )

    def _representar_creada(
        self, invitacion: InvitacionEstablecimiento, codigo: str
    ) -> InvitacionCreada:
        """La invitación con el código en claro: solo en esta respuesta.

        Es para que el owner lo comparta por otro medio si el email no llega.
        No se puede volver a leer: en la base queda solo el HMAC.
        """
        return InvitacionCreada(
            **self._representar(invitacion).model_dump(),
            codigo=codigos.formatear_codigo(codigo),
        )

    def _representar(self, invitacion: InvitacionEstablecimiento) -> InvitacionRead:
        return InvitacionRead(
            id=invitacion.id,
            establecimiento_id=invitacion.establecimiento_id,
            email=invitacion.email,
            rol=RolUsuario(invitacion.rol),
            estado=EstadoInvitacion(invitacion.estado),
            expira_en=as_utc(invitacion.expira_en),
            vencida=self._vencida(invitacion),
            email_enviado=invitacion.email_enviado_en is not None,
            invitado_por_id=invitacion.invitado_por_id,
            created_at=as_utc(invitacion.created_at),
        )
