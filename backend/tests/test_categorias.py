"""Tests del CRUD de categorías (catálogo global + propias del establecimiento)."""

from datetime import date
from uuid import uuid4

import pytest

from api.modules.animales.models import Animal
from api.modules.categorias.models import Categoria
from api.modules.establecimientos.models import (
    Establecimiento,
    UsuarioEstablecimiento,
)
from api.shared.enums import EstadoAnimal, RolUsuario, SexoAnimal


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


@pytest.mark.anyio
async def test_crear_y_listar_categoria_propia(auth_client, establecimiento):
    resp = await auth_client.post(
        "/api/v1/categorias",
        json={
            "establecimiento_id": str(establecimiento.id),
            "nombre": "Vaquillona",
            "descripcion": "Hembra joven",
        },
    )
    assert resp.status_code == 201
    assert resp.json()["data"]["nombre"] == "Vaquillona"

    listado = await auth_client.get(
        "/api/v1/categorias", params={"establecimiento_id": str(establecimiento.id)}
    )
    nombres = [c["nombre"] for c in listado.json()["data"]]
    assert "Vaquillona" in nombres


@pytest.mark.anyio
async def test_listado_incluye_catalogo_global(auth_client, session, establecimiento):
    """El listado devuelve categorías globales (establecimiento_id null) + propias."""
    session.add(Categoria(nombre="Ternero", establecimiento_id=None))
    await session.commit()

    resp = await auth_client.get(
        "/api/v1/categorias", params={"establecimiento_id": str(establecimiento.id)}
    )
    data = resp.json()["data"]
    global_cat = next(c for c in data if c["nombre"] == "Ternero")
    assert global_cat["establecimiento_id"] is None


@pytest.mark.anyio
async def test_no_lista_categorias_de_otro_establecimiento(
    auth_client, session, establecimiento, usuario_actual
):
    otro = Establecimiento(
        owner_id=usuario_actual.id, nombre="Otro", nro_renspa="09.008.7.06543"
    )
    session.add(otro)
    await session.flush()
    session.add(Categoria(nombre="Ajena", establecimiento_id=otro.id))
    await session.commit()

    resp = await auth_client.get(
        "/api/v1/categorias", params={"establecimiento_id": str(establecimiento.id)}
    )
    nombres = [c["nombre"] for c in resp.json()["data"]]
    assert "Ajena" not in nombres


@pytest.mark.anyio
async def test_nombre_duplicado_falla(auth_client, establecimiento):
    payload = {"establecimiento_id": str(establecimiento.id), "nombre": "Novillo"}
    await auth_client.post("/api/v1/categorias", json=payload)
    # Mismo nombre distinto id -> conflicto (case-insensitive).
    resp = await auth_client.post(
        "/api/v1/categorias",
        json={"establecimiento_id": str(establecimiento.id), "nombre": "novillo"},
    )
    assert resp.status_code == 409
    assert resp.json()["errors"][0]["code"] == "categoria_duplicada"


@pytest.mark.anyio
async def test_crear_sin_acceso_falla(auth_client):
    resp = await auth_client.post(
        "/api/v1/categorias",
        json={"establecimiento_id": str(uuid4()), "nombre": "X"},
    )
    assert resp.status_code == 403
    assert resp.json()["errors"][0]["code"] == "establecimiento_no_autorizado"


@pytest.mark.anyio
async def test_actualizar_categoria(auth_client, establecimiento):
    cid = str(uuid4())
    await auth_client.post(
        "/api/v1/categorias",
        json={
            "id": cid,
            "establecimiento_id": str(establecimiento.id),
            "nombre": "Vaca",
            "updated_at": "2025-01-01T00:00:00",
        },
    )
    resp = await auth_client.put(
        f"/api/v1/categorias/{cid}",
        json={"descripcion": "Hembra adulta", "updated_at": "2025-06-01T00:00:00"},
    )
    assert resp.status_code == 200
    assert resp.json()["data"]["descripcion"] == "Hembra adulta"


@pytest.mark.anyio
async def test_no_editar_categoria_global(auth_client, session, establecimiento):
    global_cat = Categoria(nombre="Toro", establecimiento_id=None)
    session.add(global_cat)
    await session.commit()
    resp = await auth_client.put(
        f"/api/v1/categorias/{global_cat.id}",
        json={"nombre": "Toro reproductor", "updated_at": "2025-06-01T00:00:00"},
    )
    assert resp.status_code == 403
    assert resp.json()["errors"][0]["code"] == "categoria_global_no_editable"


@pytest.mark.anyio
async def test_borrar_soft_y_pull_include_deleted(auth_client, establecimiento):
    cid = str(uuid4())
    await auth_client.post(
        "/api/v1/categorias",
        json={
            "id": cid,
            "establecimiento_id": str(establecimiento.id),
            "nombre": "Recría",
        },
    )
    d = await auth_client.delete(f"/api/v1/categorias/{cid}")
    assert d.status_code == 200
    assert d.json()["data"]["deleted_at"] is not None

    normal = await auth_client.get(
        "/api/v1/categorias", params={"establecimiento_id": str(establecimiento.id)}
    )
    assert cid not in [c["id"] for c in normal.json()["data"]]

    pull = await auth_client.get(
        "/api/v1/categorias",
        params={
            "establecimiento_id": str(establecimiento.id),
            "include_deleted": "true",
        },
    )
    borrados = [c for c in pull.json()["data"] if c["id"] == cid]
    assert len(borrados) == 1 and borrados[0]["deleted_at"] is not None


@pytest.mark.anyio
async def test_no_borrar_categoria_con_animales(auth_client, session, establecimiento):
    """Borrar una categoría con animales asignados se bloquea (409)."""
    cid = uuid4()
    session.add(
        Categoria(id=cid, nombre="Engorde", establecimiento_id=establecimiento.id)
    )
    session.add(
        Animal(
            id=uuid4(),
            establecimiento_id=establecimiento.id,
            nro_caravana_rfid="123456789012345",
            sexo=SexoAnimal.macho,
            raza="Angus",
            fecha_nacimiento=date(2023, 1, 1),
            categoria_id=cid,
            estado=EstadoAnimal.activo,
        )
    )
    await session.commit()

    resp = await auth_client.delete(f"/api/v1/categorias/{cid}")
    assert resp.status_code == 409
    assert resp.json()["errors"][0]["code"] == "categoria_en_uso"
