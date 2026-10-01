"""Evita diferencias entre índices históricos de Supabase y SQLModel."""

from pathlib import Path

from api.modules.egresos_operativos.models import EgresoOperativo
from api.modules.usuarios.models import Usuario
from api.reportes.models import ExportacionSenasa, ExportacionSenasaAnimal

_BACKEND = Path(__file__).parent.parent
_ARTEFACTOS_POR_INDICE = {
    "ix_egresos_operativos_sync": (_BACKEND / "scripts/crear_egresos_operativos.sql",),
    "ix_exportaciones_senasa_historial": (
        _BACKEND / "scripts/crear_exportaciones_senasa.sql",
    ),
    "ix_exportaciones_senasa_animales_exportacion_id": (
        _BACKEND / "scripts/crear_exportaciones_senasa.sql",
    ),
    "uq_usuarios_email": (
        _BACKEND / "scripts/agregar_unicidad_usuarios.sql",
        _BACKEND / "alembic/versions/20260819_01_unicidad_usuarios.py",
    ),
    "uq_usuarios_cuit": (
        _BACKEND / "scripts/agregar_unicidad_usuarios.sql",
        _BACKEND / "alembic/versions/20260819_01_unicidad_usuarios.py",
    ),
}


def _indices(modelo) -> dict[str, object]:
    return {indice.name: indice for indice in modelo.__table__.indexes}


def test_nombres_de_indices_coinciden_con_artefactos_historicos():
    indices_metadata = {
        nombre
        for modelo in (
            EgresoOperativo,
            ExportacionSenasa,
            ExportacionSenasaAnimal,
            Usuario,
        )
        for nombre in _indices(modelo)
    }

    for indice, artefactos in _ARTEFACTOS_POR_INDICE.items():
        assert indice in indices_metadata
        for artefacto in artefactos:
            assert indice in artefacto.read_text(encoding="utf-8")


def test_indices_de_sincronizacion_e_historial_estan_en_metadata():
    indices_egresos = _indices(EgresoOperativo)
    indices_exportaciones = _indices(ExportacionSenasa)

    assert "ix_egresos_operativos_sync" in indices_egresos
    assert "ix_exportaciones_senasa_historial" in indices_exportaciones


def test_indice_de_exportacion_detalle_conserva_nombre_historico():
    indices = _indices(ExportacionSenasaAnimal)

    assert "ix_exportaciones_senasa_animales_exportacion_id" in indices
    assert "ix_exportaciones_senasa_animales_exportacion_senasa_id" not in indices


def test_indices_unicos_de_usuario_conservan_nombres_historicos():
    indices = _indices(Usuario)

    assert indices["uq_usuarios_email"].unique
    assert indices["uq_usuarios_cuit"].unique
    assert "ix_usuarios_email" not in indices
    assert "ix_usuarios_cuit" not in indices
