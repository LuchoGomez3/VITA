"""Reglas de sexo y condición reproductiva entre animales y categorías (VITA-173).

1. ``categorias`` gana ``sexo_permitido`` (``macho`` | ``hembra`` | ``ambos``) y
   ``permite_estado_reproductivo``: reglas explícitas que nunca se infieren del
   nombre de la categoría.
2. ``animales`` gana ``estado_reproductivo`` (``sin_determinar`` | ``vacia`` |
   ``prenada`` | null), separado de ``estado``.
3. Dos triggers sostienen la compatibilidad ante escrituras directas: uno valida
   el animal contra su categoría y el otro impide que cambiar las reglas de una
   categoría deje animales inválidos.

4. Siembra el catálogo global de categorías (``establecimiento_id`` null): las
   6 que usa el front, con los mismos UUIDs. Decisión de Ernesto (PO) y Lucho,
   2026-10-02: "las categorías están en el front".

Las categorías se clasifican por ID con tablas revisadas a mano: el catálogo
global y los datos de prueba heredados que ya existen en Supabase. Si queda
alguna sin clasificar o algún animal vivo incompatible con la clasificación, la
migración se detiene y los lista: no inventa una regla ni asigna ``ambos`` por
defecto.

Revision ID: 20261001_02
Revises: 20260910_02
Create Date: 2026-10-01
"""

from collections.abc import Sequence

from alembic import op
import sqlalchemy as sa
from sqlalchemy.engine import Connection

revision: str = "20261001_02"
# Pasa a "20261001_01" cuando se integre VITA-172.
down_revision: str | None = "20260910_02"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None

_TABLAS_REQUERIDAS = ("categorias", "animales")

# Catálogo global (``establecimiento_id`` null): son las categorías del front,
# con los mismos UUIDs que usa mobile. Se siembran si no existen; si ya existen
# sin clasificar, se clasifican. Decisión de Ernesto (PO) y Lucho, 2026-10-02.
# (id, nombre, sexo_permitido, permite_estado_reproductivo)
_CATALOGO_GLOBAL: tuple[tuple[str, str, str, bool], ...] = (
    ("d37e62fb-96db-4ff1-a26b-0e3b2c3b36d8", "Ternera", "hembra", False),
    ("b9a6e57b-20ae-49b1-a7bb-17c71af546f3", "Ternero", "macho", False),
    ("b6d6440c-88c6-48cc-9003-0ad2cc05f3d5", "Vaquillona", "hembra", True),
    ("ef69117b-c979-4665-b13f-2b26ff0f19b3", "Vaca", "hembra", True),
    ("41da4271-bd25-4ba0-ba34-24dc6586f0f2", "Novillo", "macho", False),
    ("b5e8ea91-9789-4f7e-9dad-10262f1920f4", "Toro", "macho", False),
)

# Datos de prueba heredados: categorías propias que se cargaron en Supabase
# (establecimientos e35a810e-… y 550e8400-…-446655440010) antes de que existiera
# el catálogo. Se clasifican para que la migración no se corte con los datos
# actuales; el script SQL trae un paso manual y opcional para limpiarlas.
# "Ternero" de prueba queda en ``ambos`` porque tiene 2 hembras asignadas; el
# Ternero del catálogo es solo macho, y las hembras van en Ternera.
_CLASIFICACION_DATOS_PRUEBA: dict[str, tuple[str, bool]] = {
    "550e8400-e29b-41d4-a716-446655440030": ("ambos", False),  # Ternero
    "550e8400-e29b-41d4-a716-446655440031": ("macho", False),  # Novillo
    "550e8400-e29b-41d4-a716-446655440032": ("hembra", True),  # Vaca
    "550e8400-e29b-41d4-a716-446655440033": ("macho", False),  # Toro
    "550e8400-e29b-41d4-a716-446655440034": ("ambos", False),  # Engorde Rápido
}

# id -> (sexo_permitido, permite_estado_reproductivo). Solo se aplica a filas
# todavía sin clasificar, así que reejecutar la migración no pisa un cambio
# posterior.
_CLASIFICACION: dict[str, tuple[str, bool]] = {
    **{cid: (sexo, permite) for cid, _, sexo, permite in _CATALOGO_GLOBAL},
    **_CLASIFICACION_DATOS_PRUEBA,
}

_SEXOS_PERMITIDOS = ("macho", "hembra", "ambos")
_ESTADOS_REPRODUCTIVOS = ("sin_determinar", "vacia", "prenada")

_CK_SEXO_PERMITIDO = "ck_categorias_sexo_permitido_valido"
_CK_ESTADO_REPRODUCTIVO = "ck_animales_estado_reproductivo_valido"
_CK_SOLO_HEMBRAS = "ck_animales_estado_reproductivo_solo_hembras"

# Copia literal de ``api.modules.animales.models`` y ``api.modules.categorias
# .models``: la migración no importa código de la aplicación, que puede cambiar
# después. ``test_reglas_reproductivas_migration`` verifica que coincidan.
_FUNCION_CATEGORIA_COMPATIBLE = """
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
    if new.categoria_id is null then
        if new.estado_reproductivo in ('vacia', 'prenada') then
            raise exception 'La condición reproductiva requiere una categoría habilitada'
                using errcode = 'check_violation';
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
    -- borra después no debe trabar la edición de otros campos del animal.
    if tg_op = 'INSERT' or new.categoria_id is distinct from old.categoria_id then
        if v_borrada is not null then
            raise exception 'No se puede asignar una categoría eliminada'
                using errcode = 'check_violation';
        end if;
        if v_establecimiento_id is not null
           and v_establecimiento_id <> new.establecimiento_id then
            raise exception 'La categoría pertenece a otro establecimiento'
                using errcode = 'check_violation';
        end if;
    end if;

    if v_sexo_permitido <> 'ambos' and v_sexo_permitido <> new.sexo then
        raise exception 'La categoría seleccionada no es compatible con el sexo del animal'
            using errcode = 'check_violation';
    end if;

    if new.estado_reproductivo in ('vacia', 'prenada') and not v_permite then
        raise exception 'La categoría del animal no admite condición reproductiva'
            using errcode = 'check_violation';
    end if;

    return new;
end;
$$
"""

_TRIGGERS_CATEGORIA_COMPATIBLE = (
    "drop trigger if exists trg_animales_categoria_compatible on public.animales",
    """
create trigger trg_animales_categoria_compatible
before insert or update of sexo, categoria_id, estado_reproductivo, deleted_at
on public.animales
for each row execute function public.validar_categoria_animal()
""",
)

_FUNCION_REGLAS_CATEGORIA = """
create or replace function public.validar_reglas_categoria()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
    v_incompatibles integer;
begin
    if new.sexo_permitido = old.sexo_permitido
       and new.permite_estado_reproductivo = old.permite_estado_reproductivo then
        return new;
    end if;

    select count(*)
      into v_incompatibles
      from public.animales a
     where a.categoria_id = new.id
       and a.deleted_at is null
       and (
            (new.sexo_permitido <> 'ambos' and a.sexo <> new.sexo_permitido)
            or (not new.permite_estado_reproductivo
                and a.estado_reproductivo in ('vacia', 'prenada'))
       );

    if v_incompatibles > 0 then
        -- Mensaje concatenado: DDL() de SQLAlchemy interpreta el signo de porcentaje.
        raise exception using
            errcode = 'check_violation',
            message = 'Hay ' || v_incompatibles
                || ' animal(es) que quedarían incompatibles con la categoría';
    end if;

    return new;
end;
$$
"""

_TRIGGERS_REGLAS_CATEGORIA = (
    "drop trigger if exists trg_categorias_reglas_compatibles on public.categorias",
    """
create trigger trg_categorias_reglas_compatibles
before update of sexo_permitido, permite_estado_reproductivo
on public.categorias
for each row execute function public.validar_reglas_categoria()
""",
)


def _lista_sql(valores: Sequence[str]) -> str:
    return ", ".join(f"'{v}'" for v in valores)


def _exigir_tablas_previas(connection: Connection) -> None:
    inspector = sa.inspect(connection)
    faltantes = [t for t in _TABLAS_REQUERIDAS if not inspector.has_table(t)]
    if faltantes:
        raise RuntimeError(
            "No se puede aplicar la migración: faltan las tablas "
            f"{', '.join(faltantes)}."
        )


def _agregar_columnas(connection: Connection) -> None:
    """Agrega las columnas como nullable para clasificar antes de endurecerlas."""
    inspector = sa.inspect(connection)
    categorias = {c["name"] for c in inspector.get_columns("categorias")}
    if "sexo_permitido" not in categorias:
        op.add_column(
            "categorias", sa.Column("sexo_permitido", sa.String(), nullable=True)
        )
    if "permite_estado_reproductivo" not in categorias:
        op.add_column(
            "categorias",
            sa.Column(
                "permite_estado_reproductivo",
                sa.Boolean(),
                server_default=sa.false(),
                nullable=False,
            ),
        )
    animales = {c["name"] for c in inspector.get_columns("animales")}
    if "estado_reproductivo" not in animales:
        op.add_column(
            "animales", sa.Column("estado_reproductivo", sa.String(), nullable=True)
        )


def _sembrar_catalogo_global(connection: Connection) -> None:
    """Crea las categorías globales que falten, ya clasificadas.

    Las que ya existen no se tocan acá: si están sin clasificar las completa
    ``_clasificar_categorias``.
    """
    for categoria_id, nombre, sexo, permite in _CATALOGO_GLOBAL:
        existe = connection.execute(
            sa.text("select 1 from categorias where id = :id"), {"id": categoria_id}
        ).first()
        if existe:
            continue
        connection.execute(
            sa.text(
                "insert into categorias (id, establecimiento_id, nombre,"
                " sexo_permitido, permite_estado_reproductivo, created_at,"
                " updated_at)"
                " values (:id, null, :nombre, :sexo, :permite,"
                " current_timestamp, current_timestamp)"
            ),
            {"id": categoria_id, "nombre": nombre, "sexo": sexo, "permite": permite},
        )


def _clasificar_categorias(connection: Connection) -> None:
    for categoria_id, (sexo, permite) in _CLASIFICACION.items():
        connection.execute(
            sa.text(
                "update categorias"
                " set sexo_permitido = :sexo, permite_estado_reproductivo = :permite"
                " where id = :id and sexo_permitido is null"
            ),
            {"id": categoria_id, "sexo": sexo, "permite": permite},
        )


def _exigir_categorias_clasificadas(connection: Connection) -> None:
    """Detiene la migración si alguna categoría no está en la clasificación."""
    sin_clasificar = connection.execute(
        sa.text(
            "select id, nombre from categorias"
            " where sexo_permitido is null order by nombre, id"
        )
    ).all()
    if sin_clasificar:
        detalle = ", ".join(f"{cid} ('{nombre}')" for cid, nombre in sin_clasificar)
        raise RuntimeError(
            "No se puede inferir qué sexo admite cada categoría: agregá a "
            f"_CLASIFICACION las categorías sin clasificar: {detalle}."
        )


def _exigir_animales_compatibles(connection: Connection) -> None:
    """Detiene la migración si la clasificación deja animales vivos inválidos.

    Crear los triggers con datos inválidos dejaría esos animales sin poder
    editarse: mejor resolverlos antes, a mano, sabiendo cuáles son.
    """
    incompatibles = connection.execute(
        sa.text(
            """
            select c.nombre, c.sexo_permitido, a.sexo, count(*)
              from animales a
              join categorias c on c.id = a.categoria_id
             where a.deleted_at is null
               and c.sexo_permitido <> 'ambos'
               and a.sexo <> c.sexo_permitido
             group by c.nombre, c.sexo_permitido, a.sexo
             order by c.nombre
            """
        )
    ).all()
    if incompatibles:
        detalle = ", ".join(
            f"{cantidad} {sexo}(s) en '{nombre}' ({permitido})"
            for nombre, permitido, sexo, cantidad in incompatibles
        )
        raise RuntimeError(
            "La clasificación de categorías deja animales con un sexo "
            f"incompatible: {detalle}. Reasignalos o corregí _CLASIFICACION."
        )


def _endurecer(connection: Connection) -> None:
    op.alter_column(
        "categorias", "sexo_permitido", existing_type=sa.String(), nullable=False
    )
    checks = (
        (
            _CK_SEXO_PERMITIDO,
            "categorias",
            f"sexo_permitido in ({_lista_sql(_SEXOS_PERMITIDOS)})",
        ),
        (
            _CK_ESTADO_REPRODUCTIVO,
            "animales",
            "estado_reproductivo is null"
            f" or estado_reproductivo in ({_lista_sql(_ESTADOS_REPRODUCTIVOS)})",
        ),
        (
            _CK_SOLO_HEMBRAS,
            "animales",
            "estado_reproductivo is null or sexo = 'hembra'",
        ),
    )
    inspector = sa.inspect(connection)
    for nombre, tabla, condicion in checks:
        existentes = {c["name"] for c in inspector.get_check_constraints(tabla)}
        if nombre not in existentes:
            op.create_check_constraint(nombre, tabla, condicion)


def _crear_triggers(connection: Connection) -> None:
    # plpgsql solo existe en Postgres; en otro motor la regla la sostiene el
    # service.
    if connection.dialect.name != "postgresql":
        return
    for sentencia in (
        _FUNCION_CATEGORIA_COMPATIBLE,
        *_TRIGGERS_CATEGORIA_COMPATIBLE,
        _FUNCION_REGLAS_CATEGORIA,
        *_TRIGGERS_REGLAS_CATEGORIA,
    ):
        connection.execute(sa.text(sentencia))


def upgrade() -> None:
    connection = op.get_bind()
    _exigir_tablas_previas(connection)
    _agregar_columnas(connection)
    _sembrar_catalogo_global(connection)
    _clasificar_categorias(connection)
    _exigir_categorias_clasificadas(connection)
    _exigir_animales_compatibles(connection)
    _endurecer(connection)
    _crear_triggers(connection)


def downgrade() -> None:
    """Quita reglas, triggers y columnas. El catálogo global sembrado se conserva:
    puede haber animales que ya lo referencian."""
    connection = op.get_bind()
    if connection.dialect.name == "postgresql":
        for sentencia in (
            "drop trigger if exists trg_animales_categoria_compatible"
            " on public.animales",
            "drop trigger if exists trg_categorias_reglas_compatibles"
            " on public.categorias",
            "drop function if exists public.validar_categoria_animal()",
            "drop function if exists public.validar_reglas_categoria()",
        ):
            connection.execute(sa.text(sentencia))

    inspector = sa.inspect(connection)
    for nombre, tabla in (
        (_CK_SOLO_HEMBRAS, "animales"),
        (_CK_ESTADO_REPRODUCTIVO, "animales"),
        (_CK_SEXO_PERMITIDO, "categorias"),
    ):
        if nombre in {c["name"] for c in inspector.get_check_constraints(tabla)}:
            op.drop_constraint(nombre, tabla, type_="check")

    for tabla, columna in (
        ("animales", "estado_reproductivo"),
        ("categorias", "permite_estado_reproductivo"),
        ("categorias", "sexo_permitido"),
    ):
        if columna in {c["name"] for c in inspector.get_columns(tabla)}:
            op.drop_column(tabla, columna)
