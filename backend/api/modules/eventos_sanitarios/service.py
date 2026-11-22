"""Lógica de negocio de Sanidad: catálogo, alta por grupo, resultado e historial.

Contrato acordado con Mobile en ``docs/plan-backend-integracion-sanidad.md`` y
decisiones en ``docs/adr/adr-0017-eventos-sanitarios-por-operacion.md``.
"""

from datetime import UTC, date, datetime, timedelta, timezone
from decimal import Decimal, DecimalException
import hashlib
import json
import re
from typing import Any
from uuid import UUID

from sqlalchemy.ext.asyncio import AsyncSession

from api.modules.establecimientos.repository import UsuarioEstablecimientoRepository
from api.modules.eventos_sanitarios.catalogo import (
    MODELO_APLICACION,
    MODELO_MUESTREO,
    PRACTICAS,
    PRACTICAS_POR_ID,
    Practica,
)
from api.modules.eventos_sanitarios.exceptions import (
    AnimalNoDisponibleError,
    EventoSanitarioExistenteError,
    EventoSanitarioInvalidoError,
    EventoSanitarioNoEncontradoError,
    OperacionSanitariaConflictoError,
    ResultadoYaCompletadoError,
)
from api.modules.eventos_sanitarios.models import EventoSanitario, OperacionSanitaria
from api.modules.eventos_sanitarios.repository import EventoSanitarioRepository
from api.modules.eventos_sanitarios.schemas import AltaSanitaria, ResultadoSanitario
from api.modules.productos_sanitarios.models import ProductoSanitario
from api.modules.usuarios.models import Usuario
from api.shared.enums import EstadoAnimal
from api.shared.exceptions import EstablecimientoNoAutorizadoError
from api.shared.sync import as_utc

MAX_ANIMALES_POR_OPERACION = 500
TAMANIO_PAGINA_HISTORIAL = 200
# Margen para relojes de celulares levemente adelantados.
_TOLERANCIA_FUTURO = timedelta(minutes=10)
# Día calendario que ve el productor. Argentina no tiene horario de verano
# desde 2009, así que un desfasaje fijo alcanza y no depende de tzdata.
ZONA_HORARIA_CAMPO = timezone(timedelta(hours=-3), "ART")
DOSIS_MAXIMA = Decimal(10000)
DECIMALES_DOSIS = 4
# Cabe en un bigint de Postgres: un cursor más largo no es uno que emitimos.
_CURSOR_VALIDO = re.compile(r"[0-9]{1,18}")
_TIPO_ALTA = "alta"
_TIPO_RESULTADO = "resultado"

_LIMITES = {
    "responsable": 120,
    "observaciones": 1000,
    "caravana": 60,
    "referencia_muestra": 60,
    "unidad": 20,
    "via": 40,
    "serie": 60,
    "descripcion": 500,
    "tipo_muestra": 60,
    "resultado": 1000,
}


def huella(cuerpo: Any) -> str:
    """Hash estable del cuerpo de una operación (mismo cuerpo, misma huella)."""
    serializado = json.dumps(cuerpo, sort_keys=True, separators=(",", ":"))
    return hashlib.sha256(serializado.encode()).hexdigest()


def _iso(valor: datetime | None) -> str | None:
    return as_utc(valor).isoformat() if valor is not None else None


def _texto_obligatorio(valor: Any, campo: str, *, animal_id: UUID | None = None) -> str:
    nombre = campo.rsplit(".", 1)[-1]
    if not isinstance(valor, str) or not valor.strip():
        raise EventoSanitarioInvalidoError(
            f"Falta completar {nombre}", campo=campo, animal_id=animal_id
        )
    return _texto_opcional(valor, campo, animal_id=animal_id)  # type: ignore[return-value]


def _texto_opcional(
    valor: Any, campo: str, *, animal_id: UUID | None = None
) -> str | None:
    if valor is None:
        return None
    nombre = campo.rsplit(".", 1)[-1]
    if not isinstance(valor, str):
        raise EventoSanitarioInvalidoError(
            f"{nombre} tiene un formato inválido", campo=campo, animal_id=animal_id
        )
    limpio = valor.strip()
    if len(limpio) > _LIMITES[nombre]:
        raise EventoSanitarioInvalidoError(
            f"{nombre} supera los {_LIMITES[nombre]} caracteres",
            campo=campo,
            animal_id=animal_id,
        )
    return limpio or None


def _no_futura(valor: datetime, campo: str) -> datetime:
    valor = as_utc(valor)
    if valor > datetime.now(UTC) + _TOLERANCIA_FUTURO:
        raise EventoSanitarioInvalidoError("La fecha no puede ser futura", campo=campo)
    return valor


def _dia_del_campo(valor: datetime) -> date:
    return as_utc(valor).astimezone(ZONA_HORARIA_CAMPO).date()


def representar(evento: EventoSanitario) -> dict[str, Any]:
    """Forma canónica de un evento: igual en POST, PUT, GET y en el 409."""
    producto_ids = (
        [str(evento.producto_id)]
        if evento.practica_modelo == MODELO_APLICACION and evento.producto_id
        else []
    )
    resultado = None
    if evento.resultado is not None:
        resultado = {
            "valor": evento.resultado,
            "fecha": _iso(evento.resultado_fecha),
            "registrado_por_id": str(evento.resultado_registrado_por_id)
            if evento.resultado_registrado_por_id
            else None,
        }
    return {
        "id": str(evento.id),
        "establecimiento_id": str(evento.establecimiento_id),
        "animal_id": str(evento.animal_id),
        "caravana": evento.caravana,
        "lote_id": str(evento.lote_id) if evento.lote_id else None,
        "referencia_muestra": evento.referencia_muestra,
        "practica": {
            "id": evento.practica_id,
            "nombre": evento.practica_nombre,
            "modelo": evento.practica_modelo,
            "producto_ids": producto_ids,
        },
        "datos": evento.datos,
        "fecha_aplicacion": _iso(evento.fecha_aplicacion),
        "responsable": evento.responsable,
        "registrado_por_id": str(evento.registrado_por_id)
        if evento.registrado_por_id
        else None,
        "observaciones": evento.observaciones,
        "created_at": _iso(evento.created_at),
        "updated_at": _iso(evento.updated_at),
        "deleted_at": _iso(evento.deleted_at),
        "resultado": resultado,
    }


class EventoSanitarioService:
    def __init__(self, session: AsyncSession) -> None:
        self.session = session
        self.repository = EventoSanitarioRepository(session)
        self.membership_repository = UsuarioEstablecimientoRepository(session)

    async def _es_miembro(self, usuario: Usuario, establecimiento_id: UUID) -> bool:
        membresia = await self.membership_repository.get_membership(
            usuario.id, establecimiento_id
        )
        return membresia is not None

    async def _exigir_acceso(self, usuario: Usuario, establecimiento_id: UUID) -> None:
        if not await self._es_miembro(usuario, establecimiento_id):
            raise EstablecimientoNoAutorizadoError()

    # ------------------------------------------------------------------ catálogo

    async def catalogo(
        self, usuario: Usuario, establecimiento_id: UUID
    ) -> dict[str, Any]:
        """Prácticas y productos vigentes del establecimiento."""
        await self._exigir_acceso(usuario, establecimiento_id)
        productos = await self.repository.productos_vigentes(establecimiento_id)
        practicas = []
        usados: set[UUID] = set()
        for practica in PRACTICAS:
            elegibles = [p for p in productos if p.tipo in practica.tipos_producto]
            usados.update(p.id for p in elegibles)
            practicas.append(
                {
                    "id": practica.id,
                    "nombre": practica.nombre,
                    "modelo": practica.modelo,
                    "producto_ids": [str(p.id) for p in elegibles],
                }
            )
        return {
            "practicas": practicas,
            "productos": [
                {"id": str(p.id), "nombre": p.nombre}
                for p in productos
                if p.id in usados
            ],
        }

    # ---------------------------------------------------------------------- alta

    async def registrar(
        self, usuario: Usuario, data: AltaSanitaria
    ) -> list[dict[str, Any]]:
        """Alta atómica e idempotente de una práctica sobre un grupo de animales."""
        await self._exigir_acceso(usuario, data.establecimiento_id)
        cuerpo = huella(data.model_dump(mode="json"))
        await self.repository.bloquear_establecimiento(data.establecimiento_id)

        # Un reenvío se resuelve antes de revalidar: el producto o el animal
        # pueden haber cambiado desde que se aceptó.
        previa = await self.repository.get_operacion(data.id)
        if previa is not None:
            if (
                previa.tipo != _TIPO_ALTA
                or previa.establecimiento_id != data.establecimiento_id
                or previa.huella != cuerpo
            ):
                raise OperacionSanitariaConflictoError()
            return await self._eventos_de_alta(data)

        practica = PRACTICAS_POR_ID.get(data.practica_id)
        if practica is None:
            raise EventoSanitarioInvalidoError(
                "La práctica no está disponible", campo="practica_id"
            )
        responsable = _texto_obligatorio(data.responsable, "responsable")
        observaciones = _texto_opcional(data.observaciones, "observaciones")
        fecha_aplicacion = _no_futura(data.fecha_aplicacion, "fecha_aplicacion")
        datos, producto = await self._validar_datos(practica, data)
        await self._validar_animales(practica, data)

        ahora = datetime.now(UTC)
        version = await self.repository.siguiente_version(data.establecimiento_id)
        carencia = producto.periodo_carencia_dias if producto else None
        eventos = []
        for indice, item in enumerate(data.animales):
            eventos.append(
                EventoSanitario(
                    id=item.id,
                    created_at=as_utc(item.created_at) or ahora,
                    # Nunca menor al reloj del servidor ni al del celular: la
                    # versión que guarda el celular no puede quedar adelante.
                    updated_at=max(ahora, as_utc(item.updated_at) or ahora),
                    establecimiento_id=data.establecimiento_id,
                    animal_id=item.animal_id,
                    tipo=practica.tipo,
                    producto_id=producto.id if producto else None,
                    fecha_aplicacion=fecha_aplicacion,
                    dosis=datos.get("dosis"),
                    periodo_carencia_dias=carencia,
                    fecha_fin_carencia=(
                        fecha_aplicacion.date() + timedelta(days=carencia)
                        if carencia
                        else None
                    ),
                    observaciones=observaciones,
                    operacion_id=data.id,
                    practica_id=practica.id,
                    practica_nombre=practica.nombre,
                    practica_modelo=practica.modelo,
                    datos=datos,
                    caravana=_texto_opcional(
                        item.caravana,
                        f"animales.{indice}.caravana",
                        animal_id=item.animal_id,
                    ),
                    lote_id=item.lote_id,
                    referencia_muestra=_texto_opcional(
                        item.referencia_muestra,
                        f"animales.{indice}.referencia_muestra",
                        animal_id=item.animal_id,
                    ),
                    responsable=responsable,
                    registrado_por_id=usuario.id,
                    version=version + indice,
                )
            )
        operacion = OperacionSanitaria(
            id=data.id,
            establecimiento_id=data.establecimiento_id,
            tipo=_TIPO_ALTA,
            huella=cuerpo,
            usuario_id=usuario.id,
        )
        self.repository.agregar([operacion, *eventos])
        await self.repository.flush()
        return [representar(evento) for evento in eventos]

    async def _eventos_de_alta(self, data: AltaSanitaria) -> list[dict[str, Any]]:
        """Estado vigente de una operación aceptada, en el orden del envío."""
        por_id = {e.id: e for e in await self.repository.eventos_de_operacion(data.id)}
        return [
            representar(por_id[item.id]) for item in data.animales if item.id in por_id
        ]

    async def _validar_datos(
        self, practica: Practica, data: AltaSanitaria
    ) -> tuple[dict[str, Any], ProductoSanitario | None]:
        datos = data.datos
        if practica.modelo == MODELO_APLICACION:
            producto = await self._producto_elegible(practica, data)
            dosis = self._dosis(datos.get("dosis"))
            vencimiento = datos.get("vencimiento")
            if vencimiento is not None:
                try:
                    vencimiento = date.fromisoformat(vencimiento).isoformat()
                except (TypeError, ValueError):
                    raise EventoSanitarioInvalidoError(
                        "El vencimiento tiene que ser una fecha AAAA-MM-DD",
                        campo="datos.vencimiento",
                    ) from None
            return (
                {
                    "producto_id": str(producto.id),
                    # El nombre lo decide el servidor: queda como foto histórica.
                    "producto_nombre": producto.nombre,
                    "dosis": dosis,
                    "unidad": _texto_obligatorio(datos.get("unidad"), "datos.unidad"),
                    "via": _texto_obligatorio(datos.get("via"), "datos.via"),
                    "serie": _texto_opcional(datos.get("serie"), "datos.serie"),
                    "vencimiento": vencimiento,
                },
                producto,
            )
        descripcion = _texto_obligatorio(datos.get("descripcion"), "datos.descripcion")
        if practica.modelo == MODELO_MUESTREO:
            tipo_muestra = _texto_obligatorio(
                datos.get("tipo_muestra"), "datos.tipo_muestra"
            )
            return {"descripcion": descripcion, "tipo_muestra": tipo_muestra}, None
        if datos.get("tipo_muestra") is not None:
            raise EventoSanitarioInvalidoError(
                "Una lesión no lleva tipo de muestra", campo="datos.tipo_muestra"
            )
        return {"descripcion": descripcion, "tipo_muestra": None}, None

    async def _producto_elegible(
        self, practica: Practica, data: AltaSanitaria
    ) -> ProductoSanitario:
        try:
            producto_id = UUID(str(data.datos.get("producto_id")))
        except ValueError:
            producto_id = None
        productos = await self.repository.productos_vigentes(data.establecimiento_id)
        producto = next(
            (
                p
                for p in productos
                if p.id == producto_id and p.tipo in practica.tipos_producto
            ),
            None,
        )
        if producto is None:
            raise EventoSanitarioInvalidoError(
                "El producto no está disponible para esta práctica",
                campo="datos.producto_id",
            )
        return producto

    @staticmethod
    def _dosis(valor: Any) -> str:
        texto = str(valor).replace(",", ".").strip() if valor is not None else ""
        try:
            # El largo acota el costo de parsear; Overflow o Underflow no son
            # InvalidOperation, por eso se atrapa la base de los errores decimales.
            dosis = Decimal(texto) if 0 < len(texto) <= 20 else None
        except DecimalException:
            dosis = None
        if dosis is None or not dosis.is_finite() or dosis <= 0:
            raise EventoSanitarioInvalidoError(
                "La dosis tiene que ser un número mayor a cero", campo="datos.dosis"
            )
        if (
            dosis > DOSIS_MAXIMA
            or -dosis.normalize().as_tuple().exponent > DECIMALES_DOSIS
        ):
            raise EventoSanitarioInvalidoError(
                f"La dosis admite hasta {DOSIS_MAXIMA} con {DECIMALES_DOSIS} decimales",
                campo="datos.dosis",
            )
        return format(dosis.normalize(), "f")

    async def _validar_animales(self, practica: Practica, data: AltaSanitaria) -> None:
        if not data.animales:
            raise EventoSanitarioInvalidoError(
                "Elegí al menos un animal", campo="animales"
            )
        if len(data.animales) > MAX_ANIMALES_POR_OPERACION:
            raise EventoSanitarioInvalidoError(
                f"Una operación admite hasta {MAX_ANIMALES_POR_OPERACION} animales",
                campo="animales",
            )
        animales = await self.repository.animales_por_ids(
            i.animal_id for i in data.animales
        )
        lotes = await self.repository.lotes_por_ids(
            i.lote_id for i in data.animales if i.lote_id is not None
        )
        existentes = {
            e.id
            for e in await self.repository.eventos_por_ids(i.id for i in data.animales)
        }
        vistos_animal: set[UUID] = set()
        vistos_evento: set[UUID] = set()
        for indice, item in enumerate(data.animales):
            prefijo = f"animales.{indice}"
            if item.animal_id in vistos_animal:
                raise EventoSanitarioInvalidoError(
                    "El animal está repetido en la selección",
                    campo=f"{prefijo}.animal_id",
                    animal_id=item.animal_id,
                )
            if item.id in vistos_evento:
                raise EventoSanitarioInvalidoError(
                    "El identificador del evento está repetido",
                    campo=f"{prefijo}.id",
                    animal_id=item.animal_id,
                )
            vistos_animal.add(item.animal_id)
            vistos_evento.add(item.id)
            if item.id in existentes:
                raise EventoSanitarioExistenteError(f"{prefijo}.id", item.animal_id)
            animal = animales.get(item.animal_id)
            if (
                animal is None
                or animal.establecimiento_id != data.establecimiento_id
                or animal.deleted_at is not None
                or animal.estado != EstadoAnimal.activo
            ):
                raise AnimalNoDisponibleError(f"{prefijo}.animal_id", item.animal_id)
            if item.lote_id is not None:
                # Contexto histórico: el lote puede estar dado de baja, pero
                # tiene que ser de este establecimiento.
                lote = lotes.get(item.lote_id)
                if lote is None or lote.establecimiento_id != data.establecimiento_id:
                    raise EventoSanitarioInvalidoError(
                        "El potrero no es de este establecimiento",
                        campo=f"{prefijo}.lote_id",
                        animal_id=item.animal_id,
                    )
            if (
                item.referencia_muestra is not None
                and practica.modelo != MODELO_MUESTREO
            ):
                raise EventoSanitarioInvalidoError(
                    "Solo un muestreo lleva referencia de muestra",
                    campo=f"{prefijo}.referencia_muestra",
                    animal_id=item.animal_id,
                )

    # ----------------------------------------------------------------- resultado

    async def registrar_resultado(
        self, usuario: Usuario, evento_id: UUID, data: ResultadoSanitario
    ) -> dict[str, Any]:
        """Primer resultado de un estudio. Gana la primera operación confirmada."""
        evento = await self.repository.get_evento(evento_id)
        if (
            evento is None
            or evento.deleted_at is not None
            or evento.practica_id is None
            or not await self._es_miembro(usuario, evento.establecimiento_id)
        ):
            # Sin acceso también es 404: no se revela que existe en otro campo.
            raise EventoSanitarioNoEncontradoError()

        await self.repository.bloquear_establecimiento(evento.establecimiento_id)
        await self.session.refresh(evento)
        cuerpo = huella({"evento_id": str(evento_id), **data.model_dump(mode="json")})

        previa = await self.repository.get_operacion(data.id)
        if previa is not None:
            if previa.tipo != _TIPO_RESULTADO or previa.huella != cuerpo:
                raise OperacionSanitariaConflictoError()
            return representar(evento)

        if evento.practica_modelo != MODELO_MUESTREO:
            raise EventoSanitarioInvalidoError(
                "Esta práctica no lleva resultado", campo="resultado"
            )
        if evento.resultado is not None:
            raise ResultadoYaCompletadoError(representar(evento))

        valor = _texto_obligatorio(data.resultado, "resultado")
        fecha = _no_futura(data.fecha, "fecha")
        # Se compara el día que ve el usuario, no el día en UTC: una toma del
        # lunes a las 22 en Córdoba ya es martes en UTC.
        if _dia_del_campo(fecha) < _dia_del_campo(evento.fecha_aplicacion):
            raise EventoSanitarioInvalidoError(
                "El resultado no puede ser anterior a la toma de la muestra",
                campo="fecha",
            )

        # Se consulta antes de tocar el evento: una consulta posterior haría un
        # autoflush parcial y el segundo UPDATE pisaría ``updated_at``.
        version = await self.repository.siguiente_version(evento.establecimiento_id)
        evento.resultado = valor
        evento.resultado_fecha = fecha
        evento.resultado_registrado_por_id = usuario.id
        evento.resultado_operacion_id = data.id
        # La versión avanza aunque el alta haya llegado con el reloj adelantado.
        evento.updated_at = max(
            datetime.now(UTC), as_utc(evento.updated_at) + timedelta(microseconds=1)
        )
        evento.version = version
        self.repository.agregar(
            [
                evento,
                OperacionSanitaria(
                    id=data.id,
                    establecimiento_id=evento.establecimiento_id,
                    tipo=_TIPO_RESULTADO,
                    evento_id=evento.id,
                    huella=cuerpo,
                    usuario_id=usuario.id,
                ),
            ]
        )
        await self.repository.flush()
        return representar(evento)

    # ----------------------------------------------------------------- historial

    async def historial(
        self, usuario: Usuario, establecimiento_id: UUID, cursor: str | None
    ) -> tuple[list[dict[str, Any]], dict[str, Any]]:
        """Página de cambios confirmados desde ``cursor`` (sin cursor: desde el inicio)."""
        await self._exigir_acceso(usuario, establecimiento_id)
        desde = 0
        if cursor is not None:
            if not _CURSOR_VALIDO.fullmatch(cursor):
                raise EventoSanitarioInvalidoError(
                    "El cursor no es válido", campo="cursor"
                )
            desde = int(cursor)
        filas = await self.repository.historial(
            establecimiento_id, desde, TAMANIO_PAGINA_HISTORIAL + 1
        )
        hay_mas = len(filas) > TAMANIO_PAGINA_HISTORIAL
        pagina = filas[:TAMANIO_PAGINA_HISTORIAL]
        siguiente = pagina[-1].version if pagina else desde
        return (
            [representar(e) for e in pagina],
            {"next_cursor": str(siguiente), "has_more": hay_mas},
        )
