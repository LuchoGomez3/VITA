"""Piezas del equipo que no pasan por la API: códigos, email y envío SMTP."""

from datetime import UTC, datetime
import logging
import smtplib
from uuid import uuid4

import anyio
import pytest

from api.modules.equipo import codigos
from api.modules.equipo.email_templates import email_aceptacion, email_invitacion
from api.modules.equipo.models import InvitacionEstablecimiento
from api.modules.equipo.service import EquipoService
from api.shared.enums import RolUsuario
from core import email as email_modulo
from core.email import (
    ConsoleEmailSender,
    Email,
    EmailEnvioError,
    SmtpEmailSender,
    get_email_sender,
)


# ─── Códigos ────────────────────────────────────────────────────────────────


def test_los_codigos_usan_solo_el_alfabeto_sin_caracteres_ambiguos():
    generados = {codigos.generar_codigo() for _ in range(200)}

    assert len(generados) == 200
    for codigo in generados:
        assert len(codigo) == 6
        assert not set(codigo) & set("01OIL")
        assert codigos.tiene_formato_valido(codigo)


def test_el_hash_ignora_formato_y_depende_de_la_clave():
    base = codigos.hashear_codigo("7K4P2M", "clave")

    assert codigos.hashear_codigo(" 7k4-p2m ", "clave") == base
    assert codigos.hashear_codigo("7K4P2M", "otra-clave") != base
    assert codigos.formatear_codigo("7K4P2M") == "7K4-P2M"


# ─── Contenido del email ────────────────────────────────────────────────────


def _email(**cambios):
    datos = {
        "destinatario": "mariano@example.com",
        "establecimiento": "La Sirena",
        "invitado_por": "Cecilia Lazarte",
        "rol": RolUsuario.veterinarian,
        "codigo_formateado": "7K4-P2M",
        # 03:00 UTC del 25 es todavía el 25 en Córdoba (UTC-3), 02:59 es el 24.
        "expira_en": datetime(2026, 10, 25, 2, 59, tzinfo=UTC),
    }
    datos.update(cambios)
    return email_invitacion(**datos)


def test_el_email_explica_como_sumarse_y_muestra_la_fecha_local():
    email = _email()

    assert email.asunto == "Te invitaron a La Sirena en VITA"
    assert "Cecilia Lazarte te invitó" in email.texto
    assert "como Veterinario" in email.texto
    assert "7K4-P2M" in email.texto and "7K4-P2M" in email.html
    assert "Vence el 24/10/2026" in email.texto
    assert "Sumarme a otro establecimiento" in email.texto
    assert "mariano@example.com" in email.texto


def test_el_aviso_de_aceptacion_le_cuenta_quien_se_sumo():
    email = email_aceptacion(
        destinatario="ceci@example.com",
        establecimiento="La Sirena",
        nuevo_miembro="Diego <b>Romero</b>",
        rol=RolUsuario.employee,
    )

    assert email.destinatario == "ceci@example.com"
    assert email.asunto == "Diego <b>Romero</b> se sumó a La Sirena"
    assert "como Empleado" in email.texto
    assert "<b>Romero</b>" not in email.html


def test_el_email_escapa_los_nombres_y_no_rompe_el_asunto():
    email = _email(
        establecimiento="Campo <b>\nBcc: otro@example.com",
        invitado_por="<script>x</script>",
    )

    assert "\n" not in email.asunto
    assert "<script>" not in email.html
    assert "&lt;script&gt;" in email.html
    assert "<b>" not in email.html


# ─── Envío ──────────────────────────────────────────────────────────────────


class _SmtpFalso:
    instancias: list["_SmtpFalso"] = []
    fallar = False

    def __init__(self, host, port, timeout=None, context=None):
        self.host, self.port, self.timeout = host, port, timeout
        self.acciones: list[str] = []
        self.mensajes = []
        _SmtpFalso.instancias.append(self)

    def __enter__(self):
        return self

    def __exit__(self, *exc):
        return False

    def starttls(self, context=None):
        self.acciones.append("starttls")

    def login(self, usuario, password):
        self.acciones.append(f"login:{usuario}")

    def send_message(self, mensaje):
        if _SmtpFalso.fallar:
            raise smtplib.SMTPRecipientsRefused({})
        self.mensajes.append(mensaje)


@pytest.fixture
def smtp_falso(monkeypatch):
    _SmtpFalso.instancias = []
    _SmtpFalso.fallar = False
    monkeypatch.setattr(email_modulo.smtplib, "SMTP", _SmtpFalso)
    monkeypatch.setattr(email_modulo.smtplib, "SMTP_SSL", _SmtpFalso)
    return _SmtpFalso


def _sender(port=587, usuario="apikey"):
    return SmtpEmailSender(
        host="smtp.example.com",
        port=port,
        usuario=usuario,
        password="secreto",
        remitente="VITA <no-reply@example.com>",
        timeout=5,
    )


_MENSAJE = Email(
    destinatario="mariano@example.com", asunto="Hola", texto="Texto", html="<p>Hola</p>"
)


@pytest.mark.anyio
async def test_smtp_usa_starttls_se_autentica_y_manda_texto_y_html(smtp_falso):
    await _sender().enviar(_MENSAJE)

    [conexion] = smtp_falso.instancias
    assert (conexion.host, conexion.port, conexion.timeout) == (
        "smtp.example.com",
        587,
        5,
    )
    assert conexion.acciones == ["starttls", "login:apikey"]
    [mensaje] = conexion.mensajes
    assert mensaje["To"] == "mariano@example.com"
    assert mensaje["From"] == "VITA <no-reply@example.com>"
    tipos = [parte.get_content_type() for parte in mensaje.iter_parts()]
    assert tipos == ["text/plain", "text/html"]


@pytest.mark.anyio
async def test_smtp_en_el_puerto_465_usa_ssl_directo_y_sin_usuario_no_hace_login(
    smtp_falso,
):
    await _sender(port=465, usuario="").enviar(_MENSAJE)

    [conexion] = smtp_falso.instancias
    assert conexion.acciones == []
    assert len(conexion.mensajes) == 1


@pytest.mark.anyio
async def test_una_falla_de_smtp_se_traduce_y_no_filtra_el_detalle(smtp_falso, caplog):
    smtp_falso.fallar = True

    with caplog.at_level(logging.ERROR), pytest.raises(EmailEnvioError):
        await _sender().enviar(_MENSAJE)

    assert "SMTPRecipientsRefused" in caplog.text
    assert "secreto" not in caplog.text


@pytest.mark.anyio
async def test_el_sender_de_consola_solo_loguea(caplog):
    with caplog.at_level(logging.INFO):
        await ConsoleEmailSender().enviar(_MENSAJE)

    assert "mariano@example.com" in caplog.text


def test_la_dependencia_elige_el_sender_segun_la_configuracion(monkeypatch):
    email_modulo._sender_configurado.cache_clear()
    monkeypatch.setattr(email_modulo.settings, "EMAIL_PROVIDER", "smtp")
    assert isinstance(get_email_sender(), SmtpEmailSender)

    email_modulo._sender_configurado.cache_clear()
    monkeypatch.setattr(email_modulo.settings, "EMAIL_PROVIDER", "console")
    assert isinstance(get_email_sender(), ConsoleEmailSender)
    email_modulo._sender_configurado.cache_clear()


class _SenderLento:
    async def enviar(self, email: Email) -> None:
        await anyio.sleep(5)


@pytest.mark.anyio
async def test_un_smtp_colgado_no_bloquea_la_invitacion(session, monkeypatch):
    monkeypatch.setattr(
        "api.modules.equipo.service.settings.EMAIL_TIMEOUT_SECONDS", 0.05
    )
    servicio = EquipoService(session, email_sender=_SenderLento())
    invitacion = InvitacionEstablecimiento(
        establecimiento_id=uuid4(),
        email="x@example.com",
        rol=RolUsuario.employee,
        codigo_hash="h",
        expira_en=datetime.now(UTC),
        invitado_por_id=uuid4(),
    )

    class _Campo:
        nombre = "La Sirena"

    class _Yo:
        nombre, apellido = "Cecilia", "Lazarte"

    await servicio._enviar(invitacion, "7K4P2M", _Campo(), _Yo())

    assert invitacion.email_enviado_en is None
