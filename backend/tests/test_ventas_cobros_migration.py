"""Contrato entre el modelo, la migración y el script de cobros (VITA-172).

No necesita base: compara los textos de los tres artefactos para que no
diverjan. El comportamiento real se prueba en ``test_ventas_cobros_postgres.py``.
"""

import importlib.util
from pathlib import Path
import re

from alembic.config import Config
from alembic.script import ScriptDirectory
import pytest

from api.modules.ventas import models as ventas_models
from api.shared.enums import MedioCobro, RolUsuario

_BACKEND = Path(__file__).parent.parent
_MIGRACION = _BACKEND / "alembic/versions/20261001_01_crear_ventas_cobros.py"
_SCRIPT_SQL = _BACKEND / "scripts/crear_ventas_cobros.sql"
_POLITICAS = {
    "ventas_cobros_select_miembros",
    "ventas_cobros_insert_miembros",
    "ventas_cobros_update_miembros",
}
# Exhaustivo a propósito: un rol nuevo rompe este contrato hasta que se decida
# si puede ver importes cobrados.
_ACCESO_COMERCIAL_POR_ROL = {
    RolUsuario.admin: True,
    RolUsuario.owner: True,
    RolUsuario.employee: False,
}
_ROLES_PERMITIDOS = {
    rol.value for rol, permitido in _ACCESO_COMERCIAL_POR_ROL.items() if permitido
}


@pytest.fixture(scope="module")
def migracion():
    spec = importlib.util.spec_from_file_location("migracion_cobros", _MIGRACION)
    assert spec is not None and spec.loader is not None
    modulo = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(modulo)
    return modulo


@pytest.fixture(scope="module")
def script() -> str:
    return _SCRIPT_SQL.read_text(encoding="utf-8")


def _normalizar(sql: str) -> str:
    return re.sub(r"\s+", " ", sql).strip().rstrip(";").strip()


def _bloque_funcion(sql: str, nombre: str) -> str:
    """Extrae ``create or replace function <nombre> ... $$`` de un texto SQL."""
    coincidencia = re.search(
        rf"create or replace function public\.{nombre}\(\).*?\$\$.*?\$\$",
        sql,
        re.DOTALL,
    )
    assert coincidencia, f"No se encontró la función {nombre}"
    return _normalizar(coincidencia.group(0))


def test_migracion_hereda_del_head_vigente(migracion):
    assert migracion.revision == "20261001_01"
    assert migracion.down_revision == "20260910_02"


def test_la_cadena_de_migraciones_tiene_un_unico_head():
    config = Config(str(_BACKEND / "alembic.ini"))
    config.set_main_option("script_location", str(_BACKEND / "alembic"))
    assert len(ScriptDirectory.from_config(config).get_heads()) == 1


def test_todos_los_roles_tienen_una_decision_explicita():
    assert set(_ACCESO_COMERCIAL_POR_ROL) == set(RolUsuario)


@pytest.mark.parametrize(
    ("nombre", "constante_modelo", "constante_migracion"),
    [
        ("validar_fecha_cobro", "FUNCION_FECHA_COBRO", "_FUNCION_FECHA_COBRO"),
        ("validar_tope_cobros_venta", "FUNCION_TOPE_COBROS", "_FUNCION_TOPE_COBROS"),
        (
            "validar_monto_venta_cubre_cobros",
            "FUNCION_MONTO_CUBRE_COBROS",
            "_FUNCION_MONTO_CUBRE_COBROS",
        ),
    ],
)
def test_las_funciones_del_tope_son_identicas_en_los_tres_artefactos(
    migracion, script, nombre, constante_modelo, constante_migracion
):
    del_modelo = _normalizar(getattr(ventas_models, constante_modelo))
    assert _normalizar(getattr(migracion, constante_migracion)) == del_modelo
    assert _bloque_funcion(script, nombre) == del_modelo
    # Invoker: un trigger privilegiado leería ventas ajenas antes del RLS.
    assert "security invoker" in del_modelo
    assert "security definer" not in del_modelo


def test_los_triggers_son_identicos_en_los_tres_artefactos(migracion, script):
    del_modelo = [_normalizar(sql) for sql in ventas_models.TRIGGERS_COBROS]

    assert [_normalizar(sql) for sql in migracion._TRIGGERS] == del_modelo
    script_normalizado = _normalizar(script)
    for sentencia in del_modelo:
        assert sentencia in script_normalizado


def test_el_tope_bloquea_la_venta_antes_de_sumar():
    """Sin el ``for update`` dos cobros simultáneos podrían sobrepagar."""
    funcion = _normalizar(ventas_models.FUNCION_TOPE_COBROS)
    assert funcion.index("for update") < funcion.index("sum(c.monto)")


def test_indices_coinciden_entre_modelo_migracion_y_script(migracion, script):
    del_modelo = {
        indice.name: [columna.name for columna in indice.columns]
        for indice in ventas_models.VentaCobro.__table__.indexes
    }

    assert dict(migracion._INDICES) == del_modelo
    for nombre, columnas in del_modelo.items():
        assert re.search(
            rf"create index if not exists {nombre}\s+on public\.ventas_cobros "
            rf"\({', '.join(columnas)}\)",
            script,
        )


def test_restriccion_de_monto_esta_en_los_tres_artefactos(script):
    assert "ck_ventas_cobros_monto_positivo" in _MIGRACION.read_text(encoding="utf-8")
    assert "constraint ck_ventas_cobros_monto_positivo check (monto > 0)" in script
    nombres = {
        restriccion.name
        for restriccion in ventas_models.VentaCobro.__table__.constraints
    }
    assert "ck_ventas_cobros_monto_positivo" in nombres


def _allowlists_de_roles(contenido: str) -> list[set[str]]:
    return [
        {literal.strip().strip("'\"") for literal in grupo.split(",")}
        for grupo in re.findall(r"ue\.rol\s+in\s*\(([^)]+)\)", contenido)
    ]


def test_las_politicas_de_la_migracion_usan_la_allowlist_comercial(migracion):
    creaciones = [
        sql for sql in migracion._sentencias_politicas() if "create policy" in sql
    ]

    assert len(creaciones) == len(_POLITICAS)
    for politica in _POLITICAS:
        sentencia = next(sql for sql in creaciones if politica in sql)
        allowlists = _allowlists_de_roles(sentencia)
        assert allowlists
        assert all(allowlist == _ROLES_PERMITIDOS for allowlist in allowlists)


def test_el_script_aplica_las_mismas_politicas(script):
    for politica in _POLITICAS:
        assert f"create policy {politica}" in script
    allowlists = _allowlists_de_roles(script)
    # select (1) + insert (1) + update using/with check (2)
    assert len(allowlists) == 4
    assert all(allowlist == _ROLES_PERMITIDOS for allowlist in allowlists)


@pytest.mark.parametrize("fuente", ["migracion", "script"])
def test_no_hay_borrado_fisico_para_los_clientes(migracion, script, fuente):
    texto = (
        "\n".join(migracion._sentencias_politicas())
        if fuente == "migracion"
        else script
    ).lower()

    assert "for delete" not in texto
    assert "revoke all on public.ventas_cobros from anon, authenticated" in texto
    assert (
        "grant select, insert, update on public.ventas_cobros to authenticated" in texto
    )
    assert "registrado_por_id = auth.uid()" in texto


def _valores_del_check(contenido: str) -> set[str]:
    coincidencia = re.search(r"medio_cobro in \(([^)]+)\)", contenido)
    assert coincidencia, "No se encontró el CHECK de medio_cobro"
    return {valor.strip().strip("'\"") for valor in coincidencia.group(1).split(",")}


def test_medios_de_cobro_coinciden_entre_modelo_migracion_y_script(script):
    """El modelo deriva los literales del enum; migración y script los escriben a mano."""
    esperados = {medio.value for medio in MedioCobro}
    restriccion = next(
        r
        for r in ventas_models.VentaCobro.__table__.constraints
        if r.name == "ck_ventas_cobros_medio_cobro_valido"
    )

    assert _valores_del_check(str(restriccion.sqltext)) == esperados
    assert _valores_del_check(_MIGRACION.read_text(encoding="utf-8")) == esperados
    assert _valores_del_check(script) == esperados
    assert "medio_cobro varchar not null" in script
