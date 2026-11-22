from uuid import UUID

from sqlalchemy import String
from sqlmodel import Field

from api.shared.enums import TipoProductoSanitario
from database.models import Base, SoftDeleteMixin


class ProductoSanitario(Base, SoftDeleteMixin, table=True):
    """Producto del catálogo: global (``establecimiento_id`` null) o de un campo.

    ``deleted_at`` marca un producto retirado: deja de ofrecerse en el catálogo,
    pero los eventos que ya lo aplicaron conservan su nombre.
    """

    __tablename__ = "productos_sanitarios"

    establecimiento_id: UUID | None = Field(
        default=None, foreign_key="establecimientos.id", index=True
    )
    nombre: str
    tipo: TipoProductoSanitario = Field(
        default=TipoProductoSanitario.vacuna, sa_type=String, nullable=False
    )
    enfermedad_objetivo: str | None = None
    periodo_carencia_dias: int = 0
