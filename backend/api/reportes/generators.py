"""Generación de archivos del reporte SENASA (CSV y PDF)."""

import csv
import io

from reportlab.lib import colors
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import getSampleStyleSheet
from reportlab.lib.units import mm
from reportlab.platypus import (
    Paragraph,
    SimpleDocTemplate,
    Spacer,
    Table,
    TableStyle,
)

from api.reportes.schemas import ReporteFila

_COLUMNAS = ["renspa", "identificador_animal", "fecha_hora", "tipo_evento"]
_ENCABEZADOS = ["RENSPA", "Identificador (RFID)", "Fecha/Hora", "Tipo de evento"]


def _fecha(fila: ReporteFila) -> str:
    return fila.fecha_hora.isoformat()


def to_csv(filas: list[ReporteFila]) -> bytes:
    buffer = io.StringIO()
    writer = csv.writer(buffer)
    writer.writerow(_ENCABEZADOS)
    for fila in filas:
        writer.writerow(
            [
                fila.renspa or "",
                fila.identificador_animal or "",
                _fecha(fila),
                fila.tipo_evento,
            ]
        )
    return buffer.getvalue().encode("utf-8")


def to_pdf(
    filas: list[ReporteFila],
    *,
    responsable_nombre: str | None = None,
    responsable_dni: str | None = None,
) -> bytes:
    buffer = io.BytesIO()
    doc = SimpleDocTemplate(buffer, pagesize=A4, title="Reporte SENASA")
    styles = getSampleStyleSheet()
    elementos = [
        Paragraph("Reporte SENASA — Trazabilidad", styles["Title"]),
        Spacer(1, 6 * mm),
    ]

    data = [_ENCABEZADOS]
    for fila in filas:
        data.append(
            [
                fila.renspa or "",
                fila.identificador_animal or "",
                _fecha(fila),
                fila.tipo_evento,
            ]
        )

    tabla = Table(data, repeatRows=1)
    tabla.setStyle(
        TableStyle(
            [
                ("BACKGROUND", (0, 0), (-1, 0), colors.HexColor("#2e7d32")),
                ("TEXTCOLOR", (0, 0), (-1, 0), colors.white),
                ("FONTSIZE", (0, 0), (-1, -1), 8),
                ("GRID", (0, 0), (-1, -1), 0.5, colors.grey),
                (
                    "ROWBACKGROUNDS",
                    (0, 1),
                    (-1, -1),
                    [colors.white, colors.HexColor("#f0f0f0")],
                ),
            ]
        )
    )
    elementos.append(tabla)

    # Pie opcional con el responsable.
    if responsable_nombre or responsable_dni:
        elementos.append(Spacer(1, 10 * mm))
        partes = []
        if responsable_nombre:
            partes.append(f"Responsable: {responsable_nombre}")
        if responsable_dni:
            partes.append(f"DNI: {responsable_dni}")
        elementos.append(Paragraph(" — ".join(partes), styles["Normal"]))

    doc.build(elementos)
    return buffer.getvalue()
