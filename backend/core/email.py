"""Envío de emails salientes (invitaciones al equipo, adr-0012).

Dos implementaciones detrás del mismo ``Protocol``:

- ``SmtpEmailSender``: SMTP con STARTTLS (o SSL directo en el puerto 465). Sirve
  para cualquier proveedor con SMTP (Brevo, Resend, una casilla con contraseña de
  aplicación) sin sumar dependencias: ``smtplib`` es de la stdlib.
- ``ConsoleEmailSender``: solo loguea el mensaje. Es para LOCAL/TEST; staging y
  producción no arrancan sin SMTP (``Settings.validate_runtime_configuration``).

``smtplib`` es bloqueante, así que el envío corre en un thread aparte, con el
mismo criterio que ``core/storage.py``.
"""

import logging
import smtplib
import ssl
from dataclasses import dataclass
from email.message import EmailMessage
from functools import lru_cache
from typing import Protocol

import anyio

from core.config import settings

logger = logging.getLogger(__name__)


class EmailEnvioError(Exception):
    """No se pudo entregar el email al servidor SMTP.

    El servicio decide qué hacer (p. ej. dejar la invitación creada y avisar que
    hay que reenviarla); nunca se expone el detalle del proveedor al cliente.
    """


@dataclass(frozen=True)
class Email:
    destinatario: str
    asunto: str
    texto: str
    html: str | None = None


class EmailSender(Protocol):
    """Contrato mínimo para mandar un email. Los tests inyectan un doble."""

    async def enviar(self, email: Email) -> None: ...


class ConsoleEmailSender:
    """Loguea el email en lugar de mandarlo. Solo para desarrollo y tests."""

    async def enviar(self, email: Email) -> None:
        logger.info(
            "[EMAIL] (console) Para: %s | Asunto: %s\n%s",
            email.destinatario,
            email.asunto,
            email.texto,
        )


class SmtpEmailSender:
    def __init__(
        self,
        *,
        host: str,
        port: int,
        usuario: str,
        password: str,
        remitente: str,
        timeout: float,
    ) -> None:
        self._host = host
        self._port = port
        self._usuario = usuario
        self._password = password
        self._remitente = remitente
        self._timeout = timeout

    def _armar(self, email: Email) -> EmailMessage:
        mensaje = EmailMessage()
        mensaje["From"] = self._remitente
        mensaje["To"] = email.destinatario
        mensaje["Subject"] = email.asunto
        mensaje.set_content(email.texto)
        if email.html is not None:
            mensaje.add_alternative(email.html, subtype="html")
        return mensaje

    def _enviar_bloqueante(self, mensaje: EmailMessage) -> None:
        contexto = ssl.create_default_context()
        if self._port == 465:
            with smtplib.SMTP_SSL(
                self._host, self._port, timeout=self._timeout, context=contexto
            ) as smtp:
                self._autenticar_y_enviar(smtp, mensaje)
            return
        with smtplib.SMTP(self._host, self._port, timeout=self._timeout) as smtp:
            smtp.starttls(context=contexto)
            self._autenticar_y_enviar(smtp, mensaje)

    def _autenticar_y_enviar(self, smtp: smtplib.SMTP, mensaje: EmailMessage) -> None:
        if self._usuario:
            smtp.login(self._usuario, self._password)
        smtp.send_message(mensaje)

    async def enviar(self, email: Email) -> None:
        mensaje = self._armar(email)
        try:
            await anyio.to_thread.run_sync(self._enviar_bloqueante, mensaje)
        except Exception as exc:
            # Sin el cuerpo de la excepción: puede traer la respuesta del servidor
            # con datos de la cuenta. El destinatario alcanza para diagnosticar.
            logger.error(
                "[EMAIL] Falló el envío a %s vía %s:%s (%s)",
                email.destinatario,
                self._host,
                self._port,
                type(exc).__name__,
            )
            raise EmailEnvioError("No se pudo enviar el email") from exc


@lru_cache
def _sender_configurado() -> EmailSender:
    if settings.EMAIL_PROVIDER == "smtp":
        return SmtpEmailSender(
            host=settings.SMTP_HOST,
            port=settings.SMTP_PORT,
            usuario=settings.SMTP_USER,
            password=settings.SMTP_PASSWORD,
            remitente=settings.SMTP_FROM,
            timeout=settings.EMAIL_TIMEOUT_SECONDS,
        )
    return ConsoleEmailSender()


def get_email_sender() -> EmailSender:
    """Dependencia FastAPI del envío de emails (overrideable en tests)."""
    return _sender_configurado()
