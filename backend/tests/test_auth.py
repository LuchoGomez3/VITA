import pytest

from api.auth.providers.local_provider import LocalAuthProvider
from core.config import settings


@pytest.mark.anyio
async def test_openapi_solicita_solo_token_bearer(app):
    """Swagger debe pedir un JWT, no usuario y contraseña en Authorize."""
    esquema = app.openapi()
    seguridad = esquema["components"]["securitySchemes"]

    assert seguridad == {
        "BearerAuth": {
            "type": "http",
            "description": (
                "Pegue únicamente el access token JWT, sin escribir el prefijo Bearer."
            ),
            "scheme": "bearer",
        }
    }
    assert esquema["paths"]["/api/auth/me"]["get"]["security"] == [{"BearerAuth": []}]


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
async def test_me_no_acepta_token_por_query(client, usuario_actual):
    token = LocalAuthProvider().create_token_for(usuario_actual.id)

    resp = await client.get(f"/api/auth/me?token={token}")

    assert resp.status_code == 401


@pytest.mark.anyio
async def test_me_no_acepta_refresh_token_como_bearer(client, usuario_actual):
    refresh_token = LocalAuthProvider().create_refresh_token_for(usuario_actual.id)

    resp = await client.get(
        "/api/auth/me",
        headers={"Authorization": f"Bearer {refresh_token}"},
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


@pytest.mark.anyio
@pytest.mark.parametrize(
    ("path", "payload", "setting_name"),
    [
        ("/api/v1/usuarios/registro", {}, "AUTH_REGISTRATION_RATE_LIMIT"),
        ("/api/auth/login", {}, "AUTH_LOGIN_RATE_LIMIT"),
        ("/api/auth/refresh", {}, "AUTH_REFRESH_RATE_LIMIT"),
    ],
)
async def test_endpoints_auth_aplican_rate_limit(
    client,
    monkeypatch,
    path,
    payload,
    setting_name,
):
    monkeypatch.setattr(settings, setting_name, 1)

    await client.post(path, json=payload)
    limited = await client.post(path, json=payload)

    assert limited.status_code == 429


@pytest.mark.anyio
async def test_logout_requiere_sesion_y_acepta_token_valido(client, usuario_actual):
    without_token = await client.post("/api/auth/logout")
    token = LocalAuthProvider().create_token_for(usuario_actual.id)
    with_token = await client.post(
        "/api/auth/logout",
        headers={"Authorization": f"Bearer {token}"},
    )

    assert without_token.status_code == 401
    assert with_token.status_code == 200
