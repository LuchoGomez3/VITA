"""Contrato de la migración de reglas reproductivas de categorías (VITA-173).

Corre sin Postgres, así que el CI lo ejecuta siempre. El comportamiento real de
los triggers se prueba en ``test_reglas_reproductivas_postgres``.
"""

import importlib.util
from pathlib import Path
import re
from unittest.mock import MagicMock

import pytest

from api.modules.animales import models as animales_models
from api.modules.categorias import models as categorias_models
from api.shared.enums import EstadoReproductivo, SexoPermitido

_BACKEND = Path(__file__).parent.parent
_MIGRACION = (
    _BACKEND / "alembic/versions/20261001_02_reglas_reproductivas_categorias.py"
)
_SCRIPT_SQL = _BACKEND / "scripts/agregar_reglas_reproductivas_categorias.sql"

_TERNERO_SUPABASE = "550e8400-e29b-41d4-a716-446655440030"
_ENGORDE_RAPIDO = "550e8400-e29b-41d4-a716-446655440034"


@pytest.fixture(scope="module")
def migracion():
    spec = importlib.util.spec_from_file_location("migracion_reglas", _MIGRACION)
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
    assert migracion.revision == "20261001_02"
    # Se encadena detrás de los cobros de ventas (VITA-172).
    assert migracion.down_revision == "20261001_01"


def test_triggers_de_la_migracion_son_copia_literal_de_los_modelos(migracion):
    assert (
        migracion._FUNCION_CATEGORIA_COMPATIBLE
        == animales_models.FUNCION_CATEGORIA_COMPATIBLE
    )
    assert (
        migracion._TRIGGERS_CATEGORIA_COMPATIBLE
        == animales_models.TRIGGERS_CATEGORIA_COMPATIBLE
    )
    assert (
        migracion._FUNCION_REGLAS_CATEGORIA
        == categorias_models.FUNCION_REGLAS_CATEGORIA
    )
    assert (
        migracion._TRIGGERS_REGLAS_CATEGORIA
        == categorias_models.TRIGGERS_REGLAS_CATEGORIA
    )


def test_script_espejo_contiene_los_mismos_triggers(migracion, script):
    sentencias = (
        migracion._FUNCION_CATEGORIA_COMPATIBLE,
        *migracion._TRIGGERS_CATEGORIA_COMPATIBLE,
        migracion._FUNCION_REGLAS_CATEGORIA,
        *migracion._TRIGGERS_REGLAS_CATEGORIA,
    )
    script_normalizado = _normalizar(script)
    for sentencia in sentencias:
        assert _normalizar(sentencia) in script_normalizado


def test_script_y_migracion_comparten_restricciones(migracion, script):
    for nombre in (
        migracion._CK_SEXO_PERMITIDO,
        migracion._CK_ESTADO_REPRODUCTIVO,
        migracion._CK_SOLO_HEMBRAS,
    ):
        assert nombre in script
    # Transaccional: un abort no deja columnas a medio crear.
    assert "\nbegin;\n" in script
    # La limpieza opcional va después, comentada y fuera de la transacción.
    principal = script[: script.index("\n-- ----")]
    assert principal.rstrip().endswith("commit;")


def test_valores_validos_coinciden_con_los_enums(migracion):
    assert set(migracion._SEXOS_PERMITIDOS) == {s.value for s in SexoPermitido}
    assert set(migracion._ESTADOS_REPRODUCTIVOS) == {
        e.value for e in EstadoReproductivo
    }


def test_script_clasifica_igual_que_la_migracion(migracion, script):
    for categoria_id, (sexo, permite) in migracion._CLASIFICACION.items():
        fila = f"('{categoria_id}'::uuid, '{sexo}', {'true' if permite else 'false'})"
        assert fila in script


_CATALOGO_FRONT = {
    # Mismos UUIDs que animal_registration_offline_context.dart en mobile.
    "d37e62fb-96db-4ff1-a26b-0e3b2c3b36d8": ("Ternera", "hembra", False),
    "b9a6e57b-20ae-49b1-a7bb-17c71af546f3": ("Ternero", "macho", False),
    "b6d6440c-88c6-48cc-9003-0ad2cc05f3d5": ("Vaquillona", "hembra", True),
    "ef69117b-c979-4665-b13f-2b26ff0f19b3": ("Vaca", "hembra", True),
    "41da4271-bd25-4ba0-ba34-24dc6586f0f2": ("Novillo", "macho", False),
    "b5e8ea91-9789-4f7e-9dad-10262f1920f4": ("Toro", "macho", False),
}


def test_catalogo_global_es_el_del_front(migracion):
    """Decisión de Ernesto (PO) y Lucho, 2026-10-02: el catálogo es el del front."""
    assert {
        cid: (nombre, sexo, permite)
        for cid, nombre, sexo, permite in migracion._CATALOGO_GLOBAL
    } == _CATALOGO_FRONT


def test_script_siembra_el_mismo_catalogo_sin_duplicar(migracion, script):
    for cid, nombre, sexo, permite in migracion._CATALOGO_GLOBAL:
        fila = (
            f"('{cid}'::uuid, '{nombre}', '{sexo}', {'true' if permite else 'false'})"
        )
        assert fila in script
    assert "on conflict (id) do nothing" in script


def test_datos_de_prueba_heredados_no_cortan_la_migracion(migracion):
    """El Ternero de prueba tiene 2 hembras: en ``ambos`` la migración no aborta.

    El Ternero del catálogo, en cambio, es solo macho.
    """
    assert migracion._CLASIFICACION[_TERNERO_SUPABASE] == ("ambos", False)
    assert migracion._CLASIFICACION[_ENGORDE_RAPIDO] == ("ambos", False)
    assert migracion._CLASIFICACION["b9a6e57b-20ae-49b1-a7bb-17c71af546f3"] == (
        "macho",
        False,
    )
    assert set(migracion._CLASIFICACION_DATOS_PRUEBA).isdisjoint(_CATALOGO_FRONT)


def test_limpieza_de_datos_de_prueba_esta_comentada(script):
    """La limpieza la corre Lucho a mano: nunca se ejecuta con el script."""
    inicio = script.index("-- INICIO LIMPIEZA")
    fin = script.index("-- FIN LIMPIEZA")
    bloque = script[inicio:fin].splitlines()
    assert all(not linea.strip() or linea.startswith("--") for linea in bloque)
    assert "update public.animales" in script[inicio:fin]
    # Fuera del bloque comentado, el script no mueve animales.
    assert "update public.animales" not in script[:inicio]


def test_clasificacion_usa_valores_validos(migracion):
    for sexo, permite in migracion._CLASIFICACION.values():
        assert sexo in migracion._SEXOS_PERMITIDOS
        assert isinstance(permite, bool)
        # Habilitar la condición reproductiva en una categoría solo de machos
        # no tendría efecto y revela un error de carga.
        assert not (permite and sexo == "macho")


def test_aborta_con_categorias_sin_clasificar(migracion):
    connection = MagicMock()
    connection.execute.return_value.all.return_value = [("id-1", "Recría")]

    with pytest.raises(RuntimeError, match="id-1 \\('Recría'\\)"):
        migracion._exigir_categorias_clasificadas(connection)


def test_aborta_con_animales_incompatibles(migracion):
    connection = MagicMock()
    connection.execute.return_value.all.return_value = [("Vaca", "hembra", "macho", 2)]

    with pytest.raises(RuntimeError, match="2 macho\\(s\\) en 'Vaca'"):
        migracion._exigir_animales_compatibles(connection)


def test_no_aborta_con_datos_compatibles(migracion):
    connection = MagicMock()
    connection.execute.return_value.all.return_value = []

    migracion._exigir_categorias_clasificadas(connection)
    migracion._exigir_animales_compatibles(connection)


def test_triggers_solo_en_postgres(migracion):
    connection = MagicMock()
    connection.dialect.name = "sqlite"

    migracion._crear_triggers(connection)

    connection.execute.assert_not_called()
