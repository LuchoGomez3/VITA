import pytest


@pytest.mark.anyio
async def test_login_and_me(client):
    resp = await client.post(
        "/api/auth/login", data={"username": "admin", "password": "admin"}
    )
    assert resp.status_code == 200
    token = resp.json()["data"]["access_token"]

    resp2 = await client.get(
        "/api/auth/me", headers={"Authorization": f"Bearer {token}"}
    )
    assert resp2.status_code == 200
    assert resp2.json()["data"]["username"] == "admin"


@pytest.mark.anyio
async def test_login_fail(client):
    resp = await client.post(
        "/api/auth/login", data={"username": "admin", "password": "wrong"}
    )
    assert resp.status_code == 401
