"""Contrato de la migración que crea ``observaciones_animales`` (VITA-173).

Corre sin Postgres, así que el CI lo ejecuta siempre. El comportamiento real
—migración de datos, trigger y RLS— se prueba en
``test_observaciones_animales_postgres``.
"""

import hashlib
import importlib.util
from pathlib import Path
import re
from uuid import UUID, uuid4

import pytest

from api.modules.observaciones_animales import models

_BACKEND = Path(__file__).parent.parent
_MIGRACION = _BACKEND / "alembic/versions/20261001_03_crear_observaciones_animales.py"
_SCRIPT_SQL = _BACKEND / "scripts/crear_observaciones_animales.sql"


@pytest.fixture(scope="module")
def migracion():
    spec = importlib.util.spec_from_file_location("migracion_obs", _MIGRACION)
    assert spec is not None and spec.loader is not None
    modulo = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(modulo)
    return modulo


@pytest.fixture(scope="module")
def script() -> str:
    return _SCRIPT_SQL.read_text(encoding="utf-8")


def _normalizar(sql: str) -> str:
    return re.sub(r"\s+", " ", sql).strip().rstrip(";")


def test_se_encadena_sobre_las_reglas_reproductivas(migracion):
    assert migracion.revision == "20261001_03"
    assert migracion.down_revision == "20261001_02"


def test_trigger_es_copia_literal_del_modelo(migracion):
    assert migracion._FUNCION_OBSERVACION_ANIMAL == models.FUNCION_OBSERVACION_ANIMAL
    assert migracion._TRIGGERS_OBSERVACION_ANIMAL == models.TRIGGERS_OBSERVACION_ANIMAL


def test_script_contiene_el_mismo_trigger(migracion, script):
    script_normalizado = _normalizar(script)
    for sentencia in (
        migracion._FUNCION_OBSERVACION_ANIMAL,
        *migracion._TRIGGERS_OBSERVACION_ANIMAL,
    ):
        assert _normalizar(sentencia) in script_normalizado


def test_indices_y_restriccion_coinciden_con_el_modelo(migracion, script):
    tabla = models.ObservacionAnimal.__table__
    indices = {i.name: [c.name for c in i.columns] for i in tabla.indexes}
    for nombre, columnas in migracion._INDICES:
        assert indices[nombre] == columnas
        assert nombre in script
    restricciones = {c.name for c in tabla.constraints}
    assert migracion._CK_TEXTO in restricciones
    assert migracion._CK_TEXTO in script


def test_id_legacy_es_el_mismo_que_calcula_el_script(migracion, script):
    animal_id = uuid4()
    esperado = UUID(hashlib.md5(f"observacion_legacy:{animal_id}".encode()).hexdigest())

    assert migracion.id_observacion_legacy(animal_id) == esperado
    assert "md5('observacion_legacy:' || a.id::text)::uuid" in script
    assert "on conflict (id) do nothing" in script


def test_script_documenta_el_timestamp_usado(script):
    assert "fecha = animales.created_at" in script
    assert "a.created_at" in script


def test_script_es_transaccional_y_solo_otorga_lo_necesario(script):
    assert "\nbegin;\n" in script
    assert script.rstrip().endswith("commit;")
    assert "revoke all on public.observaciones_animales from anon;" in script
    assert (
        "grant select, insert, update on public.observaciones_animales"
        " to authenticated;" in script
    )
    assert "for delete" not in script
