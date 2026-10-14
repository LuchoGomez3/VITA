"""Contrato de las políticas RLS comerciales de ventas."""

import importlib.util
from pathlib import Path
import re

import pytest

from api.shared.enums import RolUsuario

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
# La enumeración es intencionalmente exhaustiva: agregar un rol al dominio debe
# romper este contrato hasta decidir expresamente si puede acceder a datos comerciales.
_ACCESO_COMERCIAL_POR_ROL = {
    RolUsuario.admin: True,
    RolUsuario.owner: True,
    RolUsuario.employee: False,
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
    assert modulo_migracion.down_revision == "20260905_03"


def _allowlists_de_roles(contenido: str) -> list[set[str]]:
    coincidencias = re.findall(r"ue\.rol\s+in\s*\(([^)]+)\)", contenido)
    return [
        {literal.strip().strip("'").strip('"') for literal in grupo.split(",")}
        for grupo in coincidencias
    ]


def test_todos_los_roles_tienen_una_decision_comercial_explicita():
    assert set(_ACCESO_COMERCIAL_POR_ROL) == set(RolUsuario)


def test_todas_las_politicas_usan_la_allowlist_completa(modulo_migracion):
    sentencias = modulo_migracion._sentencias_politicas(restringir_roles=True)
    creaciones = [sql for sql in sentencias if "create policy" in sql]
    roles_permitidos = {
        rol.value for rol, permitido in _ACCESO_COMERCIAL_POR_ROL.items() if permitido
    }

    assert len(creaciones) == len(_POLITICAS)
    for politica in _POLITICAS:
        sentencia = next(sql for sql in creaciones if politica in sql)
        allowlists = _allowlists_de_roles(sentencia)
        assert allowlists
        assert all(allowlist == roles_permitidos for allowlist in allowlists)


def test_script_espejo_restringe_las_mismas_politicas():
    contenido = _SCRIPT_SQL.read_text(encoding="utf-8")
    roles_permitidos = {
        rol.value for rol, permitido in _ACCESO_COMERCIAL_POR_ROL.items() if permitido
    }

    for politica in _POLITICAS:
        assert f"create policy {politica}" in contenido
    allowlists = _allowlists_de_roles(contenido)
    assert len(allowlists) == 6
    assert all(allowlist == roles_permitidos for allowlist in allowlists)
