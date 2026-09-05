"""Tests de PRO-22: registro de animal (+ pesaje inicial)."""

from uuid import UUID, uuid4

import pytest
from sqlalchemy import select

from api.modules.establecimientos.models import (
    Establecimiento,
    UsuarioEstablecimiento,
)
from api.modules.pesajes.models import Pesaje
from api.shared.enums import RolUsuario
from tests.factories import crear_lote


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
    lote = crear_lote(est.id, "Lote 1")
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
    lote_ajeno = crear_lote(otro_est.id, "Lote B")
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


# ---------------------------------------------------------------------------
# Sincronización offline-first: identidad/timestamps del cliente, idempotencia,
# last-write-wins, soft delete y pull delta. (Módulo crítico de sync.)
# ---------------------------------------------------------------------------


@pytest.mark.anyio
async def test_post_respeta_id_y_timestamps_del_cliente(
    auth_client, establecimiento_con_lote
):
    """El backend toma el UUID y los timestamps generados por el cliente offline."""
    est, lote = establecimiento_con_lote
    cid = str(uuid4())
    resp = await auth_client.post(
        "/api/v1/animales",
        json=_payload(
            est.id,
            lote.id,
            id=cid,
            created_at="2025-03-10T12:00:00",
            updated_at="2025-03-10T12:00:00",
        ),
    )
    assert resp.status_code == 201
    data = resp.json()["data"]
    assert data["id"] == cid
    assert data["created_at"].startswith("2025-03-10")
    assert data["updated_at"].startswith("2025-03-10")


@pytest.mark.anyio
async def test_post_idempotente_no_duplica_ni_recrea_pesaje(
    auth_client, session, establecimiento_con_lote
):
    """Reenviar el mismo alta (replay de Brick) no duplica ni rompe por caravana."""
    from api.modules.animales.models import Animal

    est, lote = establecimiento_con_lote
    cid = str(uuid4())
    payload = _payload(est.id, lote.id, id=cid, updated_at="2025-03-10T12:00:00")

    r1 = await auth_client.post("/api/v1/animales", json=payload)
    assert r1.status_code == 201
    r2 = await auth_client.post("/api/v1/animales", json=payload)
    assert r2.status_code == 201
    assert r2.json()["data"]["id"] == cid

    animales = (
        (await session.execute(select(Animal).where(Animal.id == UUID(cid))))
        .scalars()
        .all()
    )
    assert len(animales) == 1
    pesajes = (
        (await session.execute(select(Pesaje).where(Pesaje.animal_id == UUID(cid))))
        .scalars()
        .all()
    )
    assert len(pesajes) == 1


@pytest.mark.anyio
async def test_post_last_write_wins(auth_client, establecimiento_con_lote):
    """En re-sync gana el updated_at más nuevo; el más viejo se ignora."""
    est, lote = establecimiento_con_lote
    cid = str(uuid4())
    await auth_client.post(
        "/api/v1/animales",
        json=_payload(
            est.id, lote.id, id=cid, raza="Angus", updated_at="2025-03-10T12:00:00"
        ),
    )

    # Versión más nueva: aplica el cambio.
    nuevo = await auth_client.post(
        "/api/v1/animales",
        json=_payload(
            est.id, lote.id, id=cid, raza="Hereford", updated_at="2025-06-01T12:00:00"
        ),
    )
    assert nuevo.json()["data"]["raza"] == "Hereford"

    # Versión más vieja: se descarta (gana el servidor).
    viejo = await auth_client.post(
        "/api/v1/animales",
        json=_payload(
            est.id, lote.id, id=cid, raza="Brangus", updated_at="2025-01-01T12:00:00"
        ),
    )
    assert viejo.json()["data"]["raza"] == "Hereford"


@pytest.mark.anyio
async def test_put_conserva_updated_at_del_cliente(
    auth_client, session, establecimiento_con_lote
):
    """PUT aplica con LWW y el updated_at del cliente sobrevive en la DB.

    Verifica el caveat del onupdate=func.now(): al asignarlo explícito no se pisa.
    """
    from api.modules.animales.models import Animal

    est, lote = establecimiento_con_lote
    cid = str(uuid4())
    await auth_client.post(
        "/api/v1/animales",
        json=_payload(est.id, lote.id, id=cid, updated_at="2025-03-10T12:00:00"),
    )

    resp = await auth_client.put(
        f"/api/v1/animales/{cid}",
        json={"raza": "Hereford", "updated_at": "2025-06-01T12:00:00"},
    )
    assert resp.status_code == 200
    assert resp.json()["data"]["raza"] == "Hereford"

    animal = await session.get(Animal, UUID(cid))
    await session.refresh(animal)
    # Si el onupdate hubiese pisado el valor, el año sería el actual (2026), no 2025.
    assert animal.updated_at.year == 2025
    assert animal.updated_at.month == 6


@pytest.mark.anyio
async def test_put_descarta_cambio_rancio(auth_client, establecimiento_con_lote):
    """Un PUT con updated_at más viejo que el persistido no modifica nada."""
    est, lote = establecimiento_con_lote
    cid = str(uuid4())
    await auth_client.post(
        "/api/v1/animales",
        json=_payload(
            est.id, lote.id, id=cid, raza="Angus", updated_at="2025-06-01T12:00:00"
        ),
    )
    resp = await auth_client.put(
        f"/api/v1/animales/{cid}",
        json={"raza": "Hereford", "updated_at": "2025-01-01T12:00:00"},
    )
    assert resp.status_code == 200
    assert resp.json()["data"]["raza"] == "Angus"


@pytest.mark.anyio
async def test_delete_soft_y_pull_include_deleted(
    auth_client, establecimiento_con_lote
):
    """DELETE marca deleted_at; el listado normal lo oculta y el pull lo propaga."""
    est, lote = establecimiento_con_lote
    cid = str(uuid4())
    await auth_client.post("/api/v1/animales", json=_payload(est.id, lote.id, id=cid))

    d = await auth_client.delete(f"/api/v1/animales/{cid}")
    assert d.status_code == 200
    assert d.json()["data"]["deleted_at"] is not None

    normal = await auth_client.get(
        "/api/v1/animales", params={"establecimiento_id": str(est.id)}
    )
    assert cid not in [a["id"] for a in normal.json()["data"]]

    pull = await auth_client.get(
        "/api/v1/animales",
        params={"establecimiento_id": str(est.id), "include_deleted": "true"},
    )
    borrados = [a for a in pull.json()["data"] if a["id"] == cid]
    assert len(borrados) == 1
    assert borrados[0]["deleted_at"] is not None


@pytest.mark.anyio
async def test_pull_updated_since_devuelve_solo_lo_nuevo(
    auth_client, establecimiento_con_lote
):
    """La descarga delta solo trae lo modificado desde el corte indicado."""
    est, lote = establecimiento_con_lote
    await auth_client.post(
        "/api/v1/animales",
        json=_payload(
            est.id,
            lote.id,
            id=str(uuid4()),
            nro_caravana_rfid="111111111111111",
            updated_at="2025-01-01T00:00:00",
        ),
    )
    nuevo_id = str(uuid4())
    await auth_client.post(
        "/api/v1/animales",
        json=_payload(
            est.id,
            lote.id,
            id=nuevo_id,
            nro_caravana_rfid="222222222222222",
            updated_at="2025-12-01T00:00:00",
        ),
    )

    resp = await auth_client.get(
        "/api/v1/animales",
        params={
            "establecimiento_id": str(est.id),
            "updated_since": "2025-06-01T00:00:00",
        },
    )
    ids = [a["id"] for a in resp.json()["data"]]
    assert ids == [nuevo_id]


@pytest.mark.anyio
async def test_put_animal_inexistente_devuelve_404(auth_client):
    resp = await auth_client.put(
        f"/api/v1/animales/{uuid4()}", json={"raza": "Hereford"}
    )
    assert resp.status_code == 404
    assert resp.json()["errors"][0]["code"] == "animal_no_encontrado"


@pytest.mark.anyio
async def test_delete_animal_inexistente_devuelve_404(auth_client):
    resp = await auth_client.delete(f"/api/v1/animales/{uuid4()}")
    assert resp.status_code == 404
    assert resp.json()["errors"][0]["code"] == "animal_no_encontrado"


@pytest.mark.anyio
async def test_put_a_lote_de_otro_establecimiento_falla(
    auth_client, session, establecimiento_con_lote, usuario_actual
):
    """Mover un animal a un lote ajeno es inválido aunque el updated_at sea nuevo."""
    est, lote = establecimiento_con_lote
    cid = str(uuid4())
    await auth_client.post(
        "/api/v1/animales",
        json=_payload(est.id, lote.id, id=cid, updated_at="2025-01-01T00:00:00"),
    )
    otro_est = Establecimiento(
        owner_id=usuario_actual.id, nombre="Campo C", nro_renspa="07.006.5.04321"
    )
    session.add(otro_est)
    await session.flush()
    lote_ajeno = crear_lote(otro_est.id, "Lote C")
    session.add(lote_ajeno)
    await session.commit()

    resp = await auth_client.put(
        f"/api/v1/animales/{cid}",
        json={"lote_id": str(lote_ajeno.id), "updated_at": "2025-06-01T00:00:00"},
    )
    assert resp.status_code == 422
    assert resp.json()["errors"][0]["code"] == "lote_no_pertenece_establecimiento"


@pytest.mark.anyio
async def test_put_actualiza_multiples_campos(auth_client, establecimiento_con_lote):
    """PUT aplica todos los campos de negocio provistos y propaga deleted_at."""
    est, lote = establecimiento_con_lote
    cid = str(uuid4())
    await auth_client.post(
        "/api/v1/animales",
        json=_payload(est.id, lote.id, id=cid, updated_at="2025-01-01T00:00:00"),
    )
    resp = await auth_client.put(
        f"/api/v1/animales/{cid}",
        json={
            "raza": "Brangus",
            "fecha_nacimiento": "2023-05-05",
            "pelaje": "colorado",
            "observaciones": "revisar",
            "estado": "vendido",
            "deleted_at": "2025-06-02T00:00:00",
            "updated_at": "2025-06-01T00:00:00",
        },
    )
    assert resp.status_code == 200
    data = resp.json()["data"]
    assert data["raza"] == "Brangus"
    assert data["fecha_nacimiento"] == "2023-05-05"
    assert data["pelaje"] == "colorado"
    assert data["observaciones"] == "revisar"
    assert data["estado"] == "vendido"
    assert data["deleted_at"] is not None
