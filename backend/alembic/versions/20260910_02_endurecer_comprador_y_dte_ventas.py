"""Distingue al comprador empresa del particular y vuelve obligatorio el DTe.

El comprador deja de ser un texto libre con un apellido opcional: ``es_empresa``
decide qué identidad corresponde. Una empresa (frigorífico o remate) se nombra
por su razón social y no lleva apellido; un particular es una persona física y
sin apellido queda mal identificada en el DTe.

El ``nro_dte`` pasa a ser obligatorio: la venta no se considera registrada hasta
que existe el Documento de Tránsito electrónico que la respalda ante SENASA.

Revision ID: 20260910_02
Revises: 20260905_03
Create Date: 2026-09-10
"""

from collections.abc import Sequence

from alembic import op
import sqlalchemy as sa
from sqlalchemy.engine import Connection

revision: str = "20260910_02"
down_revision: str | None = "20260905_03"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None

_VENTAS = "ventas"

_CK_DTE_NO_VACIO = "ck_ventas_nro_dte_no_vacio"
_CK_APELLIDO_SEGUN_COMPRADOR = "ck_ventas_apellido_segun_comprador"

# Una empresa se identifica por razón social y no lleva apellido; un particular
# siempre debe tenerlo. Las dos mitades son excluyentes por construcción.
_APELLIDO_SEGUN_COMPRADOR = (
    "(es_empresa and apellido_comprador is null)"
    " or (not es_empresa and apellido_comprador is not null"
    " and trim(apellido_comprador) <> '')"
)

# (nombre, expresión)
_CHECKS = (
    (_CK_DTE_NO_VACIO, "trim(nro_dte) <> ''"),
    (_CK_APELLIDO_SEGUN_COMPRADOR, _APELLIDO_SEGUN_COMPRADOR),
)


def _tiene_columna(connection: Connection, columna: str) -> bool:
    return columna in {c["name"] for c in sa.inspect(connection).get_columns(_VENTAS)}


def _checks_existentes(connection: Connection) -> set[str]:
    return {
        c["name"]
        for c in sa.inspect(connection).get_check_constraints(_VENTAS)
        if c["name"]
    }


def _exigir_datos_compatibles(connection: Connection) -> None:
    """Aborta antes de endurecer si las filas actuales no cumplen las reglas.

    Endurecer primero y fallar después dejaría la migración a medio aplicar. Las
    dos consultas son las mismas que imponen los ``CHECK`` de más abajo.
    """
    dte_invalidos = connection.execute(
        sa.text(
            f"select count(*) from {_VENTAS}"
            " where nro_dte is null or trim(nro_dte) = ''"
        )
    ).scalar_one()
    if dte_invalidos:
        raise RuntimeError(
            f"No se puede aplicar la migración: {dte_invalidos} venta(s) sin"
            " nro_dte. Completar el Documento de Tránsito de esas ventas antes"
            " de volver a ejecutarla."
        )

    apellidos_invalidos = connection.execute(
        sa.text(
            f"select count(*) from {_VENTAS} where not ({_APELLIDO_SEGUN_COMPRADOR})"
        )
    ).scalar_one()
    if apellidos_invalidos:
        raise RuntimeError(
            f"No se puede aplicar la migración: {apellidos_invalidos} venta(s)"
            " con apellido_comprador incoherente con es_empresa. Corregir esas"
            " filas antes de volver a ejecutarla."
        )


def upgrade() -> None:
    connection = op.get_bind()

    # Se agrega nullable para poder derivar el valor de las filas que ya existen;
    # recién después se endurece.
    if not _tiene_columna(connection, "es_empresa"):
        op.add_column(_VENTAS, sa.Column("es_empresa", sa.Boolean(), nullable=True))

    # Hasta ahora el apellido era el único indicio del tipo de comprador: su
    # ausencia implicaba una razón social.
    connection.execute(
        sa.text(
            f"update {_VENTAS} set es_empresa = (apellido_comprador is null)"
            " where es_empresa is null"
        )
    )

    _exigir_datos_compatibles(connection)

    op.alter_column(_VENTAS, "es_empresa", existing_type=sa.Boolean(), nullable=False)
    op.alter_column(_VENTAS, "nro_dte", existing_type=sa.String(), nullable=False)

    existentes = _checks_existentes(connection)
    for nombre, expresion in _CHECKS:
        if nombre not in existentes:
            op.create_check_constraint(nombre, _VENTAS, expresion)


def downgrade() -> None:
    connection = op.get_bind()

    existentes = _checks_existentes(connection)
    for nombre, _ in _CHECKS:
        if nombre in existentes:
            op.drop_constraint(nombre, _VENTAS, type_="check")

    op.alter_column(_VENTAS, "nro_dte", existing_type=sa.String(), nullable=True)

    if _tiene_columna(connection, "es_empresa"):
        op.drop_column(_VENTAS, "es_empresa")
