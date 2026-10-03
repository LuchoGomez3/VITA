"""Conserva hasta seis decimales del precio por kilo de una venta.

Revision ID: 20261003_01
Revises: 20261001_01
Create Date: 2026-10-03
"""

from collections.abc import Sequence

from alembic import op
import sqlalchemy as sa
from sqlalchemy.engine import Connection

revision: str = "20261003_01"
down_revision: str | None = "20261001_01"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None

_TABLA = "ventas"
_COLUMNA = "precio_por_kg"
_TIPO_ANTERIOR = sa.Numeric(precision=14, scale=2)
_TIPO_NUEVO = sa.Numeric(precision=18, scale=6)


def _existe_columna(connection: Connection) -> bool:
    inspector = sa.inspect(connection)
    if not inspector.has_table(_TABLA):
        return False
    return _COLUMNA in {columna["name"] for columna in inspector.get_columns(_TABLA)}


def upgrade() -> None:
    connection = op.get_bind()
    if not _existe_columna(connection):
        return
    op.alter_column(
        _TABLA,
        _COLUMNA,
        existing_type=_TIPO_ANTERIOR,
        type_=_TIPO_NUEVO,
        existing_nullable=True,
    )


def downgrade() -> None:
    connection = op.get_bind()
    if not _existe_columna(connection):
        return
    op.alter_column(
        _TABLA,
        _COLUMNA,
        existing_type=_TIPO_NUEVO,
        type_=_TIPO_ANTERIOR,
        existing_nullable=True,
    )
