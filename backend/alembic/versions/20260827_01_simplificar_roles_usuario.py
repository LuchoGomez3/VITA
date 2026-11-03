"""Reduce los roles de membresía a owner y employee.

Revision ID: 20260827_01
Revises: 20260819_01
Create Date: 2026-08-27
"""

from collections.abc import Sequence

from alembic import op
import sqlalchemy as sa

revision: str = "20260827_01"
down_revision: str | None = "20260819_01"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None

_TABLE = "usuarios_establecimientos"
_OWNER_ROLES = ("administrator", "owner")
_ROLE_CONSTRAINT = "ck_usuarios_establecimientos_rol"


def upgrade() -> None:
    connection = op.get_bind()
    if not sa.inspect(connection).has_table(_TABLE):
        raise RuntimeError(
            "No se puede aplicar la migración: la tabla "
            "usuarios_establecimientos no existe."
        )

    # La restricción única anterior incluía el rol, por lo que un usuario
    # podía tener varias membresías que ahora convergen al mismo valor. Se
    # conserva primero una membresía activa y se eliminan solo los duplicados.
    connection.execute(
        sa.text(
            f"""
            DELETE FROM {_TABLE}
            WHERE id IN (
                SELECT id
                FROM (
                    SELECT
                        id,
                        ROW_NUMBER() OVER (
                            PARTITION BY
                                usuario_id,
                                establecimiento_id,
                                CASE
                                    WHEN rol IN ('administrator', 'owner')
                                        THEN 'owner'
                                    ELSE 'employee'
                                END
                            ORDER BY activo DESC, created_at ASC, id ASC
                        ) AS posicion
                    FROM {_TABLE}
                ) AS membresias_normalizadas
                WHERE posicion > 1
            )
            """
        )
    )

    owner_roles = sa.bindparam("owner_roles", expanding=True)
    connection.execute(
        sa.text(
            f"""
            UPDATE {_TABLE}
            SET rol = CASE
                WHEN rol IN :owner_roles THEN 'owner'
                ELSE 'employee'
            END
            """
        ).bindparams(owner_roles),
        {"owner_roles": _OWNER_ROLES},
    )

    with op.batch_alter_table(_TABLE) as batch_op:
        batch_op.create_check_constraint(
            _ROLE_CONSTRAINT,
            "rol IN ('owner', 'employee')",
        )


def downgrade() -> None:
    # Los roles anteriores no pueden reconstruirse sin inventar información.
    raise RuntimeError(
        "La migración de roles no es reversible: owner y employee no permiten "
        "deducir el rol anterior."
    )
