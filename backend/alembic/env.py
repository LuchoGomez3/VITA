"""Configuración de Alembic para el esquema PostgreSQL de VITA."""

from __future__ import annotations

import asyncio
from logging.config import fileConfig
from pathlib import Path
import sys

from alembic import context
from sqlalchemy import pool
from sqlalchemy.ext.asyncio import async_engine_from_config
from sqlmodel import SQLModel

# Alembic carga env.py como un módulo aislado. Agregamos rutas absolutas para
# que funcione igual en Windows y Linux, independientemente del directorio desde
# el que se invoque el comando.
_BACKEND_DIR = Path(__file__).resolve().parents[1]
_REPOSITORY_DIR = _BACKEND_DIR.parent
for path in (_BACKEND_DIR, _REPOSITORY_DIR):
    path_string = str(path)
    if path_string not in sys.path:
        sys.path.insert(0, path_string)

# Registra todos los modelos antes de exponer metadata a Alembic.
import api.modules  # noqa: F401, E402
from core.config import settings  # noqa: E402

config = context.config

if config.config_file_name is not None:
    fileConfig(config.config_file_name)

# ConfigParser interpreta los porcentajes; duplicarlos permite URLs que los
# contengan sin alterar la contraseña ni registrar el secreto en el repositorio.
config.set_main_option("sqlalchemy.url", settings.DATABASE_URL.replace("%", "%%"))
target_metadata = SQLModel.metadata


def run_migrations_offline() -> None:
    """Genera SQL sin abrir una conexión a la base."""
    context.configure(
        url=config.get_main_option("sqlalchemy.url"),
        target_metadata=target_metadata,
        literal_binds=True,
        dialect_opts={"paramstyle": "named"},
        compare_type=True,
    )

    with context.begin_transaction():
        context.run_migrations()


def do_run_migrations(connection) -> None:
    context.configure(
        connection=connection,
        target_metadata=target_metadata,
        compare_type=True,
    )

    with context.begin_transaction():
        context.run_migrations()


async def run_async_migrations() -> None:
    connect_args: dict[str, int] = {}
    if settings.DB_USE_PGBOUNCER:
        connect_args["statement_cache_size"] = 0

    connectable = async_engine_from_config(
        config.get_section(config.config_ini_section, {}),
        prefix="sqlalchemy.",
        poolclass=pool.NullPool,
        connect_args=connect_args,
    )

    async with connectable.connect() as connection:
        await connection.run_sync(do_run_migrations)

    await connectable.dispose()


def run_migrations_online() -> None:
    asyncio.run(run_async_migrations())


if context.is_offline_mode():
    run_migrations_offline()
else:
    run_migrations_online()
