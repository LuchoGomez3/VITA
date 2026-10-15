"""Registra la fecha autoritativa del ultimo cambio de estado productivo.

Revision ID: 20261015_01
Revises: 20261014_01
Create Date: 2026-10-15
"""

from collections.abc import Sequence

from alembic import op
import sqlalchemy as sa

revision: str = "20261015_01"
down_revision: str | None = "20261014_01"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def _columnas() -> set[str]:
    connection = op.get_bind()
    return {column["name"] for column in sa.inspect(connection).get_columns("animales")}


def upgrade() -> None:
    connection = op.get_bind()
    if "animales" not in sa.inspect(connection).get_table_names():
        raise RuntimeError("Falta la tabla animales: migracion previa no aplicada")
    if "estado_actualizado_en" not in _columnas():
        op.add_column(
            "animales",
            sa.Column(
                "estado_actualizado_en", sa.DateTime(timezone=True), nullable=True
            ),
        )


def downgrade() -> None:
    if "estado_actualizado_en" in _columnas():
        op.drop_column("animales", "estado_actualizado_en")
