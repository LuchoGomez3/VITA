"""Equipo del establecimiento: rol veterinario e invitaciones por email (adr-0012).

- ``usuarios_establecimientos``: el check de roles suma ``veterinarian``.
- ``invitaciones_establecimientos``: invitación de un email a un campo con un rol.
  Guarda el HMAC del código (nunca el código), vence a los 7 días y admite una
  sola pendiente por email y establecimiento. Tiene RLS activado sin policies:
  ni ``anon`` ni ``authenticated`` la leen vía PostgREST; el backend entra como
  ``postgres`` y no se ve afectado.

Defensiva: no recrea lo que ya exista. Espejo para el SQL Editor de Supabase:
``backend/scripts/equipo_establecimiento.sql``.

Revision ID: 20261017_02
Revises: 20261017_01
Create Date: 2026-10-17
"""

from collections.abc import Sequence

from alembic import op
import sqlalchemy as sa

revision: str = "20261017_02"
down_revision: str | None = "20261017_01"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None

_MEMBRESIAS = "usuarios_establecimientos"
_CHECK_MEMBRESIAS = "ck_usuarios_establecimientos_rol"
_TABLA = "invitaciones_establecimientos"
# Copias literales de los modelos (un test lo verifica): la migración no importa
# modelos vivos.
_CHECK_ROL = "rol IN ('admin', 'owner', 'employee', 'veterinarian')"
_CHECK_ROL_PREVIO = "rol IN ('admin', 'owner', 'employee')"
_CHECK_ESTADO = "estado IN ('pendiente', 'aceptada', 'cancelada')"
_WHERE_PENDIENTE = "estado = 'pendiente'"


def _reemplazar_check_de_roles(definicion: str) -> None:
    with op.batch_alter_table(_MEMBRESIAS) as batch_op:
        batch_op.drop_constraint(_CHECK_MEMBRESIAS, type_="check")
        batch_op.create_check_constraint(_CHECK_MEMBRESIAS, definicion)


def upgrade() -> None:
    bind = op.get_bind()
    inspector = sa.inspect(bind)

    checks = {
        c["name"]: c.get("sqltext") or ""
        for c in inspector.get_check_constraints(_MEMBRESIAS)
    }
    if "veterinarian" not in checks.get(_CHECK_MEMBRESIAS, ""):
        _reemplazar_check_de_roles(_CHECK_ROL)

    if _TABLA not in inspector.get_table_names():
        op.create_table(
            _TABLA,
            sa.Column("id", sa.Uuid(), primary_key=True),
            sa.Column(
                "created_at",
                sa.DateTime(timezone=True),
                server_default=sa.func.now(),
                nullable=False,
            ),
            sa.Column(
                "updated_at",
                sa.DateTime(timezone=True),
                server_default=sa.func.now(),
                nullable=False,
            ),
            sa.Column(
                "establecimiento_id",
                sa.Uuid(),
                sa.ForeignKey("establecimientos.id"),
                nullable=False,
            ),
            sa.Column("email", sa.String(), nullable=False),
            sa.Column("rol", sa.String(), nullable=False),
            sa.Column("codigo_hash", sa.String(64), nullable=False),
            sa.Column("expira_en", sa.DateTime(timezone=True), nullable=False),
            sa.Column("estado", sa.String(), nullable=False),
            sa.Column(
                "invitado_por_id",
                sa.Uuid(),
                sa.ForeignKey("usuarios.id"),
                nullable=False,
            ),
            sa.Column(
                "aceptada_por_id",
                sa.Uuid(),
                sa.ForeignKey("usuarios.id"),
                nullable=True,
            ),
            sa.Column("aceptada_en", sa.DateTime(timezone=True), nullable=True),
            sa.Column("email_enviado_en", sa.DateTime(timezone=True), nullable=True),
            sa.CheckConstraint(_CHECK_ROL, name="ck_invitaciones_establecimientos_rol"),
            sa.CheckConstraint(
                _CHECK_ESTADO, name="ck_invitaciones_establecimientos_estado"
            ),
        )

    indices = {i["name"] for i in sa.inspect(bind).get_indexes(_TABLA)}
    if "ix_invitaciones_establecimientos_establecimiento_id" not in indices:
        op.create_index(
            "ix_invitaciones_establecimientos_establecimiento_id",
            _TABLA,
            ["establecimiento_id"],
        )
    if "ix_invitaciones_establecimientos_codigo_hash" not in indices:
        op.create_index(
            "ix_invitaciones_establecimientos_codigo_hash", _TABLA, ["codigo_hash"]
        )
    if "uq_invitaciones_establecimientos_pendiente" not in indices:
        op.create_index(
            "uq_invitaciones_establecimientos_pendiente",
            _TABLA,
            ["establecimiento_id", "email"],
            unique=True,
            postgresql_where=sa.text(_WHERE_PENDIENTE),
            sqlite_where=sa.text(_WHERE_PENDIENTE),
        )

    if bind.dialect.name == "postgresql":
        op.execute(f"ALTER TABLE {_TABLA} ENABLE ROW LEVEL SECURITY")


def downgrade() -> None:
    bind = op.get_bind()
    inspector = sa.inspect(bind)
    if _TABLA in inspector.get_table_names():
        op.drop_table(_TABLA)

    # Un veterinario vuelve a ser empleado. Si ya tenía también la membresía de
    # empleado, se borra la de veterinario para no violar la unicidad
    # (usuario, establecimiento, rol).
    op.execute(
        f"DELETE FROM {_MEMBRESIAS} WHERE rol = 'veterinarian' AND EXISTS ("
        f"SELECT 1 FROM {_MEMBRESIAS} otra"
        f" WHERE otra.usuario_id = {_MEMBRESIAS}.usuario_id"
        f" AND otra.establecimiento_id = {_MEMBRESIAS}.establecimiento_id"
        " AND otra.rol = 'employee')"
    )
    op.execute(f"UPDATE {_MEMBRESIAS} SET rol = 'employee' WHERE rol = 'veterinarian'")
    _reemplazar_check_de_roles(_CHECK_ROL_PREVIO)
