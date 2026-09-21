"""Restringe el acceso directo a ventas a roles comerciales.

Revision ID: 20260910_01
Revises: 20260902_02
Create Date: 2026-09-10
"""

from collections.abc import Sequence

from alembic import op
import sqlalchemy as sa
from sqlalchemy.engine import Connection

revision: str = "20260910_01"
down_revision: str | None = "20260902_02"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None

_TABLAS_REQUERIDAS = ("ventas", "ventas_detalles", "usuarios_establecimientos")
_ROLES_COMERCIALES = "ue.rol in ('admin', 'owner')"

_ES_MIEMBRO = """
    exists (
        select 1
        from public.usuarios_establecimientos ue
        where ue.establecimiento_id = {tabla}.establecimiento_id
          and ue.usuario_id = auth.uid()
          and ue.activo = true
          {restriccion_rol}
    )
"""

_ES_MIEMBRO_DE_LA_VENTA = """
    exists (
        select 1
        from public.ventas v
        join public.usuarios_establecimientos ue
          on ue.establecimiento_id = v.establecimiento_id
        where v.id = ventas_detalles.venta_id
          and ue.usuario_id = auth.uid()
          and ue.activo = true
          {restriccion_rol}
    )
"""

_ANIMAL_DEL_MISMO_ESTABLECIMIENTO = """
    exists (
        select 1
        from public.ventas v
        join public.animales a
          on a.id = ventas_detalles.animal_id
         and a.establecimiento_id = v.establecimiento_id
        join public.usuarios_establecimientos ue
          on ue.establecimiento_id = v.establecimiento_id
        where v.id = ventas_detalles.venta_id
          and ue.usuario_id = auth.uid()
          and ue.activo = true
          {restriccion_rol}
    )
"""


def _exigir_tablas_previas(connection: Connection) -> None:
    inspector = sa.inspect(connection)
    faltantes = [
        tabla for tabla in _TABLAS_REQUERIDAS if not inspector.has_table(tabla)
    ]
    if faltantes:
        raise RuntimeError(
            "No se pueden restringir las ventas: faltan las tablas "
            f"{', '.join(faltantes)}."
        )


def _soporta_rls(connection: Connection) -> bool:
    if connection.dialect.name != "postgresql":
        return False
    return connection.execute(
        sa.text("select to_regprocedure('auth.uid()') is not null")
    ).scalar_one()


def _sentencias_politicas(restringir_roles: bool) -> list[str]:
    restriccion_rol = f"and {_ROLES_COMERCIALES}" if restringir_roles else ""
    ventas_es_miembro = _ES_MIEMBRO.format(
        tabla="ventas", restriccion_rol=restriccion_rol
    )
    detalle_es_miembro = _ES_MIEMBRO_DE_LA_VENTA.format(restriccion_rol=restriccion_rol)
    animal_valido = _ANIMAL_DEL_MISMO_ESTABLECIMIENTO.format(
        restriccion_rol=restriccion_rol
    )

    # Las cinco políticas deben usar exactamente el mismo conjunto de roles para
    # que un operario no pueda ver montos ni modificar la composición por otra vía.
    return [
        "drop policy if exists ventas_select_miembros on public.ventas",
        f"""
        create policy ventas_select_miembros on public.ventas
        for select to authenticated
        using ({ventas_es_miembro})
        """,
        "drop policy if exists ventas_insert_miembros on public.ventas",
        f"""
        create policy ventas_insert_miembros on public.ventas
        for insert to authenticated
        with check (registrada_por_id = auth.uid() and {ventas_es_miembro})
        """,
        "drop policy if exists ventas_update_miembros on public.ventas",
        f"""
        create policy ventas_update_miembros on public.ventas
        for update to authenticated
        using ({ventas_es_miembro})
        with check ({ventas_es_miembro})
        """,
        "drop policy if exists ventas_detalles_select_miembros"
        " on public.ventas_detalles",
        f"""
        create policy ventas_detalles_select_miembros on public.ventas_detalles
        for select to authenticated
        using ({detalle_es_miembro})
        """,
        "drop policy if exists ventas_detalles_insert_miembros"
        " on public.ventas_detalles",
        f"""
        create policy ventas_detalles_insert_miembros on public.ventas_detalles
        for insert to authenticated
        with check ({animal_valido})
        """,
    ]


def _reemplazar_politicas(connection: Connection, *, restringir_roles: bool) -> None:
    for sentencia in _sentencias_politicas(restringir_roles):
        connection.execute(sa.text(sentencia))


def upgrade() -> None:
    connection = op.get_bind()
    _exigir_tablas_previas(connection)
    if _soporta_rls(connection):
        _reemplazar_politicas(connection, restringir_roles=True)


def downgrade() -> None:
    connection = op.get_bind()
    _exigir_tablas_previas(connection)
    if _soporta_rls(connection):
        _reemplazar_politicas(connection, restringir_roles=False)
