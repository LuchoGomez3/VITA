"""Migración 20261017_02 (equipo del establecimiento, adr-0012).

La parte estática corre siempre. La parte contra Postgres real se saltea sin
``VITA_TEST_POSTGRES_URL`` y prueba los dos caminos de producción, Alembic y el
script espejo, más el downgrade y la reejecución sobre un esquema ya completo.
"""

import importlib.util
from pathlib import Path
import re
from uuid import uuid4

import asyncpg
import pytest
from sqlalchemy.ext.asyncio import create_async_engine
from sqlmodel import SQLModel

import api.modules  # noqa: F401  -- registra todas las tablas en la metadata
from api.modules.equipo import models as equipo_models
from api.modules.equipo.models import InvitacionEstablecimiento
from api.modules.establecimientos import models as establecimientos_models
from tests.postgres_helpers import base_temporal, requiere_postgres, url_sqlalchemy
from tests.test_reglas_reproductivas_postgres import _alembic

_BACKEND = Path(__file__).parent.parent
_MIGRACION = _BACKEND / "alembic/versions/20261017_02_equipo_establecimiento.py"
_SCRIPT_SQL = _BACKEND / "scripts/equipo_establecimiento.sql"
_REVISION_PREVIA = "20261017_01"


@pytest.fixture(scope="module")
def migracion():
    spec = importlib.util.spec_from_file_location("equipo_establecimiento", _MIGRACION)
    assert spec is not None and spec.loader is not None
    modulo = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(modulo)
    return modulo


def _normalizar(sql: str) -> str:
    return re.sub(r"\s+", " ", sql).strip().lower()


# ─── Estático ───────────────────────────────────────────────────────────────


def test_revision_y_encadenamiento(migracion):
    assert migracion.revision == "20261017_02"
    assert migracion.down_revision == _REVISION_PREVIA


def test_los_checks_son_copia_literal_de_los_modelos(migracion):
    assert migracion._CHECK_ROL == establecimientos_models.CHECK_ROL_USUARIO
    assert migracion._CHECK_ESTADO == equipo_models.CHECK_ESTADO_INVITACION
    assert migracion._WHERE_PENDIENTE == equipo_models.WHERE_PENDIENTE


def test_los_indices_del_modelo_son_los_que_crea_la_migracion(migracion):
    fuente = _MIGRACION.read_text(encoding="utf-8")
    script = _SCRIPT_SQL.read_text(encoding="utf-8")
    for indice in InvitacionEstablecimiento.__table__.indexes:
        assert indice.name in fuente
        assert indice.name in script


def test_el_script_espejo_hace_lo_mismo_que_la_migracion(migracion):
    script = _normalizar(_SCRIPT_SQL.read_text(encoding="utf-8"))
    assert script.startswith("--") and "begin;" in script and script.endswith("commit;")
    assert _normalizar(f"check ({migracion._CHECK_ROL})") in script
    assert _normalizar(f"check ({migracion._CHECK_ESTADO})") in script
    assert _normalizar(f"where {migracion._WHERE_PENDIENTE}") in script
    assert "enable row level security" in script


# ─── Postgres ───────────────────────────────────────────────────────────────

# Esquema previo mínimo: las tablas que la migración toca o referencia.
_PREVIO = (
    """
    create table usuarios (
        id uuid primary key, nombre varchar not null, apellido varchar not null,
        email varchar not null, is_platform_admin boolean not null default false,
        created_at timestamptz not null default now(),
        updated_at timestamptz not null default now()
    )
    """,
    """
    create table establecimientos (
        id uuid primary key, owner_id uuid not null references usuarios (id),
        nombre varchar not null,
        created_at timestamptz not null default now(),
        updated_at timestamptz not null default now()
    )
    """,
    """
    create table usuarios_establecimientos (
        id uuid primary key,
        usuario_id uuid not null references usuarios (id),
        establecimiento_id uuid not null references establecimientos (id),
        rol varchar not null, activo boolean not null default true,
        created_at timestamptz not null default now(),
        updated_at timestamptz not null default now(),
        constraint ck_usuarios_establecimientos_rol
            check (rol IN ('admin', 'owner', 'employee')),
        constraint uq_usuario_establecimiento_rol
            unique (usuario_id, establecimiento_id, rol)
    )
    """,
)
_USUARIO, _CAMPO = uuid4(), uuid4()


async def _sembrar(conexion: asyncpg.Connection) -> None:
    await conexion.execute(
        "insert into usuarios (id, nombre, apellido, email, is_platform_admin)"
        " values ($1, 'Test', 'Sintético', 'owner@example.com', false)",
        _USUARIO,
    )
    await conexion.execute(
        "insert into establecimientos (id, owner_id, nombre) values ($1, $2, 'X')",
        _CAMPO,
        _USUARIO,
    )


async def _aplicar(url: str, camino: str) -> None:
    conexion = await asyncpg.connect(url)
    try:
        for sentencia in _PREVIO:
            await conexion.execute(sentencia)
        await _sembrar(conexion)
        if camino == "script":
            await conexion.execute(_SCRIPT_SQL.read_text(encoding="utf-8"))
            return
    finally:
        await conexion.close()
    assert _alembic(url, "stamp", _REVISION_PREVIA).returncode == 0
    resultado = _alembic(url, "upgrade", "20261017_02")
    assert resultado.returncode == 0, resultado.stderr


async def _invitar(conexion: asyncpg.Connection, email: str, estado: str) -> None:
    await conexion.execute(
        "insert into invitaciones_establecimientos"
        " (id, establecimiento_id, email, rol, codigo_hash, expira_en, estado,"
        "  invitado_por_id)"
        " values ($1, $2, $3, 'veterinarian', $4, now(), $5, $6)",
        uuid4(),
        _CAMPO,
        email,
        uuid4().hex,
        estado,
        _USUARIO,
    )


async def _verificar_esquema(conexion: asyncpg.Connection) -> None:
    await conexion.execute(
        "insert into usuarios_establecimientos"
        " (id, usuario_id, establecimiento_id, rol, activo)"
        " values ($1, $2, $3, 'veterinarian', true)",
        uuid4(),
        _USUARIO,
        _CAMPO,
    )
    await _invitar(conexion, "a@example.com", "pendiente")
    await _invitar(conexion, "a@example.com", "cancelada")
    await _invitar(conexion, "a@example.com", "aceptada")
    with pytest.raises(asyncpg.UniqueViolationError):
        await _invitar(conexion, "a@example.com", "pendiente")
    with pytest.raises(asyncpg.CheckViolationError):
        await _invitar(conexion, "b@example.com", "vencida")
    rls = await conexion.fetchval(
        "select relrowsecurity from pg_class where relname = 'invitaciones_establecimientos'"
    )
    assert rls is True


@requiere_postgres
@pytest.mark.anyio
@pytest.mark.parametrize("camino", ("migracion", "script"))
async def test_amplia_los_roles_y_crea_las_invitaciones(camino):
    async with base_temporal() as url:
        await _aplicar(url, camino)
        conexion = await asyncpg.connect(url)
        try:
            await _verificar_esquema(conexion)
        finally:
            await conexion.close()


@requiere_postgres
@pytest.mark.anyio
async def test_el_script_es_reejecutable():
    async with base_temporal() as url:
        await _aplicar(url, "script")
        conexion = await asyncpg.connect(url)
        try:
            await conexion.execute(_SCRIPT_SQL.read_text(encoding="utf-8"))
            await _verificar_esquema(conexion)
        finally:
            await conexion.close()


@requiere_postgres
@pytest.mark.anyio
async def test_el_downgrade_vuelve_veterinarios_a_empleados():
    async with base_temporal() as url:
        await _aplicar(url, "migracion")
        conexion = await asyncpg.connect(url)
        try:
            otro_campo = uuid4()
            await conexion.execute(
                "insert into establecimientos (id, owner_id, nombre) values ($1, $2, 'Y')",
                otro_campo,
                _USUARIO,
            )
            # En _CAMPO solo es veterinario; en otro_campo es ambas cosas.
            for campo, rol in (
                (_CAMPO, "veterinarian"),
                (otro_campo, "veterinarian"),
                (otro_campo, "employee"),
            ):
                await conexion.execute(
                    "insert into usuarios_establecimientos"
                    " (id, usuario_id, establecimiento_id, rol, activo)"
                    " values ($1, $2, $3, $4, true)",
                    uuid4(),
                    _USUARIO,
                    campo,
                    rol,
                )
        finally:
            await conexion.close()

        resultado = _alembic(url, "downgrade", _REVISION_PREVIA)
        assert resultado.returncode == 0, resultado.stderr

        conexion = await asyncpg.connect(url)
        try:
            filas = await conexion.fetch(
                "select establecimiento_id, rol from usuarios_establecimientos"
            )
            tabla = await conexion.fetchval(
                "select to_regclass('invitaciones_establecimientos')"
            )
        finally:
            await conexion.close()
        assert sorted((f["establecimiento_id"] == _CAMPO, f["rol"]) for f in filas) == [
            (False, "employee"),
            (True, "employee"),
        ]
        assert tabla is None


@requiere_postgres
@pytest.mark.anyio
async def test_sobre_un_esquema_completo_la_migracion_no_hace_nada():
    async with base_temporal() as url:
        engine = create_async_engine(url_sqlalchemy(url))
        try:
            async with engine.begin() as conn:
                await conn.run_sync(SQLModel.metadata.create_all)
        finally:
            await engine.dispose()
        conexion = await asyncpg.connect(url)
        try:
            await _sembrar(conexion)
        finally:
            await conexion.close()

        assert _alembic(url, "stamp", _REVISION_PREVIA).returncode == 0
        resultado = _alembic(url, "upgrade", "20261017_02")
        assert resultado.returncode == 0, resultado.stderr

        conexion = await asyncpg.connect(url)
        try:
            await _verificar_esquema(conexion)
        finally:
            await conexion.close()
