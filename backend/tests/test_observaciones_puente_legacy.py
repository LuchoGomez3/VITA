"""Puente de transición desde ``animales.observaciones`` (VITA-173, adr-0007).

Los clientes anteriores a ``observaciones_animales`` escriben la nota en la
columna del animal, y pueden tener esas escrituras encoladas offline. Estos
tests fijan que ninguna se pierda ni se duplique al reintentarse.
"""

from uuid import uuid4

import pytest

from api.modules.establecimientos.models import (
    Establecimiento,
    UsuarioEstablecimiento,
)
from api.shared.enums import RolUsuario

_CARAVANAS = iter(f"{n:015d}" for n in range(200000000000001, 200000000001000))


@pytest.fixture
async def campo(session, usuario_actual):
    est = Establecimiento(owner_id=usuario_actual.id, nombre="Estancia Test")
    session.add(est)
    await session.flush()
    session.add(
        UsuarioEstablecimiento(
            usuario_id=usuario_actual.id,
            establecimiento_id=est.id,
            rol=RolUsuario.owner,
            activo=True,
        )
    )
    await session.commit()
    return est.id


def _alta(campo, **extra):
    payload = {
        "id": str(uuid4()),
        "nro_caravana_rfid": next(_CARAVANAS),
        "sexo": "hembra",
        "raza": "Angus",
        "fecha_nacimiento": "2022-03-10",
        "establecimiento_id": str(campo),
        "peso_inicial": "380",
        "updated_at": "2026-09-01T10:00:00Z",
    }
    payload.update(extra)
    return payload


async def _entradas(client, campo, animal_id):
    resp = await client.get(
        "/api/v1/observaciones_animales",
        params={"establecimiento_id": str(campo), "animal_id": animal_id},
    )
    return resp.json()["data"]


@pytest.mark.anyio
async def test_alta_con_observaciones_crea_una_entrada(
    auth_client, campo, usuario_actual
):
    payload = _alta(
        campo, observaciones="Llegó flaca", created_at="2026-08-30T07:00:00Z"
    )
    resp = await auth_client.post("/api/v1/animales", json=payload)
    assert resp.status_code == 201
    # La columna sigue escribiéndose para los clientes que todavía la leen.
    assert resp.json()["data"]["observaciones"] == "Llegó flaca"

    entradas = await _entradas(auth_client, campo, payload["id"])
    assert [e["texto"] for e in entradas] == ["Llegó flaca"]
    assert entradas[0]["autor_id"] == str(usuario_actual.id)
    assert entradas[0]["fecha"].startswith("2026-08-30T07:00:00")


@pytest.mark.anyio
@pytest.mark.parametrize("observaciones", [None, "", "   "])
async def test_alta_sin_nota_no_crea_entradas(auth_client, campo, observaciones):
    payload = _alta(campo, observaciones=observaciones)
    await auth_client.post("/api/v1/animales", json=payload)
    assert await _entradas(auth_client, campo, payload["id"]) == []


@pytest.mark.anyio
async def test_reintentos_del_alta_no_duplican(auth_client, campo):
    payload = _alta(campo, observaciones="Llegó flaca")
    for _ in range(3):
        await auth_client.post("/api/v1/animales", json=payload)

    assert len(await _entradas(auth_client, campo, payload["id"])) == 1


@pytest.mark.anyio
async def test_edicion_con_nota_nueva_agrega_sin_pisar_la_anterior(auth_client, campo):
    payload = _alta(campo, observaciones="Llegó flaca")
    await auth_client.post("/api/v1/animales", json=payload)
    ruta = f"/api/v1/animales/{payload['id']}"

    edicion = {"observaciones": "Recuperó estado", "updated_at": "2026-09-05T00:00:00Z"}
    await auth_client.put(ruta, json=edicion)
    # El reintento de la misma edición no duplica.
    await auth_client.put(ruta, json=edicion)

    textos = {e["texto"] for e in await _entradas(auth_client, campo, payload["id"])}
    assert textos == {"Llegó flaca", "Recuperó estado"}


@pytest.mark.anyio
async def test_edicion_que_no_cambia_la_nota_no_crea_entradas(auth_client, campo):
    payload = _alta(campo, observaciones="Llegó flaca")
    await auth_client.post("/api/v1/animales", json=payload)

    await auth_client.put(
        f"/api/v1/animales/{payload['id']}",
        json={
            "observaciones": "Llegó flaca",
            "raza": "Brangus",
            "updated_at": "2026-09-05T00:00:00Z",
        },
    )

    assert len(await _entradas(auth_client, campo, payload["id"])) == 1


@pytest.mark.anyio
async def test_nota_de_una_escritura_rancia_no_se_pierde(auth_client, campo):
    """Otro dispositivo sincronizó antes: el animal no cambia, la nota sí entra."""
    payload = _alta(campo, updated_at="2026-09-10T00:00:00Z")
    await auth_client.post("/api/v1/animales", json=payload)

    resp = await auth_client.put(
        f"/api/v1/animales/{payload['id']}",
        json={"observaciones": "Escrita offline", "updated_at": "2026-09-01T00:00:00Z"},
    )

    assert resp.json()["data"]["observaciones"] is None
    textos = [e["texto"] for e in await _entradas(auth_client, campo, payload["id"])]
    assert textos == ["Escrita offline"]


@pytest.mark.anyio
async def test_reenvio_del_alta_con_otra_nota_la_agrega(auth_client, campo):
    payload = _alta(campo, observaciones="Primera")
    await auth_client.post("/api/v1/animales", json=payload)

    await auth_client.post(
        "/api/v1/animales",
        json={
            **payload,
            "observaciones": "Segunda",
            "updated_at": "2026-09-02T10:00:00Z",
        },
    )

    textos = {e["texto"] for e in await _entradas(auth_client, campo, payload["id"])}
    assert textos == {"Primera", "Segunda"}


@pytest.mark.anyio
async def test_una_entrada_borrada_no_reaparece_por_un_reintento(auth_client, campo):
    payload = _alta(campo, observaciones="Llegó flaca")
    await auth_client.post("/api/v1/animales", json=payload)
    entrada = (await _entradas(auth_client, campo, payload["id"]))[0]
    await auth_client.delete(f"/api/v1/observaciones_animales/{entrada['id']}")

    await auth_client.post("/api/v1/animales", json=payload)

    assert await _entradas(auth_client, campo, payload["id"]) == []


@pytest.mark.anyio
async def test_una_combinacion_invalida_rechaza_tambien_la_nota(auth_client, campo):
    payload = _alta(campo)
    await auth_client.post("/api/v1/animales", json=payload)

    resp = await auth_client.put(
        f"/api/v1/animales/{payload['id']}",
        json={
            "observaciones": "No debería quedar",
            "estado_reproductivo": "prenada",
            "updated_at": "2026-09-05T00:00:00Z",
        },
    )

    assert resp.status_code == 422
    assert await _entradas(auth_client, campo, payload["id"]) == []
