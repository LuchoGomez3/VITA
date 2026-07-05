"""DTOs Pydantic del módulo usuarios."""

import re
from uuid import UUID

from pydantic import BaseModel, ConfigDict, EmailStr, field_validator


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
        return v

    @field_validator("cuit")
    @classmethod
    def _normalizar_cuit(cls, v: str) -> str:
        # Acepta guiones/espacios y los normaliza a 11 dígitos.
        digits = re.sub(r"[\s-]", "", v)
        if not digits.isdigit() or len(digits) != 11:
            raise ValueError("El CUIT/CUIL debe tener 11 dígitos")
        return digits

    @field_validator("password")
    @classmethod
    def _password_segura(cls, v: str) -> str:
        if len(v) < 8:
            raise ValueError("La contraseña debe tener al menos 8 caracteres")
        if not any(c.isdigit() or c.isupper() for c in v):
            raise ValueError(
                "La contraseña debe incluir al menos un número o una mayúscula"
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
