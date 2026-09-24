"""Exige DTe y distingue empresas de personas físicas en ventas.

Revision ID: 20260910_02
Revises: 20260910_01
Create Date: 2026-09-10
"""

from collections.abc import Sequence

from alembic import op
import sqlalchemy as sa
from sqlalchemy.engine import Connection

revision: str = "20260910_02"
down_revision: str | None = "20260910_01"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None

_TABLA = "ventas"
_CK_DTE = "ck_ventas_nro_dte_no_vacio"
_CK_APELLIDO = "ck_ventas_apellido_segun_comprador"


def _exigir_tabla_previa(connection: Connection) -> None:
    if not sa.inspect(connection).has_table(_TABLA):
        raise RuntimeError("No se puede ajustar ventas: la tabla ventas no existe.")


def _agregar_clasificacion_si_falta(connection: Connection) -> None:
    columnas = {
        columna["name"] for columna in sa.inspect(connection).get_columns(_TABLA)
    }
    if "es_empresa" not in columnas:
        op.add_column(_TABLA, sa.Column("es_empresa", sa.Boolean(), nullable=True))

    # Tipo de comprador, apellido y naturaleza jurídica eran datos independientes
    # en el esquema anterior. No hay una regla confiable para inferir es_empresa:
    # cualquier backfill automático podría alterar el significado de una venta.
    compradores_sin_clasificar = connection.execute(
        sa.text("select count(*) from ventas where es_empresa is null")
    ).scalar_one()
    if compradores_sin_clasificar:
        raise RuntimeError(
            "No se puede inferir la clasificación del comprador: "
            f"hay {compradores_sin_clasificar} venta(s) sin es_empresa explícito."
        )


def _exigir_datos_compatibles(connection: Connection) -> None:
    dte_invalidos = connection.execute(
        sa.text(
            "select count(*) from ventas where nro_dte is null or trim(nro_dte) = ''"
        )
    ).scalar_one()
    if dte_invalidos:
        raise RuntimeError(
            "No se puede exigir el DTe: "
            f"hay {dte_invalidos} venta(s) sin un número válido."
        )

    compradores_invalidos = connection.execute(
        sa.text(
            "select count(*) from ventas "
            "where (es_empresa and apellido_comprador is not null) "
            "or (not es_empresa and (apellido_comprador is null "
            "or trim(apellido_comprador) = ''))"
        )
    ).scalar_one()
    if compradores_invalidos:
        raise RuntimeError(
            "No se puede aplicar la clasificación del comprador: "
            f"hay {compradores_invalidos} venta(s) con un apellido incompatible."
        )


def _crear_checks_faltantes(connection: Connection) -> None:
    existentes = {
        restriccion["name"]
        for restriccion in sa.inspect(connection).get_check_constraints(_TABLA)
    }
    if _CK_DTE not in existentes:
        op.create_check_constraint(_CK_DTE, _TABLA, "trim(nro_dte) <> ''")
    if _CK_APELLIDO not in existentes:
        op.create_check_constraint(
            _CK_APELLIDO,
            _TABLA,
            "(es_empresa and apellido_comprador is null) "
            "or (not es_empresa and apellido_comprador is not null "
            "and trim(apellido_comprador) <> '')",
        )


def upgrade() -> None:
    connection = op.get_bind()
    _exigir_tabla_previa(connection)
    _agregar_clasificacion_si_falta(connection)
    _exigir_datos_compatibles(connection)

    op.alter_column(_TABLA, "es_empresa", existing_type=sa.Boolean(), nullable=False)
    op.alter_column(_TABLA, "nro_dte", existing_type=sa.String(), nullable=False)
    _crear_checks_faltantes(connection)


def downgrade() -> None:
    connection = op.get_bind()
    _exigir_tabla_previa(connection)
    checks = {
        restriccion["name"]
        for restriccion in sa.inspect(connection).get_check_constraints(_TABLA)
    }
    if _CK_APELLIDO in checks:
        op.drop_constraint(_CK_APELLIDO, _TABLA, type_="check")
    if _CK_DTE in checks:
        op.drop_constraint(_CK_DTE, _TABLA, type_="check")

    op.alter_column(_TABLA, "nro_dte", existing_type=sa.String(), nullable=True)
    columnas = {
        columna["name"] for columna in sa.inspect(connection).get_columns(_TABLA)
    }
    if "es_empresa" in columnas:
        op.drop_column(_TABLA, "es_empresa")
