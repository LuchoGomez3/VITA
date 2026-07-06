"""Lógica de negocio del módulo reportes SENASA."""

from sqlalchemy.ext.asyncio import AsyncSession

from api.modules.establecimientos.repository import (
    EstablecimientoRepository,
    UsuarioEstablecimientoRepository,
)
from api.modules.usuarios.models import Usuario
from api.reportes.exceptions import (
    DatosIncompletosParaReporteError,
    EstablecimientoNoAutorizadoError,
)
from api.reportes.generators import to_csv, to_pdf
from api.reportes.repository import ReporteRepository
from api.reportes.schemas import ReporteFila, ReporteSenasaFiltros


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
        animales sin RFID de 15 dígitos o sin categoría.
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

        # Validación previa: bloquear si hay animales con datos incompletos.
        incompletos = await self.repository.animales_incompletos(
            filtros.establecimiento_id, filtros.lote_id
        )
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

        eventos = await self.repository.eventos(
            filtros.establecimiento_id,
            desde=filtros.desde,
            hasta=filtros.hasta,
            lote_id=filtros.lote_id,
        )
        if filtros.tipo_evento:
            eventos = [e for e in eventos if e.tipo == filtros.tipo_evento]

        filas = [
            ReporteFila(
                renspa=establecimiento.nro_renspa,
                # TODO(PO): la historia menciona "CUIG de cada animal", distinto
                # del RFID; el modelo no lo tiene. Por ahora se usa el RFID como
                # identificador. Confirmar inclusión de CUIG con el PO.
                identificador_animal=e.caravana,
                fecha_hora=e.fecha,
                tipo_evento=e.tipo,
            )
            for e in eventos
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
            return contenido, "application/pdf", "reporte_senasa.pdf"

        contenido = to_csv(filas)
        return contenido, "text/csv", "reporte_senasa.csv"


def _faltantes(animal) -> list[str]:
    faltante: list[str] = []
    if animal.nro_caravana_rfid is None or len(animal.nro_caravana_rfid) != 15:
        faltante.append("nro_caravana_rfid")
    if animal.categoria_id is None:
        faltante.append("categoria_id")
    return faltante
