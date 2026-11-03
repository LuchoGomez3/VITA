"""Persistencia de las invitaciones al equipo de un establecimiento (adr-0012).

Los miembros del equipo no tienen tabla propia: son las membresías activas de
``usuarios_establecimientos``. Acá vive solo la invitación, que se convierte en
membresía cuando la persona canjea el código que le llegó por email.
"""

from datetime import datetime
from uuid import UUID

from sqlalchemy import CheckConstraint, DateTime, Index, String, text
from sqlmodel import Field

from api.modules.establecimientos.models import CHECK_ROL_USUARIO
from api.shared.enums import EstadoInvitacion, RolUsuario
from database.models import Base

CHECK_ESTADO_INVITACION = "estado IN ('pendiente', 'aceptada', 'cancelada')"
# Una sola invitación pendiente por email y establecimiento. Las aceptadas y
# canceladas quedan como historial y no cuentan.
WHERE_PENDIENTE = "estado = 'pendiente'"


class InvitacionEstablecimiento(Base, table=True):
    __tablename__ = "invitaciones_establecimientos"
    __table_args__ = (
        CheckConstraint(CHECK_ROL_USUARIO, name="ck_invitaciones_establecimientos_rol"),
        CheckConstraint(
            CHECK_ESTADO_INVITACION, name="ck_invitaciones_establecimientos_estado"
        ),
        Index(
            "uq_invitaciones_establecimientos_pendiente",
            "establecimiento_id",
            "email",
            unique=True,
            postgresql_where=text(WHERE_PENDIENTE),
            sqlite_where=text(WHERE_PENDIENTE),
        ),
        Index("ix_invitaciones_establecimientos_codigo_hash", "codigo_hash"),
    )

    establecimiento_id: UUID = Field(foreign_key="establecimientos.id", index=True)
    # Normalizado (minúsculas, sin espacios): se compara con el email de la
    # sesión al canjear.
    email: str
    rol: RolUsuario = Field(sa_type=String, nullable=False)
    # HMAC-SHA256 del código normalizado (hex). El código en claro solo viaja en
    # el email; reenviar lo reemplaza y el anterior deja de servir.
    codigo_hash: str = Field(sa_type=String(64), nullable=False)
    expira_en: datetime = Field(sa_type=DateTime(timezone=True), nullable=False)
    estado: EstadoInvitacion = Field(
        default=EstadoInvitacion.pendiente, sa_type=String, nullable=False
    )
    invitado_por_id: UUID = Field(foreign_key="usuarios.id")
    aceptada_por_id: UUID | None = Field(default=None, foreign_key="usuarios.id")
    aceptada_en: datetime | None = Field(
        default=None, sa_type=DateTime(timezone=True), nullable=True
    )
    # Null cuando el último envío falló: la app ofrece reenviar.
    email_enviado_en: datetime | None = Field(
        default=None, sa_type=DateTime(timezone=True), nullable=True
    )
