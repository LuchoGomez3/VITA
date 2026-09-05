"""Modelos persistentes del movimiento de animales entre lotes.

El movimiento es un **agregado**: una cabecera (``movimientos_lotes``) que
describe la operación y un detalle (``movimientos_lotes_animales``) con los
animales que la componen. Mismo patrón que ``ventas``/``ventas_detalles``.

La cardinalidad importa para offline-first: la app crea *una* operación con N
animales y le asigna *un* UUID. Ese UUID es la clave de idempotencia, así que
tiene que ser PK de una única fila — una tabla con una fila por animal no podría
sostenerlo y un reintento duplicaría el historial.
"""

from datetime import datetime
from uuid import UUID

from sqlalchemy import CheckConstraint, DateTime, Index, UniqueConstraint
from sqlmodel import Field

from database.models import Base, SoftDeleteMixin


class MovimientoLote(Base, SoftDeleteMixin, table=True):
    """Traslado de un conjunto de animales de un lote a otro.

    Entidad sincronizable: UUID del cliente, timestamps propios y borrado lógico
    para que el tombstone también viaje.
    """

    __tablename__ = "movimientos_lotes"
    __table_args__ = (
        CheckConstraint(
            "lote_origen_id is null or lote_origen_id <> lote_destino_id",
            name="ck_movimientos_lotes_origen_distinto_destino",
        ),
        Index("ix_movimientos_lotes_sync", "establecimiento_id", "updated_at"),
    )

    establecimiento_id: UUID = Field(foreign_key="establecimientos.id", index=True)
    # Nullable en la base para admitir el ingreso desde fuera del establecimiento
    # (compra, nacimiento) cuando se modele. El contrato V1 lo exige al escribir.
    lote_origen_id: UUID | None = Field(
        default=None, foreign_key="lotes.id", index=True
    )
    lote_destino_id: UUID = Field(foreign_key="lotes.id", index=True)
    fecha_movimiento: datetime = Field(sa_type=DateTime(timezone=True), nullable=False)
    motivo: str | None = None
    # Siempre se deriva del JWT; el cliente no puede elegir a quién se le imputa.
    responsable_id: UUID | None = Field(default=None, foreign_key="usuarios.id")


class MovimientoLoteAnimal(Base, table=True):
    """Animal incluido en un movimiento.

    Sin ``SoftDeleteMixin``: es la hoja de un agregado atómico, viaja dentro del
    payload de su cabecera y no se sincroniza ni se borra por separado.
    """

    __tablename__ = "movimientos_lotes_animales"
    __table_args__ = (
        # Impide que un replay mal resuelto duplique el detalle del movimiento.
        UniqueConstraint(
            "movimiento_lote_id", "animal_id", name="uq_movimiento_lote_animal"
        ),
    )

    movimiento_lote_id: UUID = Field(foreign_key="movimientos_lotes.id", index=True)
    # Indexado: responde "¿por qué lotes pasó este animal?" para su historial.
    animal_id: UUID = Field(foreign_key="animales.id", index=True)
