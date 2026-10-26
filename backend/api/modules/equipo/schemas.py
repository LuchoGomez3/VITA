"""DTOs Pydantic del módulo equipo."""

from datetime import datetime
from uuid import UUID

from pydantic import BaseModel, EmailStr, field_validator

from api.shared.enums import EstadoInvitacion, RolUsuario


class MiembroEquipoRead(BaseModel):
    usuario_id: UUID
    nombre: str
    apellido: str
    email: str
    rol: RolUsuario
    # El titular (``establecimientos.owner_id``) no se puede quitar.
    es_titular: bool
    # Color de la cabecera del perfil, para pintar el avatar de iniciales.
    color_cabecera: str | None = None
    miembro_desde: datetime


class InvitacionCreate(BaseModel):
    email: EmailStr
    rol: RolUsuario

    @field_validator("email")
    @classmethod
    def _normalizar_email(cls, v: EmailStr) -> str:
        return str(v).strip().lower()


class InvitacionRead(BaseModel):
    id: UUID
    establecimiento_id: UUID
    email: str
    rol: RolUsuario
    estado: EstadoInvitacion
    expira_en: datetime
    vencida: bool
    # False cuando el último envío falló: la app ofrece reenviar.
    email_enviado: bool
    invitado_por_id: UUID
    created_at: datetime


class InvitacionCreada(InvitacionRead):
    """Respuesta de invitar y reenviar: lleva el código en claro una sola vez."""

    codigo: str


class CodigoInvitacion(BaseModel):
    codigo: str

    @field_validator("codigo")
    @classmethod
    def _no_vacio(cls, v: str) -> str:
        if not v.strip():
            raise ValueError("El código es obligatorio")
        return v


class InvitacionPrevia(BaseModel):
    """Lo que ve quien canjea antes de confirmar: a qué campo y con qué rol."""

    establecimiento_id: UUID
    establecimiento_nombre: str
    establecimiento_renspa: str | None = None
    establecimiento_localidad: str | None = None
    establecimiento_provincia: str | None = None
    rol: RolUsuario
    email: str
    invitado_por: str
    invitado_por_rol: RolUsuario | None = None
    expira_en: datetime
