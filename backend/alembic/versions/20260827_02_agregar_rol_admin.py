"""Agrega el rol admin a las membresías de establecimientos.

Revision ID: 20260827_02
Revises: 20260827_01
Create Date: 2026-08-27
"""

from collections.abc import Sequence

from alembic import op

revision: str = "20260827_02"
down_revision: str | None = "20260827_01"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None

_TABLE = "usuarios_establecimientos"
_ROLE_CONSTRAINT = "ck_usuarios_establecimientos_rol"


def upgrade() -> None:
    with op.batch_alter_table(_TABLE) as batch_op:
        batch_op.drop_constraint(_ROLE_CONSTRAINT, type_="check")
        batch_op.create_check_constraint(
            _ROLE_CONSTRAINT,
            "rol IN ('admin', 'owner', 'employee')",
        )


def downgrade() -> None:
    # Un admin se degrada a owner para volver al conjunto anterior sin perder
    # su acceso al establecimiento.
    op.execute(
        f"UPDATE {_TABLE} SET rol = 'owner' WHERE rol = 'admin'"
    )
    with op.batch_alter_table(_TABLE) as batch_op:
        batch_op.drop_constraint(_ROLE_CONSTRAINT, type_="check")
        batch_op.create_check_constraint(
            _ROLE_CONSTRAINT,
            "rol IN ('owner', 'employee')",
        )
