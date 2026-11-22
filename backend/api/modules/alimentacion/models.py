"""Registros de alimentación: suplementos y dietas suministrados a los animales.

Mismo agregado que ``movimientos_lotes``: una cabecera con la operación (qué
alimento, dónde, cuándo, cuánto) y un detalle con los animales que la recibieron.
El UUID de la cabecera es la clave de idempotencia de la cola offline, así que
tiene que identificar una única fila aunque el registro abarque N animales.

El pastoreo no se registra acá: se deriva en el cliente cruzando los movimientos
del animal con el historial de recursos de cada potrero.
"""

from datetime import date
from decimal import Decimal
from uuid import UUID

from sqlalchemy import CheckConstraint, Date, Index, Numeric, String, UniqueConstraint
from sqlmodel import Field

from api.shared.enums import (
    BaseCantidadAlimento,
    TipoRegistroAlimentacion,
    UnidadAlimento,
)
from database.models import Base, SoftDeleteMixin


def _valores_sql(enum) -> str:
    return ", ".join(f"'{miembro.value}'" for miembro in enum)


class RegistroAlimentacion(Base, SoftDeleteMixin, table=True):
    __tablename__ = "registros_alimentacion"
    __table_args__ = (
        CheckConstraint(
            f"tipo in ({_valores_sql(TipoRegistroAlimentacion)})",
            name="ck_registros_alimentacion_tipo_valido",
        ),
        CheckConstraint(
            f"unidad in ({_valores_sql(UnidadAlimento)})",
            name="ck_registros_alimentacion_unidad_valida",
        ),
        CheckConstraint(
            f"base_cantidad in ({_valores_sql(BaseCantidadAlimento)})",
            name="ck_registros_alimentacion_base_valida",
        ),
        CheckConstraint("cantidad > 0", name="ck_registros_alimentacion_cantidad"),
        CheckConstraint(
            "fecha_hasta is null or fecha_hasta >= fecha_desde",
            name="ck_registros_alimentacion_fechas",
        ),
        Index("ix_registros_alimentacion_sync", "establecimiento_id", "updated_at"),
        Index("ix_registros_alimentacion_fecha", "establecimiento_id", "fecha_desde"),
    )

    establecimiento_id: UUID = Field(foreign_key="establecimientos.id", index=True)
    tipo: TipoRegistroAlimentacion = Field(sa_type=String, nullable=False)
    alimento_id: UUID = Field(foreign_key="alimentos.id", index=True)
    # Dónde se suministró, guardado como hecho: no se deriva del historial de
    # movimientos, que puede tener huecos. Null = corral o manga.
    lote_id: UUID | None = Field(default=None, foreign_key="lotes.id")
    fecha_desde: date = Field(sa_type=Date, nullable=False)
    # Null = en curso. Un suministro de un solo día lleva hasta = desde.
    fecha_hasta: date | None = Field(default=None, sa_type=Date)
    cantidad: Decimal = Field(sa_type=Numeric(12, 3))
    unidad: UnidadAlimento = Field(sa_type=String, nullable=False)
    base_cantidad: BaseCantidadAlimento = Field(sa_type=String, nullable=False)
    motivo: str | None = None
    # Siempre se deriva del JWT.
    responsable_id: UUID | None = Field(default=None, foreign_key="usuarios.id")


class RegistroAlimentacionAnimal(Base, table=True):
    """Animal que recibió un registro de alimentación.

    Sin ``SoftDeleteMixin``: es la hoja de un agregado y viaja dentro del payload
    de su cabecera.
    """

    __tablename__ = "registros_alimentacion_animales"
    __table_args__ = (
        UniqueConstraint(
            "registro_alimentacion_id",
            "animal_id",
            name="uq_registro_alimentacion_animal",
        ),
    )

    registro_alimentacion_id: UUID = Field(
        foreign_key="registros_alimentacion.id", index=True
    )
    # Indexado: responde "¿qué le dieron a este animal?" para su historial.
    animal_id: UUID = Field(foreign_key="animales.id", index=True)
