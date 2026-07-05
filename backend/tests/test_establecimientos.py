"""Tests de PRO-40: registro de establecimiento ganadero."""

from uuid import UUID, uuid4

import pytest
from sqlalchemy import select

from api.modules.establecimientos.models import (
    Establecimiento,
    UsuarioEstablecimiento,
)
from api.modules.usuarios.models import Usuario
from api.shared.enums import RolUsuario


def _payload(**overrides):
    base = {
        "nombre": "Estancia La Vita",
        "nro_renspa": "12.345.6.78901",
        "superficie_ha": "150.50",
        "provincia": "Córdoba",
        "departamento": "Río Cuarto",
        "localidad": "Sampacho",
    }
    base.update(overrides)
    return base


@pytest.mark.anyio
async def test_alta_exitosa_crea_membresia_owner(auth_client, session, usuario_actual):
    resp = await auth_client.post("/api/v1/establecimientos", json=_payload())
    assert resp.status_code == 201
    body = resp.json()
    assert body["success"] is True
    est_id = body["data"]["id"]
    assert body["data"]["owner_id"] == str(usuario_actual.id)
    assert body["data"]["nro_renspa"] == "12.345.6.78901"

    # Se creó la membresía owner en la misma operación.
    result = await session.execute(
        select(UsuarioEstablecimiento).where(
            UsuarioEstablecimiento.establecimiento_id == UUID(est_id)
        )
    )
    membresia = result.scalar_one()
    assert membresia.usuario_id == usuario_actual.id
    assert membresia.rol == RolUsuario.owner
    assert membresia.activo is True


@pytest.mark.anyio
async def test_renspa_duplicado_rechazado(auth_client):
    await auth_client.post("/api/v1/establecimientos", json=_payload())
    resp = await auth_client.post(
        "/api/v1/establecimientos",
        json=_payload(nombre="Otra estancia"),
    )
    assert resp.status_code == 409
    assert resp.json()["errors"][0]["code"] == "renspa_duplicado"


@pytest.mark.anyio
async def test_renspa_vacio_rechazado(auth_client):
    resp = await auth_client.post(
        "/api/v1/establecimientos",
        json=_payload(nro_renspa="   "),
    )
    assert resp.status_code == 422
    assert resp.json()["errors"][0]["code"] == "renspa_vacio"


@pytest.mark.anyio
async def test_nombre_obligatorio_faltante(auth_client):
    resp = await auth_client.post(
        "/api/v1/establecimientos",
        json=_payload(nombre=""),
    )
    assert resp.status_code == 422


@pytest.mark.anyio
async def test_detalle_incluye_auditoria(auth_client, usuario_actual):
    creado = await auth_client.post("/api/v1/establecimientos", json=_payload())
    est_id = creado.json()["data"]["id"]

    resp = await auth_client.get(f"/api/v1/establecimientos/{est_id}")
    assert resp.status_code == 200
    data = resp.json()["data"]
    assert data["owner_id"] == str(usuario_actual.id)
    assert data["created_at"]
    assert data["updated_at"]


@pytest.mark.anyio
async def test_listado_solo_del_usuario(auth_client, session):
    # Establecimiento propio (vía API, como usuario_actual).
    propio = await auth_client.post("/api/v1/establecimientos", json=_payload())
    propio_id = propio.json()["data"]["id"]

    # Establecimiento de otro usuario, sembrado directamente.
    otro_usuario = Usuario(
        id=uuid4(),
        nombre="Otro",
        apellido="Dueño",
        email="otro@dueno.com",
        cuit="20111111120",
    )
    session.add(otro_usuario)
    ajeno = Establecimiento(
        owner_id=otro_usuario.id,
        nombre="Campo Ajeno",
        nro_renspa="99.999.9.99999",
    )
    session.add(ajeno)
    await session.flush()
    session.add(
        UsuarioEstablecimiento(
            usuario_id=otro_usuario.id,
            establecimiento_id=ajeno.id,
            rol=RolUsuario.owner,
            activo=True,
        )
    )
    await session.commit()

    resp = await auth_client.get("/api/v1/establecimientos")
    assert resp.status_code == 200
    ids = {e["id"] for e in resp.json()["data"]}
    assert propio_id in ids
    assert str(ajeno.id) not in ids

    # Y el detalle ajeno no es accesible.
    detalle = await auth_client.get(f"/api/v1/establecimientos/{ajeno.id}")
    assert detalle.status_code == 404
    assert detalle.json()["errors"][0]["code"] == "establecimiento_no_encontrado"
