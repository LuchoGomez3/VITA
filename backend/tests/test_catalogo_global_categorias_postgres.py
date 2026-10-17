"""Migración 20261014_01 contra un Postgres real: catálogo global (adr-0010).

Parte del estado que dejó VITA-173 (20261001_02) con los datos de prueba de
Supabase —categorías propias de un establecimiento con animales— y verifica la
transición por los dos caminos de producción: Alembic y el script espejo. El
esquema final (``create_all``) se prueba al final.
"""

from datetime import UTC, datetime
from pathlib import Path
from uuid import UUID

import asyncpg
import pytest
from sqlalchemy.ext.asyncio import create_async_engine
from sqlmodel import SQLModel

import api.modules  # noqa: F401  -- registra todas las tablas en la metadata
from tests.postgres_helpers import base_temporal, requiere_postgres, url_sqlalchemy
from tests.test_reglas_reproductivas_postgres import (
    _CAMPO,
    _CAMPO_AJENO,
    _ENGORDE,
    _G_NOVILLO,
    _G_TERNERA,
    _G_TERNERO,
    _G_TORO,
    _G_VACA,
    _G_VAQUILLONA,
    _alembic,
    _base,
    _insertar_animal,
    _sembrar_base,
)

pytestmark = [requiere_postgres, pytest.mark.anyio]

_SCRIPT_SQL = Path(__file__).parent.parent / "scripts/catalogo_global_categorias.sql"
_GLOBALES = {_G_TERNERA, _G_TERNERO, _G_VAQUILLONA, _G_VACA, _G_NOVILLO, _G_TORO}


async def _aplicar(url: str, conexion: asyncpg.Connection, camino: str) -> None:
    if camino == "migracion":
        resultado = _alembic(url, "upgrade", "head")
        assert resultado.returncode == 0, resultado.stderr
    else:
        await conexion.execute(_SCRIPT_SQL.read_text(encoding="utf-8"))


async def _columnas_categorias(conexion: asyncpg.Connection) -> set[str]:
    filas = await conexion.fetch(
        "select column_name from information_schema.columns"
        " where table_schema = 'public' and table_name = 'categorias'"
    )
    return {f["column_name"] for f in filas}


async def _categorias_por_animal(conexion: asyncpg.Connection) -> dict[str, int]:
    """Cantidad de animales por (nombre de categoría, sexo)."""
    filas = await conexion.fetch(
        "select coalesce(c.nombre, '(sin categoría)') as nombre, a.sexo, count(*)"
        " from animales a left join categorias c on c.id = a.categoria_id"
        " group by 1, 2"
    )
    return {f"{f['nombre']}/{f['sexo']}": f["count"] for f in filas}


@pytest.mark.parametrize("camino", ("migracion", "script"))
async def test_reasigna_los_animales_y_borra_la_columna(camino):
    async with _base(camino) as (url, conexion):
        # Engorde Rápido no tiene equivalente en el catálogo global.
        sin_equivalente = await _insertar_animal(conexion, "hembra", _ENGORDE)
        antes = datetime.now(UTC)

        await _aplicar(url, conexion, camino)

        assert "establecimiento_id" not in await _columnas_categorias(conexion)
        ids = {f["id"] for f in await conexion.fetch("select id from categorias")}
        assert ids == _GLOBALES
        # Las hembras del "Ternero" de prueba (admitía ambos sexos) van a Ternera.
        assert await _categorias_por_animal(conexion) == {
            "Ternera/hembra": 2,
            "Novillo/macho": 5,
            "Vaca/hembra": 4,
            "Toro/macho": 3,
            "(sin categoría)/hembra": 1,
        }
        assert (
            await conexion.fetchval(
                "select categoria_id from animales where id = $1", sin_equivalente
            )
            is None
        )
        # Todos cambiaron: la descarga delta tiene que propagarlos.
        assert (
            await conexion.fetchval(
                "select count(*) from animales where updated_at < $1", antes
            )
            == 0
        )


@pytest.mark.parametrize("camino", ("migracion", "script"))
async def test_una_categoria_global_se_asigna_en_cualquier_establecimiento(camino):
    async with _base(camino) as (url, conexion):
        await _aplicar(url, conexion, camino)

        for campo in (_CAMPO, _CAMPO_AJENO):
            animal = await _insertar_animal(
                conexion, "hembra", _G_VAQUILLONA, establecimiento_id=campo
            )
            assert animal is not None


@pytest.mark.parametrize("camino", ("migracion", "script"))
async def test_sigue_rechazando_una_categoria_borrada(camino):
    async with _base(camino) as (url, conexion):
        await _aplicar(url, conexion, camino)
        await conexion.execute(
            "update categorias set deleted_at = now() where id = $1", _G_TORO
        )

        with pytest.raises(asyncpg.CheckViolationError) as error:
            await _insertar_animal(conexion, "macho", _G_TORO)
        assert error.value.constraint_name == "animales_categoria_asignable"


async def test_el_script_es_reejecutable():
    async with _base("script") as (url, conexion):
        await _aplicar(url, conexion, "script")
        await _aplicar(url, conexion, "script")

        assert "establecimiento_id" not in await _columnas_categorias(conexion)
        assert await conexion.fetchval("select count(*) from categorias") == 6


async def test_la_migracion_tiene_downgrade():
    async with _base("migracion") as (url, conexion):
        await _aplicar(url, conexion, "migracion")

        resultado = _alembic(url, "downgrade", "20261001_03")
        assert resultado.returncode == 0, resultado.stderr

        assert "establecimiento_id" in await _columnas_categorias(conexion)
        funcion = await conexion.fetchval(
            "select prosrc from pg_proc where proname = 'validar_categoria_animal'"
        )
        assert "c.establecimiento_id" in funcion


async def test_create_all_arma_el_esquema_final():
    """``create_all`` (LOCAL/TEST) instala el trigger nuevo sin la columna."""
    async with base_temporal() as url:
        engine = create_async_engine(url_sqlalchemy(url))
        try:
            async with engine.begin() as conn:
                await conn.run_sync(SQLModel.metadata.create_all)
        finally:
            await engine.dispose()

        conexion = await asyncpg.connect(url)
        try:
            await _sembrar_base(conexion)
            assert "establecimiento_id" not in await _columnas_categorias(conexion)
            categoria = UUID("00000000-0000-0000-0000-0000000000c1")
            await conexion.execute(
                "insert into categorias (id, nombre, sexo_permitido,"
                " permite_estado_reproductivo) values ($1, 'Vaca', 'hembra', true)",
                categoria,
            )
            animal = await _insertar_animal(
                conexion,
                "hembra",
                categoria,
                estado_reproductivo="prenada",
                establecimiento_id=_CAMPO_AJENO,
            )
            assert animal is not None
        finally:
            await conexion.close()
