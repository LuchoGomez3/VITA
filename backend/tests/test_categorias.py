"""Tests del catálogo global de categorías (adr-0010).

El catálogo es igual para todos los establecimientos y la API solo lo lee: así
lo descarga mobile en la sincronización inicial (``GET /api/v1/categorias``, sin
establecimiento).
"""

from datetime import UTC, datetime, timedelta
from uuid import uuid4

import pytest

from api.modules.categorias.models import Categoria
from api.shared.enums import SexoPermitido

_URL = "/api/v1/categorias"


@pytest.fixture
async def catalogo(session):
    """Tres categorías vivas y una dada de baja."""
    ahora = datetime.now(UTC)
    categorias = {
        "vaca": Categoria(
            nombre="Vaca",
            sexo_permitido=SexoPermitido.hembra,
            permite_estado_reproductivo=True,
            updated_at=ahora - timedelta(days=10),
        ),
        "toro": Categoria(
            nombre="Toro",
            sexo_permitido=SexoPermitido.macho,
            updated_at=ahora - timedelta(days=10),
        ),
        "novillo": Categoria(
            nombre="Novillo",
            descripcion="Macho castrado",
            sexo_permitido=SexoPermitido.macho,
            updated_at=ahora,
        ),
        "retirada": Categoria(
            nombre="Engorde",
            sexo_permitido=SexoPermitido.ambos,
            updated_at=ahora,
            deleted_at=ahora,
        ),
    }
    session.add_all(categorias.values())
    await session.commit()
    return categorias


@pytest.mark.anyio
async def test_lista_el_catalogo_sin_pedir_establecimiento(auth_client, catalogo):
    resp = await auth_client.get(_URL)

    assert resp.status_code == 200
    body = resp.json()
    assert body["success"] is True
    # Ordenado por nombre y sin las bajas.
    assert [c["nombre"] for c in body["data"]] == ["Novillo", "Toro", "Vaca"]


@pytest.mark.anyio
async def test_cada_categoria_trae_los_campos_del_contrato(auth_client, catalogo):
    resp = await auth_client.get(_URL)

    novillo = next(c for c in resp.json()["data"] if c["nombre"] == "Novillo")
    assert novillo["id"] == str(catalogo["novillo"].id)
    assert novillo["descripcion"] == "Macho castrado"
    assert novillo["deleted_at"] is None
    assert {"created_at", "updated_at"} <= novillo.keys()
    # Ya no pertenece a ningún establecimiento.
    assert "establecimiento_id" not in novillo


@pytest.mark.anyio
async def test_include_deleted_devuelve_las_bajas(auth_client, catalogo):
    resp = await auth_client.get(_URL, params={"include_deleted": "true"})

    por_nombre = {c["nombre"]: c for c in resp.json()["data"]}
    assert set(por_nombre) == {"Engorde", "Novillo", "Toro", "Vaca"}
    assert por_nombre["Engorde"]["deleted_at"] is not None


@pytest.mark.anyio
async def test_updated_since_devuelve_solo_lo_modificado(auth_client, catalogo):
    desde = (datetime.now(UTC) - timedelta(days=1)).isoformat()

    resp = await auth_client.get(
        _URL, params={"updated_since": desde, "include_deleted": "true"}
    )

    assert {c["nombre"] for c in resp.json()["data"]} == {"Novillo", "Engorde"}


@pytest.mark.anyio
async def test_un_establecimiento_en_la_consulta_no_filtra_nada(auth_client, catalogo):
    """Un cliente viejo que todavía manda ``establecimiento_id`` recibe el mismo
    catálogo completo: el parámetro ya no existe y se ignora."""
    resp = await auth_client.get(_URL, params={"establecimiento_id": str(uuid4())})

    assert resp.status_code == 200
    assert [c["nombre"] for c in resp.json()["data"]] == ["Novillo", "Toro", "Vaca"]


@pytest.mark.anyio
async def test_exige_autenticacion(client, catalogo):
    resp = await client.get(_URL)

    assert resp.status_code == 401


@pytest.mark.anyio
@pytest.mark.parametrize(
    ("metodo", "ruta"),
    [
        ("POST", _URL),
        ("PUT", f"{_URL}/{uuid4()}"),
        ("DELETE", f"{_URL}/{uuid4()}"),
    ],
)
async def test_la_api_no_modifica_el_catalogo(auth_client, catalogo, metodo, ruta):
    """El catálogo se administra desde la base: no hay alta, edición ni baja."""
    resp = await auth_client.request(
        metodo, ruta, json={"nombre": "Nueva", "sexo_permitido": "ambos"}
    )

    # 405 en la colección (solo admite GET); 404 en /{id}, que ya no existe.
    assert resp.status_code in (404, 405)
