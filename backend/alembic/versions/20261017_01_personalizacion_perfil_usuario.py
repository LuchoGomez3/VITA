"""Personalización del perfil: color de la cabecera y fecha de la foto (adr-0011).

Agrega a ``usuarios``:

- ``color_cabecera`` (``varchar(7)``, nullable): reemplaza el verde por defecto
  de la cabecera de Perfil. Formato ``#RRGGBB`` en mayúsculas, garantizado por
  ``ck_usuarios_color_cabecera``.
- ``avatar_actualizado_en`` (``timestamptz``, nullable): cuándo se subió la foto
  de perfil. La foto vive en el bucket privado ``avatars`` con clave
  ``{usuario_id}.jpg``; la fecha les avisa a otros dispositivos que hay una
  nueva para bajar.

Defensiva: no recrea lo que ya exista. Espejo para el SQL Editor de Supabase:
``backend/scripts/personalizacion_perfil_usuario.sql``.

Revision ID: 20261017_01
Revises: 20261014_01
Create Date: 2026-10-17
"""

from collections.abc import Sequence

from alembic import op
import sqlalchemy as sa

revision: str = "20261017_01"
down_revision: str | None = "20261014_01"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None

_TABLA = "usuarios"
_CHECK = "ck_usuarios_color_cabecera"
# Copia literal de ``CHECK_COLOR_CABECERA`` en ``api/modules/usuarios/models.py``
# (un test lo verifica): la migración no importa modelos vivos.
_CHECK_COLOR_CABECERA = (
    "color_cabecera IS NULL OR ("
    "length(color_cabecera) = 7"
    " AND substr(color_cabecera, 1, 1) = '#'"
    " AND ltrim(substr(color_cabecera, 2), '0123456789ABCDEF') = ''"
    ")"
)


def upgrade() -> None:
    inspector = sa.inspect(op.get_bind())
    columnas = {c["name"] for c in inspector.get_columns(_TABLA)}
    if "color_cabecera" not in columnas:
        op.add_column(_TABLA, sa.Column("color_cabecera", sa.String(7), nullable=True))
    if "avatar_actualizado_en" not in columnas:
        op.add_column(
            _TABLA,
            sa.Column(
                "avatar_actualizado_en", sa.DateTime(timezone=True), nullable=True
            ),
        )
    checks = {c["name"] for c in inspector.get_check_constraints(_TABLA)}
    if _CHECK not in checks:
        op.create_check_constraint(_CHECK, _TABLA, _CHECK_COLOR_CABECERA)


def downgrade() -> None:
    inspector = sa.inspect(op.get_bind())
    if _CHECK in {c["name"] for c in inspector.get_check_constraints(_TABLA)}:
        op.drop_constraint(_CHECK, _TABLA, type_="check")
    columnas = {c["name"] for c in inspector.get_columns(_TABLA)}
    if "avatar_actualizado_en" in columnas:
        op.drop_column(_TABLA, "avatar_actualizado_en")
    if "color_cabecera" in columnas:
        op.drop_column(_TABLA, "color_cabecera")
