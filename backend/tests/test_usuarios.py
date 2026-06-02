"""Tests de PRO-15: registro de dueño de campo."""

import pytest
from sqlalchemy import select

from api.modules.usuarios.models import Usuario
from api.modules.usuarios.utils import validar_cuit

CUIT_VALIDO = "20111111112"


def _payload(**overrides):
    base = {
        "nombre": "Juan",
        "apellido": "Pérez",
        "cuit": CUIT_VALIDO,
        "email": "juan@campo.com",
        "password": "Segura123",
    }
    base.update(overrides)
    return base


@pytest.mark.anyio
async def test_registro_exitoso(client, session):
    resp = await client.post("/api/v1/usuarios/registro", json=_payload())
    assert resp.status_code == 201
    body = resp.json()
    assert body["success"] is True
    assert body["data"]["usuario"]["email"] == "juan@campo.com"
    assert body["data"]["access_token"]
    assert body["data"]["token_type"] == "bearer"
    # El password no se expone.
    assert "password" not in body["data"]["usuario"]

    # El perfil quedó persistido en la DB.
    result = await session.execute(
        select(Usuario).where(Usuario.email == "juan@campo.com")
    )
    usuario = result.scalar_one()
    assert usuario.cuit == CUIT_VALIDO


@pytest.mark.anyio
async def test_registro_email_duplicado(client):
    await client.post("/api/v1/usuarios/registro", json=_payload())
    # Mismo email, distinto CUIT válido.
    resp = await client.post(
        "/api/v1/usuarios/registro",
        json=_payload(cuit="20111111120"),
    )
    assert resp.status_code == 409
    assert resp.json()["errors"][0]["code"] == "email_ya_registrado"


@pytest.mark.anyio
async def test_registro_cuit_duplicado(client):
    await client.post("/api/v1/usuarios/registro", json=_payload())
    resp = await client.post(
        "/api/v1/usuarios/registro",
        json=_payload(email="otro@campo.com"),
    )
    assert resp.status_code == 409
    assert resp.json()["errors"][0]["code"] == "cuit_ya_registrado"


@pytest.mark.anyio
async def test_registro_cuit_invalido(client):
    # 11 dígitos (pasa el schema) pero dígito verificador incorrecto.
    resp = await client.post(
        "/api/v1/usuarios/registro",
        json=_payload(cuit="20111111113"),
    )
    assert resp.status_code == 422
    assert resp.json()["errors"][0]["code"] == "cuit_invalido"


@pytest.mark.anyio
async def test_registro_campo_obligatorio_vacio(client):
    resp = await client.post(
        "/api/v1/usuarios/registro",
        json=_payload(nombre=""),
    )
    assert resp.status_code == 422


@pytest.mark.anyio
async def test_registro_password_debil(client):
    resp = await client.post(
        "/api/v1/usuarios/registro",
        json=_payload(password="corta"),
    )
    assert resp.status_code == 422


def test_validar_cuit_unitario():
    assert validar_cuit(CUIT_VALIDO) is True
    assert validar_cuit("20111111113") is False
    assert validar_cuit("123") is False
    assert validar_cuit("2011111111a") is False
