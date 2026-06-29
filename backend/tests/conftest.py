"""Fixtures de test.

DB SQLite in-memory (aiosqlite) compartida vía ``StaticPool``, con override de
``get_session`` y ``get_current_user`` sobre la app. Permite tests de
integración async sin Postgres ni Supabase reales.
"""

import sys
from pathlib import Path
from uuid import uuid4

import pytest

# Agregar la raíz del monorepo a PYTHONPATH
_monorepo_root = Path(__file__).parent.parent.parent
sys.path.insert(0, str(_monorepo_root))
from fastapi import FastAPI, HTTPException  # noqa: E402
from httpx import ASGITransport, AsyncClient  # noqa: E402
from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker, create_async_engine  # noqa: E402
from sqlalchemy.pool import StaticPool  # noqa: E402
from sqlmodel import SQLModel  # noqa: E402

import api.modules  # noqa: F401, E402  -- registra todas las tablas en SQLModel.metadata
from api.auth.dependencies import get_current_user  # noqa: E402
from api.auth.providers import get_auth_provider  # noqa: E402
from api.auth.providers.local_provider import LocalAuthProvider  # noqa: E402
from api.modules.usuarios.models import Usuario  # noqa: E402
from api.shared.exceptions import DomainException  # noqa: E402
from core.middlewares import custom_exception_handler, domain_exception_handler  # noqa: E402
from core.router import get_global_router  # noqa: E402
from database.database import get_session  # noqa: E402


@pytest.fixture
def anyio_backend() -> str:
    # Forzar asyncio: aiosqlite/asyncpg no corren sobre trio.
    return "asyncio"


@pytest.fixture
async def engine():
    eng = create_async_engine(
        "sqlite+aiosqlite://",
        connect_args={"check_same_thread": False},
        poolclass=StaticPool,
    )
    async with eng.begin() as conn:
        await conn.run_sync(SQLModel.metadata.create_all)
    yield eng
    await eng.dispose()


@pytest.fixture
def session_maker(engine):
    return async_sessionmaker(engine, class_=AsyncSession, expire_on_commit=False)


@pytest.fixture
async def session(session_maker) -> AsyncSession:
    async with session_maker() as s:
        yield s


@pytest.fixture
def app(session_maker) -> FastAPI:
    test_app = FastAPI()
    test_app.include_router(get_global_router(), prefix="/api")
    test_app.add_exception_handler(HTTPException, custom_exception_handler)
    test_app.add_exception_handler(DomainException, domain_exception_handler)

    async def _override_get_session():
        async with session_maker() as s:
            try:
                yield s
                await s.commit()
            except Exception:
                await s.rollback()
                raise

    test_app.dependency_overrides[get_session] = _override_get_session
    # Provider local: los tests no deben depender del AUTH_PROVIDER del .env ni
    # tocar Supabase real (alta de credenciales offline, sin red).
    test_app.dependency_overrides[get_auth_provider] = lambda: LocalAuthProvider()
    return test_app


@pytest.fixture
async def client(app) -> AsyncClient:
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as ac:
        yield ac


@pytest.fixture
async def usuario_actual(session) -> Usuario:
    """Usuario autenticado de prueba, persistido en la DB de test."""
    usuario = Usuario(
        id=uuid4(),
        nombre="Test",
        apellido="User",
        email="test@vita.test",
        cuit="20111111112",
    )
    session.add(usuario)
    await session.commit()
    await session.refresh(usuario)
    return usuario


@pytest.fixture
async def auth_client(app, usuario_actual) -> AsyncClient:
    """Cliente con ``get_current_user`` overrideado al usuario de prueba."""

    async def _override_current_user():
        return usuario_actual

    app.dependency_overrides[get_current_user] = _override_current_user
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as ac:
        yield ac
