"""Garantías de la alimentación que solo Postgres puede probar (adr-0016).

El backfill de recursos, los triggers de pertenencia y el RLS sobre
``auth.uid()`` no existen en SQLite. La migración y el script espejo se aplican
sobre una base que reproduce el estado previo de Supabase: ``alimentos`` con su
forma heredada (sin sync ni categoría) y el catálogo original de recursos.

Se saltean si no está ``VITA_TEST_POSTGRES_URL`` (ver ``tests/postgres_helpers``).
"""

from contextlib import asynccontextmanager
from datetime import UTC, date, datetime
import hashlib
import os
from pathlib import Path
import subprocess
import sys
from uuid import UUID, uuid4

import asyncpg
import pytest
from sqlalchemy.ext.asyncio import create_async_engine
from sqlmodel import SQLModel

import api.modules  # noqa: F401  -- registra todas las tablas en la metadata
from tests.postgres_helpers import (
    base_temporal,
    como_usuario,
    instalar_auth_supabase,
    requiere_postgres,
    simular_privilegios_por_defecto,
    url_sqlalchemy,
)

pytestmark = [requiere_postgres, pytest.mark.anyio]

_BACKEND = Path(__file__).parent.parent
_SCRIPTS = _BACKEND / "scripts"
_SCRIPT_OBSERVACIONES = _SCRIPTS / "crear_observaciones_animales.sql"
_SCRIPT_RECURSOS = _SCRIPTS / "crear_recursos_forrajeros_por_periodo.sql"
_SCRIPT_ALIMENTACION = _SCRIPTS / "crear_alimentacion.sql"
_REVISION_PREVIA = "20261017_02"
_REVISION = "20261114_02"

_TABLAS_NUEVAS = {
    "alimentos",
    "lotes_recursos_forrajeros",
    "registros_alimentacion",
    "registros_alimentacion_animales",
}

_MIEMBRO = UUID("00000000-0000-0000-0000-00000000000a")
_AJENO = UUID("00000000-0000-0000-0000-00000000000d")
_CAMPO = UUID("00000000-0000-0000-0000-0000000000e1")
_CAMPO_AJENO = UUID("00000000-0000-0000-0000-0000000000e2")
_ALTA_LOTE = datetime(2026, 3, 15, 9, 30, tzinfo=UTC)

# ``alimentos`` como existía en Supabase antes de adoptarla.
_ALIMENTOS_HEREDADA = """
create table public.alimentos (
    id uuid primary key,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    establecimiento_id uuid,
    nombre varchar not null,
    valor_proteico numeric(6, 2),
    valor_vitaminico numeric(6, 2),
    costo_unitario numeric(14, 2),
    unidad varchar not null default 'kg'
)
"""
_CHECK_RECURSOS_PREVIO = (
    "alter table public.lotes drop constraint ck_lotes_recurso_forrajero_valido",
    "alter table public.lotes add constraint ck_lotes_recurso_forrajero_valido"
    " check (recurso_forrajero_codigo is null or recurso_forrajero_codigo in"
    " ('pasto_natural', 'alfalfa', 'sorgo', 'maiz', 'avena', 'otro'))",
)


async def _crear_esquema_previo(url: str) -> None:
    conexion = await asyncpg.connect(url)
    try:
        await conexion.execute(_ALIMENTOS_HEREDADA)
    finally:
        await conexion.close()

    engine = create_async_engine(url_sqlalchemy(url))
    tablas = [
        tabla
        for tabla in SQLModel.metadata.sorted_tables
        if tabla.name not in _TABLAS_NUEVAS
    ]
    try:
        async with engine.begin() as conn:
            await conn.run_sync(
                lambda sync: SQLModel.metadata.create_all(sync, tables=tablas)
            )
    finally:
        await engine.dispose()


def _alembic(url: str, *argumentos: str) -> subprocess.CompletedProcess:
    """Corre Alembic en un proceso aparte contra la base descartable del test."""
    assert "supabase" not in url, "Nunca correr estos tests contra Supabase"
    entorno = {**os.environ, "DATABASE_URL": url_sqlalchemy(url)}
    return subprocess.run(
        [sys.executable, "-m", "alembic", *argumentos],
        cwd=_BACKEND,
        env=entorno,
        capture_output=True,
        text=True,
        check=False,
    )


async def _sembrar(conexion: asyncpg.Connection) -> dict[str, UUID]:
    for indice, usuario in enumerate((_MIEMBRO, _AJENO)):
        await conexion.execute(
            "insert into usuarios (id, nombre, apellido, email, is_platform_admin)"
            " values ($1, 'Test', 'Sintético', $2, false)",
            usuario,
            f"usuario{indice}@example.test",
        )
    for campo, owner in ((_CAMPO, _MIEMBRO), (_CAMPO_AJENO, _AJENO)):
        await conexion.execute(
            "insert into establecimientos (id, owner_id, nombre) values ($1, $2, $3)",
            campo,
            owner,
            f"Campo {campo}",
        )
        await conexion.execute(
            "insert into usuarios_establecimientos"
            " (id, usuario_id, establecimiento_id, rol, activo)"
            " values ($1, $2, $3, 'employee', true)",
            uuid4(),
            owner,
            campo,
        )

    ids: dict[str, UUID] = {}
    lotes = {
        "con_recurso": (_CAMPO, "avena"),
        "sin_recurso": (_CAMPO, None),
        "ajeno": (_CAMPO_AJENO, "alfalfa"),
    }
    for indice, (nombre, (campo, recurso)) in enumerate(lotes.items()):
        ids[f"lote_{nombre}"] = uuid4()
        await conexion.execute(
            "insert into lotes (id, establecimiento_id, nombre, geometria_local,"
            " modo_geometria, superficie_ha, estado, tiene_agua,"
            " recurso_forrajero_codigo, created_at, updated_at)"
            " values ($1, $2, $3, '{}'::jsonb, 'local_schematic', 10, 'activo',"
            " true, $4, $5, $5)",
            ids[f"lote_{nombre}"],
            campo,
            f"Lote {indice}",
            recurso,
            _ALTA_LOTE,
        )
    for nombre, campo in (("animal", _CAMPO), ("animal_ajeno", _CAMPO_AJENO)):
        ids[nombre] = uuid4()
        await conexion.execute(
            "insert into animales (id, establecimiento_id, sexo, estado)"
            " values ($1, $2, 'macho', 'activo')",
            ids[nombre],
            campo,
        )
    # Filas del catálogo heredado: una propia con unidad fuera del catálogo nuevo
    # (no debe trabar la adopción), una ajena y una global.
    for nombre, campo, unidad in (
        ("alimento_heredado", _CAMPO, "Kg"),
        ("alimento_ajeno", _CAMPO_AJENO, "kg"),
        ("alimento_global", None, "kg"),
    ):
        ids[nombre] = uuid4()
        await conexion.execute(
            "insert into alimentos (id, establecimiento_id, nombre, unidad)"
            " values ($1, $2, $3, $4)",
            ids[nombre],
            campo,
            nombre,
            unidad,
        )
    return ids


async def _materializar(url: str, camino: str) -> dict[str, UUID]:
    conexion = await asyncpg.connect(url)
    try:
        await instalar_auth_supabase(conexion)
        await simular_privilegios_por_defecto(conexion)
    finally:
        await conexion.close()

    await _crear_esquema_previo(url)
    conexion = await asyncpg.connect(url)
    try:
        for sentencia in _CHECK_RECURSOS_PREVIO:
            await conexion.execute(sentencia)
        # Estado real de Supabase: RLS sin policies en las tablas que leen los
        # triggers, y ``animal_pertenece_a_establecimiento`` ya creada.
        await conexion.execute("alter table animales enable row level security")
        await conexion.execute("alter table lotes enable row level security")
        await conexion.execute(_SCRIPT_OBSERVACIONES.read_text(encoding="utf-8"))
        ids = await _sembrar(conexion)
        if camino == "script":
            await conexion.execute(_SCRIPT_RECURSOS.read_text(encoding="utf-8"))
            await conexion.execute(_SCRIPT_ALIMENTACION.read_text(encoding="utf-8"))
    finally:
        await conexion.close()

    if camino == "migracion":
        assert _alembic(url, "stamp", _REVISION_PREVIA).returncode == 0
        resultado = _alembic(url, "upgrade", _REVISION)
        assert resultado.returncode == 0, resultado.stderr
    return ids


@asynccontextmanager
async def _base(camino: str):
    async with base_temporal() as url:
        ids = await _materializar(url, camino)
        conexion = await asyncpg.connect(url)
        try:
            yield url, conexion, ids
        finally:
            await conexion.close()


async def _insertar_periodo(
    conexion,
    lote_id: UUID,
    *,
    establecimiento_id: UUID = _CAMPO,
    registrado_por_id: UUID | None = _MIEMBRO,
    fecha_desde: date = date(2026, 6, 1),
) -> UUID:
    periodo_id = uuid4()
    await conexion.execute(
        "insert into lotes_recursos_forrajeros (id, establecimiento_id, lote_id,"
        " recurso_forrajero_codigo, fecha_desde, registrado_por_id)"
        " values ($1, $2, $3, 'rastrojo_maiz', $4, $5)",
        periodo_id,
        establecimiento_id,
        lote_id,
        fecha_desde,
        registrado_por_id,
    )
    return periodo_id


async def _insertar_registro(
    conexion,
    alimento_id: UUID,
    *,
    establecimiento_id: UUID = _CAMPO,
    lote_id: UUID | None = None,
    responsable_id: UUID | None = _MIEMBRO,
) -> UUID:
    registro_id = uuid4()
    await conexion.execute(
        "insert into registros_alimentacion (id, establecimiento_id, tipo,"
        " alimento_id, lote_id, fecha_desde, cantidad, unidad, base_cantidad,"
        " responsable_id)"
        " values ($1, $2, 'suplemento', $3, $4, '2026-10-01', 2, 'kg',"
        " 'por_animal_dia', $5)",
        registro_id,
        establecimiento_id,
        alimento_id,
        lote_id,
        responsable_id,
    )
    return registro_id


async def _insertar_detalle(conexion, registro_id: UUID, animal_id: UUID) -> None:
    await conexion.execute(
        "insert into registros_alimentacion_animales"
        " (id, registro_alimentacion_id, animal_id) values ($1, $2, $3)",
        uuid4(),
        registro_id,
        animal_id,
    )


_CAMINOS = pytest.mark.parametrize("camino", ("migracion", "script"))


# ------------------------------------------------------------ backfill


@_CAMINOS
async def test_cada_lote_con_recurso_tiene_su_periodo_inicial(camino):
    async with _base(camino) as (_, conexion, ids):
        filas = await conexion.fetch(
            "select id, lote_id, recurso_forrajero_codigo, fecha_desde, fecha_hasta,"
            " registrado_por_id from lotes_recursos_forrajeros"
        )

    por_lote = {fila["lote_id"]: fila for fila in filas}
    assert set(por_lote) == {ids["lote_con_recurso"], ids["lote_ajeno"]}
    periodo = por_lote[ids["lote_con_recurso"]]
    assert periodo["recurso_forrajero_codigo"] == "avena"
    assert periodo["fecha_desde"] == _ALTA_LOTE.date()
    assert periodo["fecha_hasta"] is None
    assert periodo["registrado_por_id"] is None
    esperado = hashlib.md5(f"recurso_legacy:{ids['lote_con_recurso']}".encode())
    assert periodo["id"] == UUID(esperado.hexdigest())


@_CAMINOS
async def test_reejecutar_el_script_no_duplica(camino):
    """Migración y script generan los mismos ids: correr uno sobre el otro no
    agrega nada."""
    async with _base(camino) as (_, conexion, _ids):
        await conexion.execute(_SCRIPT_RECURSOS.read_text(encoding="utf-8"))
        await conexion.execute(_SCRIPT_ALIMENTACION.read_text(encoding="utf-8"))
        total = await conexion.fetchval(
            "select count(*) from lotes_recursos_forrajeros"
        )
    assert total == 2


@_CAMINOS
async def test_el_lote_acepta_el_catalogo_ampliado(camino):
    async with _base(camino) as (_, conexion, ids):
        await conexion.execute(
            "update lotes set recurso_forrajero_codigo = 'rastrojo_maiz' where id = $1",
            ids["lote_sin_recurso"],
        )
        with pytest.raises(asyncpg.CheckViolationError):
            await conexion.execute(
                "update lotes set recurso_forrajero_codigo = 'soja' where id = $1",
                ids["lote_sin_recurso"],
            )


async def test_la_migracion_tiene_downgrade():
    async with _base("migracion") as (url, conexion, ids):
        resultado = _alembic(url, "downgrade", _REVISION_PREVIA)
        assert resultado.returncode == 0, resultado.stderr
        existe = await conexion.fetchval(
            "select to_regclass('public.lotes_recursos_forrajeros') is not null"
        )
        assert existe is False
        # ``alimentos`` existía antes: se conserva.
        heredado = await conexion.fetchval(
            "select nombre from alimentos where id = $1", ids["alimento_heredado"]
        )
        assert heredado == "alimento_heredado"
        with pytest.raises(asyncpg.CheckViolationError):
            await conexion.execute(
                "update lotes set recurso_forrajero_codigo = 'rastrojo_maiz'"
                " where id = $1",
                ids["lote_sin_recurso"],
            )


# --------------------------------------------------- adopción de alimentos


@_CAMINOS
async def test_alimentos_heredados_se_conservan_y_los_nuevos_se_validan(camino):
    async with _base(camino) as (_, conexion, ids):
        heredado = await conexion.fetchrow(
            "select unidad, categoria, deleted_at from alimentos where id = $1",
            ids["alimento_heredado"],
        )
        with pytest.raises(asyncpg.CheckViolationError):
            await conexion.execute(
                "insert into alimentos (id, establecimiento_id, nombre, unidad)"
                " values ($1, $2, 'Nuevo', 'tonelada')",
                uuid4(),
                _CAMPO,
            )

    assert heredado["unidad"] == "Kg"
    assert heredado["categoria"] == "otro"
    assert heredado["deleted_at"] is None


@_CAMINOS
async def test_alimentos_rls_global_de_solo_lectura(camino):
    async with _base(camino) as (_, conexion, ids):
        async with como_usuario(conexion, _MIEMBRO) as cliente:
            visibles = {
                r["id"] for r in await cliente.fetch("select id from alimentos")
            }
        async with como_usuario(conexion, _MIEMBRO) as cliente:
            await cliente.execute(
                "insert into alimentos (id, establecimiento_id, nombre, creado_por_id)"
                " values ($1, $2, 'Maíz partido', $3)",
                uuid4(),
                _CAMPO,
                _MIEMBRO,
            )
        async with como_usuario(conexion, _MIEMBRO) as cliente:
            with pytest.raises(asyncpg.InsufficientPrivilegeError):
                await cliente.execute(
                    "insert into alimentos (id, nombre, creado_por_id)"
                    " values ($1, 'Global', $2)",
                    uuid4(),
                    _MIEMBRO,
                )
        async with como_usuario(conexion, _MIEMBRO) as cliente:
            editados = await cliente.execute(
                "update alimentos set nombre = 'Pisado' where id = $1",
                ids["alimento_global"],
            )

    assert visibles == {ids["alimento_heredado"], ids["alimento_global"]}
    assert editados == "UPDATE 0"


@_CAMINOS
@pytest.mark.parametrize(
    "tabla",
    sorted(_TABLAS_NUEVAS),
)
async def test_anon_no_tiene_permisos(camino, tabla):
    async with _base(camino) as (_, conexion, _ids):
        async with como_usuario(conexion, None) as cliente:
            with pytest.raises(asyncpg.InsufficientPrivilegeError):
                await cliente.fetch(f"select * from {tabla}")


# ------------------------------------------------------ períodos de recurso


@_CAMINOS
async def test_periodo_rls_miembro_escribe_como_si_mismo(camino):
    async with _base(camino) as (_, conexion, ids):
        async with como_usuario(conexion, _MIEMBRO) as cliente:
            await _insertar_periodo(cliente, ids["lote_con_recurso"])
        async with como_usuario(conexion, _MIEMBRO) as cliente:
            with pytest.raises(asyncpg.InsufficientPrivilegeError):
                await _insertar_periodo(
                    cliente, ids["lote_con_recurso"], registrado_por_id=_AJENO
                )
        async with como_usuario(conexion, _MIEMBRO) as cliente:
            with pytest.raises(asyncpg.InsufficientPrivilegeError):
                await _insertar_periodo(
                    cliente, ids["lote_ajeno"], establecimiento_id=_CAMPO_AJENO
                )
        async with como_usuario(conexion, _AJENO) as cliente:
            vistos = {
                r["lote_id"]
                for r in await cliente.fetch(
                    "select lote_id from lotes_recursos_forrajeros"
                )
            }
    assert vistos == {ids["lote_ajeno"]}


@_CAMINOS
async def test_periodo_trigger_rechaza_lote_de_otro_campo(camino):
    async with _base(camino) as (_, conexion, ids):
        with pytest.raises(asyncpg.CheckViolationError):
            await _insertar_periodo(conexion, ids["lote_ajeno"])
        periodo = await _insertar_periodo(conexion, ids["lote_sin_recurso"])
        with pytest.raises(asyncpg.CheckViolationError):
            await conexion.execute(
                "update lotes_recursos_forrajeros set lote_id = $1 where id = $2",
                ids["lote_con_recurso"],
                periodo,
            )


@_CAMINOS
async def test_periodo_unico_por_lote_y_fecha_mientras_este_vigente(camino):
    async with _base(camino) as (_, conexion, ids):
        periodo = await _insertar_periodo(conexion, ids["lote_sin_recurso"])
        with pytest.raises(asyncpg.UniqueViolationError):
            await _insertar_periodo(conexion, ids["lote_sin_recurso"])
        await conexion.execute(
            "update lotes_recursos_forrajeros set deleted_at = now() where id = $1",
            periodo,
        )
        await _insertar_periodo(conexion, ids["lote_sin_recurso"])


# ------------------------------------------------- registros de alimentación


@_CAMINOS
async def test_registro_rls_miembro_registra_para_sus_animales(camino):
    async with _base(camino) as (_, conexion, ids):
        async with como_usuario(conexion, _MIEMBRO) as cliente:
            registro = await _insertar_registro(
                cliente, ids["alimento_heredado"], lote_id=ids["lote_con_recurso"]
            )
            await _insertar_detalle(cliente, registro, ids["animal"])
            with pytest.raises(asyncpg.InsufficientPrivilegeError):
                await _insertar_detalle(cliente, registro, ids["animal_ajeno"])

        async with como_usuario(conexion, _MIEMBRO) as cliente:
            with pytest.raises(asyncpg.InsufficientPrivilegeError):
                await _insertar_registro(
                    cliente, ids["alimento_heredado"], responsable_id=_AJENO
                )


@_CAMINOS
async def test_registro_ajeno_no_se_ve(camino):
    async with _base(camino) as (_, conexion, ids):
        registro = await _insertar_registro(conexion, ids["alimento_heredado"])
        await _insertar_detalle(conexion, registro, ids["animal"])
        async with como_usuario(conexion, _AJENO) as cliente:
            cabeceras = await cliente.fetch("select id from registros_alimentacion")
            detalle = await cliente.fetch(
                "select id from registros_alimentacion_animales"
            )
    assert cabeceras == []
    assert detalle == []


@_CAMINOS
async def test_registro_triggers_de_pertenencia(camino):
    async with _base(camino) as (_, conexion, ids):
        with pytest.raises(asyncpg.CheckViolationError):
            await _insertar_registro(conexion, ids["alimento_ajeno"])
        with pytest.raises(asyncpg.CheckViolationError):
            await _insertar_registro(
                conexion, ids["alimento_heredado"], lote_id=ids["lote_ajeno"]
            )
        # El catálogo global lo usa cualquiera.
        registro = await _insertar_registro(conexion, ids["alimento_global"])
        with pytest.raises(asyncpg.CheckViolationError):
            await _insertar_detalle(conexion, registro, ids["animal_ajeno"])
        with pytest.raises(asyncpg.CheckViolationError):
            await conexion.execute(
                "update registros_alimentacion set alimento_id = $1 where id = $2",
                ids["alimento_heredado"],
                registro,
            )
