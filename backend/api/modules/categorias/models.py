from uuid import UUID

from sqlmodel import Field

from database.models import Base


class Categoria(Base, table=True):
    __tablename__ = "categorias"

    # null = catálogo global; con valor = categoría propia del establecimiento.
    establecimiento_id: UUID | None = Field(
        default=None, foreign_key="establecimientos.id", index=True
    )
    nombre: str
    descripcion: str | None = None
