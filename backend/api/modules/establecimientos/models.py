from decimal import Decimal
from uuid import UUID

from sqlalchemy import Numeric, String, UniqueConstraint
from sqlmodel import Field

from api.shared.enums import RolUsuario
from database.models import Base, SoftDeleteMixin


class Establecimiento(Base, SoftDeleteMixin, table=True):
    __tablename__ = "establecimientos"

    owner_id: UUID = Field(foreign_key="usuarios.id", index=True)
    nombre: str
    nro_renspa: str | None = Field(default=None, unique=True)
    cuit: str | None = None
    superficie_ha: Decimal | None = Field(default=None, sa_type=Numeric(12, 2))
    provincia: str | None = None
    departamento: str | None = None
    localidad: str | None = None


class UsuarioEstablecimiento(Base, table=True):
    __tablename__ = "usuarios_establecimientos"
    __table_args__ = (
        UniqueConstraint(
            "usuario_id",
            "establecimiento_id",
            "rol",
            name="uq_usuario_establecimiento_rol",
        ),
    )

    usuario_id: UUID = Field(foreign_key="usuarios.id", index=True)
    establecimiento_id: UUID = Field(foreign_key="establecimientos.id", index=True)
    rol: RolUsuario = Field(sa_type=String, nullable=False)
    activo: bool = True
