"""Coherencia estática de la migración 20261017_01 (personalización, adr-0011).

El comportamiento contra un Postgres real lo prueba
``test_personalizacion_perfil_postgres``.
"""

import importlib.util
from pathlib import Path
import re

import pytest

from api.modules.usuarios import models as usuarios_models
from api.modules.usuarios.models import Usuario

_BACKEND = Path(__file__).parent.parent
_MIGRACION = _BACKEND / "alembic/versions/20261017_01_personalizacion_perfil_usuario.py"
_SCRIPT_SQL = _BACKEND / "scripts/personalizacion_perfil_usuario.sql"


@pytest.fixture(scope="module")
def migracion():
    spec = importlib.util.spec_from_file_location("personalizacion_perfil", _MIGRACION)
    assert spec is not None and spec.loader is not None
    modulo = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(modulo)
    return modulo


@pytest.fixture(scope="module")
def script() -> str:
    return _SCRIPT_SQL.read_text(encoding="utf-8")


def _normalizar(sql: str) -> str:
    return re.sub(r"\s+", " ", sql).strip().rstrip(";").lower()


def test_revision_y_encadenamiento(migracion):
    assert migracion.revision == "20261017_01"
    # Head de develop al crearla (catálogo global de categorías, adr-0010).
    assert migracion.down_revision == "20261014_01"


def test_el_check_es_copia_literal_del_modelo(migracion):
    assert migracion._CHECK_COLOR_CABECERA == usuarios_models.CHECK_COLOR_CABECERA
    checks = {
        c.name: str(c.sqltext)
        for c in Usuario.__table__.constraints
        if c.name == migracion._CHECK
    }
    assert checks == {migracion._CHECK: migracion._CHECK_COLOR_CABECERA}


def test_el_modelo_declara_las_columnas_nuevas():
    columnas = Usuario.__table__.columns
    assert columnas["color_cabecera"].type.length == 7
    assert columnas["color_cabecera"].nullable
    # Con zona horaria: create_all la crearía sin zona si no se declara.
    assert columnas["avatar_actualizado_en"].type.timezone is True
    assert columnas["avatar_actualizado_en"].nullable


def test_el_script_espejo_hace_lo_mismo_que_la_migracion(migracion, script):
    normalizado = _normalizar(script)
    assert "add column if not exists color_cabecera varchar(7)" in normalizado
    assert (
        "add column if not exists avatar_actualizado_en timestamp with time zone"
        in normalizado
    )
    assert f"drop constraint if exists {migracion._CHECK}" in normalizado
    assert (
        _normalizar(
            f"add constraint {migracion._CHECK} check ({migracion._CHECK_COLOR_CABECERA})"
        )
        in normalizado
    )


def test_el_script_es_una_transaccion(script):
    lineas = [
        linea for linea in script.splitlines() if linea and not linea.startswith("--")
    ]
    assert lineas[0] == "begin;"
    assert lineas[-1] == "commit;"


def test_sin_porcentajes_en_el_ddl(migracion, script):
    """``DDL()`` de SQLAlchemy formatea con ``%``: ni en el check ni en el script."""
    assert "%" not in migracion._CHECK_COLOR_CABECERA
    assert "%" not in script
