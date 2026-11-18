"""Tests del catálogo de alimentos y de los registros de alimentación (adr-0015)."""

from datetime import UTC, date, datetime, timedelta
from uuid import uuid4

import pytest
from sqlalchemy import func, select

from api.modules.alimentacion.models import (
    RegistroAlimentacion,
    RegistroAlimentacionAnimal,
)
from api.modules.alimentos.models import Alimento
from api.modules.animales.models import Animal
from api.modules.establecimientos.models import (
    Establecimiento,
    UsuarioEstablecimiento,
)
from api.shared.enums import EstadoAnimal, RolUsuario, SexoAnimal
from tests.factories import crear_lote

ALIMENTOS = "/api/v1/alimentos"
REGISTROS = "/api/v1/registros_alimentacion"


def _animal(est_id, rfid: str, **overrides) -> Animal:
    campos = {
        "id": uuid4(),
        "establecimiento_id": est_id,
        "nro_caravana_rfid": rfid,
        "sexo": SexoAnimal.macho,
        "raza": "Angus",
        "fecha_nacimiento": date(2024, 1, 1),
        "estado": EstadoAnimal.activo,
    }
    campos.update(overrides)
    return Animal(**campos)


@pytest.fixture
async def campo(session, usuario_actual):
    """Establecimiento con membresía, un potrero, un alimento y tres animales."""
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
    lote = crear_lote(est.id, "La Cumbre")
    alimento = Alimento(establecimiento_id=est.id, nombre="Maíz partido")
    animales = [_animal(est.id, f"98200041288400{i}") for i in range(3)]
    session.add_all([lote, alimento, *animales])
    await session.commit()
    return {"est": est, "lote": lote, "alimento": alimento, "animales": animales}


@pytest.fixture
async def campo_ajeno(session):
    est = Establecimiento(
        owner_id=uuid4(), nombre="Estancia Ajena", nro_renspa="09.008.7.06543"
    )
    session.add(est)
    await session.flush()
    lote = crear_lote(est.id, "Del vecino")
    alimento = Alimento(establecimiento_id=est.id, nombre="Rollo del vecino")
    animal = _animal(est.id, "982000999000999")
    session.add_all([lote, alimento, animal])
    await session.commit()
    return {"est": est, "lote": lote, "alimento": alimento, "animal": animal}


def _registro(campo, **overrides):
    base = {
        "id": str(uuid4()),
        "establecimiento_id": str(campo["est"].id),
        "tipo": "suplemento",
        "alimento_id": str(campo["alimento"].id),
        "lote_id": str(campo["lote"].id),
        "fecha_desde": "2026-10-01",
        "fecha_hasta": None,
        "cantidad": "2.5",
        "unidad": "kg",
        "base_cantidad": "por_animal_dia",
        "motivo": "Sequía",
        "animal_ids": [str(a.id) for a in campo["animales"]],
        "updated_at": "2026-10-01T12:00:00Z",
    }
    base.update(overrides)
    return base


# ================================================================ alimentos


@pytest.mark.anyio
async def test_alta_de_alimento_con_autor_del_jwt(auth_client, campo, usuario_actual):
    resp = await auth_client.post(
        ALIMENTOS,
        json={
            "id": str(uuid4()),
            "establecimiento_id": str(campo["est"].id),
            "nombre": "  Núcleo proteico  ",
            "categoria": "concentrado",
            "unidad": "bolsa",
            "creado_por_id": str(uuid4()),
        },
    )

    assert resp.status_code == 201
    data = resp.json()["data"]
    assert data["nombre"] == "Núcleo proteico"
    assert data["categoria"] == "concentrado"
    assert data["unidad"] == "bolsa"
    assert data["creado_por_id"] == str(usuario_actual.id)
    # Los costos no se exponen todavía.
    assert "costo_unitario" not in data


@pytest.mark.anyio
async def test_alimento_sin_nombre_se_rechaza(auth_client, campo):
    resp = await auth_client.post(
        ALIMENTOS, json={"establecimiento_id": str(campo["est"].id), "nombre": "  "}
    )
    assert resp.status_code == 422


@pytest.mark.anyio
async def test_nombres_repetidos_se_toleran(auth_client, campo):
    """Dos altas offline del mismo nombre no pueden dejar registros rechazados."""
    for _ in range(2):
        resp = await auth_client.post(
            ALIMENTOS,
            json={"establecimiento_id": str(campo["est"].id), "nombre": "Maíz partido"},
        )
        assert resp.status_code == 201


@pytest.mark.anyio
async def test_alimento_reenvio_lww_y_borrado(auth_client, campo):
    payload = {
        "id": str(uuid4()),
        "establecimiento_id": str(campo["est"].id),
        "nombre": "Rollo",
        "unidad": "rollo",
        "updated_at": "2026-10-01T00:00:00Z",
    }
    await auth_client.post(ALIMENTOS, json=payload)
    rancio = await auth_client.post(
        ALIMENTOS,
        json={**payload, "nombre": "Viejo", "updated_at": "2026-09-01T00:00:00Z"},
    )
    assert rancio.json()["data"]["nombre"] == "Rollo"

    borrado = await auth_client.post(
        ALIMENTOS,
        json={
            **payload,
            "nombre": "Rollo de alfalfa",
            "deleted_at": "2026-10-02T00:00:00Z",
            "updated_at": "2026-10-02T00:00:00Z",
        },
    )
    assert borrado.json()["data"]["nombre"] == "Rollo de alfalfa"
    assert borrado.json()["data"]["deleted_at"] is not None


@pytest.mark.anyio
async def test_alimento_con_id_de_otro_campo_es_conflicto(
    auth_client, campo, campo_ajeno
):
    resp = await auth_client.post(
        ALIMENTOS,
        json={
            "id": str(campo_ajeno["alimento"].id),
            "establecimiento_id": str(campo["est"].id),
            "nombre": "Robado",
            "updated_at": "2030-01-01T00:00:00Z",
        },
    )
    assert resp.status_code == 409
    assert resp.json()["errors"][0]["code"] == "alimento_id_en_conflicto"


@pytest.mark.anyio
async def test_listar_alimentos_incluye_el_catalogo_global_y_no_los_ajenos(
    auth_client, session, campo, campo_ajeno
):
    session.add(Alimento(establecimiento_id=None, nombre="Sales minerales"))
    await session.commit()

    resp = await auth_client.get(
        ALIMENTOS, params={"establecimiento_id": str(campo["est"].id)}
    )
    nombres = {a["nombre"] for a in resp.json()["data"]}
    assert nombres == {"Maíz partido", "Sales minerales"}


@pytest.mark.anyio
async def test_alimentos_sin_membresia(auth_client, campo_ajeno):
    resp = await auth_client.get(
        ALIMENTOS, params={"establecimiento_id": str(campo_ajeno["est"].id)}
    )
    assert resp.status_code == 403


# ================================================================ registros


@pytest.mark.anyio
async def test_alta_para_varios_animales(auth_client, session, campo, usuario_actual):
    payload = _registro(campo, responsable_id=str(uuid4()))
    resp = await auth_client.post(REGISTROS, json=payload)

    assert resp.status_code == 201
    data = resp.json()["data"]
    assert data["cantidad"] == "2.500"
    assert data["fecha_hasta"] is None
    assert set(data["animal_ids"]) == set(payload["animal_ids"])
    assert data["responsable_id"] == str(usuario_actual.id)

    detalle = await session.execute(
        select(func.count()).select_from(RegistroAlimentacionAnimal)
    )
    assert detalle.scalar_one() == 3


@pytest.mark.anyio
async def test_alta_de_un_dia_en_corral(auth_client, campo):
    resp = await auth_client.post(
        REGISTROS,
        json=_registro(
            campo,
            tipo="dieta",
            lote_id=None,
            fecha_hasta="2026-10-01",
            base_cantidad="grupo_dia",
            animal_ids=[str(campo["animales"][0].id)],
        ),
    )
    assert resp.status_code == 201
    assert resp.json()["data"]["lote_id"] is None


@pytest.mark.anyio
async def test_alimento_global_se_puede_usar(auth_client, session, campo):
    global_ = Alimento(establecimiento_id=None, nombre="Sales minerales")
    session.add(global_)
    await session.commit()
    resp = await auth_client.post(
        REGISTROS, json=_registro(campo, alimento_id=str(global_.id))
    )
    assert resp.status_code == 201


@pytest.mark.parametrize(
    "overrides",
    [
        {"cantidad": "0"},
        {"cantidad": "-1"},
        {"fecha_hasta": "2026-09-30"},
        {"animal_ids": []},
        {"tipo": "golosina"},
        {"unidad": "tonelada"},
        {"base_cantidad": "por_semana"},
    ],
)
@pytest.mark.anyio
async def test_validaciones_del_payload(auth_client, campo, overrides):
    resp = await auth_client.post(REGISTROS, json=_registro(campo, **overrides))
    assert resp.status_code == 422


@pytest.mark.anyio
async def test_animales_repetidos_se_rechazan(auth_client, campo):
    animal = str(campo["animales"][0].id)
    resp = await auth_client.post(
        REGISTROS, json=_registro(campo, animal_ids=[animal, animal])
    )
    assert resp.status_code == 422


@pytest.mark.anyio
async def test_fecha_futura_se_rechaza(auth_client, campo):
    futura = (date.today() + timedelta(days=5)).isoformat()
    resp = await auth_client.post(REGISTROS, json=_registro(campo, fecha_desde=futura))
    assert resp.status_code == 422
    assert resp.json()["errors"][0]["code"] == "fecha_futura"


@pytest.mark.anyio
async def test_un_animal_ajeno_rechaza_el_registro_entero(
    auth_client, session, campo, campo_ajeno
):
    ids = [str(a.id) for a in campo["animales"]] + [str(campo_ajeno["animal"].id)]
    resp = await auth_client.post(REGISTROS, json=_registro(campo, animal_ids=ids))

    assert resp.status_code == 422
    error = resp.json()["errors"][0]
    assert error["code"] == "animales_no_disponibles"
    total = await session.execute(
        select(func.count()).select_from(RegistroAlimentacion)
    )
    assert total.scalar_one() == 0


@pytest.mark.anyio
async def test_animal_borrado_se_rechaza(auth_client, session, campo):
    borrado = _animal(campo["est"].id, "982000412884999", deleted_at=datetime.now(UTC))
    session.add(borrado)
    await session.commit()
    resp = await auth_client.post(
        REGISTROS, json=_registro(campo, animal_ids=[str(borrado.id)])
    )
    assert resp.status_code == 422


@pytest.mark.anyio
async def test_animal_vendido_se_acepta(auth_client, session, campo):
    """Se puede registrar retroactivamente lo que comió un animal ya vendido."""
    vendido = _animal(campo["est"].id, "982000412884998", estado=EstadoAnimal.vendido)
    session.add(vendido)
    await session.commit()
    resp = await auth_client.post(
        REGISTROS, json=_registro(campo, animal_ids=[str(vendido.id)])
    )
    assert resp.status_code == 201


@pytest.mark.anyio
async def test_alimento_ajeno_o_borrado_se_rechaza(
    auth_client, session, campo, campo_ajeno
):
    resp = await auth_client.post(
        REGISTROS, json=_registro(campo, alimento_id=str(campo_ajeno["alimento"].id))
    )
    assert resp.status_code == 422
    assert resp.json()["errors"][0]["code"] == "alimento_no_disponible"

    borrado = Alimento(
        establecimiento_id=campo["est"].id, nombre="Viejo", deleted_at=datetime.now(UTC)
    )
    session.add(borrado)
    await session.commit()
    resp = await auth_client.post(
        REGISTROS, json=_registro(campo, alimento_id=str(borrado.id))
    )
    assert resp.status_code == 422


@pytest.mark.anyio
async def test_lote_ajeno_se_rechaza(auth_client, campo, campo_ajeno):
    resp = await auth_client.post(
        REGISTROS, json=_registro(campo, lote_id=str(campo_ajeno["lote"].id))
    )
    assert resp.status_code == 422
    assert resp.json()["errors"][0]["code"] == "lote_no_disponible"


@pytest.mark.anyio
async def test_sin_membresia_no_escribe(auth_client, campo_ajeno):
    payload = {
        "establecimiento_id": str(campo_ajeno["est"].id),
        "tipo": "suplemento",
        "alimento_id": str(campo_ajeno["alimento"].id),
        "fecha_desde": "2026-10-01",
        "cantidad": "1",
        "unidad": "kg",
        "base_cantidad": "grupo_dia",
        "animal_ids": [str(campo_ajeno["animal"].id)],
    }
    resp = await auth_client.post(REGISTROS, json=payload)
    assert resp.status_code == 403


# ------------------------------------------------------- idempotencia y sync


@pytest.mark.anyio
async def test_reenvio_identico_no_duplica(auth_client, session, campo):
    payload = _registro(campo)
    await auth_client.post(REGISTROS, json=payload)
    resp = await auth_client.post(REGISTROS, json=payload)

    assert resp.status_code == 201
    cabeceras = await session.execute(
        select(func.count()).select_from(RegistroAlimentacion)
    )
    detalle = await session.execute(
        select(func.count()).select_from(RegistroAlimentacionAnimal)
    )
    assert cabeceras.scalar_one() == 1
    assert detalle.scalar_one() == 3


@pytest.mark.anyio
async def test_cerrar_una_dieta_en_curso_por_lww(auth_client, campo):
    payload = _registro(campo, tipo="dieta")
    await auth_client.post(REGISTROS, json=payload)

    resp = await auth_client.post(
        REGISTROS,
        json={
            **payload,
            "fecha_hasta": "2026-10-20",
            "cantidad": "3",
            "motivo": "Terminó la sequía",
            "updated_at": "2026-10-20T18:00:00Z",
        },
    )
    data = resp.json()["data"]
    assert data["fecha_hasta"] == "2026-10-20"
    assert data["cantidad"] == "3.000"
    assert data["motivo"] == "Terminó la sequía"


@pytest.mark.anyio
async def test_reenvio_rancio_no_pisa(auth_client, campo):
    payload = _registro(campo)
    await auth_client.post(REGISTROS, json=payload)
    resp = await auth_client.post(
        REGISTROS,
        json={**payload, "cantidad": "9", "updated_at": "2026-09-01T00:00:00Z"},
    )
    assert resp.json()["data"]["cantidad"] == "2.500"


@pytest.mark.parametrize(
    "cambio",
    ["animales", "alimento", "tipo"],
)
@pytest.mark.anyio
async def test_cambiar_la_identidad_con_el_mismo_uuid_es_conflicto(
    auth_client, session, campo, cambio
):
    payload = _registro(campo)
    await auth_client.post(REGISTROS, json=payload)

    if cambio == "animales":
        cambios = {"animal_ids": payload["animal_ids"][:1]}
    elif cambio == "alimento":
        otro = Alimento(establecimiento_id=campo["est"].id, nombre="Rollo")
        session.add(otro)
        await session.commit()
        cambios = {"alimento_id": str(otro.id)}
    else:
        cambios = {"tipo": "dieta"}

    resp = await auth_client.post(
        REGISTROS,
        json={**payload, **cambios, "updated_at": "2030-01-01T00:00:00Z"},
    )
    assert resp.status_code == 409
    assert resp.json()["errors"][0]["code"] == "registro_alimentacion_id_en_conflicto"


@pytest.mark.anyio
async def test_mismos_animales_en_otro_orden_no_es_conflicto(auth_client, campo):
    payload = _registro(campo)
    await auth_client.post(REGISTROS, json=payload)
    resp = await auth_client.post(
        REGISTROS, json={**payload, "animal_ids": list(reversed(payload["animal_ids"]))}
    )
    assert resp.status_code == 201


@pytest.mark.anyio
async def test_borrado_logico_y_pull(auth_client, campo):
    payload = _registro(campo)
    await auth_client.post(REGISTROS, json=payload)
    await auth_client.post(
        REGISTROS,
        json={
            **payload,
            "deleted_at": "2026-10-05T00:00:00Z",
            "updated_at": "2026-10-05T00:00:00Z",
        },
    )

    params = {"establecimiento_id": str(campo["est"].id)}
    vigentes = await auth_client.get(REGISTROS, params=params)
    con_borrados = await auth_client.get(
        REGISTROS, params={**params, "include_deleted": True}
    )
    assert vigentes.json()["data"] == []
    [borrado] = con_borrados.json()["data"]
    assert borrado["deleted_at"] is not None
    assert len(borrado["animal_ids"]) == 3


@pytest.mark.anyio
async def test_listar_por_animal_y_delta(auth_client, campo):
    primero, segundo, _ = campo["animales"]
    await auth_client.post(
        REGISTROS, json=_registro(campo, animal_ids=[str(primero.id)])
    )
    await auth_client.post(
        REGISTROS, json=_registro(campo, animal_ids=[str(segundo.id)])
    )

    params = {"establecimiento_id": str(campo["est"].id)}
    del_primero = await auth_client.get(
        REGISTROS, params={**params, "animal_id": str(primero.id)}
    )
    assert [r["animal_ids"] for r in del_primero.json()["data"]] == [[str(primero.id)]]

    delta = await auth_client.get(
        REGISTROS, params={**params, "updated_since": "2030-01-01T00:00:00Z"}
    )
    assert delta.json()["data"] == []


@pytest.mark.anyio
async def test_listar_sin_membresia(auth_client, campo_ajeno):
    resp = await auth_client.get(
        REGISTROS, params={"establecimiento_id": str(campo_ajeno["est"].id)}
    )
    assert resp.status_code == 403
