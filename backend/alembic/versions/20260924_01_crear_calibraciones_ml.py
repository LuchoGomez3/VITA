"""Crea la tabla del dataset de calibración del modelo de visión.

Guarda los pares (foto lateral, peso real de balanza) que el móvil captura en el
"Modo Calibración" y sincroniza cuando recupera señal. Es una entidad
sincronizable más: PK UUID generada en el cliente, ``created_at`` /
``updated_at`` / ``deleted_at``, last-write-wins y borrado soft.

La foto NO vive acá: se guarda en un bucket privado de Storage y la tabla
conserva solo la **clave** del objeto (``imagen_key``). Una URL pública
expondría la imagen y una firmada vence, y el registro tiene que seguir
resolviendo la foto dentro de meses, cuando se reentrene el modelo.

Revision ID: 20260924_01
Revises: 20260910_02
Create Date: 2026-09-24
"""

from collections.abc import Sequence

from alembic import op
import sqlalchemy as sa
import sqlmodel
from sqlalchemy.engine import Connection

revision: str = "20260924_01"
down_revision: str | None = "20260910_02"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None

_TABLA = "calibraciones_ml"
_TABLAS_REQUERIDAS = ("establecimientos", "animales", "usuarios")

# La migración conserva su allowlist inmutable. Un estado nuevo en
# ``EstadoMuestraCalibracion`` exige una migración que lo agregue de forma
# explícita, en vez de colarse en silencio por una escritura directa.
_ESTADOS = ("pendiente_imagen", "completa", "descartada")
_ESTADOS_SQL = ", ".join(f"'{estado}'" for estado in _ESTADOS)

# (nombre, columnas, único)
_INDICES = (
    ("ix_calibraciones_ml_establecimiento_id", ["establecimiento_id"], False),
    ("ix_calibraciones_ml_animal_id", ["animal_id"], False),
    # Sostiene la descarga delta del cliente offline (``updated_since``).
    ("ix_calibraciones_ml_sync", ["establecimiento_id", "updated_at"], False),
    # Dos filas no pueden apuntar al mismo objeto de Storage: la clave se deriva
    # del UUID de la muestra, así que un duplicado significaría que algo pisó el
    # dataset de otra muestra.
    ("ix_calibraciones_ml_imagen_key", ["imagen_key"], True),
)

# Predicado de pertenencia al tenant, idéntico al del resto de las tablas.
_ES_MIEMBRO = """
    exists (
        select 1
        from public.usuarios_establecimientos ue
        where ue.establecimiento_id = calibraciones_ml.establecimiento_id
          and ue.usuario_id = auth.uid()
          and ue.activo = true
    )
"""


def _exigir_tablas_previas(connection: Connection) -> None:
    inspector = sa.inspect(connection)
    faltantes = [
        tabla for tabla in _TABLAS_REQUERIDAS if not inspector.has_table(tabla)
    ]
    if faltantes:
        raise RuntimeError(
            "No se puede crear calibraciones_ml: faltan las tablas "
            f"{', '.join(faltantes)} de las que depende."
        )


def _soporta_rls(connection: Connection) -> bool:
    if connection.dialect.name != "postgresql":
        return False
    return connection.execute(
        sa.text("select to_regprocedure('auth.uid()') is not null")
    ).scalar_one()


def _crear_tabla(connection: Connection) -> None:
    """Crea la tabla solo si no existe.

    Defensivo a propósito: el esquema de Supabase precede a Alembic y la app
    todavía puede crear tablas con ``create_all`` en LOCAL, así que la migración
    tiene que poder correr sobre una base que ya tiene el objeto.
    """
    if sa.inspect(connection).has_table(_TABLA):
        return

    op.create_table(
        _TABLA,
        sa.Column("id", sa.Uuid(), nullable=False),
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
        sa.Column("deleted_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("establecimiento_id", sa.Uuid(), nullable=False),
        sa.Column("animal_id", sa.Uuid(), nullable=False),
        sa.Column("peso_real_kg", sa.Numeric(10, 3), nullable=False),
        sa.Column("peso_estimado_kg", sa.Numeric(10, 3), nullable=True),
        sa.Column("fecha_captura", sa.DateTime(timezone=True), nullable=False),
        sa.Column("imagen_key", sqlmodel.sql.sqltypes.AutoString(), nullable=True),
        sa.Column("imagen_bytes", sa.Integer(), nullable=True),
        sa.Column("estado", sa.String(), nullable=False),
        sa.Column("responsable_id", sa.Uuid(), nullable=True),
        sa.Column("observaciones", sqlmodel.sql.sqltypes.AutoString(), nullable=True),
        sa.PrimaryKeyConstraint("id"),
        sa.ForeignKeyConstraint(["establecimiento_id"], ["establecimientos.id"]),
        sa.ForeignKeyConstraint(["animal_id"], ["animales.id"]),
        sa.ForeignKeyConstraint(["responsable_id"], ["usuarios.id"]),
        sa.CheckConstraint(
            f"estado in ({_ESTADOS_SQL})",
            name="ck_calibraciones_ml_estado_valido",
        ),
        sa.CheckConstraint(
            "peso_real_kg > 0", name="ck_calibraciones_ml_peso_real_positivo"
        ),
        sa.CheckConstraint(
            "peso_estimado_kg is null or peso_estimado_kg > 0",
            name="ck_calibraciones_ml_peso_estimado_positivo",
        ),
        # Una muestra completa es, por definición, la que tiene su objeto en
        # Storage. Sin esto, una escritura directa podría marcar ``completa`` una
        # fila sin imagen y colarla en el dataset de entrenamiento.
        sa.CheckConstraint(
            "estado <> 'completa' or imagen_key is not null",
            name="ck_calibraciones_ml_completa_exige_imagen",
        ),
        sa.CheckConstraint(
            "imagen_bytes is null or imagen_bytes > 0",
            name="ck_calibraciones_ml_imagen_bytes_positivo",
        ),
    )


def _crear_indices(connection: Connection) -> None:
    existentes = {
        indice["name"] for indice in sa.inspect(connection).get_indexes(_TABLA)
    }
    for nombre, columnas, unico in _INDICES:
        if nombre not in existentes:
            op.create_index(nombre, _TABLA, columnas, unique=unico)


def _aplicar_rls(connection: Connection) -> None:
    """Aísla el dataset por establecimiento también del lado de la base.

    El backend entra con un rol que no es ``authenticated``, así que estas
    políticas no gobiernan su tráfico: cubren el acceso directo vía la API de
    Supabase, que es la vía por la que un cliente podría leer las muestras de
    otro productor. No se habilita ninguna política de ``delete`` porque el
    borrado es soft (``deleted_at``) y ya queda cubierto por la de ``update``.
    """
    es_miembro = _ES_MIEMBRO

    sentencias = [
        f"alter table public.{_TABLA} enable row level security",
        f"drop policy if exists calibraciones_ml_select_miembros on public.{_TABLA}",
        f"""
        create policy calibraciones_ml_select_miembros on public.{_TABLA}
        for select to authenticated
        using ({es_miembro})
        """,
        f"drop policy if exists calibraciones_ml_insert_miembros on public.{_TABLA}",
        f"""
        create policy calibraciones_ml_insert_miembros on public.{_TABLA}
        for insert to authenticated
        with check (responsable_id = auth.uid() and {es_miembro})
        """,
        f"drop policy if exists calibraciones_ml_update_miembros on public.{_TABLA}",
        f"""
        create policy calibraciones_ml_update_miembros on public.{_TABLA}
        for update to authenticated
        using ({es_miembro})
        with check ({es_miembro})
        """,
    ]
    for sentencia in sentencias:
        connection.execute(sa.text(sentencia))


def upgrade() -> None:
    connection = op.get_bind()
    _exigir_tablas_previas(connection)
    _crear_tabla(connection)
    _crear_indices(connection)
    if _soporta_rls(connection):
        _aplicar_rls(connection)


def downgrade() -> None:
    connection = op.get_bind()
    if not sa.inspect(connection).has_table(_TABLA):
        return
    if _soporta_rls(connection):
        for politica in (
            "calibraciones_ml_select_miembros",
            "calibraciones_ml_insert_miembros",
            "calibraciones_ml_update_miembros",
        ):
            connection.execute(
                sa.text(f"drop policy if exists {politica} on public.{_TABLA}")
            )
    # Los índices y las FKs caen con la tabla; no hace falta soltarlos aparte.
    op.drop_table(_TABLA)
