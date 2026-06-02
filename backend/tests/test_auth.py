import pytest

from api.auth.providers.local_provider import LocalAuthProvider


@pytest.mark.anyio
async def test_me_sin_token_devuelve_401(client):
    resp = await client.get("/api/auth/me")
    assert resp.status_code == 401


@pytest.mark.anyio
async def test_me_con_token_valido(client, usuario_actual):
    # Token local con sub = id del usuario sembrado; get_current_user lo resuelve.
    token = LocalAuthProvider().create_token_for(usuario_actual.id)
    resp = await client.get(
        "/api/auth/me", headers={"Authorization": f"Bearer {token}"}
    )
    assert resp.status_code == 200
    data = resp.json()["data"]
    assert data["id"] == str(usuario_actual.id)
    assert data["email"] == usuario_actual.email


@pytest.mark.anyio
async def test_me_con_token_invalido_devuelve_401(client):
    resp = await client.get(
        "/api/auth/me", headers={"Authorization": "Bearer no-es-un-token"}
    )
    assert resp.status_code == 401


@pytest.mark.anyio
async def test_login_fail(client):
    resp = await client.post(
        "/api/auth/login", data={"username": "admin", "password": "wrong"}
    )
    assert resp.status_code == 401
