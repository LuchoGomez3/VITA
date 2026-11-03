"""Garantiza la unicidad de email y CUIT en usuarios.

Revision ID: 20260819_01
Revises: None
Create Date: 2026-08-19
"""

from collections.abc import Sequence

from alembic import op
import sqlalchemy as sa
from sqlalchemy.engine import Connection

revision: str = "20260819_01"
down_revision: str | None = None
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None

_TABLE = "usuarios"
_EMAIL_INDEX = "uq_usuarios_email"
_CUIT_INDEX = "uq_usuarios_cuit"


def _duplicate_groups(connection: Connection, expression: str) -> int:
    # Las expresiones son constantes internas, no reciben entrada externa.
    query = sa.text(
        f"""
        SELECT COUNT(*)
        FROM (
            SELECT {expression}
            FROM {_TABLE}
            WHERE {expression} IS NOT NULL
            GROUP BY {expression}
            HAVING COUNT(*) > 1
        ) AS duplicados
        """
    )
    return int(connection.execute(query).scalar_one())


def _assert_no_duplicates(connection: Connection) -> None:
    if _duplicate_groups(connection, "lower(trim(email))"):
        raise RuntimeError(
            "No se puede aplicar la migración: existen emails duplicados "
            "en public.usuarios después de normalizarlos."
        )
    if _duplicate_groups(connection, "cuit"):
        raise RuntimeError(
            "No se puede aplicar la migración: existen CUIT duplicados "
            "en public.usuarios."
        )


def _index_is_valid(connection: Connection, name: str, column: str) -> bool:
    indexes = sa.inspect(connection).get_indexes(_TABLE)
    matching = next((index for index in indexes if index["name"] == name), None)
    if matching is None:
        return False
    if not matching.get("unique") or matching.get("column_names") != [column]:
        raise RuntimeError(
            f"El índice {name} ya existe pero no garantiza unicidad sobre {column}."
        )
    return True


def upgrade() -> None:
    connection = op.get_bind()
    inspector = sa.inspect(connection)
    if not inspector.has_table(_TABLE):
        raise RuntimeError(
            "No se puede aplicar la migración: la tabla public.usuarios no existe."
        )

    # Se valida antes del UPDATE para informar el problema con claridad en vez
    # de depender de un error críptico emitido por un índice preexistente.
    _assert_no_duplicates(connection)
    connection.execute(sa.text("UPDATE usuarios SET email = lower(trim(email))"))

    if not _index_is_valid(connection, _EMAIL_INDEX, "email"):
        op.create_index(_EMAIL_INDEX, _TABLE, ["email"], unique=True)
    if not _index_is_valid(connection, _CUIT_INDEX, "cuit"):
        op.create_index(
            _CUIT_INDEX,
            _TABLE,
            ["cuit"],
            unique=True,
            postgresql_where=sa.text("cuit IS NOT NULL"),
            sqlite_where=sa.text("cuit IS NOT NULL"),
        )


def downgrade() -> None:
    connection = op.get_bind()
    indexes = {index["name"] for index in sa.inspect(connection).get_indexes(_TABLE)}
    if _CUIT_INDEX in indexes:
        op.drop_index(_CUIT_INDEX, table_name=_TABLE)
    if _EMAIL_INDEX in indexes:
        op.drop_index(_EMAIL_INDEX, table_name=_TABLE)
