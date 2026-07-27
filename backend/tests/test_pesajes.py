"""Tests del CRUD de pesajes (pesadas posteriores al alta; historial / GPD)."""

from datetime import date
from uuid import UUID, uuid4

import pytest
from sqlalchemy import select

from api.modules.animales.models import Animal
from api.modules.establecimientos.models import (
    Establecimiento,
    UsuarioEstablecimiento,
)
from api.modules.pesajes.models import Pesaje
from api.shared.enums import EstadoAnimal, RolUsuario, SexoAnimal


@pytest.fixture
async def establecimiento_con_animal(session, usuario_actual):
    """Establecimiento con membresía owner del usuario actual + un animal."""
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
    animal = Animal(
        id=uuid4(),
        establecimiento_id=est.id,
        nro_caravana_rfid="123456789012345",
        sexo=SexoAnimal.macho,
        raza="Angus",
        fecha_nacimiento=date(2023, 1, 1),
        estado=EstadoAnimal.activo,
    )
    session.add(animal)
    await session.commit()
    return est, animal


def _payload(est_id, animal_id, **overrides):
    base = {
        "establecimiento_id": str(est_id),
        "animal_id": str(animal_id),
        "peso_kg": "185.500",
        "fecha": "2025-05-01T09:00:00",
        "metodo": "manual",
    }
    base.update(overrides)
    return base


@pytest.mark.anyio
async def test_crear_pesaje(
    auth_client, session, establecimiento_con_animal, usuario_actual
):
    est, animal = establecimiento_con_animal
    resp = await auth_client.post("/api/v1/pesajes", json=_payload(est.id, animal.id))
    assert resp.status_code == 201
    data = resp.json()["data"]
    assert data["peso_kg"] == "185.500"
    # El responsable por defecto es el usuario autenticado.
    assert data["responsable_id"] == str(usuario_actual.id)

    result = await session.execute(select(Pesaje).where(Pesaje.animal_id == animal.id))
    assert result.scalar_one().peso_kg is not None


@pytest.mark.anyio
async def test_peso_no_positivo_falla(auth_client, establecimiento_con_animal):
    est, animal = establecimiento_con_animal
    resp = await auth_client.post(
        "/api/v1/pesajes", json=_payload(est.id, animal.id, peso_kg="0")
    )
    assert resp.status_code == 422


@pytest.mark.anyio
async def test_pesaje_de_animal_ajeno_falla(
    auth_client, session, establecimiento_con_animal, usuario_actual
):
    """El animal debe pertenecer al establecimiento indicado."""
    est, _ = establecimiento_con_animal
    otro = Establecimiento(
        owner_id=usuario_actual.id, nombre="Otro", nro_renspa="09.008.7.06543"
    )
    session.add(otro)
    await session.flush()
    ajeno = Animal(
        id=uuid4(),
        establecimiento_id=otro.id,
        nro_caravana_rfid="999999999999999",
        sexo=SexoAnimal.hembra,
        raza="Angus",
        fecha_nacimiento=date(2022, 1, 1),
        estado=EstadoAnimal.activo,
    )
    session.add(ajeno)
    await session.commit()

    resp = await auth_client.post("/api/v1/pesajes", json=_payload(est.id, ajeno.id))
    assert resp.status_code == 422
    assert resp.json()["errors"][0]["code"] == "animal_no_pertenece_establecimiento"


@pytest.mark.anyio
async def test_sin_acceso_al_establecimiento(auth_client):
    resp = await auth_client.post("/api/v1/pesajes", json=_payload(uuid4(), uuid4()))
    assert resp.status_code == 403
    assert resp.json()["errors"][0]["code"] == "establecimiento_no_autorizado"


@pytest.mark.anyio
async def test_listar_historial_por_animal(auth_client, establecimiento_con_animal):
    est, animal = establecimiento_con_animal
    await auth_client.post(
        "/api/v1/pesajes",
        json=_payload(est.id, animal.id, peso_kg="180", fecha="2025-01-01T09:00:00"),
    )
    await auth_client.post(
        "/api/v1/pesajes",
        json=_payload(est.id, animal.id, peso_kg="200", fecha="2025-03-01T09:00:00"),
    )
    resp = await auth_client.get(
        "/api/v1/pesajes",
        params={"establecimiento_id": str(est.id), "animal_id": str(animal.id)},
    )
    data = resp.json()["data"]
    assert len(data) == 2
    # Ordenados por fecha ascendente (evolución de peso).
    assert data[0]["fecha"] < data[1]["fecha"]


@pytest.mark.anyio
async def test_actualizar_pesaje_lww(auth_client, establecimiento_con_animal):
    est, animal = establecimiento_con_animal
    cid = str(uuid4())
    await auth_client.post(
        "/api/v1/pesajes",
        json=_payload(est.id, animal.id, id=cid, updated_at="2025-01-01T00:00:00"),
    )
    # Cambio más nuevo aplica.
    nuevo = await auth_client.put(
        f"/api/v1/pesajes/{cid}",
        json={"peso_kg": "190.000", "updated_at": "2025-06-01T00:00:00"},
    )
    assert nuevo.json()["data"]["peso_kg"] == "190.000"
    # Cambio rancio se descarta.
    viejo = await auth_client.put(
        f"/api/v1/pesajes/{cid}",
        json={"peso_kg": "170.000", "updated_at": "2025-01-01T00:00:00"},
    )
    assert viejo.json()["data"]["peso_kg"] == "190.000"


@pytest.mark.anyio
async def test_post_idempotente_no_duplica(
    auth_client, session, establecimiento_con_animal
):
    """Reenviar el mismo pesaje (replay de Brick) no lo duplica."""
    est, animal = establecimiento_con_animal
    cid = str(uuid4())
    payload = _payload(est.id, animal.id, id=cid, updated_at="2025-05-01T09:00:00")
    await auth_client.post("/api/v1/pesajes", json=payload)
    await auth_client.post("/api/v1/pesajes", json=payload)

    pesajes = (
        (await session.execute(select(Pesaje).where(Pesaje.id == UUID(cid))))
        .scalars()
        .all()
    )
    assert len(pesajes) == 1


@pytest.mark.anyio
async def test_borrar_soft_y_pull(auth_client, establecimiento_con_animal):
    est, animal = establecimiento_con_animal
    cid = str(uuid4())
    await auth_client.post("/api/v1/pesajes", json=_payload(est.id, animal.id, id=cid))
    d = await auth_client.delete(f"/api/v1/pesajes/{cid}")
    assert d.status_code == 200
    assert d.json()["data"]["deleted_at"] is not None

    normal = await auth_client.get(
        "/api/v1/pesajes", params={"establecimiento_id": str(est.id)}
    )
    assert cid not in [p["id"] for p in normal.json()["data"]]

    pull = await auth_client.get(
        "/api/v1/pesajes",
        params={"establecimiento_id": str(est.id), "include_deleted": "true"},
    )
    borrados = [p for p in pull.json()["data"] if p["id"] == cid]
    assert len(borrados) == 1 and borrados[0]["deleted_at"] is not None


@pytest.mark.anyio
async def test_detalle_pesaje_inexistente_404(auth_client):
    resp = await auth_client.get(f"/api/v1/pesajes/{uuid4()}")
    assert resp.status_code == 404
    assert resp.json()["errors"][0]["code"] == "pesaje_no_encontrado"
