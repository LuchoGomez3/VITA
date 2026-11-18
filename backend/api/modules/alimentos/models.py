"""Catálogo de alimentos del establecimiento.

La tabla existía en Supabase desde el esquema base, sin API ni políticas. La
migración ``20261115_02`` la adopta: le suma los campos de sincronización, la
categoría y el autor, y le pone RLS (ver
``docs/adr/adr-0015-alimentacion-pastoreo-derivado-y-registros.md``).
"""

from decimal import Decimal
from uuid import UUID

from sqlalchemy import CheckConstraint, Index, Numeric, String
from sqlmodel import Field

from api.shared.enums import CategoriaAlimento, UnidadAlimento
from database.models import Base, SoftDeleteMixin


def _valores_sql(enum: type[CategoriaAlimento] | type[UnidadAlimento]) -> str:
    return ", ".join(f"'{miembro.value}'" for miembro in enum)


class Alimento(Base, SoftDeleteMixin, table=True):
    """Alimento que se puede suministrar (grano, rollo, núcleo, sales...).

    Entidad sincronizable: la app lo da de alta offline desde el registro de
    alimentación, con su propio UUID. ``establecimiento_id`` null queda reservado
    para un catálogo global (de solo lectura para los clientes).
    """

    __tablename__ = "alimentos"
    __table_args__ = (
        CheckConstraint("trim(nombre) <> ''", name="ck_alimentos_nombre_no_vacio"),
        CheckConstraint(
            f"categoria in ({_valores_sql(CategoriaAlimento)})",
            name="ck_alimentos_categoria_valida",
        ),
        CheckConstraint(
            f"unidad in ({_valores_sql(UnidadAlimento)})",
            name="ck_alimentos_unidad_valida",
        ),
        Index("ix_alimentos_sync", "establecimiento_id", "updated_at"),
    )

    establecimiento_id: UUID | None = Field(
        default=None, foreign_key="establecimientos.id", index=True
    )
    nombre: str
    categoria: CategoriaAlimento = Field(
        default=CategoriaAlimento.otro, sa_type=String, nullable=False
    )
    unidad: UnidadAlimento = Field(
        default=UnidadAlimento.kg, sa_type=String, nullable=False
    )
    # Se conservan del esquema base; la API no los expone todavía (los costos
    # llegan con el módulo económico).
    valor_proteico: Decimal | None = Field(default=None, sa_type=Numeric(6, 2))
    valor_vitaminico: Decimal | None = Field(default=None, sa_type=Numeric(6, 2))
    costo_unitario: Decimal | None = Field(default=None, sa_type=Numeric(14, 2))
    # Sale del JWT, igual que el responsable de un movimiento.
    creado_por_id: UUID | None = Field(default=None, foreign_key="usuarios.id")
