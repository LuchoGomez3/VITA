"""Tests del módulo lotes: contrato de sync, reglas de negocio y aislamiento."""

from datetime import UTC, datetime, timedelta
from uuid import UUID, uuid4

import pytest
from sqlalchemy import func, select

from api.modules.animales.models import Animal
from api.modules.establecimientos.models import (
    Establecimiento,
    UsuarioEstablecimiento,
)
from api.modules.lotes.models import Lote
from api.shared.enums import RolUsuario, SexoAnimal
from tests.factories import crear_lote, geometria_cuadrado, geometria_rectangulo

BASE = "/api/v1/lotes"


@pytest.fixture
async def establecimiento(session, usuario_actual):
    """Establecimiento con membresía owner del usuario actual."""
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
    await session.commit()
    return est


@pytest.fixture
async def establecimiento_ajeno(session, usuario_actual):
    """Establecimiento en el que el usuario actual NO tiene membresía."""
    otro_usuario_id = uuid4()
    est = Establecimiento(
        owner_id=otro_usuario_id,
        nombre="Estancia Ajena",
        nro_renspa="09.008.7.06543",
    )
    session.add(est)
    await session.commit()
    return est


def _payload(est_id, **overrides):
    base = {
        "id": str(uuid4()),
        "establecimiento_id": str(est_id),
        "nombre": "Potrero Bajo",
        "geometria_local": geometria_cuadrado(0),
        "superficie_ha": "45.7",
        "tiene_agua": True,
        "estado": "activo",
        "recurso_forrajero_codigo": "alfalfa",
    }
    base.update(overrides)
    return base


async def _crear(client, est_id, **overrides):
    return await client.post(BASE, json=_payload(est_id, **overrides))


# =========================================================== contrato de sync


@pytest.mark.anyio
async def test_round_trip_completo_con_geometria(auth_client, establecimiento):
    """El polígono debe volver idéntico: el cliente lo relee tal cual lo mandó."""
    geometria = geometria_cuadrado(1)
    resp = await _crear(auth_client, establecimiento.id, geometria_local=geometria)

    assert resp.status_code == 201
    data = resp.json()["data"]
    assert data["geometria_local"] == geometria
    assert data["modo_geometria"] == "local_schematic"
    assert data["nombre"] == "Potrero Bajo"
    assert data["tiene_agua"] is True
    assert data["estado"] == "activo"
    assert data["recurso_forrajero_codigo"] == "alfalfa"
    assert data["deleted_at"] is None
    # El adapter del cliente castea estos campos de forma estricta.
    for campo in ("id", "establecimiento_id", "created_at", "updated_at"):
        assert data[campo] is not None


@pytest.mark.anyio
async def test_post_respeta_id_y_timestamps_del_cliente(auth_client, establecimiento):
    lote_id = str(uuid4())
    creado = "2026-01-15T10:00:00Z"
    resp = await _crear(
        auth_client,
        establecimiento.id,
        id=lote_id,
        created_at=creado,
        updated_at=creado,
    )
    data = resp.json()["data"]
    assert data["id"] == lote_id
    assert data["created_at"].startswith("2026-01-15T10:00:00")


@pytest.mark.anyio
async def test_post_idempotente_no_duplica(auth_client, session, establecimiento):
    """Un replay de la cola offline confirma, no falla ni duplica."""
    payload = _payload(establecimiento.id)

    primera = await auth_client.post(BASE, json=payload)
    segunda = await auth_client.post(BASE, json=payload)

    assert primera.status_code == 201
    assert segunda.status_code == 201
    total = await session.execute(select(func.count()).select_from(Lote))
    assert total.scalar_one() == 1


@pytest.mark.anyio
async def test_post_last_write_wins(auth_client, establecimiento):
    lote_id = str(uuid4())
    await _crear(
        auth_client,
        establecimiento.id,
        id=lote_id,
        updated_at="2026-01-15T10:00:00Z",
    )

    nuevo = await _crear(
        auth_client,
        establecimiento.id,
        id=lote_id,
        nombre="Potrero Alto",
        updated_at="2026-02-20T10:00:00Z",
    )
    assert nuevo.json()["data"]["nombre"] == "Potrero Alto"

    viejo = await _crear(
        auth_client,
        establecimiento.id,
        id=lote_id,
        nombre="Nombre Rancio",
        updated_at="2025-12-01T10:00:00Z",
    )
    assert viejo.json()["data"]["nombre"] == "Potrero Alto"


@pytest.mark.anyio
async def test_empate_de_updated_at_gana_el_servidor(auth_client, establecimiento):
    """Ante timestamps iguales no hay forma de saber cuál es posterior."""
    lote_id = str(uuid4())
    momento = "2026-01-15T10:00:00Z"
    await _crear(auth_client, establecimiento.id, id=lote_id, updated_at=momento)

    resp = await _crear(
        auth_client,
        establecimiento.id,
        id=lote_id,
        nombre="Otro Nombre",
        updated_at=momento,
    )
    assert resp.json()["data"]["nombre"] == "Potrero Bajo"


@pytest.mark.anyio
async def test_put_conserva_updated_at_del_cliente(
    auth_client, session, establecimiento
):
    """El ``onupdate=func.now()`` del modelo no debe pisar el timestamp local."""
    creado = await _crear(
        auth_client, establecimiento.id, updated_at="2025-06-01T10:00:00Z"
    )
    lote_id = creado.json()["data"]["id"]

    await auth_client.put(
        f"{BASE}/{lote_id}",
        json={"nombre": "Renombrado", "updated_at": "2025-08-15T12:30:00Z"},
    )

    lote = await session.get(Lote, UUID(lote_id))
    await session.refresh(lote)
    assert lote.updated_at.year == 2025
    assert lote.updated_at.month == 8
    assert lote.nombre == "Renombrado"


@pytest.mark.anyio
async def test_put_descarta_cambio_rancio(auth_client, establecimiento):
    creado = await _crear(
        auth_client, establecimiento.id, updated_at="2026-05-01T10:00:00Z"
    )
    lote_id = creado.json()["data"]["id"]

    resp = await auth_client.put(
        f"{BASE}/{lote_id}",
        json={"nombre": "Viejo", "updated_at": "2026-01-01T10:00:00Z"},
    )
    assert resp.json()["data"]["nombre"] == "Potrero Bajo"


@pytest.mark.anyio
async def test_delete_soft_y_pull_include_deleted(auth_client, establecimiento):
    creado = await _crear(auth_client, establecimiento.id)
    lote_id = creado.json()["data"]["id"]

    borrado = await auth_client.delete(f"{BASE}/{lote_id}")
    assert borrado.status_code == 200
    assert borrado.json()["data"]["deleted_at"] is not None

    visibles = await auth_client.get(
        BASE, params={"establecimiento_id": str(establecimiento.id)}
    )
    assert visibles.json()["data"] == []

    con_tombstones = await auth_client.get(
        BASE,
        params={
            "establecimiento_id": str(establecimiento.id),
            "include_deleted": "true",
        },
    )
    tombstones = con_tombstones.json()["data"]
    assert len(tombstones) == 1
    assert tombstones[0]["deleted_at"] is not None


@pytest.mark.anyio
async def test_pull_updated_since_devuelve_solo_lo_nuevo(auth_client, establecimiento):
    await _crear(
        auth_client,
        establecimiento.id,
        nombre="Viejo",
        indice=0,
        updated_at="2026-01-01T10:00:00Z",
    )
    await _crear(
        auth_client,
        establecimiento.id,
        nombre="Nuevo",
        geometria_local=geometria_cuadrado(1),
        updated_at="2026-06-01T10:00:00Z",
    )

    resp = await auth_client.get(
        BASE,
        params={
            "establecimiento_id": str(establecimiento.id),
            "updated_since": "2026-03-01T00:00:00Z",
        },
    )
    nombres = [lote["nombre"] for lote in resp.json()["data"]]
    assert nombres == ["Nuevo"]


@pytest.mark.anyio
async def test_alta_ya_borrada_offline_conserva_el_tombstone(
    auth_client, establecimiento
):
    """Se crea y se borra sin conexión: el backend recibe las dos cosas juntas."""
    resp = await _crear(
        auth_client, establecimiento.id, deleted_at="2026-03-01T10:00:00Z"
    )
    assert resp.json()["data"]["deleted_at"] is not None


@pytest.mark.anyio
async def test_superficie_se_normaliza_a_un_decimal(auth_client, establecimiento):
    """El cliente guarda décimas exactas: el servidor fija esa precisión."""
    resp = await _crear(auth_client, establecimiento.id, superficie_ha="52.25")
    assert resp.json()["data"]["superficie_ha"] == "52.3"


@pytest.mark.anyio
async def test_modo_de_geometria_desconocido_se_rechaza(auth_client, establecimiento):
    resp = await _crear(auth_client, establecimiento.id, modo_geometria="geojson_wgs84")
    assert resp.status_code == 422


# ========================================================== reglas de negocio


@pytest.mark.anyio
async def test_nombre_duplicado_normalizado_se_rechaza(auth_client, establecimiento):
    """La comparación ignora mayúsculas y espacios de los extremos."""
    await _crear(auth_client, establecimiento.id, nombre="Potrero Bajo")

    resp = await _crear(
        auth_client,
        establecimiento.id,
        nombre="  potrero BAJO  ",
        geometria_local=geometria_cuadrado(1),
    )
    assert resp.status_code == 409
    assert resp.json()["errors"][0]["code"] == "nombre_lote_duplicado"


@pytest.mark.anyio
async def test_mismo_nombre_permitido_en_otro_establecimiento(
    auth_client, session, usuario_actual, establecimiento
):
    otro = Establecimiento(
        owner_id=usuario_actual.id, nombre="Segunda Estancia", nro_renspa="02.003.4.05"
    )
    session.add(otro)
    await session.flush()
    session.add(
        UsuarioEstablecimiento(
            usuario_id=usuario_actual.id,
            establecimiento_id=otro.id,
            rol=RolUsuario.owner,
            activo=True,
        )
    )
    await session.commit()

    await _crear(auth_client, establecimiento.id, nombre="Potrero Bajo")
    resp = await _crear(auth_client, otro.id, nombre="Potrero Bajo")
    assert resp.status_code == 201


@pytest.mark.anyio
async def test_tombstone_libera_el_nombre(auth_client, establecimiento):
    creado = await _crear(auth_client, establecimiento.id, nombre="Potrero Bajo")
    await auth_client.delete(f"{BASE}/{creado.json()['data']['id']}")

    resp = await _crear(auth_client, establecimiento.id, nombre="Potrero Bajo")
    assert resp.status_code == 201


@pytest.mark.anyio
async def test_superposicion_con_area_positiva_se_rechaza(auth_client, establecimiento):
    await _crear(
        auth_client,
        establecimiento.id,
        nombre="Primero",
        geometria_local=geometria_rectangulo(0, 0, 100, 100),
    )

    resp = await _crear(
        auth_client,
        establecimiento.id,
        nombre="Segundo",
        geometria_local=geometria_rectangulo(50, 50, 150, 150),
    )
    assert resp.status_code == 409
    assert resp.json()["errors"][0]["code"] == "lotes_superpuestos"


@pytest.mark.anyio
async def test_borde_compartido_es_valido(auth_client, establecimiento):
    """Dos potreros pegados comparten alambrado: no es una superposición."""
    await _crear(
        auth_client,
        establecimiento.id,
        nombre="Primero",
        geometria_local=geometria_rectangulo(0, 0, 100, 100),
    )

    resp = await _crear(
        auth_client,
        establecimiento.id,
        nombre="Segundo",
        geometria_local=geometria_rectangulo(100, 0, 200, 100),
    )
    assert resp.status_code == 201


@pytest.mark.anyio
async def test_lote_inactivo_sigue_ocupando_espacio(auth_client, establecimiento):
    """La división física existe aunque el lote no se use."""
    await _crear(
        auth_client,
        establecimiento.id,
        nombre="Inactivo",
        estado="inactivo",
        geometria_local=geometria_rectangulo(0, 0, 100, 100),
    )

    resp = await _crear(
        auth_client,
        establecimiento.id,
        nombre="Nuevo",
        geometria_local=geometria_rectangulo(50, 50, 150, 150),
    )
    assert resp.status_code == 409
    assert resp.json()["errors"][0]["code"] == "lotes_superpuestos"


@pytest.mark.anyio
async def test_lote_borrado_deja_de_ocupar_espacio(auth_client, establecimiento):
    creado = await _crear(
        auth_client,
        establecimiento.id,
        nombre="Borrado",
        geometria_local=geometria_rectangulo(0, 0, 100, 100),
    )
    await auth_client.delete(f"{BASE}/{creado.json()['data']['id']}")

    resp = await _crear(
        auth_client,
        establecimiento.id,
        nombre="Nuevo",
        geometria_local=geometria_rectangulo(50, 50, 150, 150),
    )
    assert resp.status_code == 201


@pytest.mark.anyio
async def test_geometria_invalida_se_rechaza(auth_client, establecimiento):
    mono = {
        "type": "LocalPolygon",
        "coordinate_space": "establishment_canvas_v1",
        "version": 1,
        "extent": {"width": 1000.0, "height": 1000.0},
        "vertices": [
            {"x": 0.0, "y": 0.0},
            {"x": 100.0, "y": 100.0},
            {"x": 100.0, "y": 0.0},
            {"x": 0.0, "y": 100.0},
        ],
    }
    resp = await _crear(auth_client, establecimiento.id, geometria_local=mono)
    assert resp.status_code == 422
    assert resp.json()["errors"][0]["code"] == "geometria_lote_invalida"


@pytest.mark.anyio
async def test_superficie_no_positiva_se_rechaza(auth_client, establecimiento):
    resp = await _crear(auth_client, establecimiento.id, superficie_ha="0")
    assert resp.status_code == 422


@pytest.mark.anyio
async def test_nombre_vacio_se_rechaza(auth_client, establecimiento):
    resp = await _crear(auth_client, establecimiento.id, nombre="   ")
    assert resp.status_code == 422


@pytest.mark.anyio
async def test_geometria_no_es_editable(auth_client, session, establecimiento):
    """Queda bloqueada tras el alta: un replay que la reenvía no la cambia."""
    original = geometria_rectangulo(0, 0, 100, 100)
    lote_id = str(uuid4())
    await _crear(
        auth_client,
        establecimiento.id,
        id=lote_id,
        geometria_local=original,
        updated_at="2026-01-01T10:00:00Z",
    )

    resp = await _crear(
        auth_client,
        establecimiento.id,
        id=lote_id,
        geometria_local=geometria_rectangulo(500, 500, 600, 600),
        updated_at="2026-06-01T10:00:00Z",
    )
    # No se rechaza (sería un rechazo definitivo en la cola), pero se ignora.
    assert resp.status_code == 201
    assert resp.json()["data"]["geometria_local"] == original


# ------------------------------------------------------------ con animales


async def _crear_animal(session, est_id, lote_id):
    animal = Animal(
        establecimiento_id=est_id,
        lote_id=UUID(lote_id),
        nro_caravana_rfid="123456789012345",
        sexo=SexoAnimal.hembra,
        raza="Angus",
    )
    session.add(animal)
    await session.commit()
    return animal


@pytest.mark.anyio
async def test_inactivar_lote_con_animales_se_rechaza(
    auth_client, session, establecimiento
):
    creado = await _crear(auth_client, establecimiento.id)
    lote_id = creado.json()["data"]["id"]
    await _crear_animal(session, establecimiento.id, lote_id)

    resp = await auth_client.put(
        f"{BASE}/{lote_id}",
        json={
            "estado": "inactivo",
            "updated_at": datetime.now(UTC).isoformat().replace("+00:00", "Z"),
        },
    )
    assert resp.status_code == 409
    assert resp.json()["errors"][0]["code"] == "lote_con_animales"


@pytest.mark.anyio
async def test_borrar_lote_con_animales_se_rechaza(
    auth_client, session, establecimiento
):
    creado = await _crear(auth_client, establecimiento.id)
    lote_id = creado.json()["data"]["id"]
    await _crear_animal(session, establecimiento.id, lote_id)

    resp = await auth_client.delete(f"{BASE}/{lote_id}")
    assert resp.status_code == 409
    assert resp.json()["errors"][0]["code"] == "lote_con_animales"


@pytest.mark.anyio
async def test_poner_en_descanso_con_animales_es_valido(
    auth_client, session, establecimiento
):
    """Descanso y mantenimiento no expulsan hacienda: solo cortan el ingreso."""
    creado = await _crear(auth_client, establecimiento.id)
    lote_id = creado.json()["data"]["id"]
    await _crear_animal(session, establecimiento.id, lote_id)

    futuro = (datetime.now(UTC) + timedelta(days=1)).isoformat().replace("+00:00", "Z")
    resp = await auth_client.put(
        f"{BASE}/{lote_id}", json={"estado": "descanso", "updated_at": futuro}
    )
    assert resp.status_code == 200
    assert resp.json()["data"]["estado"] == "descanso"


# ============================================================== aislamiento


@pytest.mark.anyio
async def test_crear_en_establecimiento_sin_membresia_se_rechaza(
    auth_client, establecimiento_ajeno
):
    resp = await _crear(auth_client, establecimiento_ajeno.id)
    assert resp.status_code == 403
    assert resp.json()["errors"][0]["code"] == "establecimiento_no_autorizado"


@pytest.mark.anyio
async def test_listar_establecimiento_sin_membresia_se_rechaza(
    auth_client, establecimiento_ajeno
):
    resp = await auth_client.get(
        BASE, params={"establecimiento_id": str(establecimiento_ajeno.id)}
    )
    assert resp.status_code == 403


@pytest.mark.anyio
async def test_detalle_de_otro_tenant_devuelve_404(
    auth_client, session, establecimiento_ajeno
):
    """404 y no 403: no se revela que el lote existe en otro establecimiento."""
    lote = crear_lote(establecimiento_ajeno.id, "Ajeno")
    session.add(lote)
    await session.commit()

    resp = await auth_client.get(f"{BASE}/{lote.id}")
    assert resp.status_code == 404
    assert resp.json()["errors"][0]["code"] == "lote_no_encontrado"


@pytest.mark.anyio
async def test_actualizar_lote_de_otro_tenant_se_rechaza(
    auth_client, session, establecimiento_ajeno
):
    lote = crear_lote(establecimiento_ajeno.id, "Ajeno")
    session.add(lote)
    await session.commit()

    resp = await auth_client.put(
        f"{BASE}/{lote.id}",
        json={"nombre": "Intruso", "updated_at": "2030-01-01T00:00:00Z"},
    )
    assert resp.status_code == 403


@pytest.mark.anyio
async def test_borrar_lote_de_otro_tenant_se_rechaza(
    auth_client, session, establecimiento_ajeno
):
    lote = crear_lote(establecimiento_ajeno.id, "Ajeno")
    session.add(lote)
    await session.commit()

    resp = await auth_client.delete(f"{BASE}/{lote.id}")
    assert resp.status_code == 403


@pytest.mark.anyio
async def test_listado_no_filtra_lotes_de_otro_tenant(
    auth_client, session, establecimiento, establecimiento_ajeno
):
    session.add(crear_lote(establecimiento_ajeno.id, "Ajeno"))
    await session.commit()
    await _crear(auth_client, establecimiento.id, nombre="Propio")

    resp = await auth_client.get(
        BASE, params={"establecimiento_id": str(establecimiento.id)}
    )
    nombres = [lote["nombre"] for lote in resp.json()["data"]]
    assert nombres == ["Propio"]


@pytest.mark.anyio
async def test_lote_inexistente_devuelve_404(auth_client):
    resp = await auth_client.put(
        f"{BASE}/{uuid4()}",
        json={"nombre": "X", "updated_at": "2030-01-01T00:00:00Z"},
    )
    assert resp.status_code == 404


@pytest.mark.anyio
async def test_detalle_devuelve_el_lote_propio(auth_client, establecimiento):
    creado = await _crear(auth_client, establecimiento.id)
    lote_id = creado.json()["data"]["id"]

    resp = await auth_client.get(f"{BASE}/{lote_id}")
    assert resp.status_code == 200
    assert resp.json()["data"]["nombre"] == "Potrero Bajo"


@pytest.mark.anyio
async def test_detalle_de_lote_borrado_devuelve_404(auth_client, establecimiento):
    creado = await _crear(auth_client, establecimiento.id)
    lote_id = creado.json()["data"]["id"]
    await auth_client.delete(f"{BASE}/{lote_id}")

    resp = await auth_client.get(f"{BASE}/{lote_id}")
    assert resp.status_code == 404


@pytest.mark.anyio
async def test_vecino_con_geometria_ilegible_no_bloquea_el_alta(
    auth_client, session, establecimiento
):
    """Un lote heredado sin geometría válida no puede frenar la sincronización."""
    roto = crear_lote(establecimiento.id, "Heredado")
    roto.geometria_local = {"type": "Vaya a saber", "vertices": []}
    session.add(roto)
    await session.commit()

    resp = await _crear(auth_client, establecimiento.id, nombre="Nuevo")
    assert resp.status_code == 201


@pytest.mark.anyio
async def test_put_con_nombre_vacio_se_rechaza(auth_client, establecimiento):
    creado = await _crear(auth_client, establecimiento.id)
    resp = await auth_client.put(
        f"{BASE}/{creado.json()['data']['id']}",
        json={"nombre": "  ", "updated_at": "2030-01-01T00:00:00Z"},
    )
    assert resp.status_code == 422


@pytest.mark.anyio
async def test_put_con_superficie_no_positiva_se_rechaza(auth_client, establecimiento):
    creado = await _crear(auth_client, establecimiento.id)
    resp = await auth_client.put(
        f"{BASE}/{creado.json()['data']['id']}",
        json={"superficie_ha": "-3", "updated_at": "2030-01-01T00:00:00Z"},
    )
    assert resp.status_code == 422


@pytest.mark.anyio
async def test_put_actualiza_forraje_agua_y_superficie(auth_client, establecimiento):
    creado = await _crear(
        auth_client, establecimiento.id, updated_at="2026-01-01T10:00:00Z"
    )
    resp = await auth_client.put(
        f"{BASE}/{creado.json()['data']['id']}",
        json={
            "superficie_ha": "60.4",
            "recurso_forrajero_codigo": "sorgo",
            "tiene_agua": False,
            "updated_at": "2026-07-01T10:00:00Z",
        },
    )
    data = resp.json()["data"]
    assert data["superficie_ha"] == "60.4"
    assert data["recurso_forrajero_codigo"] == "sorgo"
    assert data["tiene_agua"] is False
