"""Migración 20261017_01 contra un Postgres real (adr-0011).

Parte de ``usuarios`` como estaba antes (sin las columnas nuevas) y verifica los
dos caminos de producción, Alembic y el script espejo, más el esquema final de
``create_all``.
"""

from pathlib import Path
from uuid import uuid4

import asyncpg
import pytest
from sqlalchemy.ext.asyncio import create_async_engine
from sqlmodel import SQLModel

import api.modules  # noqa: F401  -- registra todas las tablas en la metadata
from tests.postgres_helpers import base_temporal, requiere_postgres, url_sqlalchemy
from tests.test_reglas_reproductivas_postgres import _alembic

pytestmark = [requiere_postgres, pytest.mark.anyio]

_SCRIPT_SQL = (
    Path(__file__).parent.parent / "scripts/personalizacion_perfil_usuario.sql"
)
_REVISION_PREVIA = "20261014_01"

# ``usuarios`` antes de la migración, con lo mínimo para insertar.
_USUARIOS_PREVIO = """
create table usuarios (
    id uuid primary key,
    nombre varchar not null,
    apellido varchar not null,
    email varchar not null,
    cuit varchar,
    telefono varchar,
    is_platform_admin boolean not null default false,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
)
"""


async def _aplicar(url: str, camino: str) -> None:
    conexion = await asyncpg.connect(url)
    try:
        await conexion.execute(_USUARIOS_PREVIO)
        if camino == "script":
            await conexion.execute(_SCRIPT_SQL.read_text(encoding="utf-8"))
            return
    finally:
        await conexion.close()
    assert _alembic(url, "stamp", _REVISION_PREVIA).returncode == 0
    resultado = _alembic(url, "upgrade", "20261017_01")
    assert resultado.returncode == 0, resultado.stderr


async def _tipos(conexion: asyncpg.Connection) -> dict[str, str]:
    filas = await conexion.fetch(
        "select column_name, data_type from information_schema.columns"
        " where table_schema = 'public' and table_name = 'usuarios'"
    )
    return {f["column_name"]: f["data_type"] for f in filas}


async def _insertar(conexion: asyncpg.Connection, color: str | None) -> None:
    await conexion.execute(
        "insert into usuarios"
        " (id, nombre, apellido, email, is_platform_admin, color_cabecera)"
        " values ($1, 'Test', 'Sintético', $2, false, $3)",
        uuid4(),
        f"{uuid4().hex}@example.test",
        color,
    )


async def _verificar_esquema(conexion: asyncpg.Connection) -> None:
    tipos = await _tipos(conexion)
    assert tipos["color_cabecera"] == "character varying"
    assert tipos["avatar_actualizado_en"] == "timestamp with time zone"
    for valido in (None, "#2E7D32", "#000000", "#FFFFFF"):
        await _insertar(conexion, valido)
    for invalido in ("#2e7d32", "#12345", "verde", "#GG0000", "2E7D32A"):
        with pytest.raises(asyncpg.CheckViolationError) as error:
            await _insertar(conexion, invalido)
        assert error.value.constraint_name == "ck_usuarios_color_cabecera"


@pytest.mark.parametrize("camino", ("migracion", "script"))
async def test_agrega_las_columnas_y_el_check(camino):
    async with base_temporal() as url:
        await _aplicar(url, camino)
        conexion = await asyncpg.connect(url)
        try:
            await _verificar_esquema(conexion)
        finally:
            await conexion.close()


async def test_el_script_es_reejecutable():
    async with base_temporal() as url:
        await _aplicar(url, "script")
        conexion = await asyncpg.connect(url)
        try:
            await conexion.execute(_SCRIPT_SQL.read_text(encoding="utf-8"))
            await _verificar_esquema(conexion)
        finally:
            await conexion.close()


async def test_la_migracion_tiene_downgrade():
    async with base_temporal() as url:
        await _aplicar(url, "migracion")
        resultado = _alembic(url, "downgrade", _REVISION_PREVIA)
        assert resultado.returncode == 0, resultado.stderr
        conexion = await asyncpg.connect(url)
        try:
            tipos = await _tipos(conexion)
        finally:
            await conexion.close()
        assert "color_cabecera" not in tipos
        assert "avatar_actualizado_en" not in tipos


async def test_create_all_arma_el_esquema_final():
    async with base_temporal() as url:
        engine = create_async_engine(url_sqlalchemy(url))
        try:
            async with engine.begin() as conn:
                await conn.run_sync(SQLModel.metadata.create_all)
        finally:
            await engine.dispose()
        conexion = await asyncpg.connect(url)
        try:
            await _verificar_esquema(conexion)
        finally:
            await conexion.close()
