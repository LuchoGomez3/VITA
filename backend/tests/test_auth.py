import pytest
from httpx import AsyncClient, ASGITransport
from api.main import app

@pytest.mark.anyio("asyncio")
async def test_login_and_me():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as ac:
        resp = await ac.post("/v1/auth/login", data={"username": "admin", "password": "admin"})
        assert resp.status_code == 200
        token = resp.json()["data"]["access_token"]
        resp2 = await ac.get("/v1/auth/me", headers={"Authorization": f"Bearer {token}"})
        assert resp2.status_code == 200
        assert resp2.json()["data"]["username"] == "admin"

@pytest.mark.anyio("asyncio")
async def test_login_fail():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as ac:
        resp = await ac.post("/v1/auth/login", data={"username": "admin", "password": "wrong"})
        assert resp.status_code == 401 