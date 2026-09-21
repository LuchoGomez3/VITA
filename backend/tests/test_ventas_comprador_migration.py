"""Contrato de la migración de DTe y clasificación del comprador."""

import importlib.util
from pathlib import Path

import pytest

_BACKEND = Path(__file__).parent.parent
_MIGRACION = (
    _BACKEND / "alembic/versions/20260910_02_exigir_dte_y_clasificar_comprador.py"
)
_SCRIPT_SQL = _BACKEND / "scripts/exigir_dte_y_clasificar_comprador.sql"
_RESTRICCIONES = {
    "ck_ventas_nro_dte_no_vacio",
    "ck_ventas_apellido_segun_comprador",
}


@pytest.fixture(scope="module")
def modulo_migracion():
    spec = importlib.util.spec_from_file_location("migracion_comprador", _MIGRACION)
    assert spec is not None and spec.loader is not None
    modulo = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(modulo)
    return modulo


def test_migracion_se_encadena_sobre_permisos_de_ventas(modulo_migracion):
    assert modulo_migracion.revision == "20260910_02"
    assert modulo_migracion.down_revision == "20260910_01"


def test_migracion_y_script_comparten_restricciones(modulo_migracion):
    contenido_migracion = _MIGRACION.read_text(encoding="utf-8")
    contenido_script = _SCRIPT_SQL.read_text(encoding="utf-8")

    assert modulo_migracion._CK_DTE in _RESTRICCIONES
    assert modulo_migracion._CK_APELLIDO in _RESTRICCIONES
    for restriccion in _RESTRICCIONES:
        assert restriccion in contenido_migracion
        assert restriccion in contenido_script


def test_script_exige_dte_y_clasificacion_del_comprador():
    contenido = _SCRIPT_SQL.read_text(encoding="utf-8").lower()

    assert "add column if not exists es_empresa boolean" in contenido
    assert "alter column es_empresa set not null" in contenido
    assert "alter column nro_dte set not null" in contenido
    assert "trim(nro_dte) <> ''" in contenido
    assert "es_empresa" in contenido
    assert "trim(apellido_comprador) <> ''" in contenido
