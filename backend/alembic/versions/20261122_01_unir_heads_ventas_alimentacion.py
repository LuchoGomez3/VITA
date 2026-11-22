"""Une el ramal de ventas con el de alimentación.

Las dos ramas salieron de ``20261017_02`` y no comparten tablas, así que la
unión no cambia el esquema.

Revision ID: 20261122_01
Revises: 20261027_01, 20261114_02
Create Date: 2026-11-22
"""

from collections.abc import Sequence

revision: str = "20261122_01"
down_revision: str | Sequence[str] | None = (
    "20261027_01",
    "20261114_02",
)
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    """Une ambos historiales; los cambios de esquema viven en sus ramales."""


def downgrade() -> None:
    """Separa nuevamente ambos historiales sin modificar el esquema."""
