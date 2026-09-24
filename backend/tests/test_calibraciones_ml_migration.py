"""Contrato de la migración que crea la tabla del dataset de calibración.

Verifica lo que ``pytest`` no puede comprobar corriendo la migración: que quede
encadenada donde corresponde, que el espejo SQL manual no se desincronice de
ella, y que las invariantes que sostienen el aislamiento multi-tenant y la
integridad del dataset estén en los dos artefactos.
"""

import importlib.util
from pathlib import Path
from unittest.mock import MagicMock

import pytest

from api.modules.calibraciones_ml.models import MuestraCalibracion
from api.shared.enums import EstadoMuestraCalibracion

_BACKEND = Path(__file__).parent.parent
_MIGRACION = _BACKEND / "alembic/versions/20260924_01_crear_calibraciones_ml.py"
_SCRIPT_SQL = _BACKEND / "scripts/crear_calibraciones_ml.sql"

_RESTRICCIONES = (
    "ck_calibraciones_ml_estado_valido",
    "ck_calibraciones_ml_peso_real_positivo",
    "ck_calibraciones_ml_peso_estimado_positivo",
    "ck_calibraciones_ml_completa_exige_imagen",
    "ck_calibraciones_ml_imagen_bytes_positivo",
)
_INDICES = (
    "ix_calibraciones_ml_establecimiento_id",
    "ix_calibraciones_ml_animal_id",
    "ix_calibraciones_ml_sync",
    "ix_calibraciones_ml_imagen_key",
)
_POLITICAS = (
    "calibraciones_ml_select_miembros",
    "calibraciones_ml_insert_miembros",
    "calibraciones_ml_update_miembros",
)


@pytest.fixture(scope="module")
def modulo_migracion():
    spec = importlib.util.spec_from_file_location("migracion_calibraciones", _MIGRACION)
    assert spec is not None and spec.loader is not None
    modulo = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(modulo)
    return modulo


def test_migracion_se_encadena_sobre_la_cabeza_de_ventas(modulo_migracion):
    """La cabeza real de Supabase era 20260910_02 al escribir esta migración."""
    assert modulo_migracion.revision == "20260924_01"
    assert modulo_migracion.down_revision == "20260910_02"


def test_migracion_y_script_comparten_restricciones_indices_y_politicas():
    """El espejo manual tiene que producir el MISMO esquema que Alembic.

    Si divergen, una base migrada a mano desde el SQL Editor queda distinta de
    una migrada por CI y el bug aparece recién en producción.
    """
    contenido_migracion = _MIGRACION.read_text(encoding="utf-8")
    contenido_script = _SCRIPT_SQL.read_text(encoding="utf-8")

    for nombre in _RESTRICCIONES + _INDICES + _POLITICAS:
        assert nombre in contenido_migracion, nombre
        assert nombre in contenido_script, nombre


def test_los_estados_de_la_migracion_cubren_el_enum(modulo_migracion):
    """Un estado nuevo en el enum sin migración rompería el CHECK en produccion."""
    assert set(modulo_migracion._ESTADOS) == {
        estado.value for estado in EstadoMuestraCalibracion
    }


def test_los_indices_del_modelo_coinciden_con_los_de_la_migracion():
    """El nombre del índice de sync vive en tres lados y tiene que ser el mismo."""
    indices_modelo = {indice.name for indice in MuestraCalibracion.__table__.indexes}

    assert "ix_calibraciones_ml_sync" in indices_modelo
    assert "ix_calibraciones_ml_sync" in _INDICES


def test_las_restricciones_del_modelo_coinciden_con_las_de_la_migracion():
    nombres_modelo = {
        restriccion.name
        for restriccion in MuestraCalibracion.__table__.constraints
        if restriccion.name is not None
    }

    for nombre in _RESTRICCIONES:
        assert nombre in nombres_modelo, nombre


def test_el_insert_exige_que_el_responsable_sea_el_usuario_autenticado():
    """Impide que un cliente cargue muestras a nombre de otro productor."""
    contenido_migracion = _MIGRACION.read_text(encoding="utf-8")
    contenido_script = _SCRIPT_SQL.read_text(encoding="utf-8")

    assert "responsable_id = auth.uid()" in contenido_migracion
    assert "responsable_id = auth.uid()" in contenido_script


def test_no_se_habilita_ninguna_politica_de_delete():
    """El borrado es soft para que se sincronice; un delete real lo saltearía."""
    for contenido in (
        _MIGRACION.read_text(encoding="utf-8"),
        _SCRIPT_SQL.read_text(encoding="utf-8"),
    ):
        assert "for delete" not in contenido.lower()


def test_el_script_manual_es_idempotente():
    """Se ejecuta a mano sobre una base que puede tener parte del esquema."""
    contenido = _SCRIPT_SQL.read_text(encoding="utf-8").lower()

    assert "create table if not exists public.calibraciones_ml" in contenido
    assert contenido.count("create index if not exists") >= 3
    assert (
        "create unique index if not exists ix_calibraciones_ml_imagen_key" in contenido
    )
    # Cada CHECK se suelta antes de recrearse, si no, la segunda corrida falla.
    assert contenido.count("drop constraint if exists") == len(_RESTRICCIONES)
    assert contenido.count("drop policy if exists") == len(_POLITICAS)


def test_la_migracion_exige_las_tablas_de_las_que_depende(
    modulo_migracion, monkeypatch
):
    """Sin animales/establecimientos, las FKs fallarían con un error opaco."""
    inspector = MagicMock()
    inspector.has_table.return_value = False
    # Vía monkeypatch y no por asignación directa: ``modulo_migracion.sa`` ES el
    # módulo sqlalchemy, así que pisarlo a mano filtraría el doble al resto de la
    # suite según el orden de ejecución.
    monkeypatch.setattr(modulo_migracion.sa, "inspect", lambda _: inspector)

    with pytest.raises(RuntimeError, match="faltan las tablas"):
        modulo_migracion._exigir_tablas_previas(MagicMock())


def test_la_migracion_no_recrea_una_tabla_existente(modulo_migracion, monkeypatch):
    """Debe poder correr sobre Supabase, cuyo esquema precede a Alembic."""
    inspector = MagicMock()
    inspector.has_table.return_value = True
    monkeypatch.setattr(modulo_migracion.sa, "inspect", lambda _: inspector)
    create_table = MagicMock()
    monkeypatch.setattr(modulo_migracion.op, "create_table", create_table)

    modulo_migracion._crear_tabla(MagicMock())

    create_table.assert_not_called()


def test_la_migracion_no_duplica_un_indice_existente(modulo_migracion, monkeypatch):
    inspector = MagicMock()
    inspector.get_indexes.return_value = [{"name": nombre} for nombre in _INDICES]
    monkeypatch.setattr(modulo_migracion.sa, "inspect", lambda _: inspector)
    create_index = MagicMock()
    monkeypatch.setattr(modulo_migracion.op, "create_index", create_index)

    modulo_migracion._crear_indices(MagicMock())

    create_index.assert_not_called()


def test_la_rls_se_saltea_en_un_postgres_sin_supabase(modulo_migracion):
    """``auth.uid()`` no existe fuera de Supabase: sin el guard, CI no migraría."""
    connection = MagicMock()
    connection.dialect.name = "sqlite"

    assert modulo_migracion._soporta_rls(connection) is False
    connection.execute.assert_not_called()
