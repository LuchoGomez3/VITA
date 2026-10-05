"""Observaciones de un animal como entradas independientes (VITA-173)."""

from datetime import date
from uuid import UUID, uuid4

import pytest
from sqlalchemy import select

from api.modules.animales.models import Animal
from api.modules.establecimientos.models import (
    Establecimiento,
    UsuarioEstablecimiento,
)
from api.modules.observaciones_animales.models import ObservacionAnimal
from api.modules.usuarios.models import Usuario
from api.shared.enums import RolUsuario, SexoAnimal

_RUTA = "/api/v1/observaciones_animales"


def _animal(establecimiento_id, caravana) -> Animal:
    return Animal(
        establecimiento_id=establecimiento_id,
        nro_caravana_rfid=caravana,
        sexo=SexoAnimal.hembra,
        raza="Angus",
        fecha_nacimiento=date(2022, 3, 10),
    )


@pytest.fixture
async def campo(session, usuario_actual):
    """Establecimiento del usuario con dos animales, y uno ajeno con el suyo."""
    otro_usuario = Usuario(
        id=uuid4(),
        nombre="Otro",
        apellido="Dueño",
        email="otro@vita.test",
        cuit="20222222223",
    )
    session.add(otro_usuario)
    await session.flush()
    est = Establecimiento(owner_id=usuario_actual.id, nombre="Estancia Test")
    ajeno = Establecimiento(owner_id=otro_usuario.id, nombre="Campo Ajeno")
    session.add_all([est, ajeno])
    await session.flush()
    session.add(
        UsuarioEstablecimiento(
            usuario_id=usuario_actual.id,
            establecimiento_id=est.id,
            rol=RolUsuario.employee,
            activo=True,
        )
    )
    vaca = _animal(est.id, "100000000000001")
    ternera = _animal(est.id, "100000000000002")
    animal_ajeno = _animal(ajeno.id, "100000000000003")
    session.add_all([vaca, ternera, animal_ajeno])
    await session.commit()
    return {
        "est": est.id,
        "ajeno": ajeno.id,
        "vaca": vaca.id,
        "ternera": ternera.id,
        "animal_ajeno": animal_ajeno.id,
        "otro_usuario": otro_usuario.id,
    }


def _payload(campo, texto="Cojea de la pata trasera", **extra):
    payload = {
        "establecimiento_id": str(campo["est"]),
        "animal_id": str(campo["vaca"]),
        "texto": texto,
    }
    payload.update(extra)
    return payload


async def _agregar(client, campo, texto, **extra):
    resp = await client.post(_RUTA, json=_payload(campo, texto, **extra))
    assert resp.status_code == 201, resp.json()
    return resp.json()["data"]


async def _listar(client, campo, **params):
    """Lista las de la vaca; ``animal_id=None`` lista todo el establecimiento."""
    consulta = {
        "establecimiento_id": str(campo["est"]),
        "animal_id": str(campo["vaca"]),
        **params,
    }
    resp = await client.get(
        _RUTA, params={k: v for k, v in consulta.items() if v is not None}
    )
    assert resp.status_code == 200
    return resp.json()["data"]


def _codigo(resp) -> str:
    return resp.json()["errors"][0]["code"]


@pytest.mark.anyio
async def test_alta_registra_texto_fecha_y_autor(auth_client, campo, usuario_actual):
    data = await _agregar(
        auth_client, campo, "Vacunada contra aftosa", fecha="2026-09-20T10:00:00Z"
    )

    assert data["texto"] == "Vacunada contra aftosa"
    assert data["fecha"].startswith("2026-09-20T10:00:00")
    assert data["autor_id"] == str(usuario_actual.id)
    assert data["animal_id"] == str(campo["vaca"])


@pytest.mark.anyio
async def test_el_autor_sale_del_usuario_autenticado(
    auth_client, campo, usuario_actual
):
    payload = _payload(campo, autor_id=str(campo["otro_usuario"]))
    resp = await auth_client.post(_RUTA, json=payload)
    assert resp.json()["data"]["autor_id"] == str(usuario_actual.id)


@pytest.mark.anyio
async def test_sin_fecha_usa_la_de_creacion_del_cliente(auth_client, campo):
    data = await _agregar(
        auth_client, campo, "Nota offline", created_at="2026-08-01T08:00:00Z"
    )
    assert data["fecha"].startswith("2026-08-01T08:00:00")


@pytest.mark.anyio
@pytest.mark.parametrize("texto", ["", "   ", "\n\t "])
async def test_texto_vacio_se_rechaza(auth_client, campo, texto):
    resp = await auth_client.post(_RUTA, json=_payload(campo, texto))
    assert resp.status_code == 422
    assert await _listar(auth_client, campo) == []


@pytest.mark.anyio
async def test_el_texto_se_guarda_tal_cual(auth_client, campo):
    data = await _agregar(auth_client, campo, "  Línea 1\nLínea 2  ")
    assert data["texto"] == "  Línea 1\nLínea 2  "


@pytest.mark.anyio
async def test_varias_observaciones_conviven_y_editar_una_no_toca_las_demas(
    auth_client, campo
):
    primera = await _agregar(
        auth_client, campo, "Primera", fecha="2026-09-01T00:00:00Z"
    )
    segunda = await _agregar(
        auth_client, campo, "Segunda", fecha="2026-09-02T00:00:00Z"
    )

    resp = await auth_client.put(
        f"{_RUTA}/{primera['id']}", json={"texto": "Primera corregida"}
    )
    assert resp.status_code == 200

    textos = {o["id"]: o["texto"] for o in await _listar(auth_client, campo)}
    assert textos == {primera["id"]: "Primera corregida", segunda["id"]: "Segunda"}


@pytest.mark.anyio
async def test_borrado_logico_no_altera_las_restantes(auth_client, campo):
    queda = await _agregar(auth_client, campo, "Queda")
    borrada = await _agregar(auth_client, campo, "Se borra")

    resp = await auth_client.delete(f"{_RUTA}/{borrada['id']}")
    assert resp.status_code == 200
    assert resp.json()["data"]["deleted_at"] is not None

    visibles = await _listar(auth_client, campo)
    assert [o["id"] for o in visibles] == [queda["id"]]
    assert visibles[0]["texto"] == "Queda"


@pytest.mark.anyio
async def test_orden_por_fecha_descendente_con_desempate_estable(auth_client, campo):
    misma_fecha = "2026-09-10T12:00:00Z"
    vieja = await _agregar(auth_client, campo, "Vieja", fecha="2026-09-01T00:00:00Z")
    a = await _agregar(
        auth_client,
        campo,
        "A",
        fecha=misma_fecha,
        created_at="2026-09-10T12:00:00Z",
    )
    b = await _agregar(
        auth_client,
        campo,
        "B",
        fecha=misma_fecha,
        created_at="2026-09-10T12:05:00Z",
    )
    nueva = await _agregar(auth_client, campo, "Nueva", fecha="2026-09-20T00:00:00Z")

    ids = [o["id"] for o in await _listar(auth_client, campo)]

    # Misma fecha: primero la creada después.
    assert ids == [nueva["id"], b["id"], a["id"], vieja["id"]]
    assert ids == [o["id"] for o in await _listar(auth_client, campo)]


@pytest.mark.anyio
async def test_filtra_por_animal(auth_client, campo):
    await _agregar(auth_client, campo, "De la vaca")
    await _agregar(auth_client, campo, "De la ternera", animal_id=str(campo["ternera"]))

    de_la_vaca = await _listar(auth_client, campo)
    todas = await _listar(auth_client, campo, animal_id=None)

    assert [o["texto"] for o in de_la_vaca] == ["De la vaca"]
    assert len(todas) == 2


# ------------------------------------------------------------- aislamiento


@pytest.mark.anyio
async def test_no_se_consultan_observaciones_de_un_establecimiento_ajeno(
    auth_client, campo
):
    resp = await auth_client.get(
        _RUTA, params={"establecimiento_id": str(campo["ajeno"])}
    )
    assert resp.status_code == 403
    assert _codigo(resp) == "establecimiento_no_autorizado"


@pytest.mark.anyio
async def test_no_se_agrega_a_un_animal_de_otro_establecimiento(auth_client, campo):
    resp = await auth_client.post(
        _RUTA, json=_payload(campo, animal_id=str(campo["animal_ajeno"]))
    )
    assert resp.status_code == 422
    assert _codigo(resp) == "animal_no_pertenece_establecimiento"

    resp = await auth_client.post(
        _RUTA,
        json=_payload(
            campo,
            establecimiento_id=str(campo["ajeno"]),
            animal_id=str(campo["animal_ajeno"]),
        ),
    )
    assert resp.status_code == 403


@pytest.mark.anyio
async def test_no_se_agrega_a_un_animal_borrado(auth_client, session, campo):
    vaca = await session.get(Animal, campo["vaca"])
    vaca.deleted_at = vaca.updated_at
    await session.commit()

    resp = await auth_client.post(_RUTA, json=_payload(campo))
    assert resp.status_code == 422


@pytest.mark.anyio
async def test_no_se_edita_ni_borra_una_observacion_ajena(auth_client, session, campo):
    ajena = ObservacionAnimal(
        establecimiento_id=campo["ajeno"],
        animal_id=campo["animal_ajeno"],
        texto="Nota del vecino",
        fecha=date(2026, 9, 1),
        autor_id=campo["otro_usuario"],
    )
    session.add(ajena)
    await session.commit()

    editar = await auth_client.put(f"{_RUTA}/{ajena.id}", json={"texto": "Pisada"})
    borrar = await auth_client.delete(f"{_RUTA}/{ajena.id}")
    # Reenviar un alta con su id tampoco sirve para tocarla.
    reenvio = await auth_client.post(
        _RUTA, json=_payload(campo, id=str(ajena.id), texto="Pisada")
    )

    for resp in (editar, borrar, reenvio):
        assert resp.status_code == 404
        assert _codigo(resp) == "observacion_no_encontrada"
    await session.refresh(ajena)
    assert ajena.texto == "Nota del vecino"
    assert ajena.deleted_at is None


@pytest.mark.anyio
async def test_observacion_inexistente_da_404(auth_client, campo):
    resp = await auth_client.put(f"{_RUTA}/{uuid4()}", json={"texto": "x"})
    assert resp.status_code == 404


# ------------------------------------------------------------ sincronización


@pytest.mark.anyio
async def test_reintento_offline_no_duplica(auth_client, session, campo):
    payload = _payload(campo, id=str(uuid4()), updated_at="2026-09-01T10:00:00Z")
    primera = await auth_client.post(_RUTA, json=payload)
    segunda = await auth_client.post(_RUTA, json=payload)
    sin_timestamps = await auth_client.post(
        _RUTA, json={k: v for k, v in payload.items() if k != "updated_at"}
    )

    assert primera.status_code == segunda.status_code == sin_timestamps.status_code
    filas = await session.execute(
        select(ObservacionAnimal).where(ObservacionAnimal.id == UUID(payload["id"]))
    )
    assert len(filas.scalars().all()) == 1
    assert len(await _listar(auth_client, campo)) == 1


@pytest.mark.anyio
async def test_reenvio_mas_nuevo_aplica_y_uno_rancio_no(auth_client, campo):
    base = _payload(campo, id=str(uuid4()), updated_at="2026-09-01T10:00:00Z")
    await auth_client.post(_RUTA, json=base)

    nuevo = await auth_client.post(
        _RUTA, json={**base, "texto": "Editada", "updated_at": "2026-09-02T10:00:00Z"}
    )
    rancio = await auth_client.post(
        _RUTA, json={**base, "texto": "Vieja", "updated_at": "2026-08-01T10:00:00Z"}
    )

    assert nuevo.json()["data"]["texto"] == "Editada"
    assert rancio.json()["data"]["texto"] == "Editada"


@pytest.mark.anyio
async def test_edicion_rancia_pierde_por_updated_at(auth_client, campo):
    obs = await _agregar(
        auth_client, campo, "Original", updated_at="2026-09-05T00:00:00Z"
    )

    resp = await auth_client.put(
        f"{_RUTA}/{obs['id']}",
        json={"texto": "Vieja", "updated_at": "2026-09-01T00:00:00Z"},
    )

    assert resp.status_code == 200
    assert resp.json()["data"]["texto"] == "Original"


@pytest.mark.anyio
async def test_reenvio_no_puede_mover_la_observacion_de_animal(auth_client, campo):
    base = _payload(campo, id=str(uuid4()), updated_at="2026-09-01T10:00:00Z")
    await auth_client.post(_RUTA, json=base)

    resp = await auth_client.post(
        _RUTA,
        json={
            **base,
            "animal_id": str(campo["ternera"]),
            "updated_at": "2026-09-02T10:00:00Z",
        },
    )

    assert resp.status_code == 422
    assert _codigo(resp) == "observacion_inmutable"
    assert (await _listar(auth_client, campo))[0]["animal_id"] == str(campo["vaca"])


@pytest.mark.anyio
async def test_el_borrado_se_propaga_en_el_pull_delta(auth_client, campo):
    obs = await _agregar(auth_client, campo, "Se borra offline")
    await auth_client.delete(
        f"{_RUTA}/{obs['id']}",
        params={
            "deleted_at": "2030-01-01T00:00:00Z",
            "updated_at": "2030-01-01T00:00:00Z",
        },
    )

    delta = await _listar(
        auth_client,
        campo,
        animal_id=None,
        updated_since="2029-12-31T00:00:00Z",
        include_deleted="true",
    )

    assert [o["id"] for o in delta] == [obs["id"]]
    assert delta[0]["deleted_at"] is not None
    assert await _listar(auth_client, campo, updated_since="2029-12-31T00:00:00Z") == []


@pytest.mark.anyio
async def test_borrado_por_reenvio_del_alta(auth_client, campo):
    base = _payload(campo, id=str(uuid4()), updated_at="2026-09-01T10:00:00Z")
    await auth_client.post(_RUTA, json=base)

    await auth_client.post(
        _RUTA,
        json={
            **base,
            "deleted_at": "2026-09-02T10:00:00Z",
            "updated_at": "2026-09-02T10:00:00Z",
        },
    )

    assert await _listar(auth_client, campo) == []
