"""Tests de PRO-40: registro de establecimiento ganadero."""

from uuid import UUID, uuid4

import pytest
from sqlalchemy import select, update

from api.modules.establecimientos.models import (
    Establecimiento,
    UsuarioEstablecimiento,
)
from api.modules.establecimientos.repository import EstablecimientoRepository
from api.modules.usuarios.models import Usuario
from api.shared.enums import RolUsuario


def _payload(**overrides):
    base = {
        "nombre": "Estancia La Vita",
        "nro_renspa": "12.345.6.78901/00",
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
    assert body["data"]["nro_renspa"] == "12.345.6.78901/00"
    assert body["data"]["rol"] == "owner"

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
async def test_renspa_duplicado_por_carrera_lo_atrapa_la_constraint(
    auth_client, session, usuario_actual, monkeypatch
):
    """Si el pre-chequeo no ve el duplicado (carrera concurrente), la
    UniqueConstraint de la DB debe atrapar el INSERT y traducirse a 409.

    Se simula la ventana de carrera sembrando el RENSPA y forzando a
    ``get_by_renspa`` a devolver ``None`` (como si el otro alta aún no se viera).
    """
    # Ya existe un establecimiento con ese RENSPA.
    session.add(
        Establecimiento(
            owner_id=usuario_actual.id,
            nombre="Estancia previa",
            nro_renspa="12.345.6.78901/00",
        )
    )
    await session.commit()

    # El pre-chequeo no lo ve: sólo queda la constraint como garantía final.
    async def _no_ve_duplicado(self, nro_renspa):
        return None

    monkeypatch.setattr(EstablecimientoRepository, "get_by_renspa", _no_ve_duplicado)

    resp = await auth_client.post("/api/v1/establecimientos", json=_payload())
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
    assert data["rol"] == "owner"
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
        nro_renspa="99.999.9.99999/00",
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


@pytest.mark.anyio
async def test_listado_y_detalle_incluyen_rol_admin(
    auth_client, session, usuario_actual
):
    creado = await auth_client.post("/api/v1/establecimientos", json=_payload())
    establecimiento_id = creado.json()["data"]["id"]
    await session.execute(
        update(UsuarioEstablecimiento)
        .where(
            UsuarioEstablecimiento.usuario_id == usuario_actual.id,
            UsuarioEstablecimiento.establecimiento_id == UUID(establecimiento_id),
        )
        .values(rol=RolUsuario.admin)
    )
    await session.commit()

    listado = await auth_client.get("/api/v1/establecimientos")
    establecimiento = next(
        item for item in listado.json()["data"] if item["id"] == establecimiento_id
    )
    assert listado.status_code == 200
    assert establecimiento["rol"] == "admin"

    detalle = await auth_client.get(
        f"/api/v1/establecimientos/{establecimiento_id}"
    )
    assert detalle.status_code == 200
    assert detalle.json()["data"]["rol"] == "admin"


@pytest.mark.anyio
async def test_renspa_formato_invalido_rechazado(auth_client):
    resp = await auth_client.post(
        "/api/v1/establecimientos",
        json=_payload(nro_renspa="12.345.678901"),
    )
    assert resp.status_code == 422
    assert resp.json()["errors"][0]["code"] == "renspa_formato_invalido"


@pytest.mark.anyio
async def test_cuit_invalido_rechazado(auth_client):
    resp = await auth_client.post(
        "/api/v1/establecimientos",
        json=_payload(cuit="20-11111111-9"),
    )
    assert resp.status_code == 422
    assert resp.json()["errors"][0]["code"] == "cuit_invalido"


@pytest.mark.anyio
async def test_cuit_valido_se_normaliza_y_persiste(auth_client):
    resp = await auth_client.post(
        "/api/v1/establecimientos",
        json=_payload(cuit="20-11111111-2"),
    )
    assert resp.status_code == 201
    assert resp.json()["data"]["cuit"] == "20111111112"


@pytest.mark.anyio
async def test_superficie_no_positiva_rechazada(auth_client):
    resp = await auth_client.post(
        "/api/v1/establecimientos",
        json=_payload(superficie_ha="0"),
    )
    assert resp.status_code == 422
    assert resp.json()["errors"][0]["code"] == "superficie_invalida"


@pytest.mark.anyio
async def test_geolocalizacion_y_poligono_persistidos(auth_client):
    poligono = [
        {"orden": 1, "latitud": -33.1, "longitud": -64.1},
        {"orden": 2, "latitud": -33.2, "longitud": -64.1},
        {"orden": 3, "latitud": -33.2, "longitud": -64.2},
    ]
    creado = await auth_client.post(
        "/api/v1/establecimientos",
        json=_payload(
            descripcion="Cría y recría de Aberdeen Angus.",
            tipo_produccion=["Cría", "Recría"],
            latitud="-33.15",
            longitud="-64.15",
            poligono=poligono,
        ),
    )
    assert creado.status_code == 201
    est_id = creado.json()["data"]["id"]

    resp = await auth_client.get(f"/api/v1/establecimientos/{est_id}")
    assert resp.status_code == 200
    data = resp.json()["data"]
    assert data["descripcion"] == "Cría y recría de Aberdeen Angus."
    assert data["tipo_produccion"] == ["Cría", "Recría"]
    assert float(data["latitud"]) == -33.15
    assert float(data["longitud"]) == -64.15
    assert data["poligono"] == poligono


@pytest.mark.anyio
async def test_actualizar_establecimiento_exitoso(auth_client):
    creado = await auth_client.post("/api/v1/establecimientos", json=_payload())
    est_id = creado.json()["data"]["id"]

    resp = await auth_client.put(
        f"/api/v1/establecimientos/{est_id}",
        json={"nombre": "Estancia Renombrada", "superficie_ha": "200.00"},
    )
    assert resp.status_code == 200
    data = resp.json()["data"]
    assert data["nombre"] == "Estancia Renombrada"
    assert data["superficie_ha"] == "200.00"
    # Los campos no enviados no se pisan.
    assert data["nro_renspa"] == "12.345.6.78901/00"


@pytest.mark.anyio
async def test_actualizar_con_renspa_duplicado_rechazado(auth_client):
    await auth_client.post(
        "/api/v1/establecimientos",
        json=_payload(nro_renspa="55.555.5.55555/00"),
    )
    otro = await auth_client.post(
        "/api/v1/establecimientos",
        json=_payload(nro_renspa="66.666.6.66666/00"),
    )
    otro_id = otro.json()["data"]["id"]

    resp = await auth_client.put(
        f"/api/v1/establecimientos/{otro_id}",
        json={"nro_renspa": "55.555.5.55555/00"},
    )
    assert resp.status_code == 409
    assert resp.json()["errors"][0]["code"] == "renspa_duplicado"


@pytest.mark.anyio
async def test_actualizar_establecimiento_inexistente_404(auth_client):
    resp = await auth_client.put(
        f"/api/v1/establecimientos/{uuid4()}",
        json={"nombre": "No existe"},
    )
    assert resp.status_code == 404
    assert resp.json()["errors"][0]["code"] == "establecimiento_no_encontrado"
