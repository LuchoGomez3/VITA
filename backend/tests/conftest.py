import pytest
from fastapi import FastAPI
from httpx import ASGITransport, AsyncClient

from core.router import get_global_router


@pytest.fixture
def app():
    """Minimal test app without DB lifespan."""
    test_app = FastAPI()
    test_app.include_router(get_global_router(), prefix="/api")
    return test_app


@pytest.fixture
async def client(app):
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as ac:
        yield ac
