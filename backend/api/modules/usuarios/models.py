from datetime import datetime
from uuid import UUID

from sqlalchemy import CheckConstraint, DateTime, Index, String, text
from sqlmodel import Field

from database.models import Base

# Color "#RRGGBB" en mayúsculas. Se escribe con ``ltrim`` y no con una expresión
# regular para que el mismo check corra en Postgres y en el SQLite de los tests:
# quitar todos los dígitos hexa del resto del texto tiene que dejarlo vacío.
CHECK_COLOR_CABECERA = (
    "color_cabecera IS NULL OR ("
    "length(color_cabecera) = 7"
    " AND substr(color_cabecera, 1, 1) = '#'"
    " AND ltrim(substr(color_cabecera, 2), '0123456789ABCDEF') = ''"
    ")"
)


class Usuario(Base, table=True):
    __tablename__ = "usuarios"
    __table_args__ = (
        Index("uq_usuarios_email", "email", unique=True),
        Index(
            "uq_usuarios_cuit",
            "cuit",
            unique=True,
            postgresql_where=text("cuit IS NOT NULL"),
            sqlite_where=text("cuit IS NOT NULL"),
        ),
        CheckConstraint(CHECK_COLOR_CABECERA, name="ck_usuarios_color_cabecera"),
    )

    # El id NO se autogenera: es el id de auth.users de Supabase Auth (1:1).
    # Se provee explícitamente al crear el perfil -> override sin default_factory.
    id: UUID = Field(primary_key=True)

    nombre: str
    apellido: str
    email: str
    cuit: str | None = None
    telefono: str | None = None
    is_platform_admin: bool = False

    # Personalización de la cabecera de Perfil (adr-0011). El color reemplaza
    # el verde por defecto; la fecha avisa a otros dispositivos que hay una foto
    # nueva para bajar. La foto en sí vive en el bucket ``avatars`` con clave
    # ``{id}.jpg``: no se guarda la clave porque se deriva del id.
    color_cabecera: str | None = Field(default=None, sa_type=String(7), nullable=True)
    avatar_actualizado_en: datetime | None = Field(
        default=None, sa_type=DateTime(timezone=True), nullable=True
    )
