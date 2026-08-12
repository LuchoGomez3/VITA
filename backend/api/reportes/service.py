"""Lógica de negocio del módulo reportes SENASA."""

import hashlib
import re
import unicodedata
from datetime import date
from uuid import UUID

from sqlalchemy.ext.asyncio import AsyncSession

from api.modules.animales.models import Animal
from api.modules.establecimientos.repository import (
    EstablecimientoRepository,
    UsuarioEstablecimientoRepository,
)
from api.modules.usuarios.models import Usuario
from api.reportes.exceptions import (
    DatosIncompletosParaReporteError,
    EstablecimientoNoAutorizadoError,
    ExportacionSenasaNoEncontradaError,
)
from api.reportes.generators import to_pdf, to_txt
from api.reportes.models import ExportacionSenasa
from api.reportes.repository import ReporteRepository
from api.reportes.schemas import (
    ExportacionSenasaRead,
    ReporteDispositivo,
    ReporteSenasaFiltros,
)
from api.shared.enums import SexoAnimal


# Catálogo oficial informado para bovinos, bubalinos y cérvidos. Las claves se
# normalizan para aceptar mayúsculas, minúsculas y tildes sin alterar el código.
_CODIGOS_RAZA = {
    "holando argentino": "HA",
    "polled hereford": "PH",
    "jersey": "J",
    "limangus": "LA",
    "simmental": "FS",
    "santa gertrudis": "SG",
    "otra raza": "OR",
    "limousine": "L",
    "kiwi": "K",
    "bosmara": "BO",
    "sueca roja y blanca": "SRB",
    "senangus": "SA",
    "brahman": "B",
    "shorthorn": "SH",
    "senepol": "SP",
    "tuli": "TL",
    "san ignacio": "SI",
    "ganado cruza": "GC",
    "hereford": "H",
    "wagyu": "W",
    "seneford": "SF",
    "charolais": "CH",
    "aberdeen angus": "AA",
    "angus": "AA",
    "brangus": "BG",
    "braford": "BF",
    "criolla": "CR",
    "murray grey": "MG",
    "galloway": "G",
    "mediterranea": "ME",
    "jafarabadi": "JA",
    "murrah": "MU",
    "sin especificar": "S/E",
}

_TIPO_EXPORTACION = "declaracion_identificacion"


class ReporteService:
    def __init__(self, session: AsyncSession) -> None:
        self.repository = ReporteRepository(session)
        self.establecimiento_repository = EstablecimientoRepository(session)
        self.membership_repository = UsuarioEstablecimientoRepository(session)

    async def generar(
        self, current_user: Usuario, filtros: ReporteSenasaFiltros
    ) -> tuple[bytes, str, str]:
        """Genera el reporte y devuelve (contenido, media_type, filename).

        Lanza ``DatosIncompletosParaReporteError`` (sin generar archivo) si hay
        animales con datos incompatibles con el formato oficial de SIGSA.
        """
        # Multi-tenant.
        membership = await self.membership_repository.get_membership(
            current_user.id, filtros.establecimiento_id
        )
        if membership is None:
            raise EstablecimientoNoAutorizadoError()

        establecimiento = await self.establecimiento_repository.get_by_id(
            filtros.establecimiento_id
        )
        if establecimiento is None:
            raise EstablecimientoNoAutorizadoError()

        animales = await self.repository.animales_para_declaracion(
            filtros.establecimiento_id,
            desde=filtros.desde,
            hasta=filtros.hasta,
        )

        # Un archivo oficial no se genera parcialmente: se informa cada animal
        # que necesita corrección para que el productor pueda resolverlo.
        incompletos = [animal for animal in animales if _faltantes(animal)]
        if incompletos:
            detalle = [
                {
                    "animal_id": str(a.id),
                    "caravana": a.nro_caravana_rfid,
                    "faltante": _faltantes(a),
                }
                for a in incompletos
            ]
            raise DatosIncompletosParaReporteError(detalle)

        filas = [
            ReporteDispositivo(
                dispositivo=animal.nro_caravana_rfid,
                sexo=_codigo_sexo(animal.sexo),
                raza=_codigo_raza(animal.raza),
                fecha_nacimiento=animal.fecha_nacimiento.strftime("%m/%Y"),
            )
            for animal in animales
        ]

        if filtros.formato == "pdf":
            contenido = to_pdf(
                filas,
                responsable_nombre=filtros.responsable_nombre
                if filtros.incluir_responsable
                else None,
                responsable_dni=filtros.responsable_dni
                if filtros.incluir_responsable
                else None,
            )
            return await self._guardar_exportacion(
                current_user=current_user,
                filtros=filtros,
                animales=animales,
                contenido=contenido,
                media_type="application/pdf",
                nombre_archivo=_nombre_archivo(filtros.nombre_archivo, "pdf"),
            )

        contenido = to_txt(filas)
        return await self._guardar_exportacion(
            current_user=current_user,
            filtros=filtros,
            animales=animales,
            contenido=contenido,
            media_type="text/plain; charset=utf-8",
            nombre_archivo=_nombre_archivo(filtros.nombre_archivo, "txt"),
        )

    async def _guardar_exportacion(
        self,
        *,
        current_user: Usuario,
        filtros: ReporteSenasaFiltros,
        animales: list[Animal],
        contenido: bytes,
        media_type: str,
        nombre_archivo: str,
    ) -> tuple[bytes, str, str]:
        """Persiste una copia inmutable y las referencias a sus animales."""
        exportacion = ExportacionSenasa(
            establecimiento_id=filtros.establecimiento_id,
            usuario_generador_id=current_user.id,
            nombre_archivo=nombre_archivo,
            formato=filtros.formato,
            tipo_exportacion=_TIPO_EXPORTACION,
            media_type=media_type,
            contenido=contenido,
            hash_sha256=hashlib.sha256(contenido).hexdigest(),
            cantidad_animales=len(animales),
            desde=filtros.desde,
            hasta=filtros.hasta,
        )
        await self.repository.crear_exportacion(exportacion, animales)
        return contenido, media_type, nombre_archivo

    async def validar_declaracion(
        self,
        current_user: Usuario,
        filtros: ReporteSenasaFiltros,
    ) -> tuple[int, list[dict[str, object]]]:
        """Valida los animales sin generar ni persistir ningún archivo."""
        await self._exigir_acceso(current_user, filtros.establecimiento_id)
        animales = await self.repository.animales_para_declaracion(
            filtros.establecimiento_id,
            desde=filtros.desde,
            hasta=filtros.hasta,
        )
        incompletos = [
            {
                "animal_id": animal.id,
                "caravana": animal.nro_caravana_rfid,
                "faltante": _faltantes(animal),
            }
            for animal in animales
            if _faltantes(animal)
        ]
        return len(animales) - len(incompletos), incompletos

    async def listar_exportaciones(
        self, current_user: Usuario, establecimiento_id: UUID
    ) -> list[ExportacionSenasaRead]:
        """Devuelve los metadatos del historial visible para el usuario."""
        await self._exigir_acceso(current_user, establecimiento_id)
        exportaciones = await self.repository.listar_exportaciones(establecimiento_id)
        return [
            ExportacionSenasaRead.model_validate(exportacion, from_attributes=True)
            for exportacion in exportaciones
        ]

    async def descargar_exportacion(
        self, current_user: Usuario, exportacion_id: UUID
    ) -> tuple[bytes, str, str]:
        """Devuelve exactamente los bytes guardados durante la generación."""
        exportacion = await self.repository.obtener_exportacion(exportacion_id)
        if exportacion is None:
            raise ExportacionSenasaNoEncontradaError()
        membership = await self.membership_repository.get_membership(
            current_user.id, exportacion.establecimiento_id
        )
        if membership is None:
            # Se usa 404 para no revelar archivos pertenecientes a otro tenant.
            raise ExportacionSenasaNoEncontradaError()
        return exportacion.contenido, exportacion.media_type, exportacion.nombre_archivo

    async def _exigir_acceso(
        self, current_user: Usuario, establecimiento_id: UUID
    ) -> None:
        """Verifica que el usuario sea miembro activo del establecimiento."""
        membership = await self.membership_repository.get_membership(
            current_user.id, establecimiento_id
        )
        if membership is None:
            raise EstablecimientoNoAutorizadoError()


def _faltantes(animal) -> list[str]:
    """Enumera los datos que impiden construir el registro del dispositivo."""
    faltante: list[str] = []
    if (
        animal.nro_caravana_rfid is None
        or len(animal.nro_caravana_rfid) != 15
        or not animal.nro_caravana_rfid.isascii()
        or not animal.nro_caravana_rfid.isdigit()
    ):
        faltante.append("nro_caravana_rfid")
    if animal.raza is None or _normalizar_raza(animal.raza) not in _CODIGOS_RAZA:
        faltante.append("raza")
    if animal.fecha_nacimiento is None:
        faltante.append("fecha_nacimiento")
    return faltante


def _normalizar_raza(raza: str) -> str:
    """Uniforma la raza para compararla con el catálogo oficial."""
    sin_tildes = unicodedata.normalize("NFKD", raza.strip().lower())
    return "".join(letra for letra in sin_tildes if not unicodedata.combining(letra))


def _codigo_raza(raza: str) -> str:
    """Obtiene el código SENASA de una raza previamente validada."""
    return _CODIGOS_RAZA[_normalizar_raza(raza)]


def _codigo_sexo(sexo: SexoAnimal | str) -> str:
    """Convierte el sexo persistido al código requerido por SENASA.

    La columna se almacena como texto y SQLAlchemy puede devolver un ``str``
    aunque el modelo permita asignar un ``SexoAnimal``. Como el enum hereda de
    ``str``, la comparación contempla correctamente ambas representaciones.
    """
    if sexo == SexoAnimal.macho:
        return "M"
    if sexo == SexoAnimal.hembra:
        return "H"
    raise ValueError(f"Sexo animal no reconocido: {sexo}")


def _nombre_archivo(nombre: str | None, extension: str) -> str:
    """Construye un nombre seguro o usa la fecha actual cuando viene vacío.

    Se descarta una extensión escrita por el usuario para que el formato
    seleccionado sea siempre la fuente de verdad. Los espacios se convierten
    en guiones bajos y se eliminan caracteres que podrían alterar el encabezado
    HTTP de descarga o formar rutas de archivos.
    """
    nombre_base = (nombre or "").strip()
    nombre_base = re.sub(r"\.(?:pdf|txt)$", "", nombre_base, flags=re.IGNORECASE)
    nombre_base = unicodedata.normalize("NFKD", nombre_base)
    nombre_base = "".join(
        caracter for caracter in nombre_base if not unicodedata.combining(caracter)
    )
    nombre_base = re.sub(r"\s+", "_", nombre_base)
    nombre_base = re.sub(r"[^A-Za-z0-9_-]", "", nombre_base).strip("_-.")
    if not nombre_base:
        nombre_base = f"reporte_senasa_{date.today().isoformat()}"
    return f"{nombre_base}.{extension}"
