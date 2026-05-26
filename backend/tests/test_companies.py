import pytest
from httpx import AsyncClient, ASGITransport
from api.main import app


@pytest.mark.anyio("asyncio")
async def test_companies_list_requires_auth_and_returns_companies():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as ac:
        # Authenticate to get token
        login_resp = await ac.post("/v1/auth/login", data={"username": "admin", "password": "admin"})
        assert login_resp.status_code == 200
        token = login_resp.json()["data"]["access_token"]

        # Call companies endpoint with token
        resp = await ac.get("/v1/companies/list", headers={"Authorization": f"Bearer {token}"})
        assert resp.status_code == 200
        body = resp.json()
        assert body["success"] is True
        assert "data" in body and "companies" in body["data"]
        assert body["data"]["companies"] == ["Visa", "Mastercard"]


@pytest.mark.anyio("asyncio")
async def test_companies_list_unauthorized_without_token():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as ac:
        resp = await ac.get("/v1/companies/list")
        assert resp.status_code == 401 