from uuid import UUID

from sqlmodel import Field

from database.models import Base


class Usuario(Base, table=True):
    __tablename__ = "usuarios"

    # El id NO se autogenera: es el id de auth.users de Supabase Auth (1:1).
    # Se provee explícitamente al crear el perfil -> override sin default_factory.
    id: UUID = Field(primary_key=True)

    nombre: str
    apellido: str
    email: str
    cuit: str | None = None
    telefono: str | None = None
    is_platform_admin: bool = False
