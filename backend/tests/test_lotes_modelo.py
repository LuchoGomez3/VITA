"""Tests estructurales del esquema de lotes y movimientos.

No tocan la base: verifican que los tres artefactos que describen el esquema
—modelo, migración y script SQL espejo— digan lo mismo. Es exactamente la clase
de desalineación que motivó este módulo.
"""

import importlib.util
import re
from pathlib import Path

import pytest

from api.modules.lotes.models import MODO_GEOMETRIA_LOCAL, Lote
from api.modules.movimientos.models import MovimientoLote, MovimientoLoteAnimal
from api.shared.enums import EstadoLote, RecursoForrajero

_BACKEND = Path(__file__).resolve().parents[1]
_MIGRACION = _BACKEND / "alembic/versions/20260905_03_lotes_y_movimientos_batch.py"
_SCRIPT_SQL = _BACKEND / "scripts/crear_lotes_y_movimientos.sql"


def _cargar_migracion():
    """Importa el módulo de la revisión para leer sus constantes.

    Las revisiones de Alembic no son un paquete importable, así que se cargan por
    ruta. Leer las constantes es más robusto que hacer regex sobre el archivo.
    """
    spec = importlib.util.spec_from_file_location("_migracion_lotes", _MIGRACION)
    modulo = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(modulo)
    return modulo


def _valores_de_check_sql(contenido: str, restriccion: str) -> set[str]:
    """Extrae los literales del ``CHECK ... in (...)`` de una restricción del script."""
    coincidencia = re.search(
        rf"{restriccion}.*?\bin\s*\(([^)]+)\)", contenido, re.IGNORECASE | re.DOTALL
    )
    if coincidencia is None:
        raise AssertionError(f"No se encontró la restricción {restriccion}")
    return {
        valor.strip().strip("'").strip('"')
        for valor in coincidencia.group(1).split(",")
    }


@pytest.mark.parametrize(
    ("restriccion", "constante", "enum"),
    [
        ("ck_lotes_estado_valido", "_ESTADOS", EstadoLote),
        ("ck_lotes_recurso_forrajero_valido", "_RECURSOS_FORRAJEROS", RecursoForrajero),
    ],
)
def test_enums_coinciden_entre_modelo_migracion_y_script(restriccion, constante, enum):
    """Los tres artefactos que describen el esquema no pueden divergir.

    El modelo deriva los literales del enum; la migración y el script los
    escriben a mano, así que este test es el que evita que se desalineen.
    """
    esperados = {miembro.value for miembro in enum}
    assert set(getattr(_cargar_migracion(), constante)) == esperados
    assert (
        _valores_de_check_sql(_SCRIPT_SQL.read_text(encoding="utf-8"), restriccion)
        == esperados
    )


def test_lote_es_sincronizable():
    """UUID de cliente, timestamps y tombstone: el contrato offline-first."""
    columnas = set(Lote.__table__.columns.keys())
    assert {"id", "created_at", "updated_at", "deleted_at"} <= columnas
    assert Lote.__table__.primary_key.columns.keys() == ["id"]


def test_lote_expone_los_campos_que_mobile_sincroniza():
    columnas = set(Lote.__table__.columns.keys())
    assert {
        "establecimiento_id",
        "nombre",
        "geometria_local",
        "modo_geometria",
        "superficie_ha",
        "recurso_forrajero_codigo",
        "tiene_agua",
        "estado",
    } <= columnas


def test_lote_tiene_indice_de_descarga_delta():
    indice = next(i for i in Lote.__table__.indexes if i.name == "ix_lotes_sync")
    assert [c.name for c in indice.columns] == ["establecimiento_id", "updated_at"]


def test_unicidad_de_nombre_es_normalizada_y_parcial():
    """Debe ignorar mayúsculas/espacios y no contar los tombstones."""
    indice = next(
        i for i in Lote.__table__.indexes if i.name == "uq_lotes_nombre_establecimiento"
    )
    assert indice.unique
    expresion = " ".join(str(e) for e in indice.expressions)
    assert "lower" in expresion and "trim" in expresion
    assert (
        "deleted_at is null"
        in str(indice.dialect_options["postgresql"]["where"]).lower()
    )


def test_campos_obligatorios_del_lote_no_son_nullable():
    columnas = Lote.__table__.columns
    for nombre in ("geometria_local", "modo_geometria", "superficie_ha", "tiene_agua"):
        assert not columnas[nombre].nullable, nombre


def test_modo_de_geometria_por_defecto_es_el_esquematico():
    assert MODO_GEOMETRIA_LOCAL == "local_schematic"


def test_movimiento_es_sincronizable_y_su_detalle_no():
    """La cabecera viaja sola; el detalle va dentro de su payload."""
    assert "deleted_at" in MovimientoLote.__table__.columns
    assert "deleted_at" not in MovimientoLoteAnimal.__table__.columns


def test_movimiento_usa_el_nombre_de_tabla_plural_del_contrato():
    assert MovimientoLote.__tablename__ == "movimientos_lotes"
    assert MovimientoLoteAnimal.__tablename__ == "movimientos_lotes_animales"


def test_movimiento_expone_fecha_movimiento_no_fecha():
    """El contrato con mobile nombra el campo ``fecha_movimiento``."""
    columnas = set(MovimientoLote.__table__.columns.keys())
    assert "fecha_movimiento" in columnas
    assert "fecha" not in columnas


def test_detalle_del_movimiento_no_admite_animales_repetidos():
    nombres = {c.name for c in MovimientoLoteAnimal.__table__.constraints}
    assert "uq_movimiento_lote_animal" in nombres


def test_migracion_y_script_encadenan_desde_ventas():
    contenido = _MIGRACION.read_text(encoding="utf-8")
    assert 'down_revision: str | None = "20260902_02"' in contenido
    assert 'revision: str = "20260905_03"' in contenido


def test_el_script_espejo_cubre_las_mismas_tablas_que_la_migracion():
    sql = _SCRIPT_SQL.read_text(encoding="utf-8")
    for tabla in ("movimientos_lotes", "movimientos_lotes_animales"):
        assert f"create table if not exists public.{tabla}" in sql
    for indice in ("ix_lotes_sync", "uq_lotes_nombre_establecimiento"):
        assert indice in sql
