"""Contenido del email de invitación al equipo."""

from datetime import datetime
from html import escape
from zoneinfo import ZoneInfo

from api.shared.enums import RolUsuario
from core.email import Email

_ZONA = ZoneInfo("America/Argentina/Cordoba")

NOMBRE_ROL = {
    RolUsuario.owner: "Dueño",
    RolUsuario.admin: "Administrador",
    RolUsuario.employee: "Empleado",
    RolUsuario.veterinarian: "Veterinario",
}


def _una_linea(texto: str) -> str:
    # El asunto es un header: un salto de línea en el nombre del campo no puede
    # colarse ahí.
    return " ".join(texto.split())


def email_invitacion(
    *,
    destinatario: str,
    establecimiento: str,
    invitado_por: str,
    rol: RolUsuario,
    codigo_formateado: str,
    expira_en: datetime,
) -> Email:
    vence = expira_en.astimezone(_ZONA).strftime("%d/%m/%Y")
    rol_texto = NOMBRE_ROL[rol]
    campo = _una_linea(establecimiento)
    quien = _una_linea(invitado_por)

    texto = (
        f"Hola,\n\n"
        f"{quien} te invitó a sumarte al equipo de {campo} en VITA como "
        f"{rol_texto}.\n\n"
        f"Tu código de invitación es: {codigo_formateado}\n"
        f"Vence el {vence} y sirve una sola vez.\n\n"
        f"Cómo sumarte:\n"
        f"1. Descargá VITA e iniciá sesión o registrate con este email "
        f"({destinatario}).\n"
        f"2. Andá a Perfil > Sumarme a otro establecimiento.\n"
        f"3. Ingresá el código y confirmá.\n\n"
        f"Si no esperabas esta invitación, ignorá este email.\n"
    )
    html = (
        "<p>Hola,</p>"
        f"<p><strong>{escape(quien)}</strong> te invitó a sumarte al equipo de "
        f"<strong>{escape(campo)}</strong> en VITA como "
        f"<strong>{escape(rol_texto)}</strong>.</p>"
        "<p>Tu código de invitación es:</p>"
        '<p style="font-family:monospace;font-size:24px;font-weight:bold;'
        f'letter-spacing:4px">{escape(codigo_formateado)}</p>'
        f"<p>Vence el {escape(vence)} y sirve una sola vez.</p>"
        "<p>Cómo sumarte:</p><ol>"
        "<li>Descargá VITA e iniciá sesión o registrate con este email "
        f"({escape(destinatario)}).</li>"
        "<li>Andá a <em>Perfil &gt; Sumarme a otro establecimiento</em>.</li>"
        "<li>Ingresá el código y confirmá.</li></ol>"
        "<p>Si no esperabas esta invitación, ignorá este email.</p>"
    )
    return Email(
        destinatario=destinatario,
        asunto=f"Te invitaron a {campo} en VITA",
        texto=texto,
        html=html,
    )
