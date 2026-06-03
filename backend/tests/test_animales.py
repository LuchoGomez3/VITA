"""Tests de PRO-22: registro de animal (+ pesaje inicial)."""

from uuid import UUID, uuid4

import pytest
from sqlalchemy import select

from api.modules.establecimientos.models import (
    Establecimiento,
    UsuarioEstablecimiento,
)
from api.modules.lotes.models import Lote
from api.modules.pesajes.models import Pesaje
from api.shared.enums import RolUsuario


@pytest.fixture
async def establecimiento_con_lote(session, usuario_actual):
    """Establecimiento con membresía owner del usuario actual + un lote."""
    est = Establecimiento(
        owner_id=usuario_actual.id,
        nombre="Estancia Test",
        nro_renspa="01.002.3.04567",
    )
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
    lote = Lote(establecimiento_id=est.id, nombre="Lote 1")
    session.add(lote)
    await session.commit()
    return est, lote


def _payload(est_id, lote_id, **overrides):
    base = {
        "nro_caravana_rfid": "123456789012345",
        "sexo": "hembra",
        "raza": "Angus",
        "fecha_nacimiento": "2024-01-15",
        "lote_id": str(lote_id),
        "establecimiento_id": str(est_id),
        "peso_inicial": "120.500",
        "metodo_pesaje": "manual",
    }
    base.update(overrides)
    return base


@pytest.mark.anyio
async def test_alta_crea_animal_y_pesaje_inicial(
    auth_client, session, establecimiento_con_lote, usuario_actual
):
    est, lote = establecimiento_con_lote
    resp = await auth_client.post("/api/v1/animales", json=_payload(est.id, lote.id))
    assert resp.status_code == 201
    data = resp.json()["data"]
    assert data["nro_caravana_rfid"] == "123456789012345"
    assert data["estado"] == "activo"
    animal_id = UUID(data["id"])

    # Se creó el pesaje inicial asociado, con el responsable correcto.
    result = await session.execute(select(Pesaje).where(Pesaje.animal_id == animal_id))
    pesaje = result.scalar_one()
    assert str(pesaje.peso_kg) == "120.500"
    assert pesaje.responsable_id == usuario_actual.id
    assert pesaje.establecimiento_id == est.id


@pytest.mark.anyio
async def test_caravana_duplicada_en_establecimiento(
    auth_client, establecimiento_con_lote
):
    est, lote = establecimiento_con_lote
    await auth_client.post("/api/v1/animales", json=_payload(est.id, lote.id))
    resp = await auth_client.post("/api/v1/animales", json=_payload(est.id, lote.id))
    assert resp.status_code == 409
    assert resp.json()["errors"][0]["code"] == "caravana_duplicada"


@pytest.mark.anyio
async def test_alta_sin_sexo_falla_validacion(auth_client, establecimiento_con_lote):
    est, lote = establecimiento_con_lote
    payload = _payload(est.id, lote.id)
    del payload["sexo"]
    resp = await auth_client.post("/api/v1/animales", json=payload)
    assert resp.status_code == 422


@pytest.mark.anyio
async def test_caravana_no_15_digitos_falla(auth_client, establecimiento_con_lote):
    est, lote = establecimiento_con_lote
    resp = await auth_client.post(
        "/api/v1/animales",
        json=_payload(est.id, lote.id, nro_caravana_rfid="123"),
    )
    assert resp.status_code == 422


@pytest.mark.anyio
async def test_ternera_con_madre_existente(auth_client, establecimiento_con_lote):
    est, lote = establecimiento_con_lote
    # Alta de la madre.
    madre_resp = await auth_client.post(
        "/api/v1/animales",
        json=_payload(est.id, lote.id, nro_caravana_rfid="111111111111111"),
    )
    madre_id = madre_resp.json()["data"]["id"]

    # Alta de la ternera referenciando a la madre.
    ternera_resp = await auth_client.post(
        "/api/v1/animales",
        json=_payload(
            est.id,
            lote.id,
            nro_caravana_rfid="222222222222222",
            madre_id=madre_id,
        ),
    )
    assert ternera_resp.status_code == 201
    ternera = ternera_resp.json()["data"]
    assert ternera["madre_id"] == madre_id

    # La relación es navegable desde el detalle (madre_id persistido).
    detalle = await auth_client.get(f"/api/v1/animales/{ternera['id']}")
    assert detalle.json()["data"]["madre_id"] == madre_id


@pytest.mark.anyio
async def test_madre_de_otro_establecimiento_invalida(
    auth_client, session, establecimiento_con_lote, usuario_actual
):
    est, lote = establecimiento_con_lote
    # Animal en OTRO establecimiento (mismo dueño, distinto establecimiento).
    otro_est = Establecimiento(
        owner_id=usuario_actual.id,
        nombre="Otro Campo",
        nro_renspa="09.008.7.06543",
    )
    session.add(otro_est)
    await session.flush()
    ajeno = _seed_animal(otro_est.id)
    session.add(ajeno)
    await session.commit()

    resp = await auth_client.post(
        "/api/v1/animales",
        json=_payload(
            est.id, lote.id, nro_caravana_rfid="333333333333333", madre_id=str(ajeno.id)
        ),
    )
    assert resp.status_code == 422
    assert resp.json()["errors"][0]["code"] == "referencia_invalida"


@pytest.mark.anyio
async def test_lote_de_otro_establecimiento(
    auth_client, session, establecimiento_con_lote, usuario_actual
):
    est, _ = establecimiento_con_lote
    otro_est = Establecimiento(
        owner_id=usuario_actual.id,
        nombre="Campo B",
        nro_renspa="05.004.3.02101",
    )
    session.add(otro_est)
    await session.flush()
    lote_ajeno = Lote(establecimiento_id=otro_est.id, nombre="Lote B")
    session.add(lote_ajeno)
    await session.commit()

    resp = await auth_client.post(
        "/api/v1/animales",
        json=_payload(est.id, lote_ajeno.id, nro_caravana_rfid="444444444444444"),
    )
    assert resp.status_code == 422
    assert resp.json()["errors"][0]["code"] == "lote_no_pertenece_establecimiento"


@pytest.mark.anyio
async def test_establecimiento_sin_acceso(auth_client):
    # establecimiento_id y lote_id aleatorios: el usuario no tiene membresía.
    resp = await auth_client.post("/api/v1/animales", json=_payload(uuid4(), uuid4()))
    assert resp.status_code == 403
    assert resp.json()["errors"][0]["code"] == "establecimiento_no_autorizado"


def _seed_animal(establecimiento_id):
    """Helper: animal mínimo válido para sembrar directamente en la DB."""
    from datetime import date

    from api.modules.animales.models import Animal
    from api.shared.enums import EstadoAnimal, SexoAnimal

    return Animal(
        id=uuid4(),
        establecimiento_id=establecimiento_id,
        nro_caravana_rfid="999999999999999",
        sexo=SexoAnimal.hembra,
        raza="Angus",
        fecha_nacimiento=date(2022, 1, 1),
        estado=EstadoAnimal.activo,
    )
