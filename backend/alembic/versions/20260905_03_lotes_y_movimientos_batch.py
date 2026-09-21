"""Completa el modelo de lote y reestructura el movimiento como operación batch.

Dos cambios que habilitan la sincronización offline-first de la gestión de lotes:

1. ``lotes`` gana la geometría esquemática, el estado operativo, el recurso
   forrajero y la disponibilidad de agua que el cliente ya administra localmente,
   más la unicidad de nombre por establecimiento y el índice de descarga delta.
2. ``movimientos_lote`` (una fila por animal) se reemplaza por el agregado
   ``movimientos_lotes`` + ``movimientos_lotes_animales``. El cliente crea *una*
   operación con N animales y le asigna *un* UUID; ese UUID es la clave de
   idempotencia y necesita ser PK de una sola fila, cosa imposible en el modelo
   anterior. La tabla vieja está vacía y nada la referencia, así que se descarta
   sin migrar datos.

Revision ID: 20260905_03
Revises: 20260902_02
Create Date: 2026-09-05
"""

from collections.abc import Sequence
import json

from alembic import op
import sqlalchemy as sa
import sqlmodel
from sqlalchemy.engine import Connection

revision: str = "20260905_03"
down_revision: str | None = "20260902_02"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None

_LOTES = "lotes"
_MOVIMIENTOS_VIEJA = "movimientos_lote"
_MOVIMIENTOS = "movimientos_lotes"
_MOVIMIENTOS_ANIMALES = "movimientos_lotes_animales"
_TABLAS_REQUERIDAS = ("establecimientos", "usuarios", "animales", "lotes")

_ESTADOS = ("activo", "descanso", "mantenimiento", "inactivo")
_RECURSOS_FORRAJEROS = (
    "pasto_natural",
    "alfalfa",
    "sorgo",
    "maiz",
    "avena",
    "otro",
)

_MODO_GEOMETRIA_LOCAL = "local_schematic"
_ESPACIO_COORDENADAS = "establishment_canvas_v1"
_EXTENSION_LIENZO = 1000.0

# Grilla del backfill: 4 columnas de celdas de 245 con lados de 225, lo que deja
# 20 de separación entre lotes y los mantiene dentro del lienzo de 1000x1000.
_GRILLA_COLUMNAS = 4
_GRILLA_PASO = 245.0
_GRILLA_LADO = 225.0
_GRILLA_MARGEN = 20.0

# (nombre, tabla, columnas)
_INDICES = (
    # Sostiene la descarga delta del cliente offline (``updated_since``).
    ("ix_lotes_sync", _LOTES, ["establecimiento_id", "updated_at"]),
    ("ix_movimientos_lotes_establecimiento_id", _MOVIMIENTOS, ["establecimiento_id"]),
    ("ix_movimientos_lotes_lote_origen_id", _MOVIMIENTOS, ["lote_origen_id"]),
    ("ix_movimientos_lotes_lote_destino_id", _MOVIMIENTOS, ["lote_destino_id"]),
    ("ix_movimientos_lotes_sync", _MOVIMIENTOS, ["establecimiento_id", "updated_at"]),
    (
        "ix_movimientos_lotes_animales_movimiento_lote_id",
        _MOVIMIENTOS_ANIMALES,
        ["movimiento_lote_id"],
    ),
    # Responde "¿por qué lotes pasó este animal?" al armar su historial.
    (
        "ix_movimientos_lotes_animales_animal_id",
        _MOVIMIENTOS_ANIMALES,
        ["animal_id"],
    ),
)

_UQ_NOMBRE = "uq_lotes_nombre_establecimiento"

# Predicado de pertenencia al tenant, idéntico al del resto de las tablas.
_ES_MIEMBRO = """
    exists (
        select 1
        from public.usuarios_establecimientos ue
        where ue.establecimiento_id = {tabla}.establecimiento_id
          and ue.usuario_id = auth.uid()
          and ue.activo = true
    )
"""

_ES_MIEMBRO_DEL_MOVIMIENTO = """
    exists (
        select 1
        from public.movimientos_lotes m
        join public.usuarios_establecimientos ue
          on ue.establecimiento_id = m.establecimiento_id
        where m.id = movimientos_lotes_animales.movimiento_lote_id
          and ue.usuario_id = auth.uid()
          and ue.activo = true
    )
"""


def _exigir_tablas_previas(connection: Connection) -> None:
    inspector = sa.inspect(connection)
    faltantes = [t for t in _TABLAS_REQUERIDAS if not inspector.has_table(t)]
    if faltantes:
        raise RuntimeError(
            "No se puede aplicar la migración: faltan las tablas "
            f"{', '.join(faltantes)} de las que dependen lotes y movimientos."
        )


def _lista_sql(valores: Sequence[str]) -> str:
    return ", ".join(f"'{v}'" for v in valores)


# --------------------------------------------------------------------- lotes


def _agregar_columnas_lotes(connection: Connection) -> None:
    """Agrega las columnas nuevas como nullable para poder rellenarlas después."""
    existentes = {c["name"] for c in sa.inspect(connection).get_columns(_LOTES)}
    nuevas = (
        sa.Column("geometria_local", sa.JSON(), nullable=True),
        sa.Column("modo_geometria", sqlmodel.sql.sqltypes.AutoString(), nullable=True),
        sa.Column("recurso_forrajero_codigo", sa.String(), nullable=True),
        sa.Column("tiene_agua", sa.Boolean(), nullable=True),
        sa.Column("estado", sa.String(), nullable=True),
    )
    for columna in nuevas:
        if columna.name not in existentes:
            op.add_column(_LOTES, columna)


def _geometria_de_celda(indice: int) -> dict:
    """Cuadrado sin superposición en la posición ``indice`` de la grilla."""
    x0 = _GRILLA_MARGEN + (indice % _GRILLA_COLUMNAS) * _GRILLA_PASO
    y0 = _GRILLA_MARGEN + (indice // _GRILLA_COLUMNAS) * _GRILLA_PASO
    x1 = x0 + _GRILLA_LADO
    y1 = y0 + _GRILLA_LADO
    return {
        "type": "LocalPolygon",
        "coordinate_space": _ESPACIO_COORDENADAS,
        "version": 1,
        "extent": {"width": _EXTENSION_LIENZO, "height": _EXTENSION_LIENZO},
        # Sentido antihorario, primer vértice sin repetir al final.
        "vertices": [
            {"x": x0, "y": y0},
            {"x": x1, "y": y0},
            {"x": x1, "y": y1},
            {"x": x0, "y": y1},
        ],
    }


def _backfill_lotes(connection: Connection) -> None:
    """Rellena las columnas nuevas de los lotes que ya existían.

    La geometría es un **placeholder fabricado**: son filas anteriores al módulo
    y no tienen polígono dibujado. Dejarla en null no es opción — el cliente la
    castea de forma estricta y un lote sin geometría le rompe la deserialización.
    Se asignan cuadrados de una grilla, que por construcción no se superponen y
    respetan la invariante que el service exige de acá en adelante.
    """
    filas = connection.execute(
        sa.text(
            f"select id from {_LOTES}"
            " where geometria_local is null"
            " order by establecimiento_id, nombre, id"
        )
    ).all()

    for indice, (lote_id,) in enumerate(filas):
        connection.execute(
            sa.text(
                f"update {_LOTES} set geometria_local = :geometria where id = :lote_id"
            ),
            {"geometria": json.dumps(_geometria_de_celda(indice)), "lote_id": lote_id},
        )

    connection.execute(
        sa.text(
            f"""
            update {_LOTES}
               set modo_geometria = coalesce(modo_geometria, :modo),
                   tiene_agua = coalesce(tiene_agua, false),
                   estado = coalesce(estado, 'activo')
            """
        ),
        {"modo": _MODO_GEOMETRIA_LOCAL},
    )

    # La superficie pasa a ser obligatoria y con un decimal de precisión, que es
    # como el cliente la administra (décimas exactas de hectárea).
    connection.execute(
        sa.text(
            f"""
            update {_LOTES}
               set superficie_ha = case
                     when superficie_ha is null or superficie_ha <= 0 then 1.0
                     else round(superficie_ha, 1)
                   end
            """
        )
    )


def _endurecer_lotes(connection: Connection) -> None:
    """Aplica NOT NULL y los CHECK una vez que los datos ya son consistentes."""
    for columna, tipo in (
        ("geometria_local", sa.JSON()),
        ("modo_geometria", sqlmodel.sql.sqltypes.AutoString()),
        ("tiene_agua", sa.Boolean()),
        ("estado", sa.String()),
        ("superficie_ha", sa.Numeric(precision=12, scale=2)),
    ):
        op.alter_column(_LOTES, columna, existing_type=tipo, nullable=False)

    if connection.dialect.name == "postgresql":
        # JSONB es indexable y comparable; JSON no. La conversión es segura
        # porque todo el contenido lo escribió esta misma migración o el service.
        op.execute(
            f"alter table public.{_LOTES}"
            " alter column geometria_local type jsonb using geometria_local::jsonb"
        )

    checks = (
        ("ck_lotes_estado_valido", f"estado in ({_lista_sql(_ESTADOS)})"),
        (
            "ck_lotes_recurso_forrajero_valido",
            "recurso_forrajero_codigo is null or recurso_forrajero_codigo in "
            f"({_lista_sql(_RECURSOS_FORRAJEROS)})",
        ),
        ("ck_lotes_superficie_positiva", "superficie_ha > 0"),
        ("ck_lotes_nombre_no_vacio", "trim(nombre) <> ''"),
    )
    existentes = {
        c["name"] for c in sa.inspect(connection).get_check_constraints(_LOTES)
    }
    for nombre, condicion in checks:
        if nombre not in existentes:
            op.create_check_constraint(nombre, _LOTES, condicion)


def _crear_unicidad_nombre(connection: Connection) -> None:
    """Unicidad de nombre normalizada y compatible con el borrado lógico.

    Es un índice de expresión parcial: ``lower(btrim(nombre))`` para que
    "Potrero Bajo" y " potrero bajo " colisionen, y ``where deleted_at is null``
    para que borrar un lote libere su nombre. Solo se crea en Postgres — es la
    base real; los tests corren sobre SQLite, donde la unicidad la sostiene la
    verificación del service.
    """
    if connection.dialect.name != "postgresql":
        return

    duplicados = connection.execute(
        sa.text(
            f"""
            select establecimiento_id, lower(btrim(nombre)) as nombre_normalizado
              from public.{_LOTES}
             where deleted_at is null
             group by establecimiento_id, lower(btrim(nombre))
            having count(*) > 1
            """
        )
    ).all()
    if duplicados:
        detalle = ", ".join(f"{est}: '{nombre}'" for est, nombre in duplicados)
        raise RuntimeError(
            "No se puede crear la unicidad de nombre de lote: hay duplicados "
            f"preexistentes que hay que resolver a mano ({detalle})."
        )

    op.execute(
        f"create unique index if not exists {_UQ_NOMBRE}"
        f" on public.{_LOTES} (establecimiento_id, lower(btrim(nombre)))"
        " where deleted_at is null"
    )


# --------------------------------------------------------------- movimientos


def _crear_movimientos() -> None:
    op.create_table(
        _MOVIMIENTOS,
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column(
            "created_at",
            sa.DateTime(timezone=True),
            server_default=sa.text("now()"),
            nullable=False,
        ),
        sa.Column(
            "updated_at",
            sa.DateTime(timezone=True),
            server_default=sa.text("now()"),
            nullable=False,
        ),
        sa.Column("deleted_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("establecimiento_id", sa.Uuid(), nullable=False),
        sa.Column("lote_origen_id", sa.Uuid(), nullable=True),
        sa.Column("lote_destino_id", sa.Uuid(), nullable=False),
        sa.Column("fecha_movimiento", sa.DateTime(timezone=True), nullable=False),
        sa.Column("motivo", sqlmodel.sql.sqltypes.AutoString(), nullable=True),
        sa.Column("responsable_id", sa.Uuid(), nullable=True),
        sa.CheckConstraint(
            "lote_origen_id is null or lote_origen_id <> lote_destino_id",
            name="ck_movimientos_lotes_origen_distinto_destino",
        ),
        sa.ForeignKeyConstraint(["establecimiento_id"], ["establecimientos.id"]),
        sa.ForeignKeyConstraint(["lote_origen_id"], ["lotes.id"]),
        sa.ForeignKeyConstraint(["lote_destino_id"], ["lotes.id"]),
        sa.ForeignKeyConstraint(["responsable_id"], ["usuarios.id"]),
        sa.PrimaryKeyConstraint("id"),
    )


def _crear_movimientos_animales() -> None:
    op.create_table(
        _MOVIMIENTOS_ANIMALES,
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column(
            "created_at",
            sa.DateTime(timezone=True),
            server_default=sa.text("now()"),
            nullable=False,
        ),
        sa.Column(
            "updated_at",
            sa.DateTime(timezone=True),
            server_default=sa.text("now()"),
            nullable=False,
        ),
        sa.Column("movimiento_lote_id", sa.Uuid(), nullable=False),
        sa.Column("animal_id", sa.Uuid(), nullable=False),
        sa.ForeignKeyConstraint(["movimiento_lote_id"], ["movimientos_lotes.id"]),
        sa.ForeignKeyConstraint(["animal_id"], ["animales.id"]),
        sa.PrimaryKeyConstraint("id"),
        # Impide que un replay mal resuelto duplique el detalle del movimiento.
        sa.UniqueConstraint(
            "movimiento_lote_id", "animal_id", name="uq_movimiento_lote_animal"
        ),
    )


def _descartar_tabla_vieja(connection: Connection) -> None:
    """Elimina ``movimientos_lote``, la tabla de una fila por animal.

    Se verifica que esté vacía antes de tocarla: si alguien alcanzó a cargar un
    movimiento con el modelo anterior, la migración se detiene en vez de borrar
    historial en silencio.
    """
    tablas = set(sa.inspect(connection).get_table_names())
    if _MOVIMIENTOS_VIEJA not in tablas:
        return

    filas = connection.execute(
        sa.text(f"select count(*) from {_MOVIMIENTOS_VIEJA}")
    ).scalar_one()
    if filas:
        raise RuntimeError(
            f"'{_MOVIMIENTOS_VIEJA}' tiene {filas} fila(s). La migración al modelo "
            "de cabecera + detalle asume que está vacía; migrarlas requiere "
            "decidir cómo agrupar las filas sueltas en operaciones."
        )
    op.drop_table(_MOVIMIENTOS_VIEJA)


# ------------------------------------------------------------ índices y RLS


def _crear_indices_faltantes(connection: Connection) -> None:
    inspector = sa.inspect(connection)
    for nombre, tabla, columnas in _INDICES:
        existentes = {i["name"] for i in inspector.get_indexes(tabla)}
        if nombre not in existentes:
            op.create_index(nombre, tabla, columnas, unique=False)


def _soporta_rls(connection: Connection) -> bool:
    """Indica si la base es un Postgres con Supabase Auth disponible.

    Las políticas se apoyan en ``auth.uid()``, que solo existe en Supabase. Un
    Postgres de desarrollo no la tiene y la migración debe seguir aplicándose:
    ahí el aislamiento por tenant lo garantiza el service, que filtra por
    membresía en toda consulta.
    """
    if connection.dialect.name != "postgresql":
        return False
    return connection.execute(
        sa.text("select to_regprocedure('auth.uid()') is not null")
    ).scalar_one()


def _aplicar_rls(connection: Connection) -> None:
    if not _soporta_rls(connection):
        return

    lotes_es_miembro = _ES_MIEMBRO.format(tabla="lotes")
    movimientos_es_miembro = _ES_MIEMBRO.format(tabla="movimientos_lotes")

    sentencias = [
        f"alter table public.{_LOTES} enable row level security",
        f"alter table public.{_MOVIMIENTOS} enable row level security",
        f"alter table public.{_MOVIMIENTOS_ANIMALES} enable row level security",
        # -------------------------------------------------------------- lotes
        f"drop policy if exists lotes_select_miembros on public.{_LOTES}",
        f"""
        create policy lotes_select_miembros on public.{_LOTES}
        for select to authenticated
        using ({lotes_es_miembro})
        """,
        f"drop policy if exists lotes_insert_miembros on public.{_LOTES}",
        f"""
        create policy lotes_insert_miembros on public.{_LOTES}
        for insert to authenticated
        with check ({lotes_es_miembro})
        """,
        # El borrado es soft (``deleted_at``), así que se cubre con update y no
        # se habilita ninguna política de delete.
        f"drop policy if exists lotes_update_miembros on public.{_LOTES}",
        f"""
        create policy lotes_update_miembros on public.{_LOTES}
        for update to authenticated
        using ({lotes_es_miembro})
        with check ({lotes_es_miembro})
        """,
        # -------------------------------------------------------- movimientos
        f"drop policy if exists movimientos_lotes_select_miembros"
        f" on public.{_MOVIMIENTOS}",
        f"""
        create policy movimientos_lotes_select_miembros on public.{_MOVIMIENTOS}
        for select to authenticated
        using ({movimientos_es_miembro})
        """,
        f"drop policy if exists movimientos_lotes_insert_miembros"
        f" on public.{_MOVIMIENTOS}",
        f"""
        create policy movimientos_lotes_insert_miembros on public.{_MOVIMIENTOS}
        for insert to authenticated
        with check (
            responsable_id = auth.uid() and {movimientos_es_miembro}
        )
        """,
        f"drop policy if exists movimientos_lotes_update_miembros"
        f" on public.{_MOVIMIENTOS}",
        f"""
        create policy movimientos_lotes_update_miembros on public.{_MOVIMIENTOS}
        for update to authenticated
        using ({movimientos_es_miembro})
        with check ({movimientos_es_miembro})
        """,
        # ----------------------------------------------- detalle del agregado
        f"drop policy if exists movimientos_lotes_animales_select_miembros"
        f" on public.{_MOVIMIENTOS_ANIMALES}",
        f"""
        create policy movimientos_lotes_animales_select_miembros
        on public.{_MOVIMIENTOS_ANIMALES}
        for select to authenticated
        using ({_ES_MIEMBRO_DEL_MOVIMIENTO})
        """,
        f"drop policy if exists movimientos_lotes_animales_insert_miembros"
        f" on public.{_MOVIMIENTOS_ANIMALES}",
        f"""
        create policy movimientos_lotes_animales_insert_miembros
        on public.{_MOVIMIENTOS_ANIMALES}
        for insert to authenticated
        with check ({_ES_MIEMBRO_DEL_MOVIMIENTO})
        """,
        f"revoke all on public.{_LOTES} from anon",
        f"revoke all on public.{_MOVIMIENTOS} from anon",
        f"revoke all on public.{_MOVIMIENTOS_ANIMALES} from anon",
        f"grant select, insert, update on public.{_LOTES} to authenticated",
        f"grant select, insert, update on public.{_MOVIMIENTOS} to authenticated",
        # La composición se fija al crear el movimiento: no se edita ni se borra.
        f"grant select, insert on public.{_MOVIMIENTOS_ANIMALES} to authenticated",
    ]

    for sentencia in sentencias:
        connection.execute(sa.text(sentencia))


def upgrade() -> None:
    connection = op.get_bind()
    _exigir_tablas_previas(connection)

    _agregar_columnas_lotes(connection)
    _backfill_lotes(connection)
    _endurecer_lotes(connection)
    _crear_unicidad_nombre(connection)

    _descartar_tabla_vieja(connection)
    tablas = set(sa.inspect(connection).get_table_names())
    if _MOVIMIENTOS not in tablas:
        _crear_movimientos()
    if _MOVIMIENTOS_ANIMALES not in tablas:
        _crear_movimientos_animales()

    _crear_indices_faltantes(connection)
    _aplicar_rls(connection)


def downgrade() -> None:
    connection = op.get_bind()
    tablas = set(sa.inspect(connection).get_table_names())

    if _MOVIMIENTOS_ANIMALES in tablas:
        op.drop_table(_MOVIMIENTOS_ANIMALES)
    if _MOVIMIENTOS in tablas:
        op.drop_table(_MOVIMIENTOS)

    # No se recrea ``movimientos_lote``: quedó vacía y su modelo ya no existe en
    # el código. Volver a ella exigiría reintroducir la clase que se eliminó.

    if connection.dialect.name == "postgresql":
        op.execute(f"drop index if exists {_UQ_NOMBRE}")

    for nombre in (
        "ck_lotes_nombre_no_vacio",
        "ck_lotes_superficie_positiva",
        "ck_lotes_recurso_forrajero_valido",
        "ck_lotes_estado_valido",
    ):
        op.drop_constraint(nombre, _LOTES, type_="check")

    op.alter_column(
        _LOTES,
        "superficie_ha",
        existing_type=sa.Numeric(precision=12, scale=2),
        nullable=True,
    )
    for columna in (
        "estado",
        "tiene_agua",
        "recurso_forrajero_codigo",
        "modo_geometria",
        "geometria_local",
    ):
        op.drop_column(_LOTES, columna)
