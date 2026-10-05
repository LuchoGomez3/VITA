"""Borrar un animal borra lógicamente sus observaciones (VITA-173, Ernesto en #56).

El borrado se propaga por sync (``updated_since`` + ``include_deleted``).
Restaurar el animal restaura solo las observaciones que se borraron en esa
cascada; las que alguien borró a mano siguen borradas.
"""

from datetime import UTC, datetime, timedelta
from uuid import uuid4

import pytest

from api.modules.establecimientos.models import (
    Establecimiento,
    UsuarioEstablecimiento,
)
from api.shared.enums import RolUsuario

_OBS = "/api/v1/observaciones_animales"
_CARAVANAS = iter(f"{n:015d}" for n in range(400000000000001, 400000000001000))


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


def _alta_animal(campo, **extra) -> dict:
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


async def _animal(client, campo) -> dict:
    payload = _alta_animal(campo)
    assert (await client.post("/api/v1/animales", json=payload)).status_code == 201
    return payload


async def _nota(client, campo, animal_id, texto) -> str:
    resp = await client.post(
        _OBS,
        json={
            "establecimiento_id": str(campo),
            "animal_id": animal_id,
            "texto": texto,
            # Viejo a propósito: si aparece en un pull delta reciente, es porque
            # la cascada actualizó ``updated_at``.
            "created_at": "2026-09-01T10:00:00Z",
            "updated_at": "2026-09-01T10:00:00Z",
        },
    )
    assert resp.status_code == 201
    return resp.json()["data"]["id"]


async def _observaciones(client, campo, **params) -> dict[str, dict]:
    resp = await client.get(_OBS, params={"establecimiento_id": str(campo), **params})
    assert resp.status_code == 200
    return {o["id"]: o for o in resp.json()["data"]}


def _hace_un_rato() -> str:
    return (datetime.now(UTC) - timedelta(seconds=5)).isoformat()


@pytest.mark.anyio
async def test_borrar_el_animal_borra_sus_observaciones(auth_client, campo):
    vaca = await _animal(auth_client, campo)
    ternera = await _animal(auth_client, campo)
    notas_vaca = [
        await _nota(auth_client, campo, vaca["id"], texto) for texto in ("A", "B")
    ]
    nota_ternera = await _nota(auth_client, campo, ternera["id"], "De la ternera")
    desde = _hace_un_rato()

    resp = await auth_client.delete(
        f"/api/v1/animales/{vaca['id']}",
        params={"deleted_at": "2026-09-20T12:00:00Z"},
    )
    assert resp.status_code == 200

    # Dejan de mostrarse; las de otro animal no se tocan.
    assert set(await _observaciones(auth_client, campo)) == {nota_ternera}

    # El pull delta baja el borrado: deleted_at del animal y updated_at nuevo.
    delta = await _observaciones(
        auth_client, campo, updated_since=desde, include_deleted="true"
    )
    assert set(delta) == set(notas_vaca)
    for observacion in delta.values():
        assert observacion["deleted_at"].startswith("2026-09-20T12:00:00")


@pytest.mark.anyio
async def test_la_cascada_aplica_al_borrado_por_put_y_por_reenvio(auth_client, campo):
    por_put = await _animal(auth_client, campo)
    por_reenvio = await _animal(auth_client, campo)
    nota_put = await _nota(auth_client, campo, por_put["id"], "Por PUT")
    nota_reenvio = await _nota(auth_client, campo, por_reenvio["id"], "Por reenvío")

    await auth_client.put(
        f"/api/v1/animales/{por_put['id']}",
        json={
            "deleted_at": "2026-09-20T12:00:00Z",
            "updated_at": "2026-09-20T12:00:00Z",
        },
    )
    await auth_client.post(
        "/api/v1/animales",
        json={
            **por_reenvio,
            "deleted_at": "2026-09-21T12:00:00Z",
            "updated_at": "2026-09-21T12:00:00Z",
        },
    )

    borradas = await _observaciones(auth_client, campo, include_deleted="true")
    assert borradas[nota_put]["deleted_at"].startswith("2026-09-20T12:00:00")
    assert borradas[nota_reenvio]["deleted_at"].startswith("2026-09-21T12:00:00")
    assert await _observaciones(auth_client, campo) == {}


@pytest.mark.anyio
async def test_restaurar_el_animal_restaura_solo_las_de_la_cascada(auth_client, campo):
    vaca = await _animal(auth_client, campo)
    borrada_a_mano = await _nota(auth_client, campo, vaca["id"], "Borrada antes")
    viva = await _nota(auth_client, campo, vaca["id"], "Viva")
    await auth_client.delete(
        f"{_OBS}/{borrada_a_mano}", params={"deleted_at": "2026-09-10T00:00:00Z"}
    )
    await auth_client.delete(
        f"/api/v1/animales/{vaca['id']}",
        params={
            "deleted_at": "2026-09-20T12:00:00Z",
            "updated_at": "2026-09-20T12:00:00Z",
        },
    )
    desde = _hace_un_rato()

    # La restauración llega por el reenvío del alta, con deleted_at en null.
    resp = await auth_client.post(
        "/api/v1/animales",
        json={**vaca, "deleted_at": None, "updated_at": "2026-09-25T00:00:00Z"},
    )
    assert resp.status_code == 201
    assert resp.json()["data"]["deleted_at"] is None

    assert set(await _observaciones(auth_client, campo)) == {viva}
    # La restauración también viaja por el pull delta.
    delta = await _observaciones(
        auth_client, campo, updated_since=desde, include_deleted="true"
    )
    assert set(delta) == {viva}
    assert delta[viva]["deleted_at"] is None


@pytest.mark.anyio
async def test_volver_a_borrar_un_animal_borrado_mantiene_la_cascada(
    auth_client, campo
):
    """Si cambia la marca del borrado, las de la cascada la acompañan, y una
    restauración posterior las sigue encontrando."""
    vaca = await _animal(auth_client, campo)
    nota = await _nota(auth_client, campo, vaca["id"], "Nota")
    ruta = f"/api/v1/animales/{vaca['id']}"
    await auth_client.delete(ruta, params={"deleted_at": "2026-09-20T12:00:00Z"})
    await auth_client.delete(ruta, params={"deleted_at": "2026-09-22T12:00:00Z"})

    borradas = await _observaciones(auth_client, campo, include_deleted="true")
    assert borradas[nota]["deleted_at"].startswith("2026-09-22T12:00:00")

    await auth_client.post(
        "/api/v1/animales",
        json={**vaca, "deleted_at": None, "updated_at": "2030-01-01T00:00:00Z"},
    )
    assert set(await _observaciones(auth_client, campo)) == {nota}


@pytest.mark.anyio
async def test_un_borrado_rancio_del_animal_no_toca_observaciones(auth_client, campo):
    """Si el borrado pierde por last-write-wins, no hay cascada."""
    vaca = await _animal(auth_client, campo)
    nota = await _nota(auth_client, campo, vaca["id"], "Nota")

    await auth_client.put(
        f"/api/v1/animales/{vaca['id']}",
        json={
            "deleted_at": "2026-01-01T00:00:00Z",
            "updated_at": "2026-01-01T00:00:00Z",
        },
    )

    assert set(await _observaciones(auth_client, campo)) == {nota}


@pytest.mark.anyio
async def test_una_restauracion_rechazada_no_restaura_observaciones(
    auth_client, session, campo
):
    """Restaurar revalida el animal. Si la combinación ya no es válida, no vuelve
    ni el animal ni sus observaciones."""
    from api.modules.categorias.models import Categoria
    from api.shared.enums import SexoPermitido

    toro = Categoria(
        nombre="Toro",
        establecimiento_id=campo,
        sexo_permitido=SexoPermitido.macho,
    )
    session.add(toro)
    await session.commit()
    vaca = await _animal(auth_client, campo)
    nota = await _nota(auth_client, campo, vaca["id"], "Nota")
    await auth_client.delete(
        f"/api/v1/animales/{vaca['id']}",
        params={"deleted_at": "2026-09-20T12:00:00Z"},
    )

    resp = await auth_client.post(
        "/api/v1/animales",
        json={
            **vaca,
            "categoria_id": str(toro.id),
            "deleted_at": None,
            "updated_at": "2030-01-01T00:00:00Z",
        },
    )

    assert resp.status_code == 422
    borradas = await _observaciones(auth_client, campo, include_deleted="true")
    assert borradas[nota]["deleted_at"] is not None
