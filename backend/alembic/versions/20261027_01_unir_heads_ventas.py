"""Une el ramal de precision de ventas con el historial actual de develop.

Revision ID: 20261027_01
Revises: 20261003_01, 20261017_02
Create Date: 2026-10-27
"""

from collections.abc import Sequence

revision: str = "20261027_01"
down_revision: str | Sequence[str] | None = (
    "20261003_01",
    "20261017_02",
)
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    """Une ambos historiales; los cambios de esquema viven en sus ramales."""


def downgrade() -> None:
    """Separa nuevamente ambos historiales sin modificar el esquema."""
