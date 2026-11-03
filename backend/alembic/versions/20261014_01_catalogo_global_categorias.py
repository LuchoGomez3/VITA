"""Catálogo global de categorías: dejan de pertenecer a un establecimiento.

Contrato que pidió mobile (commit 5fc2edc, VITA-22) y decisión de adr-0010:

1. Los animales que usan categorías propias de un establecimiento (datos de
   prueba heredados, ids ``550e8400-…``) pasan a la categoría global del mismo
   nombre. El "Ternero" de prueba admitía ambos sexos: sus hembras van a
   "Ternera". Decisión de Lucho, 2026-10-14. Si alguno no tiene equivalente
   compatible queda sin categoría (y sin condición reproductiva, que la exige).
   Se actualiza su ``updated_at`` para que la descarga delta propague el cambio.
2. Se borran las categorías propias: ya ningún animal las referencia.
3. ``validar_categoria_animal()`` deja de leer ``categorias.establecimiento_id``.
   Se reemplaza antes de borrar la columna, porque plpgsql resuelve las columnas
   recién al ejecutar.
4. Se borra ``categorias.establecimiento_id`` con su índice y su FK.

Defensiva: si la columna ya no existe, solo reemplaza la función. Espejo para el
SQL Editor de Supabase: ``backend/scripts/catalogo_global_categorias.sql``.

Revision ID: 20261014_01
Revises: 20261001_03
Create Date: 2026-10-14
"""

from collections.abc import Sequence

from alembic import op
import sqlalchemy as sa
from sqlalchemy.engine import Connection

revision: str = "20261014_01"
down_revision: str | None = "20261001_03"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None

_INDICE = "ix_categorias_establecimiento_id"
_FK = "categorias_establecimiento_id_fkey"

# Reasigna cada animal de una categoría propia a la global del mismo nombre, si
# es compatible con su sexo y su condición reproductiva.
_REASIGNAR_A_GLOBAL = """
update animales a
   set categoria_id = g.id,
       updated_at = now()
  from categorias c, categorias g
 where a.categoria_id = c.id
   and c.establecimiento_id is not null
   and g.establecimiento_id is null
   and g.deleted_at is null
   and lower(g.nombre) = case
           when lower(c.nombre) = 'ternero' and a.sexo = 'hembra' then 'ternera'
           else lower(c.nombre)
       end
   and (g.sexo_permitido = 'ambos' or g.sexo_permitido = a.sexo)
   and (
       a.estado_reproductivo is null
       or a.estado_reproductivo not in ('vacia', 'prenada')
       or g.permite_estado_reproductivo
   )
"""

# Los que no tienen equivalente quedan sin categoría. Sin categoría solo se
# admite ``sin_determinar``.
_DEJAR_SIN_CATEGORIA = """
update animales a
   set categoria_id = null,
       estado_reproductivo = case
           when a.estado_reproductivo in ('vacia', 'prenada') then 'sin_determinar'
           else a.estado_reproductivo
       end,
       updated_at = now()
  from categorias c
 where a.categoria_id = c.id
   and c.establecimiento_id is not null
"""

_BORRAR_CATEGORIAS_PROPIAS = (
    "delete from categorias where establecimiento_id is not null"
)

# Copia literal de ``api.modules.animales.models.FUNCION_CATEGORIA_COMPATIBLE``:
# la migración no importa código de la aplicación, que puede cambiar después.
# ``test_catalogo_global_categorias_migration`` verifica que coincidan.
_FUNCION_CATEGORIA_COMPATIBLE = """
create or replace function public.validar_categoria_animal()
returns trigger
language plpgsql
security invoker
set search_path = public, pg_temp
as $$
declare
    v_sexo_permitido varchar;
    v_permite boolean;
    v_borrada timestamptz;
begin
    -- La compatibilidad se exige solo a animales vivos. Reenviar el borrado de un
    -- animal no puede fallar porque su categoría cambió después; restaurarlo
    -- (deleted_at vuelve a null) lo deja vivo, así que ahí sí se revalida.
    -- ``constraint`` identifica cada rechazo para que el backend lo traduzca a
    -- su error de dominio sin depender del texto del mensaje.
    if new.categoria_id is null then
        if new.deleted_at is null
           and new.estado_reproductivo in ('vacia', 'prenada') then
            raise exception 'La condición reproductiva requiere una categoría habilitada'
                using errcode = 'check_violation',
                      constraint = 'animales_estado_reproductivo_requiere_categoria';
        end if;
        return new;
    end if;

    select c.sexo_permitido, c.permite_estado_reproductivo, c.deleted_at
      into v_sexo_permitido, v_permite, v_borrada
      from public.categorias c
     where c.id = new.categoria_id
       for share;

    -- Sin categoría visible, la FK o el RLS rechazan la fila.
    if not found then
        return new;
    end if;

    -- El borrado se exige solo al asignar: una categoría que se borra después
    -- no debe trabar la edición de otros campos del animal. El catálogo es
    -- global (adr-0010), así que no hay pertenencia a un establecimiento.
    if (tg_op = 'INSERT' or new.categoria_id is distinct from old.categoria_id)
       and v_borrada is not null then
        raise exception 'No se puede asignar una categoría eliminada'
            using errcode = 'check_violation',
                  constraint = 'animales_categoria_asignable';
    end if;

    if new.deleted_at is not null then
        return new;
    end if;

    if v_sexo_permitido <> 'ambos' and v_sexo_permitido <> new.sexo then
        raise exception 'La categoría seleccionada no es compatible con el sexo del animal'
            using errcode = 'check_violation',
                  constraint = 'animales_categoria_admite_sexo';
    end if;

    if new.estado_reproductivo in ('vacia', 'prenada') and not v_permite then
        raise exception 'La categoría del animal no admite condición reproductiva'
            using errcode = 'check_violation',
                  constraint = 'animales_categoria_admite_estado_reproductivo';
    end if;

    return new;
end;
$$
"""

# La versión anterior (migración 20261001_02), para el downgrade.
_FUNCION_CATEGORIA_COMPATIBLE_ANTERIOR = """
create or replace function public.validar_categoria_animal()
returns trigger
language plpgsql
security invoker
set search_path = public, pg_temp
as $$
declare
    v_establecimiento_id uuid;
    v_sexo_permitido varchar;
    v_permite boolean;
    v_borrada timestamptz;
begin
    -- La compatibilidad se exige solo a animales vivos. Reenviar el borrado de un
    -- animal no puede fallar porque su categoría cambió después; restaurarlo
    -- (deleted_at vuelve a null) lo deja vivo, así que ahí sí se revalida.
    -- ``constraint`` identifica cada rechazo para que el backend lo traduzca a
    -- su error de dominio sin depender del texto del mensaje.
    if new.categoria_id is null then
        if new.deleted_at is null
           and new.estado_reproductivo in ('vacia', 'prenada') then
            raise exception 'La condición reproductiva requiere una categoría habilitada'
                using errcode = 'check_violation',
                      constraint = 'animales_estado_reproductivo_requiere_categoria';
        end if;
        return new;
    end if;

    select c.establecimiento_id, c.sexo_permitido,
           c.permite_estado_reproductivo, c.deleted_at
      into v_establecimiento_id, v_sexo_permitido, v_permite, v_borrada
      from public.categorias c
     where c.id = new.categoria_id
       for share;

    -- Sin categoría visible, la FK o el RLS rechazan la fila. Con security
    -- invoker, un cliente directo no ve categorías ajenas: el trigger no
    -- distingue "ajena" de "inexistente" y no revela sus reglas.
    if not found then
        return new;
    end if;

    -- Pertenencia y borrado se exigen solo al asignar: una categoría que se
    -- borra después no debe trabar la edición de otros campos del animal. Vale
    -- también para animales borrados: es aislamiento, no compatibilidad.
    if tg_op = 'INSERT' or new.categoria_id is distinct from old.categoria_id then
        if v_borrada is not null then
            raise exception 'No se puede asignar una categoría eliminada'
                using errcode = 'check_violation',
                      constraint = 'animales_categoria_asignable';
        end if;
        if v_establecimiento_id is not null
           and v_establecimiento_id <> new.establecimiento_id then
            raise exception 'La categoría pertenece a otro establecimiento'
                using errcode = 'check_violation',
                      constraint = 'animales_categoria_asignable';
        end if;
    end if;

    if new.deleted_at is not null then
        return new;
    end if;

    if v_sexo_permitido <> 'ambos' and v_sexo_permitido <> new.sexo then
        raise exception 'La categoría seleccionada no es compatible con el sexo del animal'
            using errcode = 'check_violation',
                  constraint = 'animales_categoria_admite_sexo';
    end if;

    if new.estado_reproductivo in ('vacia', 'prenada') and not v_permite then
        raise exception 'La categoría del animal no admite condición reproductiva'
            using errcode = 'check_violation',
                  constraint = 'animales_categoria_admite_estado_reproductivo';
    end if;

    return new;
end;
$$
"""


def _columnas(connection: Connection) -> set[str]:
    return {c["name"] for c in sa.inspect(connection).get_columns("categorias")}


def upgrade() -> None:
    connection = op.get_bind()
    inspector = sa.inspect(connection)
    if not {"categorias", "animales"} <= set(inspector.get_table_names()):
        raise RuntimeError(
            "Faltan las tablas categorias/animales: migración previa no aplicada"
        )

    if "establecimiento_id" in _columnas(connection):
        connection.execute(sa.text(_REASIGNAR_A_GLOBAL))
        connection.execute(sa.text(_DEJAR_SIN_CATEGORIA))
        connection.execute(sa.text(_BORRAR_CATEGORIAS_PROPIAS))

    if connection.dialect.name == "postgresql":
        connection.execute(sa.text(_FUNCION_CATEGORIA_COMPATIBLE))

    if "establecimiento_id" in _columnas(connection):
        if _INDICE in {i["name"] for i in inspector.get_indexes("categorias")}:
            op.drop_index(_INDICE, table_name="categorias")
        if _FK in {fk["name"] for fk in inspector.get_foreign_keys("categorias")}:
            op.drop_constraint(_FK, "categorias", type_="foreignkey")
        op.drop_column("categorias", "establecimiento_id")


def downgrade() -> None:
    """Devuelve la columna (vacía: todo queda como catálogo global) y la función
    anterior. Las categorías de prueba borradas no se restauran."""
    connection = op.get_bind()
    if "establecimiento_id" not in _columnas(connection):
        op.add_column(
            "categorias",
            sa.Column("establecimiento_id", sa.Uuid(), nullable=True),
        )
        op.create_foreign_key(
            _FK, "categorias", "establecimientos", ["establecimiento_id"], ["id"]
        )
        op.create_index(_INDICE, "categorias", ["establecimiento_id"])
    if connection.dialect.name == "postgresql":
        connection.execute(sa.text(_FUNCION_CATEGORIA_COMPATIBLE_ANTERIOR))
