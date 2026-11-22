"""Contrato de las migraciones de alimentación (adr-0016).

Corre sin Postgres, así que el CI lo ejecuta siempre: verifica que modelo,
migración y script espejo describan el mismo esquema. El comportamiento real
—backfill, triggers y RLS— se prueba en ``test_alimentacion_postgres``.
"""

import hashlib
import importlib.util
from pathlib import Path
import re
from uuid import UUID, uuid4

import pytest

from api.modules.alimentacion.models import (
    RegistroAlimentacion,
    RegistroAlimentacionAnimal,
)
from api.modules.alimentos.models import Alimento
from api.modules.recursos_forrajeros.models import PeriodoRecursoForrajero
from api.shared.enums import (
    BaseCantidadAlimento,
    CategoriaAlimento,
    RecursoForrajero,
    TipoRegistroAlimentacion,
    UnidadAlimento,
)

_BACKEND = Path(__file__).parent.parent
_VERSIONES = _BACKEND / "alembic/versions"
_MIGRACION_RECURSOS = _VERSIONES / "20261114_01_recursos_forrajeros_por_periodo.py"
_MIGRACION_ALIMENTACION = (
    _VERSIONES / "20261114_02_alimentos_y_registros_alimentacion.py"
)
_SCRIPT_RECURSOS = _BACKEND / "scripts/crear_recursos_forrajeros_por_periodo.sql"
_SCRIPT_ALIMENTACION = _BACKEND / "scripts/crear_alimentacion.sql"


def _cargar(ruta: Path):
    spec = importlib.util.spec_from_file_location(f"_mig_{ruta.stem}", ruta)
    assert spec is not None and spec.loader is not None
    modulo = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(modulo)
    return modulo


@pytest.fixture(scope="module")
def recursos():
    return _cargar(_MIGRACION_RECURSOS)


@pytest.fixture(scope="module")
def alimentacion():
    return _cargar(_MIGRACION_ALIMENTACION)


@pytest.fixture(scope="module")
def script_recursos() -> str:
    return _SCRIPT_RECURSOS.read_text(encoding="utf-8")


@pytest.fixture(scope="module")
def script_alimentacion() -> str:
    return _SCRIPT_ALIMENTACION.read_text(encoding="utf-8")


def _normalizar(sql: str) -> str:
    return re.sub(r"\s+", " ", sql).strip().rstrip(";")


def _indices(tabla) -> dict[str, list[str]]:
    return {i.name: [c.name for c in i.columns] for i in tabla.indexes}


def _restricciones(tabla) -> set[str]:
    return {c.name for c in tabla.constraints if c.name}


# ----------------------------------------------------------- encadenamiento


def test_las_revisiones_se_encadenan_sobre_el_equipo(recursos, alimentacion):
    assert recursos.revision == "20261114_01"
    assert recursos.down_revision == "20261017_02"
    assert alimentacion.revision == "20261114_02"
    assert alimentacion.down_revision == "20261114_01"


# --------------------------------------------------- recursos por período


def test_catalogo_de_recursos_coincide_con_el_enum(recursos):
    assert set(recursos._RECURSOS_FORRAJEROS) == {r.value for r in RecursoForrajero}
    # El catálogo original sigue dentro del ampliado: el downgrade vuelve a él.
    assert set(recursos._RECURSOS_PREVIOS) <= set(recursos._RECURSOS_FORRAJEROS)


def test_indices_y_restricciones_del_periodo_coinciden(recursos, script_recursos):
    tabla = PeriodoRecursoForrajero.__table__
    indices = _indices(tabla)
    for nombre, columnas in recursos._INDICES:
        assert indices[nombre] == columnas
        assert nombre in script_recursos
    assert indices[recursos._UQ_LOTE_DESDE] == ["lote_id", "fecha_desde"]
    assert "where deleted_at is null" in script_recursos
    for nombre in (recursos._CK_CODIGO, recursos._CK_FECHAS, recursos._CK_DESCRIPCION):
        assert nombre in _restricciones(tabla)
        assert nombre in script_recursos


def test_id_legacy_del_periodo_es_el_del_script(recursos, script_recursos):
    lote_id = uuid4()
    esperado = UUID(hashlib.md5(f"recurso_legacy:{lote_id}".encode()).hexdigest())

    assert recursos.id_periodo_legacy(lote_id) == esperado
    assert "md5('recurso_legacy:' || l.id::text)::uuid" in script_recursos
    assert "on conflict (id) do nothing" in script_recursos


def test_script_de_recursos_comparte_el_trigger(recursos, script_recursos):
    normalizado = _normalizar(script_recursos)
    for sentencia in (recursos._FUNCION_VALIDAR, *recursos._TRIGGERS):
        assert _normalizar(sentencia) in normalizado
    assert "security invoker" in recursos._FUNCION_VALIDAR
    assert "security definer" not in recursos._FUNCION_VALIDAR


def test_script_de_recursos_es_transaccional_y_solo_otorga_lo_necesario(
    script_recursos,
):
    assert "\nbegin;\n" in script_recursos
    assert script_recursos.rstrip().endswith("commit;")
    assert (
        "revoke all on public.lotes_recursos_forrajeros from anon;" in script_recursos
    )
    assert (
        "grant select, insert, update on public.lotes_recursos_forrajeros"
        " to authenticated;" in script_recursos
    )
    assert "for delete" not in script_recursos
    assert "registrado_por_id = auth.uid()" in script_recursos


# ------------------------------------------------- alimentos y registros


@pytest.mark.parametrize(
    ("constante", "enum"),
    [
        ("_CATEGORIAS_ALIMENTO", CategoriaAlimento),
        ("_UNIDADES", UnidadAlimento),
        ("_TIPOS_REGISTRO", TipoRegistroAlimentacion),
        ("_BASES_CANTIDAD", BaseCantidadAlimento),
    ],
)
def test_catalogos_de_alimentacion_coinciden_con_los_enums(
    alimentacion, script_alimentacion, constante, enum
):
    valores = getattr(alimentacion, constante)
    assert set(valores) == {miembro.value for miembro in enum}
    lista = ", ".join(f"'{v}'" for v in valores)
    assert lista in _normalizar(script_alimentacion)


@pytest.mark.parametrize(
    ("modelo", "constante"),
    [
        (Alimento, "_INDICES_ALIMENTOS"),
        (RegistroAlimentacion, "_INDICES_REGISTROS"),
        (RegistroAlimentacionAnimal, "_INDICES_DETALLE"),
    ],
)
def test_indices_de_alimentacion_coinciden_con_los_modelos(
    alimentacion, script_alimentacion, modelo, constante
):
    indices = _indices(modelo.__table__)
    for nombre, columnas in getattr(alimentacion, constante):
        assert indices[nombre] == columnas
        assert nombre in script_alimentacion


def test_restricciones_de_alimentos_coinciden(alimentacion, script_alimentacion):
    restricciones = _restricciones(Alimento.__table__)
    for nombre, _ in alimentacion._CHECKS_ALIMENTOS:
        assert nombre in restricciones
        assert nombre in script_alimentacion
    # La tabla heredada puede tener filas que no se conocen: los CHECK nuevos
    # no deben trabar la adopción.
    assert script_alimentacion.count(") not valid;") == len(
        alimentacion._CHECKS_ALIMENTOS
    )


def test_restricciones_de_registros_coinciden(script_alimentacion):
    for nombre in _restricciones(RegistroAlimentacion.__table__):
        if nombre.startswith(("ck_", "uq_")):
            assert nombre in script_alimentacion
    assert "uq_registro_alimentacion_animal" in script_alimentacion


def test_script_de_alimentacion_comparte_los_triggers(
    alimentacion, script_alimentacion
):
    normalizado = _normalizar(script_alimentacion)
    for funcion in (
        alimentacion._FUNCION_VALIDAR_REGISTRO,
        alimentacion._FUNCION_VALIDAR_DETALLE,
    ):
        assert _normalizar(funcion) in normalizado
        assert "security invoker" in funcion
        assert "security definer" not in funcion


def test_script_de_alimentacion_recorta_a_anon_y_no_borra(script_alimentacion):
    assert "\nbegin;\n" in script_alimentacion
    assert script_alimentacion.rstrip().endswith("commit;")
    for tabla in ("alimentos", "registros_alimentacion"):
        assert f"revoke all on public.{tabla} from anon;" in script_alimentacion
        assert (
            f"grant select, insert, update on public.{tabla} to authenticated;"
            in script_alimentacion
        )
    # El detalle es inmutable.
    assert (
        "grant select, insert on public.registros_alimentacion_animales"
        " to authenticated;" in script_alimentacion
    )
    assert "for delete" not in script_alimentacion
    assert "responsable_id = auth.uid()" in script_alimentacion
    assert "creado_por_id = auth.uid()" in script_alimentacion


def test_el_catalogo_global_es_de_solo_lectura(alimentacion):
    insert, update = (
        sentencia
        for sentencia in alimentacion._politicas_alimentos()
        if "create policy" in sentencia and "for select" not in sentencia
    )
    assert "establecimiento_id is not null" in insert
    assert "establecimiento_id is not null" in update
