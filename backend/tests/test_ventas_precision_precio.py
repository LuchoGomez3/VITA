"""Contrato de precisión del precio unitario de ventas por kilo."""

from pathlib import Path

from sqlalchemy import Numeric

from api.modules.ventas.models import Venta

_BACKEND = Path(__file__).parent.parent
_MIGRACION = _BACKEND / "alembic/versions/20261003_01_ampliar_precision_precio_venta.py"
_SCRIPT = _BACKEND / "scripts/ampliar_precision_precio_venta.sql"


def test_modelo_conserva_seis_decimales_del_precio_por_kilo():
    tipo = Venta.__table__.c.precio_por_kg.type

    assert isinstance(tipo, Numeric)
    assert (tipo.precision, tipo.scale) == (18, 6)


def test_migracion_y_script_declaran_la_misma_precision():
    migracion = _MIGRACION.read_text(encoding="utf-8")
    script = _SCRIPT.read_text(encoding="utf-8")

    assert "sa.Numeric(precision=18, scale=6)" in migracion
    assert "numeric(18, 6)" in script
    assert 'down_revision: str | None = "20261001_01"' in migracion
