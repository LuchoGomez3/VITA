"""Evita diferencias entre índices históricos de Supabase y SQLModel."""

from api.modules.egresos_operativos.models import EgresoOperativo
from api.modules.usuarios.models import Usuario
from api.reportes.models import ExportacionSenasa, ExportacionSenasaAnimal


def _indices(modelo) -> dict[str, object]:
    return {indice.name: indice for indice in modelo.__table__.indexes}


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
