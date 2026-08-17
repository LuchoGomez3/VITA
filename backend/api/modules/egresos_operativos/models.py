"""Modelo persistente de egresos operativos sincronizables."""

from datetime import date
from decimal import Decimal
from uuid import UUID

from sqlalchemy import Date, Numeric, String, UniqueConstraint
from sqlmodel import Field

from api.shared.enums import TipoEgresoOperativo
from database.models import Base, SoftDeleteMixin


class EgresoOperativo(Base, SoftDeleteMixin, table=True):
    """Movimiento de caja negativo asociado obligatoriamente a un establecimiento."""

    __tablename__ = "egresos_operativos"

    establecimiento_id: UUID = Field(foreign_key="establecimientos.id", index=True)
    monto: Decimal = Field(sa_type=Numeric(14, 2), nullable=False)
    tipo: TipoEgresoOperativo = Field(sa_type=String, nullable=False)
    # Guarda el valor estable de una categoría predefinida o personalizada.
    categoria: str = Field(sa_type=String, nullable=False)
    insumo: str = Field(nullable=False)
    fecha: date = Field(sa_type=Date, nullable=False, index=True)
    descripcion: str | None = None
    numero_comprobante: str | None = None
    # La identidad siempre proviene del JWT; el cliente nunca puede elegirla.
    cargado_por_id: UUID = Field(foreign_key="usuarios.id", index=True)


class CategoriaEgresoPersonalizada(Base, SoftDeleteMixin, table=True):
    """Categoría creada por un usuario y disponible solo dentro de su campo."""

    __tablename__ = "categorias_egresos_operativos"
    __table_args__ = (
        UniqueConstraint(
            "establecimiento_id",
            "valor",
            name="uq_categoria_egreso_operativo_establecimiento_valor",
        ),
    )

    establecimiento_id: UUID = Field(foreign_key="establecimientos.id", index=True)
    tipo: TipoEgresoOperativo = Field(sa_type=String, nullable=False)
    nombre: str = Field(nullable=False)
    # Valor normalizado que se persiste en el egreso y permanece estable para sync.
    valor: str = Field(nullable=False)
    creado_por_id: UUID = Field(foreign_key="usuarios.id", index=True)
