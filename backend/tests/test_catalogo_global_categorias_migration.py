"""Coherencia estática de la migración 20261014_01 (catálogo global, adr-0010).

El comportamiento contra un Postgres real lo prueba
``test_catalogo_global_categorias_postgres``.
"""

import importlib.util
from pathlib import Path
import re

import pytest

from api.modules.animales import models as animales_models
from api.modules.categorias.models import Categoria

_BACKEND = Path(__file__).parent.parent
_MIGRACION = _BACKEND / "alembic/versions/20261014_01_catalogo_global_categorias.py"
_SCRIPT_SQL = _BACKEND / "scripts/catalogo_global_categorias.sql"


@pytest.fixture(scope="module")
def migracion():
    spec = importlib.util.spec_from_file_location("catalogo_global", _MIGRACION)
    assert spec is not None and spec.loader is not None
    modulo = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(modulo)
    return modulo


@pytest.fixture(scope="module")
def script() -> str:
    return _SCRIPT_SQL.read_text(encoding="utf-8")


def _normalizar(sql: str) -> str:
    return re.sub(r"\s+", " ", sql).strip().rstrip(";")


def test_revision_y_encadenamiento(migracion):
    assert migracion.revision == "20261014_01"
    # Head de develop al crearla (observaciones, VITA-173).
    assert migracion.down_revision == "20261001_03"


def test_la_funcion_del_trigger_es_copia_literal_del_modelo(migracion):
    assert (
        migracion._FUNCION_CATEGORIA_COMPATIBLE
        == animales_models.FUNCION_CATEGORIA_COMPATIBLE
    )


def test_la_funcion_nueva_no_lee_el_establecimiento_de_la_categoria(migracion):
    """Se reemplaza antes de borrar la columna: plpgsql la resolvería recién al
    ejecutar y el trigger fallaría en cada alta de animal."""
    assert "establecimiento_id" not in migracion._FUNCION_CATEGORIA_COMPATIBLE
    assert "c.establecimiento_id" in migracion._FUNCION_CATEGORIA_COMPATIBLE_ANTERIOR


def test_el_modelo_ya_no_tiene_establecimiento():
    assert "establecimiento_id" not in Categoria.__table__.columns


def test_el_script_espejo_hace_lo_mismo_que_la_migracion(migracion, script):
    normalizado = _normalizar(script)
    for sentencia in (
        migracion._REASIGNAR_A_GLOBAL,
        migracion._DEJAR_SIN_CATEGORIA,
        migracion._BORRAR_CATEGORIAS_PROPIAS,
        migracion._FUNCION_CATEGORIA_COMPATIBLE,
    ):
        assert _normalizar(sentencia) in normalizado
    assert f"drop index if exists public.{migracion._INDICE}" in normalizado
    assert f"drop constraint if exists {migracion._FK}" in normalizado
    assert "drop column if exists establecimiento_id" in normalizado


def test_el_script_reemplaza_la_funcion_antes_de_borrar_la_columna(migracion, script):
    normalizado = _normalizar(script)
    assert normalizado.index(
        _normalizar(migracion._FUNCION_CATEGORIA_COMPATIBLE)
    ) < normalizado.index("drop column if exists establecimiento_id")


def test_el_script_es_una_transaccion(script):
    lineas = [
        linea for linea in script.splitlines() if linea and not linea.startswith("--")
    ]
    assert lineas[0] == "begin;"
    assert lineas[-1] == "commit;"
