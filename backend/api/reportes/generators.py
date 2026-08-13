"""Generación de archivos del reporte SENASA (TXT y PDF)."""

import io
from pathlib import Path

from reportlab.lib import colors
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import getSampleStyleSheet
from reportlab.lib.units import mm
from reportlab.platypus import (
    Image,
    Paragraph,
    SimpleDocTemplate,
    Spacer,
    Table,
    TableStyle,
)

from api.reportes.schemas import ReporteDispositivo

# El logo oficial se comparte con la aplicación móvil para mantener una única
# identidad visual en los documentos y en la interfaz del producto.
_RUTA_LOGO = (
    Path(__file__).resolve().parents[3]
    / "mobile"
    / "assets"
    / "images"
    / "app_icon.png"
)


def _contenido(filas: list[ReporteDispositivo]) -> str:
    """Une dispositivos con el punto y coma exigido por el importador SIGSA."""
    return ";".join(
        f"{fila.dispositivo}-{fila.sexo}-{fila.raza}-{fila.fecha_nacimiento}"
        for fila in filas
    )


def to_txt(filas: list[ReporteDispositivo]) -> bytes:
    """Genera el archivo delimitado sin encabezado requerido por SENASA."""
    return _contenido(filas).encode("utf-8")


def to_pdf(
    filas: list[ReporteDispositivo],
    *,
    responsable_nombre: str | None = None,
    responsable_dni: str | None = None,
) -> bytes:
    """Genera un PDF tabular con la identidad visual principal de VITA."""
    buffer = io.BytesIO()
    doc = SimpleDocTemplate(
        buffer,
        pagesize=A4,
        title="Reporte SENASA",
        leftMargin=15 * mm,
        rightMargin=15 * mm,
    )
    styles = getSampleStyleSheet()
    styles["Title"].textColor = colors.HexColor("#2E7D32")
    logo = Image(str(_RUTA_LOGO), width=18 * mm, height=18 * mm)
    encabezado = Table(
        [[logo, Paragraph("Reporte SENASA — Trazabilidad", styles["Title"])]],
        colWidths=[24 * mm, 141 * mm],
    )
    encabezado.setStyle(
        TableStyle(
            [
                ("ALIGN", (0, 0), (0, 0), "LEFT"),
                ("VALIGN", (0, 0), (-1, -1), "MIDDLE"),
                ("LEFTPADDING", (0, 0), (-1, -1), 0),
                ("RIGHTPADDING", (0, 0), (-1, -1), 0),
                ("TOPPADDING", (0, 0), (-1, -1), 0),
                ("BOTTOMPADDING", (0, 0), (-1, -1), 0),
            ]
        )
    )
    elementos = [
        encabezado,
        Spacer(1, 6 * mm),
    ]

    datos = [["Dispositivo RFID", "Sexo", "Raza", "Fecha de nacimiento"]]
    datos.extend(
        [fila.dispositivo, fila.sexo, fila.raza, fila.fecha_nacimiento]
        for fila in filas
    )
    tabla = Table(
        datos,
        colWidths=[65 * mm, 25 * mm, 30 * mm, 45 * mm],
        repeatRows=1,
    )
    tabla.setStyle(
        TableStyle(
            [
                ("BACKGROUND", (0, 0), (-1, 0), colors.HexColor("#2E7D32")),
                ("TEXTCOLOR", (0, 0), (-1, 0), colors.white),
                ("FONTNAME", (0, 0), (-1, 0), "Helvetica-Bold"),
                ("BACKGROUND", (0, 1), (-1, -1), colors.HexColor("#DDFFE3")),
                ("TEXTCOLOR", (0, 1), (-1, -1), colors.HexColor("#1D1B1A")),
                ("ALIGN", (1, 1), (-1, -1), "CENTER"),
                ("VALIGN", (0, 0), (-1, -1), "MIDDLE"),
                ("GRID", (0, 0), (-1, -1), 0.5, colors.HexColor("#2E7D32")),
                (
                    "ROWBACKGROUNDS",
                    (0, 1),
                    (-1, -1),
                    [colors.white, colors.HexColor("#DDFFE3")],
                ),
                ("TOPPADDING", (0, 0), (-1, -1), 7),
                ("BOTTOMPADDING", (0, 0), (-1, -1), 7),
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
