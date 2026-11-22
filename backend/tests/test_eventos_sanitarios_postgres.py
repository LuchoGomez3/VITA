"""Sanidad contra Postgres real: migración, script espejo, RLS y concurrencia.

Se saltean sin ``VITA_TEST_POSTGRES_URL`` (ver ``tests/postgres_helpers``). Lo
estático (encadenamiento y espejo) corre siempre.
"""

import asyncio
from datetime import date
import importlib.util
from pathlib import Path
import re
from uuid import uuid4

import asyncpg
from fastapi import FastAPI, HTTPException
from httpx import ASGITransport, AsyncClient
import pytest
from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker, create_async_engine
from sqlmodel import SQLModel

import api.modules  # noqa: F401  -- registra todas las tablas en la metadata
from api.auth.dependencies import get_current_user
from api.modules.animales.models import Animal
from api.modules.establecimientos.models import Establecimiento, UsuarioEstablecimiento
from api.modules.usuarios.models import Usuario
from api.shared.enums import EstadoAnimal, RolUsuario, SexoAnimal
from api.shared.exceptions import DomainException
from core.middlewares import custom_exception_handler, domain_exception_handler
from core.router import get_global_router
from database.database import get_session
from tests.postgres_helpers import (
    base_temporal,
    como_usuario,
    instalar_auth_supabase,
    requiere_postgres,
    simular_privilegios_por_defecto,
    url_sqlalchemy,
)
from tests.test_reglas_reproductivas_postgres import _alembic

_BACKEND = Path(__file__).parent.parent
_MIGRACION = (
    _BACKEND / "alembic/versions/20261121_01_eventos_sanitarios_por_operacion.py"
)
_SCRIPT_SQL = _BACKEND / "scripts/eventos_sanitarios_por_operacion.sql"
_REVISION = "20261121_01"
_REVISION_PREVIA = "20261122_01"
URL = "/api/v1/eventos_sanitarios"


@pytest.fixture(scope="module")
def migracion():
    spec = importlib.util.spec_from_file_location("sanidad", _MIGRACION)
    assert spec is not None and spec.loader is not None
    modulo = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(modulo)
    return modulo


def _normalizar(sql: str) -> str:
    return re.sub(r"\s+", " ", sql).strip().lower()


# ─── Estático ───────────────────────────────────────────────────────────────


def test_revision_y_encadenamiento(migracion):
    assert migracion.revision == _REVISION
    assert migracion.down_revision == _REVISION_PREVIA


def test_el_script_espejo_aplica_las_mismas_politicas(migracion):
    script = _normalizar(_SCRIPT_SQL.read_text(encoding="utf-8"))
    assert script.startswith("--") and "begin;" in script and script.endswith("commit;")
    for sentencia in migracion.sentencias_rls():
        if sentencia.strip().startswith(("revoke", "grant", "alter", "drop policy")):
            assert _normalizar(sentencia) in script, sentencia
    for nombre in (
        "ck_eventos_sanitarios_practica_modelo",
        "uq_eventos_sanitarios_version",
        "ix_eventos_sanitarios_historial",
        "ix_eventos_sanitarios_operacion",
        "ck_operaciones_sanitarias_tipo",
    ):
        assert nombre in script


# ─── Migración y script desde el esquema anterior ───────────────────────────

_PREVIO = (
    """
    create table usuarios (
        id uuid primary key, nombre varchar not null,
        created_at timestamptz not null default now(),
        updated_at timestamptz not null default now()
    )
    """,
    """
    create table establecimientos (
        id uuid primary key, nombre varchar not null,
        created_at timestamptz not null default now(),
        updated_at timestamptz not null default now()
    )
    """,
    """
    create table usuarios_establecimientos (
        id uuid primary key,
        usuario_id uuid not null references usuarios (id),
        establecimiento_id uuid not null references establecimientos (id),
        rol varchar not null, activo boolean not null default true
    )
    """,
    """
    create table animales (
        id uuid primary key,
        establecimiento_id uuid not null references establecimientos (id)
    )
    """,
    """
    create table lotes (
        id uuid primary key,
        establecimiento_id uuid not null references establecimientos (id)
    )
    """,
    """
    create table productos_sanitarios (
        id uuid primary key,
        created_at timestamptz not null default now(),
        updated_at timestamptz not null default now(),
        establecimiento_id uuid references establecimientos (id),
        nombre varchar not null, tipo varchar not null,
        enfermedad_objetivo varchar, periodo_carencia_dias integer not null
    )
    """,
    """
    create table eventos_sanitarios (
        id uuid primary key,
        created_at timestamptz not null default now(),
        updated_at timestamptz not null default now(),
        deleted_at timestamptz,
        establecimiento_id uuid not null references establecimientos (id),
        animal_id uuid not null references animales (id),
        tipo varchar not null,
        producto_id uuid references productos_sanitarios (id),
        fecha_aplicacion timestamptz not null,
        dosis varchar, periodo_carencia_dias integer, fecha_fin_carencia date,
        resultado varchar, responsable_id uuid references usuarios (id),
        observaciones varchar
    )
    """,
)
_MIEMBRO, _EXTRANIO, _CAMPO, _ANIMAL = uuid4(), uuid4(), uuid4(), uuid4()


async def _esquema_previo(url: str) -> None:
    conexion = await asyncpg.connect(url)
    try:
        await instalar_auth_supabase(conexion)
        await simular_privilegios_por_defecto(conexion)
        for sentencia in _PREVIO:
            await conexion.execute(sentencia)
        for usuario in (_MIEMBRO, _EXTRANIO):
            await conexion.execute(
                "insert into usuarios (id, nombre) values ($1, 'Sintético')", usuario
            )
        await conexion.execute(
            "insert into establecimientos (id, nombre) values ($1, 'X')", _CAMPO
        )
        await conexion.execute(
            "insert into usuarios_establecimientos values ($1, $2, $3, 'employee', true)",
            uuid4(),
            _MIEMBRO,
            _CAMPO,
        )
        await conexion.execute("insert into animales values ($1, $2)", _ANIMAL, _CAMPO)
        # Fila previa a VITA-20: tiene que sobrevivir a la migración.
        await conexion.execute(
            "insert into eventos_sanitarios"
            " (id, establecimiento_id, animal_id, tipo, fecha_aplicacion, resultado)"
            " values ($1, $2, $3, 'vacunacion', now(), 'texto viejo')",
            uuid4(),
            _CAMPO,
            _ANIMAL,
        )
    finally:
        await conexion.close()


async def _aplicar(url: str, camino: str) -> None:
    await _esquema_previo(url)
    if camino == "script":
        conexion = await asyncpg.connect(url)
        try:
            await conexion.execute(_SCRIPT_SQL.read_text(encoding="utf-8"))
        finally:
            await conexion.close()
        return
    assert _alembic(url, "stamp", _REVISION_PREVIA).returncode == 0
    resultado = _alembic(url, "upgrade", _REVISION)
    assert resultado.returncode == 0, resultado.stderr


async def _verificar(conexion: asyncpg.Connection) -> None:
    columnas = {
        fila["column_name"]
        for fila in await conexion.fetch(
            "select column_name from information_schema.columns"
            " where table_name = 'eventos_sanitarios'"
        )
    }
    assert {"operacion_id", "datos", "version", "resultado_fecha"} <= columnas
    assert await conexion.fetchval("select count(*) from eventos_sanitarios") == 1
    assert await conexion.fetchval(
        "select data_type = 'jsonb' from information_schema.columns"
        " where table_name = 'eventos_sanitarios' and column_name = 'datos'"
    )
    with pytest.raises(asyncpg.CheckViolationError):
        await conexion.execute("update eventos_sanitarios set practica_modelo = 'otro'")
    await conexion.execute("update productos_sanitarios set deleted_at = now()")

    evento = uuid4()
    await conexion.execute(
        "insert into eventos_sanitarios (id, establecimiento_id, animal_id, tipo,"
        " fecha_aplicacion, practica_id, practica_modelo, version)"
        " values ($1, $2, $3, 'analisis', now(), 'sangrado', 'muestreo', 1)",
        evento,
        _CAMPO,
        _ANIMAL,
    )
    with pytest.raises(asyncpg.UniqueViolationError):
        await conexion.execute(
            "insert into eventos_sanitarios (id, establecimiento_id, animal_id, tipo,"
            " fecha_aplicacion, version) values ($1, $2, $3, 'analisis', now(), 1)",
            uuid4(),
            _CAMPO,
            _ANIMAL,
        )
    await conexion.execute(
        "insert into operaciones_sanitarias"
        " (id, establecimiento_id, tipo, huella, usuario_id)"
        " values ($1, $2, 'alta', 'h', $3)",
        uuid4(),
        _CAMPO,
        _MIEMBRO,
    )

    # RLS: el miembro lee; otro usuario y anon, no; nadie escribe directo.
    async with como_usuario(conexion, _MIEMBRO) as c:
        assert await c.fetchval("select count(*) from eventos_sanitarios") == 2
        assert await c.fetchval("select count(*) from operaciones_sanitarias") == 1
        with pytest.raises(asyncpg.InsufficientPrivilegeError):
            await c.execute("update eventos_sanitarios set resultado = 'x'")
    async with como_usuario(conexion, _EXTRANIO) as c:
        assert await c.fetchval("select count(*) from eventos_sanitarios") == 0
    async with como_usuario(conexion, None) as c:
        with pytest.raises(asyncpg.InsufficientPrivilegeError):
            await c.fetchval("select count(*) from eventos_sanitarios")


@requiere_postgres
@pytest.mark.anyio
@pytest.mark.parametrize("camino", ("migracion", "script"))
async def test_migra_el_esquema_previo_y_aplica_rls(camino):
    async with base_temporal() as url:
        await _aplicar(url, camino)
        conexion = await asyncpg.connect(url)
        try:
            await _verificar(conexion)
        finally:
            await conexion.close()


@requiere_postgres
@pytest.mark.anyio
async def test_el_script_es_reejecutable_y_el_downgrade_vuelve_atras():
    async with base_temporal() as url:
        await _aplicar(url, "migracion")
        conexion = await asyncpg.connect(url)
        try:
            await conexion.execute(_SCRIPT_SQL.read_text(encoding="utf-8"))
        finally:
            await conexion.close()

        resultado = _alembic(url, "downgrade", _REVISION_PREVIA)
        assert resultado.returncode == 0, resultado.stderr

        conexion = await asyncpg.connect(url)
        try:
            assert (
                await conexion.fetchval("select to_regclass('operaciones_sanitarias')")
                is None
            )
            assert (
                await conexion.fetchval("select count(*) from eventos_sanitarios") == 1
            )
        finally:
            await conexion.close()


# ─── Concurrencia en el servicio ────────────────────────────────────────────


async def _app_sobre(url: str):
    """App con la base temporal y un usuario miembro de un campo con 2 animales."""
    engine = create_async_engine(url_sqlalchemy(url))
    async with engine.begin() as conn:
        await conn.run_sync(SQLModel.metadata.create_all)
    maker = async_sessionmaker(engine, class_=AsyncSession, expire_on_commit=False)
    usuario = Usuario(
        id=uuid4(),
        nombre="Test",
        apellido="User",
        email="t@vita.test",
        cuit="20111111112",
    )
    campo = Establecimiento(
        id=_CAMPO, owner_id=usuario.id, nombre="X", nro_renspa="01.002.3.04567"
    )
    animales = [
        Animal(
            establecimiento_id=_CAMPO,
            nro_caravana_rfid=f"98200055500000{indice}",
            sexo=SexoAnimal.hembra,
            raza="Angus",
            fecha_nacimiento=date(2024, 1, 1),
            estado=EstadoAnimal.activo,
        )
        for indice in range(2)
    ]
    async with maker() as s:
        # Sin relationships el ORM no ordena los INSERT: se hacen de a uno.
        s.add(usuario)
        await s.flush()
        s.add(campo)
        await s.flush()
        s.add(
            UsuarioEstablecimiento(
                usuario_id=usuario.id,
                establecimiento_id=_CAMPO,
                rol=RolUsuario.owner,
                activo=True,
            )
        )
        s.add_all(animales)
        await s.commit()
    usuario_id = usuario.id
    animales = [a.id for a in animales]

    app = FastAPI()
    app.include_router(get_global_router(), prefix="/api")
    app.add_exception_handler(HTTPException, custom_exception_handler)
    app.add_exception_handler(DomainException, domain_exception_handler)

    async def _sesion():
        async with maker() as s:
            try:
                yield s
                await s.commit()
            except Exception:
                await s.rollback()
                raise

    async def _usuario():
        async with maker() as s:
            return await s.get(Usuario, usuario_id)

    app.dependency_overrides[get_session] = _sesion
    app.dependency_overrides[get_current_user] = _usuario
    return app, engine, animales


def _alta(animales, practica="sangrado") -> dict:
    return {
        "id": str(uuid4()),
        "establecimiento_id": str(_CAMPO),
        "practica_id": practica,
        "fecha_aplicacion": "2026-11-21T13:00:00Z",
        "responsable": "Operario",
        "datos": {"descripcion": "Control", "tipo_muestra": "Sangre"},
        "animales": [{"id": str(uuid4()), "animal_id": str(a)} for a in animales],
    }


@requiere_postgres
@pytest.mark.anyio
async def test_envios_simultaneos_no_duplican_y_el_resultado_tiene_un_ganador():
    async with base_temporal() as url:
        app, engine, animales = await _app_sobre(url)
        try:
            transporte = ASGITransport(app=app)
            async with AsyncClient(transport=transporte, base_url="http://test") as c:
                cuerpo = _alta(animales)
                a, b = await asyncio.gather(
                    c.post(URL, json=cuerpo), c.post(URL, json=cuerpo)
                )
                assert a.status_code == b.status_code == 201, (a.text, b.text)
                assert a.json()["data"] == b.json()["data"]

                otra = await c.post(URL, json=_alta(animales))
                assert otra.status_code == 201

                evento = a.json()["data"][0]["id"]
                r1, r2 = await asyncio.gather(
                    *(
                        c.put(
                            f"{URL}/{evento}/resultado",
                            json={
                                "id": str(uuid4()),
                                "resultado": valor,
                                "fecha": "2026-11-21T15:00:00Z",
                            },
                        )
                        for valor in ("Negativo", "Positivo")
                    )
                )
                assert sorted([r1.status_code, r2.status_code]) == [200, 409]

                pagina = await c.get(URL, params={"establecimiento_id": str(_CAMPO)})
        finally:
            await engine.dispose()

        conexion = await asyncpg.connect(url)
        try:
            assert (
                await conexion.fetchval("select count(*) from eventos_sanitarios") == 4
            )
            versiones = await conexion.fetch(
                "select version from eventos_sanitarios order by version"
            )
        finally:
            await conexion.close()
        # Versiones únicas y sin huecos: 4 altas más 1 resultado.
        assert [v["version"] for v in versiones] == [2, 3, 4, 5]
        assert [e["id"] for e in pagina.json()["data"]][-1] == evento
