"""Helpers para tests que necesitan un Postgres real (triggers, locks, RLS).

SQLite no ejecuta plpgsql ni ``for update``, así que esas garantías solo se
pueden probar contra Postgres. Estos helpers **no levantan contenedores ni hacen
pull de imágenes**: consumen un servidor ya provisto en ``VITA_TEST_POSTGRES_URL``
y, sin esa variable, los tests que los usan se saltean (el CI no la define).

La URL debe apuntar a un Postgres descartable con un usuario que pueda crear
bases y roles, por ejemplo::

    docker run -d --rm --name vita-pg -e POSTGRES_PASSWORD=vita \\
        -p 127.0.0.1:55432:5432 postgres:16-alpine
    export VITA_TEST_POSTGRES_URL=postgresql://postgres:vita@127.0.0.1:55432/postgres

Nunca apuntarla a Supabase: cada test crea y borra bases enteras.

Cada llamada a ``base_temporal`` crea una base con nombre aleatorio y la elimina
al salir, así los tests no comparten estado. ``instalar_auth_supabase`` simula
lo mínimo de Supabase que usan las políticas: los roles ``anon`` y
``authenticated`` y ``auth.uid()`` leyendo el ``sub`` del JWT de la sesión.
"""

from collections.abc import AsyncIterator
from contextlib import asynccontextmanager
import os
from uuid import UUID, uuid4

import asyncpg
import pytest

URL_ENV = "VITA_TEST_POSTGRES_URL"

requiere_postgres = pytest.mark.skipif(
    not os.getenv(URL_ENV),
    reason=f"{URL_ENV} no está definida: se necesita un Postgres descartable.",
)


def _url_servidor() -> str:
    url = os.environ[URL_ENV]
    # asyncpg no entiende el sufijo de dialecto de SQLAlchemy.
    return url.replace("postgresql+asyncpg://", "postgresql://")


def _url_con_base(nombre: str) -> str:
    base, _, _ = _url_servidor().rpartition("/")
    return f"{base}/{nombre}"


def url_sqlalchemy(url: str) -> str:
    """Convierte la URL de asyncpg en una que SQLAlchemy async acepte."""
    return url.replace("postgresql://", "postgresql+asyncpg://", 1)


@asynccontextmanager
async def base_temporal() -> AsyncIterator[str]:
    """Crea una base vacía y devuelve su URL (formato asyncpg); la borra al salir."""
    nombre = f"vita_test_{uuid4().hex[:12]}"
    admin = await asyncpg.connect(_url_servidor())
    try:
        await admin.execute(f'create database "{nombre}"')
    finally:
        await admin.close()
    try:
        yield _url_con_base(nombre)
    finally:
        admin = await asyncpg.connect(_url_servidor())
        try:
            await admin.execute(f'drop database if exists "{nombre}" with (force)')
        finally:
            await admin.close()


_AUTH_SUPABASE = (
    """
    do $$
    begin
        if not exists (select 1 from pg_roles where rolname = 'anon') then
            create role anon nologin;
        end if;
        if not exists (select 1 from pg_roles where rolname = 'authenticated') then
            create role authenticated nologin;
        end if;
    end
    $$
    """,
    "create schema if not exists auth",
    """
    create or replace function auth.uid() returns uuid
    language sql stable
    as $$
        select nullif(current_setting('request.jwt.claim.sub', true), '')::uuid
    $$
    """,
    "grant usage on schema auth to anon, authenticated",
    "grant usage on schema public to anon, authenticated",
)


async def instalar_auth_supabase(conexion: asyncpg.Connection) -> None:
    """Crea los roles y ``auth.uid()`` que las migraciones detectan como Supabase.

    Los roles son globales al servidor, por eso la creación es idempotente.
    """
    for sentencia in _AUTH_SUPABASE:
        await conexion.execute(sentencia)


async def simular_privilegios_por_defecto(conexion: asyncpg.Connection) -> None:
    """Reproduce los privilegios que Supabase otorga a toda tabla nueva en ``public``.

    Llamarla antes de crear el esquema: así un test comprueba que la migración
    los recorta, y no que nunca existieron.
    """
    await conexion.execute(
        "alter default privileges in schema public"
        " grant all on tables to anon, authenticated"
    )


@asynccontextmanager
async def como_usuario(
    conexion: asyncpg.Connection, usuario_id: UUID | None
) -> AsyncIterator[asyncpg.Connection]:
    """Ejecuta el bloque como un cliente de Supabase autenticado con ese ``sub``.

    Con ``None`` se comporta como ``anon``. Todo corre en una transacción que se
    revierte al salir, así el bloque no deja datos ni cambia el rol de la conexión.
    """
    transaccion = conexion.transaction()
    await transaccion.start()
    try:
        if usuario_id is None:
            await conexion.execute("set local role anon")
        else:
            await conexion.execute(
                "select set_config('request.jwt.claim.sub', $1, true)",
                str(usuario_id),
            )
            await conexion.execute("set local role authenticated")
        yield conexion
    finally:
        await transaccion.rollback()
