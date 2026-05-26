import pytest
from httpx import AsyncClient, ASGITransport
from api.main import app

@pytest.mark.anyio("asyncio")
async def test_health_ok():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as ac:
        resp = await ac.get("/v1/health")
    assert resp.status_code == 200
    body = resp.json()
    assert body["success"] is True
    assert "data" in body and "status" in body["data"] 