"""DTOs Pydantic del módulo usuarios."""

from datetime import datetime
import re
from uuid import UUID

from pydantic import BaseModel, ConfigDict, EmailStr, field_validator

from api.shared.cuit import normalizar_cuit


_COLOR_HEX = re.compile(r"#[0-9A-F]{6}")


def normalizar_color_cabecera(valor: str | None) -> str | None:
    """Acepta ``#rrggbb`` en cualquier caja y lo guarda en mayúsculas."""
    if valor is None:
        return None
    color = valor.strip().upper()
    if not _COLOR_HEX.fullmatch(color):
        raise ValueError(
            "El color debe tener el formato #RRGGBB (por ejemplo, #2E7D32)"
        )
    return color


class UsuarioRegistroCreate(BaseModel):
    """Alta de un nuevo dueño de campo (registro público)."""

    nombre: str
    apellido: str
    cuit: str
    email: EmailStr
    password: str

    @field_validator("nombre", "apellido")
    @classmethod
    def _no_vacio(cls, v: str) -> str:
        v = v.strip()
        if not v:
            raise ValueError("Campo obligatorio")
        if len(v) > 50:
            raise ValueError("Debe tener como máximo 50 caracteres")
        return v

    @field_validator("cuit")
    @classmethod
    def _normalizar_cuit(cls, v: str) -> str:
        return normalizar_cuit(v)

    @field_validator("email")
    @classmethod
    def _normalizar_email(cls, v: EmailStr) -> str:
        return str(v).strip().lower()

    @field_validator("password")
    @classmethod
    def _password_segura(cls, v: str) -> str:
        if len(v) < 8:
            raise ValueError("La contraseña debe tener al menos 8 caracteres")
        if len(v) > 50:
            raise ValueError("La contraseña debe tener como máximo 50 caracteres")
        if not any(c.isdigit() for c in v) or not any(c.isupper() for c in v):
            raise ValueError(
                "La contraseña debe incluir al menos un número y una mayúscula"
            )
        return v


class UsuarioRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    nombre: str
    apellido: str
    email: str
    cuit: str | None = None
    telefono: str | None = None
    color_cabecera: str | None = None
    avatar_actualizado_en: datetime | None = None


class UsuarioPerfilUpdate(BaseModel):
    """Cambios que el usuario puede hacer sobre su propio perfil.

    ``color_cabecera`` en ``null`` vuelve al verde por defecto. Es obligatorio
    mandarlo (aunque sea ``null``) para no confundir "no lo cambio" con "quiero
    el color por defecto".
    """

    color_cabecera: str | None

    @field_validator("color_cabecera")
    @classmethod
    def _normalizar_color(cls, v: str | None) -> str | None:
        return normalizar_color_cabecera(v)
