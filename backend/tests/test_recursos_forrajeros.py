"""Tests del historial de recursos forrajeros de los lotes (adr-0015).

Cubren el contrato de sync del período (alta idempotente, LWW, 409), el
aislamiento entre establecimientos y cómo se mantiene
``lotes.recurso_forrajero_codigo``, incluida la compatibilidad con los clientes
que todavía editan el recurso desde el propio lote.
"""

from datetime import UTC, date, datetime, timedelta
from uuid import UUID, uuid4

import pytest
from sqlalchemy import select

from api.modules.establecimientos.models import (
    Establecimiento,
    UsuarioEstablecimiento,
)
from api.modules.lotes.models import Lote
from api.modules.recursos_forrajeros.models import PeriodoRecursoForrajero
from api.shared.enums import RolUsuario
from tests.factories import crear_lote, geometria_cuadrado

BASE = "/api/v1/lotes_recursos_forrajeros"
LOTES = "/api/v1/lotes"


@pytest.fixture
async def establecimiento(session, usuario_actual):
    est = Establecimiento(
        owner_id=usuario_actual.id, nombre="Estancia Test", nro_renspa="01.002.3.04567"
    )
    session.add(est)
    await session.flush()
    session.add(
        UsuarioEstablecimiento(
            usuario_id=usuario_actual.id,
            establecimiento_id=est.id,
            rol=RolUsuario.employee,
            activo=True,
        )
    )
    await session.commit()
    return est


@pytest.fixture
async def establecimiento_ajeno(session):
    est = Establecimiento(
        owner_id=uuid4(), nombre="Estancia Ajena", nro_renspa="09.008.7.06543"
    )
    session.add(est)
    await session.commit()
    return est


@pytest.fixture
async def lote(session, establecimiento):
    lote = crear_lote(establecimiento.id, "La Cumbre")
    session.add(lote)
    await session.commit()
    return lote


def _payload(est_id, lote_id, **overrides):
    base = {
        "id": str(uuid4()),
        "establecimiento_id": str(est_id),
        "lote_id": str(lote_id),
        "recurso_forrajero_codigo": "avena",
        "fecha_desde": "2026-05-01",
        "updated_at": "2026-05-01T12:00:00Z",
    }
    base.update(overrides)
    return base


async def _recurso_del_lote(session, lote_id):
    result = await session.execute(
        select(Lote.recurso_forrajero_codigo).where(Lote.id == lote_id)
    )
    return result.scalar_one()


# --------------------------------------------------------------------- alta


@pytest.mark.anyio
async def test_alta_registra_autor_y_deja_el_recurso_vigente(
    auth_client, session, establecimiento, lote, usuario_actual
):
    resp = await auth_client.post(BASE, json=_payload(establecimiento.id, lote.id))

    assert resp.status_code == 201
    data = resp.json()["data"]
    assert data["recurso_forrajero_codigo"] == "avena"
    assert data["fecha_hasta"] is None
    # El autor sale del JWT aunque el cliente mande otro.
    assert data["registrado_por_id"] == str(usuario_actual.id)
    assert await _recurso_del_lote(session, lote.id) == "avena"


@pytest.mark.anyio
async def test_el_autor_del_cliente_se_ignora(
    auth_client, establecimiento, lote, usuario_actual
):
    resp = await auth_client.post(
        BASE,
        json=_payload(establecimiento.id, lote.id, registrado_por_id=str(uuid4())),
    )
    assert resp.json()["data"]["registrado_por_id"] == str(usuario_actual.id)


@pytest.mark.anyio
async def test_el_periodo_mas_reciente_define_el_recurso_del_lote(
    auth_client, session, establecimiento, lote
):
    await auth_client.post(BASE, json=_payload(establecimiento.id, lote.id))
    # Se carga después un período anterior: no desplaza al vigente.
    await auth_client.post(
        BASE,
        json=_payload(
            establecimiento.id,
            lote.id,
            recurso_forrajero_codigo="rastrojo_maiz",
            fecha_desde="2026-02-01",
        ),
    )
    assert await _recurso_del_lote(session, lote.id) == "avena"

    await auth_client.post(
        BASE,
        json=_payload(
            establecimiento.id,
            lote.id,
            recurso_forrajero_codigo="verdeo_verano",
            fecha_desde="2026-09-01",
        ),
    )
    assert await _recurso_del_lote(session, lote.id) == "verdeo_verano"


@pytest.mark.anyio
async def test_un_periodo_cerrado_deja_el_lote_sin_recurso(
    auth_client, session, establecimiento, lote
):
    await auth_client.post(
        BASE,
        json=_payload(establecimiento.id, lote.id, fecha_hasta="2026-07-31"),
    )
    assert await _recurso_del_lote(session, lote.id) is None


@pytest.mark.anyio
async def test_cambiar_el_recurso_baja_el_lote_en_el_pull_delta(
    auth_client, session, establecimiento, lote
):
    antes = datetime.now(UTC) - timedelta(seconds=1)
    await auth_client.post(BASE, json=_payload(establecimiento.id, lote.id))

    resp = await auth_client.get(
        LOTES,
        params={
            "establecimiento_id": str(establecimiento.id),
            "updated_since": antes.isoformat(),
        },
    )
    ids = [lote_["id"] for lote_ in resp.json()["data"]]
    assert str(lote.id) in ids


# --------------------------------------------------------------- validaciones


@pytest.mark.anyio
async def test_misma_fecha_de_inicio_en_el_mismo_lote_es_conflicto(
    auth_client, establecimiento, lote
):
    await auth_client.post(BASE, json=_payload(establecimiento.id, lote.id))
    resp = await auth_client.post(
        BASE,
        json=_payload(establecimiento.id, lote.id, recurso_forrajero_codigo="sorgo"),
    )
    assert resp.status_code == 409
    assert resp.json()["errors"][0]["code"] == "periodo_recurso_duplicado"


@pytest.mark.anyio
async def test_otro_exige_descripcion(auth_client, establecimiento, lote):
    resp = await auth_client.post(
        BASE,
        json=_payload(
            establecimiento.id,
            lote.id,
            recurso_forrajero_codigo="otro",
            descripcion=" ",
        ),
    )
    assert resp.status_code == 422

    resp = await auth_client.post(
        BASE,
        json=_payload(
            establecimiento.id,
            lote.id,
            recurso_forrajero_codigo="otro",
            descripcion="Alfalfa + festuca",
        ),
    )
    assert resp.status_code == 201
    assert resp.json()["data"]["descripcion"] == "Alfalfa + festuca"


@pytest.mark.anyio
async def test_fin_anterior_al_inicio_se_rechaza(auth_client, establecimiento, lote):
    resp = await auth_client.post(
        BASE,
        json=_payload(establecimiento.id, lote.id, fecha_hasta="2026-04-30"),
    )
    assert resp.status_code == 422


@pytest.mark.anyio
async def test_fecha_futura_se_rechaza(auth_client, establecimiento, lote):
    futura = (date.today() + timedelta(days=5)).isoformat()
    resp = await auth_client.post(
        BASE, json=_payload(establecimiento.id, lote.id, fecha_desde=futura)
    )
    assert resp.status_code == 422
    assert resp.json()["errors"][0]["code"] == "fecha_futura"


@pytest.mark.anyio
async def test_codigo_fuera_del_catalogo_se_rechaza(auth_client, establecimiento, lote):
    resp = await auth_client.post(
        BASE,
        json=_payload(establecimiento.id, lote.id, recurso_forrajero_codigo="soja"),
    )
    assert resp.status_code == 422


# ----------------------------------------------------------- aislamiento


@pytest.mark.anyio
async def test_lote_de_otro_establecimiento_se_rechaza(
    auth_client, session, establecimiento, establecimiento_ajeno
):
    ajeno = crear_lote(establecimiento_ajeno.id, "Del vecino")
    session.add(ajeno)
    await session.commit()

    resp = await auth_client.post(BASE, json=_payload(establecimiento.id, ajeno.id))
    assert resp.status_code == 422
    assert resp.json()["errors"][0]["code"] == "lote_no_disponible"


@pytest.mark.anyio
async def test_sin_membresia_no_escribe_ni_lee(
    auth_client, session, establecimiento_ajeno
):
    ajeno = crear_lote(establecimiento_ajeno.id, "Del vecino")
    session.add(ajeno)
    await session.commit()

    resp = await auth_client.post(
        BASE, json=_payload(establecimiento_ajeno.id, ajeno.id)
    )
    assert resp.status_code == 403
    resp = await auth_client.get(
        BASE, params={"establecimiento_id": str(establecimiento_ajeno.id)}
    )
    assert resp.status_code == 403


# ------------------------------------------------------- idempotencia y sync


@pytest.mark.anyio
async def test_reenvio_identico_no_duplica(auth_client, session, establecimiento, lote):
    payload = _payload(establecimiento.id, lote.id)
    primero = await auth_client.post(BASE, json=payload)
    segundo = await auth_client.post(BASE, json=payload)

    assert primero.status_code == segundo.status_code == 201
    filas = (await session.execute(select(PeriodoRecursoForrajero))).scalars().all()
    assert len(filas) == 1


@pytest.mark.anyio
async def test_reenvio_mas_nuevo_corrige_y_cierra(
    auth_client, session, establecimiento, lote
):
    payload = _payload(establecimiento.id, lote.id)
    await auth_client.post(BASE, json=payload)

    resp = await auth_client.post(
        BASE,
        json={
            **payload,
            "recurso_forrajero_codigo": "centeno",
            "fecha_hasta": "2026-08-15",
            "updated_at": "2026-08-16T10:00:00Z",
        },
    )
    data = resp.json()["data"]
    assert data["recurso_forrajero_codigo"] == "centeno"
    assert data["fecha_hasta"] == "2026-08-15"
    assert await _recurso_del_lote(session, lote.id) is None


@pytest.mark.anyio
async def test_reenvio_rancio_no_pisa(auth_client, establecimiento, lote):
    payload = _payload(establecimiento.id, lote.id)
    await auth_client.post(BASE, json=payload)
    resp = await auth_client.post(
        BASE,
        json={
            **payload,
            "recurso_forrajero_codigo": "centeno",
            "updated_at": "2026-04-01T10:00:00Z",
        },
    )
    assert resp.json()["data"]["recurso_forrajero_codigo"] == "avena"


@pytest.mark.anyio
async def test_reenvio_con_otro_lote_es_conflicto(
    auth_client, session, establecimiento, lote
):
    otro = crear_lote(establecimiento.id, "El Bajo", indice_geometria=1)
    session.add(otro)
    await session.commit()
    payload = _payload(establecimiento.id, lote.id)
    await auth_client.post(BASE, json=payload)

    resp = await auth_client.post(
        BASE,
        json={**payload, "lote_id": str(otro.id), "updated_at": "2026-09-01T00:00:00Z"},
    )
    assert resp.status_code == 409
    assert resp.json()["errors"][0]["code"] == "periodo_recurso_id_en_conflicto"


@pytest.mark.anyio
async def test_borrado_logico_libera_la_fecha_y_viaja_en_el_pull(
    auth_client, session, establecimiento, lote
):
    payload = _payload(establecimiento.id, lote.id)
    await auth_client.post(BASE, json=payload)
    await auth_client.post(
        BASE,
        json={
            **payload,
            "deleted_at": "2026-06-01T00:00:00Z",
            "updated_at": "2026-06-01T00:00:00Z",
        },
    )
    assert await _recurso_del_lote(session, lote.id) is None

    # La fecha quedó libre para otro período.
    resp = await auth_client.post(BASE, json=_payload(establecimiento.id, lote.id))
    assert resp.status_code == 201

    vigentes = await auth_client.get(
        BASE, params={"establecimiento_id": str(establecimiento.id)}
    )
    con_borrados = await auth_client.get(
        BASE,
        params={"establecimiento_id": str(establecimiento.id), "include_deleted": True},
    )
    assert len(vigentes.json()["data"]) == 1
    assert len(con_borrados.json()["data"]) == 2


@pytest.mark.anyio
async def test_listar_filtra_por_lote_y_por_updated_since(
    auth_client, session, establecimiento, lote
):
    otro = crear_lote(establecimiento.id, "El Bajo", indice_geometria=1)
    session.add(otro)
    await session.commit()
    await auth_client.post(BASE, json=_payload(establecimiento.id, lote.id))
    await auth_client.post(BASE, json=_payload(establecimiento.id, otro.id))

    por_lote = await auth_client.get(
        BASE,
        params={"establecimiento_id": str(establecimiento.id), "lote_id": str(otro.id)},
    )
    assert [p["lote_id"] for p in por_lote.json()["data"]] == [str(otro.id)]

    delta = await auth_client.get(
        BASE,
        params={
            "establecimiento_id": str(establecimiento.id),
            "updated_since": "2030-01-01T00:00:00Z",
        },
    )
    assert delta.json()["data"] == []


# -------------------------------------- compatibilidad con el payload de /lotes


def _lote_payload(est_id, **overrides):
    base = {
        "id": str(uuid4()),
        "establecimiento_id": str(est_id),
        "nombre": "Potrero Nuevo",
        "geometria_local": geometria_cuadrado(3),
        "superficie_ha": "30",
        "tiene_agua": True,
        "estado": "activo",
        "recurso_forrajero_codigo": "alfalfa",
        "updated_at": "2026-03-01T10:00:00Z",
    }
    base.update(overrides)
    return base


async def _periodos(session, lote_id):
    session.expire_all()
    result = await session.execute(
        select(PeriodoRecursoForrajero)
        .where(PeriodoRecursoForrajero.lote_id == UUID(str(lote_id)))
        .order_by(PeriodoRecursoForrajero.fecha_desde)
    )
    return list(result.scalars().all())


@pytest.mark.anyio
async def test_alta_de_lote_con_recurso_abre_su_primer_periodo(
    auth_client, session, establecimiento
):
    payload = _lote_payload(establecimiento.id)
    resp = await auth_client.post(LOTES, json=payload)

    assert resp.status_code == 201
    assert resp.json()["data"]["recurso_forrajero_codigo"] == "alfalfa"
    # El alta conserva el updated_at del cliente.
    assert resp.json()["data"]["updated_at"].startswith("2026-03-01T10:00:00")
    periodos = await _periodos(session, payload["id"])
    assert [p.recurso_forrajero_codigo for p in periodos] == ["alfalfa"]


@pytest.mark.anyio
async def test_alta_de_lote_sin_recurso_no_abre_periodo(
    auth_client, session, establecimiento
):
    payload = _lote_payload(establecimiento.id, recurso_forrajero_codigo=None)
    await auth_client.post(LOTES, json=payload)
    assert await _periodos(session, payload["id"]) == []


@pytest.mark.anyio
async def test_put_de_cliente_viejo_registra_el_cambio_como_periodo(
    auth_client, session, establecimiento
):
    payload = _lote_payload(establecimiento.id)
    await auth_client.post(LOTES, json=payload)

    resp = await auth_client.put(
        f"{LOTES}/{payload['id']}",
        json={
            "recurso_forrajero_codigo": "sorgo",
            "updated_at": "2030-07-01T10:00:00Z",
        },
    )

    assert resp.json()["data"]["recurso_forrajero_codigo"] == "sorgo"
    periodos = await _periodos(session, payload["id"])
    assert [p.recurso_forrajero_codigo for p in periodos] == ["alfalfa", "sorgo"]
    assert periodos[-1].fecha_desde == date(2030, 7, 1)


@pytest.mark.anyio
async def test_reenvio_del_lote_con_el_mismo_recurso_no_agrega_periodos(
    auth_client, session, establecimiento
):
    payload = _lote_payload(establecimiento.id)
    await auth_client.post(LOTES, json=payload)
    await auth_client.post(
        LOTES,
        json={**payload, "nombre": "Renombrado", "updated_at": "2030-01-01T00:00:00Z"},
    )

    assert len(await _periodos(session, payload["id"])) == 1


@pytest.mark.anyio
async def test_lote_sin_recurso_en_el_payload_no_borra_el_historial(
    auth_client, session, establecimiento
):
    """Los clientes nuevos no mandan el recurso: el lote no puede perderlo."""
    payload = _lote_payload(establecimiento.id)
    await auth_client.post(LOTES, json=payload)
    resp = await auth_client.post(
        LOTES,
        json={
            **payload,
            "recurso_forrajero_codigo": None,
            "updated_at": "2030-01-01T00:00:00Z",
        },
    )

    assert resp.json()["data"]["recurso_forrajero_codigo"] == "alfalfa"
    assert len(await _periodos(session, payload["id"])) == 1
