"""DTOs Pydantic del módulo usuarios."""

from uuid import UUID

from pydantic import BaseModel, ConfigDict, EmailStr, field_validator

from api.shared.cuit import normalizar_cuit


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
