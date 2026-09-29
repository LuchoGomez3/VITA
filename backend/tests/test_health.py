import pytest
from httpx import ASGITransport, AsyncClient

from core.server import create_fastapi_app


@pytest.mark.anyio
async def test_health_ok(client):
    resp = await client.get("/api/health")
    assert resp.status_code == 200
    body = resp.json()
    assert body["success"] is True
    assert "data" in body and "status" in body["data"]


async def _get_version() -> dict:
    # /version vive en la factory, no en el router global que monta el conftest.
    # ASGITransport no dispara el lifespan, así que no hace falta base de datos.
    app = create_fastapi_app()
    async with AsyncClient(
        transport=ASGITransport(app=app), base_url="http://test"
    ) as c:
        resp = await c.get("/version")
    assert resp.status_code == 200
    return resp.json()


@pytest.mark.anyio
async def test_version_prioriza_git_sha(monkeypatch):
    monkeypatch.setenv("GIT_SHA", "abc123")
    monkeypatch.setenv("RENDER_GIT_COMMIT", "def456")
    assert await _get_version() == {"commit": "abc123"}


@pytest.mark.anyio
async def test_version_usa_commit_de_render_sin_git_sha(monkeypatch):
    monkeypatch.delenv("GIT_SHA", raising=False)
    monkeypatch.setenv("RENDER_GIT_COMMIT", "def456")
    assert await _get_version() == {"commit": "def456"}
