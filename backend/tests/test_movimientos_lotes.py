"""Tests del movimiento batch de animales entre lotes.

Las dos propiedades que sostienen el contrato offline: la operación es atómica
(todos los animales o ninguno) e idempotente (reproducir el mismo UUID no mueve
dos veces ni duplica el historial).
"""

from uuid import UUID, uuid4

import pytest
from sqlalchemy import func, select

from api.modules.animales.models import Animal
from api.modules.establecimientos.models import (
    Establecimiento,
    UsuarioEstablecimiento,
)
from api.modules.movimientos.models import MovimientoLote, MovimientoLoteAnimal
from api.shared.enums import EstadoLote, RolUsuario, SexoAnimal
from tests.factories import crear_lote

BASE = "/api/v1/movimientos_lotes"


@pytest.fixture
async def campo(session, usuario_actual):
    """Establecimiento con dos lotes y dos animales en el de origen."""
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

    origen = crear_lote(est.id, "Potrero Origen", indice_geometria=0)
    destino = crear_lote(est.id, "Potrero Destino", indice_geometria=1)
    session.add_all([origen, destino])
    await session.flush()

    animales = [
        Animal(
            establecimiento_id=est.id,
            lote_id=origen.id,
            nro_caravana_rfid=f"00000000000000{i}",
            sexo=SexoAnimal.hembra,
            raza="Angus",
        )
        for i in range(1, 3)
    ]
    session.add_all(animales)
    await session.commit()
    return est, origen, destino, animales


@pytest.fixture
async def establecimiento_ajeno(session):
    est = Establecimiento(
        owner_id=uuid4(), nombre="Estancia Ajena", nro_renspa="09.008.7.06543"
    )
    session.add(est)
    await session.commit()
    return est


def _payload(est_id, origen_id, destino_id, animal_ids, **overrides):
    base = {
        "id": str(uuid4()),
        "establecimiento_id": str(est_id),
        "lote_origen_id": str(origen_id),
        "lote_destino_id": str(destino_id),
        "animal_ids": [str(a) for a in animal_ids],
        "fecha_movimiento": "2026-08-31T15:30:00Z",
        "motivo": "Rotación de pastoreo",
    }
    base.update(overrides)
    return base


# ================================================================ camino feliz


@pytest.mark.anyio
async def test_movimiento_batch_mueve_todos_los_animales(
    auth_client, session, campo, usuario_actual
):
    est, origen, destino, animales = campo
    ids = [a.id for a in animales]

    resp = await auth_client.post(
        BASE, json=_payload(est.id, origen.id, destino.id, ids)
    )

    assert resp.status_code == 201
    data = resp.json()["data"]
    assert set(data["animal_ids"]) == {str(i) for i in ids}
    assert data["lote_destino_id"] == str(destino.id)
    assert data["motivo"] == "Rotación de pastoreo"

    for animal in animales:
        await session.refresh(animal)
        assert animal.lote_id == destino.id

    detalles = await session.execute(
        select(func.count()).select_from(MovimientoLoteAnimal)
    )
    assert detalles.scalar_one() == 2


@pytest.mark.anyio
async def test_responsable_sale_del_jwt_no_del_cliente(
    auth_client, session, campo, usuario_actual
):
    """Aceptar el del cliente permitiría imputarle el movimiento a otro usuario."""
    est, origen, destino, animales = campo
    intruso = str(uuid4())

    resp = await auth_client.post(
        BASE,
        json=_payload(
            est.id,
            origen.id,
            destino.id,
            [a.id for a in animales],
            responsable_id=intruso,
        ),
    )
    assert resp.json()["data"]["responsable_id"] == str(usuario_actual.id)


@pytest.mark.anyio
async def test_animales_movidos_bajan_en_el_pull_delta(auth_client, campo):
    """Es como los otros dispositivos se enteran del lote nuevo."""
    est, origen, destino, animales = campo
    await auth_client.post(
        BASE, json=_payload(est.id, origen.id, destino.id, [a.id for a in animales])
    )

    resp = await auth_client.get(
        "/api/v1/animales",
        params={
            "establecimiento_id": str(est.id),
            "updated_since": "2026-08-01T00:00:00Z",
        },
    )
    devueltos = resp.json()["data"]
    assert len(devueltos) == 2
    assert all(a["lote_id"] == str(destino.id) for a in devueltos)


# ================================================================ idempotencia


@pytest.mark.anyio
async def test_replay_no_mueve_dos_veces_ni_duplica_historial(
    auth_client, session, campo
):
    est, origen, destino, animales = campo
    payload = _payload(est.id, origen.id, destino.id, [a.id for a in animales])

    primera = await auth_client.post(BASE, json=payload)
    segunda = await auth_client.post(BASE, json=payload)

    assert primera.status_code == 201
    assert segunda.status_code == 201
    assert set(segunda.json()["data"]["animal_ids"]) == {str(a.id) for a in animales}

    cabeceras = await session.execute(select(func.count()).select_from(MovimientoLote))
    detalles = await session.execute(
        select(func.count()).select_from(MovimientoLoteAnimal)
    )
    assert cabeceras.scalar_one() == 1
    assert detalles.scalar_one() == 2


@pytest.mark.anyio
async def test_replay_propaga_el_tombstone_sin_revertir_animales(
    auth_client, session, campo
):
    """Borrar el registro del movimiento no deshace el traslado."""
    est, origen, destino, animales = campo
    movimiento_id = str(uuid4())
    payload = _payload(
        est.id, origen.id, destino.id, [a.id for a in animales], id=movimiento_id
    )
    await auth_client.post(BASE, json=payload)

    borrado = await auth_client.post(
        BASE, json={**payload, "deleted_at": "2026-09-01T10:00:00Z"}
    )
    assert borrado.json()["data"]["deleted_at"] is not None

    for animal in animales:
        await session.refresh(animal)
        assert animal.lote_id == destino.id


# ================================================================= atomicidad


@pytest.mark.anyio
async def test_un_animal_invalido_no_mueve_a_ninguno(auth_client, session, campo):
    """Mover 'los que se pueda' dejaría cliente y servidor con estados distintos."""
    est, origen, destino, animales = campo
    ids = [animales[0].id, uuid4()]  # el segundo no existe

    resp = await auth_client.post(
        BASE, json=_payload(est.id, origen.id, destino.id, ids)
    )

    assert resp.status_code == 422
    assert resp.json()["errors"][0]["code"] == "animales_no_pertenecen_lote_origen"

    for animal in animales:
        await session.refresh(animal)
        assert animal.lote_id == origen.id

    cabeceras = await session.execute(select(func.count()).select_from(MovimientoLote))
    assert cabeceras.scalar_one() == 0


@pytest.mark.anyio
async def test_animal_que_ya_no_esta_en_el_origen_se_rechaza(
    auth_client, session, campo
):
    """Conflicto típico del offline: otro dispositivo ya lo movió."""
    est, origen, destino, animales = campo
    animales[0].lote_id = destino.id
    session.add(animales[0])
    await session.commit()

    resp = await auth_client.post(
        BASE, json=_payload(est.id, origen.id, destino.id, [a.id for a in animales])
    )
    assert resp.status_code == 422
    errores = resp.json()["errors"][0]
    assert errores["code"] == "animales_no_pertenecen_lote_origen"
    assert str(animales[0].id) in errores["details"]["animal_ids"]


@pytest.mark.anyio
async def test_animal_borrado_se_rechaza(auth_client, session, campo):
    from datetime import UTC, datetime

    est, origen, destino, animales = campo
    animales[0].deleted_at = datetime.now(UTC)
    session.add(animales[0])
    await session.commit()

    resp = await auth_client.post(
        BASE, json=_payload(est.id, origen.id, destino.id, [a.id for a in animales])
    )
    assert resp.status_code == 422


# ============================================================ validaciones


@pytest.mark.anyio
async def test_origen_igual_a_destino_se_rechaza(auth_client, campo):
    est, origen, _, animales = campo
    resp = await auth_client.post(
        BASE, json=_payload(est.id, origen.id, origen.id, [a.id for a in animales])
    )
    assert resp.status_code == 422
    assert resp.json()["errors"][0]["code"] == "movimiento_lote_invalido"


@pytest.mark.anyio
async def test_lista_vacia_se_rechaza(auth_client, campo):
    est, origen, destino, _ = campo
    resp = await auth_client.post(
        BASE, json=_payload(est.id, origen.id, destino.id, [])
    )
    assert resp.status_code == 422


@pytest.mark.anyio
async def test_ids_repetidos_se_rechazan(auth_client, campo):
    est, origen, destino, animales = campo
    repetido = animales[0].id
    resp = await auth_client.post(
        BASE, json=_payload(est.id, origen.id, destino.id, [repetido, repetido])
    )
    assert resp.status_code == 422


@pytest.mark.anyio
async def test_motivo_vacio_se_rechaza(auth_client, campo):
    est, origen, destino, animales = campo
    resp = await auth_client.post(
        BASE,
        json=_payload(
            est.id, origen.id, destino.id, [a.id for a in animales], motivo="   "
        ),
    )
    assert resp.status_code == 422


@pytest.mark.anyio
async def test_destino_no_activo_se_rechaza(auth_client, session, campo):
    est, origen, destino, animales = campo
    destino.estado = EstadoLote.mantenimiento
    session.add(destino)
    await session.commit()

    resp = await auth_client.post(
        BASE, json=_payload(est.id, origen.id, destino.id, [a.id for a in animales])
    )
    assert resp.status_code == 422
    assert resp.json()["errors"][0]["code"] == "lote_destino_no_disponible"


@pytest.mark.anyio
async def test_destino_borrado_se_rechaza(auth_client, session, campo):
    from datetime import UTC, datetime

    est, origen, destino, animales = campo
    destino.deleted_at = datetime.now(UTC)
    session.add(destino)
    await session.commit()

    resp = await auth_client.post(
        BASE, json=_payload(est.id, origen.id, destino.id, [a.id for a in animales])
    )
    assert resp.status_code == 422
    assert resp.json()["errors"][0]["code"] == "lote_destino_no_disponible"


@pytest.mark.anyio
async def test_origen_inexistente_se_rechaza(auth_client, campo):
    est, _, destino, animales = campo
    resp = await auth_client.post(
        BASE, json=_payload(est.id, uuid4(), destino.id, [a.id for a in animales])
    )
    assert resp.status_code == 422
    assert resp.json()["errors"][0]["code"] == "lote_origen_no_disponible"


# ============================================================== aislamiento


@pytest.mark.anyio
async def test_sin_membresia_se_rechaza(auth_client, campo, establecimiento_ajeno):
    _, origen, destino, animales = campo
    resp = await auth_client.post(
        BASE,
        json=_payload(
            establecimiento_ajeno.id, origen.id, destino.id, [a.id for a in animales]
        ),
    )
    assert resp.status_code == 403
    assert resp.json()["errors"][0]["code"] == "establecimiento_no_autorizado"


@pytest.mark.anyio
async def test_lote_de_otro_establecimiento_se_rechaza(
    auth_client, session, campo, establecimiento_ajeno
):
    est, origen, _, animales = campo
    ajeno = crear_lote(establecimiento_ajeno.id, "Ajeno")
    session.add(ajeno)
    await session.commit()

    resp = await auth_client.post(
        BASE, json=_payload(est.id, origen.id, ajeno.id, [a.id for a in animales])
    )
    assert resp.status_code == 422
    assert resp.json()["errors"][0]["code"] == "lote_destino_no_disponible"


@pytest.mark.anyio
async def test_animal_de_otro_establecimiento_se_rechaza(
    auth_client, session, campo, establecimiento_ajeno
):
    est, origen, destino, _ = campo
    lote_ajeno = crear_lote(establecimiento_ajeno.id, "Ajeno")
    session.add(lote_ajeno)
    await session.flush()
    animal_ajeno = Animal(
        establecimiento_id=establecimiento_ajeno.id,
        lote_id=lote_ajeno.id,
        nro_caravana_rfid="999999999999999",
        sexo=SexoAnimal.macho,
        raza="Hereford",
    )
    session.add(animal_ajeno)
    await session.commit()

    resp = await auth_client.post(
        BASE, json=_payload(est.id, origen.id, destino.id, [animal_ajeno.id])
    )
    assert resp.status_code == 422
    assert resp.json()["errors"][0]["code"] == "animales_no_pertenecen_lote_origen"


@pytest.mark.anyio
async def test_listado_no_filtra_movimientos_de_otro_tenant(
    auth_client, campo, establecimiento_ajeno
):
    est, origen, destino, animales = campo
    await auth_client.post(
        BASE, json=_payload(est.id, origen.id, destino.id, [a.id for a in animales])
    )

    propios = await auth_client.get(BASE, params={"establecimiento_id": str(est.id)})
    assert len(propios.json()["data"]) == 1

    ajenos = await auth_client.get(
        BASE, params={"establecimiento_id": str(establecimiento_ajeno.id)}
    )
    assert ajenos.status_code == 403


# ==================================================================== pull


@pytest.mark.anyio
async def test_pull_incluye_animal_ids_y_tombstones(auth_client, campo):
    est, origen, destino, animales = campo
    movimiento_id = str(uuid4())
    payload = _payload(
        est.id, origen.id, destino.id, [a.id for a in animales], id=movimiento_id
    )
    await auth_client.post(BASE, json=payload)
    await auth_client.post(BASE, json={**payload, "deleted_at": "2026-09-01T10:00:00Z"})

    visibles = await auth_client.get(BASE, params={"establecimiento_id": str(est.id)})
    assert visibles.json()["data"] == []

    con_tombstones = await auth_client.get(
        BASE,
        params={"establecimiento_id": str(est.id), "include_deleted": "true"},
    )
    datos = con_tombstones.json()["data"]
    assert len(datos) == 1
    assert datos[0]["deleted_at"] is not None
    assert len(datos[0]["animal_ids"]) == 2
    assert all(UUID(a) for a in datos[0]["animal_ids"])
