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
    assert data["cuit"] == usuario_actual.cuit


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


@pytest.mark.anyio
async def test_refresh_devuelve_sesion_nueva(client, usuario_actual):
    # Un refresh token válido del usuario sembrado debe renovar la sesión y
    # devolver un access nuevo + refresh rotado + expiración + perfil.
    refresh_token = LocalAuthProvider().create_refresh_token_for(usuario_actual.id)
    resp = await client.post("/api/auth/refresh", json={"refresh_token": refresh_token})
    assert resp.status_code == 200
    data = resp.json()["data"]
    assert data["access_token"]
    assert data["refresh_token"]
    assert data["expires_in"] > 0
    assert data["token_type"] == "bearer"
    assert data["usuario"]["id"] == str(usuario_actual.id)
    assert data["usuario"]["cuit"] == usuario_actual.cuit

    # El access token renovado debe autenticar /auth/me.
    me = await client.get(
        "/api/auth/me",
        headers={"Authorization": f"Bearer {data['access_token']}"},
    )
    assert me.status_code == 200


@pytest.mark.anyio
async def test_login_incluye_refresh_token(app, usuario_actual):
    # Forzamos un provider local cuyo sign_in acepta credenciales (el default
    # rechaza por diseño) para verificar que /auth/login expone la sesión completa.
    from api.auth.providers import AuthResult, get_auth_provider
    from api.auth.providers.local_provider import LocalAuthProvider
    from httpx import ASGITransport, AsyncClient

    class _StubProvider(LocalAuthProvider):
        async def sign_in(self, email: str, password: str) -> AuthResult:
            return AuthResult(
                user_id=usuario_actual.id,
                access_token=self.create_token_for(usuario_actual.id),
                refresh_token=self.create_refresh_token_for(usuario_actual.id),
                expires_in=3600,
            )

    app.dependency_overrides[get_auth_provider] = _StubProvider
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as ac:
        resp = await ac.post(
            "/api/auth/login",
            data={"username": usuario_actual.email, "password": "x"},
        )
    assert resp.status_code == 200
    data = resp.json()["data"]
    assert data["access_token"]
    assert data["refresh_token"]
    assert data["expires_in"] == 3600
    assert data["usuario"]["cuit"] == usuario_actual.cuit


@pytest.mark.anyio
async def test_refresh_invalido_devuelve_401(client, usuario_actual):
    # Un access token (typ != "refresh") no sirve como refresh.
    access_token = LocalAuthProvider().create_token_for(usuario_actual.id)
    resp = await client.post("/api/auth/refresh", json={"refresh_token": access_token})
    assert resp.status_code == 401

    resp2 = await client.post(
        "/api/auth/refresh", json={"refresh_token": "no-es-un-token"}
    )
    assert resp2.status_code == 401
