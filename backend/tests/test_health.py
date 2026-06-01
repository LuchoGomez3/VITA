import pytest


@pytest.mark.anyio
async def test_health_ok(client):
    resp = await client.get("/api/health")
    assert resp.status_code == 200
    body = resp.json()
    assert body["success"] is True
    assert "data" in body and "status" in body["data"]
