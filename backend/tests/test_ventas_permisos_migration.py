"""Contrato de las políticas RLS comerciales de ventas."""

import importlib.util
from pathlib import Path

import pytest

_BACKEND = Path(__file__).parent.parent
_MIGRACION = (
    _BACKEND / "alembic/versions/20260910_01_restringir_ventas_roles_comerciales.py"
)
_SCRIPT_SQL = _BACKEND / "scripts/restringir_ventas_roles_comerciales.sql"
_POLITICAS = {
    "ventas_select_miembros",
    "ventas_insert_miembros",
    "ventas_update_miembros",
    "ventas_detalles_select_miembros",
    "ventas_detalles_insert_miembros",
}


@pytest.fixture(scope="module")
def modulo_migracion():
    spec = importlib.util.spec_from_file_location("migracion_roles_ventas", _MIGRACION)
    assert spec is not None and spec.loader is not None
    modulo = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(modulo)
    return modulo


def test_migracion_se_encadena_sobre_la_creacion_de_ventas(modulo_migracion):
    assert modulo_migracion.revision == "20260910_01"
    assert modulo_migracion.down_revision == "20260902_02"


def test_todas_las_politicas_excluyen_employee(modulo_migracion):
    sentencias = modulo_migracion._sentencias_politicas(restringir_roles=True)
    creaciones = [sql for sql in sentencias if "create policy" in sql]

    assert len(creaciones) == len(_POLITICAS)
    for politica in _POLITICAS:
        sentencia = next(sql for sql in creaciones if politica in sql)
        assert "ue.rol in ('admin', 'owner')" in sentencia
        assert "employee" not in sentencia


def test_script_espejo_restringe_las_mismas_politicas():
    contenido = _SCRIPT_SQL.read_text(encoding="utf-8")

    for politica in _POLITICAS:
        assert f"create policy {politica}" in contenido
    assert contenido.count("ue.rol in ('admin', 'owner')") == 6
    assert "employee" not in contenido
