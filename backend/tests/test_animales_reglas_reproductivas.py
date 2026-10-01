"""Reglas de sexo, categoría y condición reproductiva del animal (VITA-173).

Cubren las tres vías de escritura —alta, edición y reenvío de sincronización—
y el cambio de reglas de una categoría ya usada. La contraparte en la base (los
triggers) se prueba en ``test_reglas_reproductivas_postgres``.
"""

from datetime import UTC, datetime
from types import SimpleNamespace
from uuid import uuid4

import pytest

from api.modules.animales.exceptions import (
    CategoriaIncompatibleConSexoError,
    EstadoReproductivoInvalidoError,
)
from api.modules.animales.reglas_reproductivas import validar_combinacion
from api.modules.categorias.models import Categoria
from api.modules.establecimientos.models import (
    Establecimiento,
    UsuarioEstablecimiento,
)
from api.shared.enums import (
    EstadoReproductivo,
    RolUsuario,
    SexoAnimal,
    SexoPermitido,
)

_CARAVANAS = iter(f"{n:015d}" for n in range(100000000000001, 100000000001000))


@pytest.fixture
async def campo(session, usuario_actual):
    """Establecimiento con categorías de cada tipo y una ajena."""
    est = Establecimiento(
        owner_id=usuario_actual.id, nombre="Estancia Test", nro_renspa="01.002.3.04567"
    )
    otro = Establecimiento(owner_id=usuario_actual.id, nombre="Ajeno")
    session.add_all([est, otro])
    await session.flush()
    session.add(
        UsuarioEstablecimiento(
            usuario_id=usuario_actual.id,
            establecimiento_id=est.id,
            rol=RolUsuario.employee,
            activo=True,
        )
    )

    def categoria(nombre, sexo, permite=False, establecimiento_id=est.id, **extra):
        cat = Categoria(
            nombre=nombre,
            establecimiento_id=establecimiento_id,
            sexo_permitido=sexo,
            permite_estado_reproductivo=permite,
            **extra,
        )
        session.add(cat)
        return cat

    cats = SimpleNamespace(
        vaca=categoria("Vaca", SexoPermitido.hembra, True),
        ternero=categoria("Ternero", SexoPermitido.ambos),
        toro=categoria("Toro", SexoPermitido.macho),
        # Global y compartida entre establecimientos.
        vaquillona=categoria(
            "Vaquillona", SexoPermitido.hembra, True, establecimiento_id=None
        ),
        borrada=categoria(
            "Borrada", SexoPermitido.hembra, True, deleted_at=datetime.now(UTC)
        ),
        ajena=categoria(
            "Ajena", SexoPermitido.hembra, True, establecimiento_id=otro.id
        ),
    )
    await session.commit()
    return SimpleNamespace(id=est.id, cat=cats)


def _alta(campo, *, sexo="hembra", categoria=None, **extra):
    payload = {
        "nro_caravana_rfid": next(_CARAVANAS),
        "sexo": sexo,
        "raza": "Angus",
        "fecha_nacimiento": "2022-03-10",
        "establecimiento_id": str(campo.id),
        "peso_inicial": "380",
        "categoria_id": str(categoria.id) if categoria is not None else None,
    }
    payload.update(extra)
    return payload


async def _crear(client, campo, **kwargs):
    resp = await client.post("/api/v1/animales", json=_alta(campo, **kwargs))
    assert resp.status_code == 201, resp.json()
    return resp.json()["data"]


async def _detalle(client, animal_id):
    resp = await client.get(f"/api/v1/animales/{animal_id}")
    assert resp.status_code == 200
    return resp.json()["data"]


def _codigo(resp) -> str:
    return resp.json()["errors"][0]["code"]


# ------------------------------------------------------------ regla pura


@pytest.mark.parametrize(
    ("sexo", "permitido", "permite", "estado"),
    [
        (SexoAnimal.hembra, SexoPermitido.hembra, True, EstadoReproductivo.prenada),
        (SexoAnimal.hembra, SexoPermitido.ambos, True, EstadoReproductivo.vacia),
        (
            SexoAnimal.hembra,
            SexoPermitido.ambos,
            False,
            EstadoReproductivo.sin_determinar,
        ),
        (SexoAnimal.macho, SexoPermitido.ambos, True, None),
        (SexoAnimal.macho, SexoPermitido.macho, False, None),
    ],
)
def test_combinaciones_validas(sexo, permitido, permite, estado):
    categoria = Categoria(
        nombre="X", sexo_permitido=permitido, permite_estado_reproductivo=permite
    )
    validar_combinacion(sexo, categoria, estado)


def test_sin_categoria_solo_admite_sin_determinar():
    validar_combinacion(SexoAnimal.hembra, None, EstadoReproductivo.sin_determinar)
    validar_combinacion(SexoAnimal.hembra, None, None)
    with pytest.raises(EstadoReproductivoInvalidoError):
        validar_combinacion(SexoAnimal.hembra, None, EstadoReproductivo.prenada)


@pytest.mark.parametrize("estado", list(EstadoReproductivo))
def test_un_macho_nunca_tiene_condicion_reproductiva(estado):
    categoria = Categoria(
        nombre="X",
        sexo_permitido=SexoPermitido.ambos,
        permite_estado_reproductivo=True,
    )
    with pytest.raises(EstadoReproductivoInvalidoError):
        validar_combinacion(SexoAnimal.macho, categoria, estado)


def test_categoria_de_otro_sexo_se_rechaza_aunque_no_haya_condicion():
    categoria = Categoria(nombre="Vaca", sexo_permitido=SexoPermitido.hembra)
    with pytest.raises(CategoriaIncompatibleConSexoError):
        validar_combinacion(SexoAnimal.macho, categoria, None)


# ------------------------------------------------------------------- alta


@pytest.mark.anyio
async def test_alta_de_macho_prenado_se_rechaza(auth_client, campo):
    payload = _alta(
        campo, sexo="macho", categoria=campo.cat.ternero, estado_reproductivo="prenada"
    )
    resp = await auth_client.post("/api/v1/animales", json=payload)

    assert resp.status_code == 422
    assert _codigo(resp) == "estado_reproductivo_invalido"
    listado = await auth_client.get(
        "/api/v1/animales", params={"establecimiento_id": str(campo.id)}
    )
    assert listado.json()["data"] == []


@pytest.mark.anyio
async def test_alta_de_hembra_prenada_en_categoria_habilitada(auth_client, campo):
    data = await _crear(
        auth_client, campo, categoria=campo.cat.vaca, estado_reproductivo="prenada"
    )
    assert data["estado"] == "activo"
    assert data["estado_reproductivo"] == "prenada"


@pytest.mark.anyio
async def test_alta_sin_condicion_queda_en_null(auth_client, campo):
    data = await _crear(auth_client, campo, categoria=campo.cat.vaca)
    assert data["estado_reproductivo"] is None


@pytest.mark.anyio
async def test_alta_sin_categoria_admite_solo_sin_determinar(auth_client, campo):
    data = await _crear(auth_client, campo, estado_reproductivo="sin_determinar")
    assert data["estado_reproductivo"] == "sin_determinar"

    resp = await auth_client.post(
        "/api/v1/animales", json=_alta(campo, estado_reproductivo="vacia")
    )
    assert resp.status_code == 422
    assert _codigo(resp) == "estado_reproductivo_invalido"


@pytest.mark.anyio
async def test_alta_en_categoria_no_habilitada_rechaza_vacia(auth_client, campo):
    resp = await auth_client.post(
        "/api/v1/animales",
        json=_alta(campo, categoria=campo.cat.ternero, estado_reproductivo="vacia"),
    )
    assert resp.status_code == 422
    assert _codigo(resp) == "estado_reproductivo_invalido"


@pytest.mark.anyio
@pytest.mark.parametrize(("sexo", "categoria"), [("macho", "vaca"), ("hembra", "toro")])
async def test_alta_con_categoria_de_otro_sexo_se_rechaza(
    auth_client, campo, sexo, categoria
):
    resp = await auth_client.post(
        "/api/v1/animales",
        json=_alta(campo, sexo=sexo, categoria=getattr(campo.cat, categoria)),
    )
    assert resp.status_code == 422
    assert _codigo(resp) == "categoria_incompatible_con_sexo"
    assert (
        resp.json()["errors"][0]["message"]
        == "La categoría seleccionada no es compatible con el sexo del animal"
    )


@pytest.mark.anyio
@pytest.mark.parametrize("sexo", ["macho", "hembra"])
async def test_categoria_ambos_admite_los_dos_sexos(auth_client, campo, sexo):
    data = await _crear(auth_client, campo, sexo=sexo, categoria=campo.cat.ternero)
    assert data["categoria_id"] == str(campo.cat.ternero.id)


@pytest.mark.anyio
@pytest.mark.parametrize("categoria", ["borrada", "ajena"])
async def test_alta_rechaza_categoria_borrada_o_ajena(auth_client, campo, categoria):
    resp = await auth_client.post(
        "/api/v1/animales",
        json=_alta(campo, categoria=getattr(campo.cat, categoria)),
    )
    assert resp.status_code == 422
    assert _codigo(resp) == "referencia_invalida"


@pytest.mark.anyio
async def test_categoria_global_compartida_es_asignable(auth_client, campo):
    data = await _crear(
        auth_client, campo, categoria=campo.cat.vaquillona, estado_reproductivo="vacia"
    )
    assert data["estado_reproductivo"] == "vacia"


# ---------------------------------------------------------------- edición


@pytest.mark.anyio
async def test_hembra_habilitada_actualiza_su_condicion(auth_client, campo):
    animal = await _crear(auth_client, campo, categoria=campo.cat.vaca)

    resp = await auth_client.put(
        f"/api/v1/animales/{animal['id']}", json={"estado_reproductivo": "prenada"}
    )

    assert resp.status_code == 200
    assert (await _detalle(auth_client, animal["id"]))["estado_reproductivo"] == (
        "prenada"
    )


@pytest.mark.anyio
async def test_cambio_a_categoria_compatible_se_guarda(auth_client, campo):
    animal = await _crear(auth_client, campo, categoria=campo.cat.vaca)

    resp = await auth_client.put(
        f"/api/v1/animales/{animal['id']}",
        json={"categoria_id": str(campo.cat.ternero.id)},
    )

    assert resp.status_code == 200
    assert (await _detalle(auth_client, animal["id"]))["categoria_id"] == str(
        campo.cat.ternero.id
    )


@pytest.mark.anyio
async def test_cambio_a_categoria_incompatible_no_deja_cambios_parciales(
    auth_client, campo
):
    animal = await _crear(
        auth_client, campo, categoria=campo.cat.vaca, estado_reproductivo="vacia"
    )

    resp = await auth_client.put(
        f"/api/v1/animales/{animal['id']}",
        json={
            "categoria_id": str(campo.cat.toro.id),
            "raza": "Hereford",
            "estado_reproductivo": "prenada",
        },
    )

    assert resp.status_code == 422
    assert _codigo(resp) == "categoria_incompatible_con_sexo"
    despues = await _detalle(auth_client, animal["id"])
    assert despues["categoria_id"] == str(campo.cat.vaca.id)
    assert despues["raza"] == "Angus"
    assert despues["estado_reproductivo"] == "vacia"
    # SQLite devuelve el timestamp sin zona; lo que importa es que no se movió.
    assert despues["updated_at"].rstrip("Z") == animal["updated_at"].rstrip("Z")


@pytest.mark.anyio
async def test_cambio_de_categoria_y_condicion_valida_la_combinacion_final(
    auth_client, campo
):
    animal = await _crear(
        auth_client, campo, categoria=campo.cat.vaca, estado_reproductivo="prenada"
    )
    ruta = f"/api/v1/animales/{animal['id']}"

    # Ternero no admite condición: con "prenada" heredada, la combinación final
    # es inválida y no se autocorrige.
    rechazo = await auth_client.put(
        ruta, json={"categoria_id": str(campo.cat.ternero.id)}
    )
    assert rechazo.status_code == 422
    assert _codigo(rechazo) == "estado_reproductivo_invalido"

    # En la misma solicitud, limpiando la condición, la combinación es válida.
    ok = await auth_client.put(
        ruta,
        json={"categoria_id": str(campo.cat.ternero.id), "estado_reproductivo": None},
    )
    assert ok.status_code == 200
    assert ok.json()["data"]["estado_reproductivo"] is None


@pytest.mark.anyio
async def test_omitir_la_condicion_no_la_borra(auth_client, campo):
    animal = await _crear(
        auth_client, campo, categoria=campo.cat.vaca, estado_reproductivo="prenada"
    )
    resp = await auth_client.put(
        f"/api/v1/animales/{animal['id']}", json={"raza": "Brangus"}
    )
    assert resp.json()["data"]["estado_reproductivo"] == "prenada"


@pytest.mark.anyio
async def test_macho_no_puede_quedar_prenado_por_edicion(auth_client, campo):
    animal = await _crear(auth_client, campo, sexo="macho", categoria=campo.cat.toro)
    resp = await auth_client.put(
        f"/api/v1/animales/{animal['id']}", json={"estado_reproductivo": "prenada"}
    )
    assert resp.status_code == 422
    assert (await _detalle(auth_client, animal["id"]))["estado_reproductivo"] is None


@pytest.mark.anyio
@pytest.mark.parametrize("categoria", ["borrada", "ajena"])
async def test_edicion_rechaza_categoria_borrada_o_ajena(auth_client, campo, categoria):
    animal = await _crear(auth_client, campo, categoria=campo.cat.vaca)
    resp = await auth_client.put(
        f"/api/v1/animales/{animal['id']}",
        json={"categoria_id": str(getattr(campo.cat, categoria).id)},
    )
    assert resp.status_code == 422
    assert _codigo(resp) == "referencia_invalida"


@pytest.mark.anyio
async def test_edicion_rancia_no_valida_ni_aplica(auth_client, campo):
    """Un cambio más viejo que el persistido pierde por LWW antes de validarse."""
    animal = await _crear(
        auth_client, campo, categoria=campo.cat.vaca, updated_at="2026-06-01T00:00:00Z"
    )
    resp = await auth_client.put(
        f"/api/v1/animales/{animal['id']}",
        json={
            "categoria_id": str(campo.cat.toro.id),
            "updated_at": "2026-01-01T00:00:00Z",
        },
    )
    assert resp.status_code == 200
    assert resp.json()["data"]["categoria_id"] == str(campo.cat.vaca.id)


# ------------------------------------------------------ reenvío de un alta


@pytest.mark.anyio
async def test_reenvio_del_alta_no_elude_la_validacion(auth_client, campo):
    payload = _alta(
        campo,
        categoria=campo.cat.vaca,
        estado_reproductivo="prenada",
        id=str(uuid4()),
        updated_at="2026-06-01T00:00:00Z",
    )
    assert (await auth_client.post("/api/v1/animales", json=payload)).status_code == 201

    # El reenvío más nuevo cambia el sexo: Vaca y "prenada" dejan de ser válidas.
    reenvio = {**payload, "sexo": "macho", "updated_at": "2026-07-01T00:00:00Z"}
    resp = await auth_client.post("/api/v1/animales", json=reenvio)

    assert resp.status_code == 422
    despues = await _detalle(auth_client, payload["id"])
    assert despues["sexo"] == "hembra"
    assert despues["estado_reproductivo"] == "prenada"


@pytest.mark.anyio
async def test_reenvio_de_cliente_viejo_conserva_la_condicion(auth_client, campo):
    payload = _alta(
        campo,
        categoria=campo.cat.vaca,
        estado_reproductivo="prenada",
        id=str(uuid4()),
        updated_at="2026-06-01T00:00:00Z",
    )
    await auth_client.post("/api/v1/animales", json=payload)

    # Un cliente anterior al campo no lo envía: no debe borrarlo.
    reenvio = {k: v for k, v in payload.items() if k != "estado_reproductivo"}
    reenvio.update(raza="Hereford", updated_at="2026-07-01T00:00:00Z")
    resp = await auth_client.post("/api/v1/animales", json=reenvio)

    assert resp.status_code == 201
    assert resp.json()["data"]["raza"] == "Hereford"
    assert resp.json()["data"]["estado_reproductivo"] == "prenada"


# ------------------------------------------- reglas de la categoría en uso


@pytest.mark.anyio
async def test_catalogo_expone_las_reglas(auth_client, campo):
    resp = await auth_client.get(
        "/api/v1/categorias", params={"establecimiento_id": str(campo.id)}
    )
    por_nombre = {c["nombre"]: c for c in resp.json()["data"]}
    assert por_nombre["Vaca"]["sexo_permitido"] == "hembra"
    assert por_nombre["Vaca"]["permite_estado_reproductivo"] is True
    assert por_nombre["Ternero"]["sexo_permitido"] == "ambos"
    assert por_nombre["Vaquillona"]["establecimiento_id"] is None


@pytest.mark.anyio
async def test_alta_de_categoria_exige_sexo_permitido(auth_client, campo):
    resp = await auth_client.post(
        "/api/v1/categorias",
        json={"establecimiento_id": str(campo.id), "nombre": "Recría"},
    )
    assert resp.status_code == 422
    assert _codigo(resp) == "sexo_permitido_obligatorio"


@pytest.mark.anyio
async def test_reenvio_de_categoria_sin_reglas_conserva_las_guardadas(
    auth_client, campo
):
    cid = str(uuid4())
    base = {"id": cid, "establecimiento_id": str(campo.id), "nombre": "Recría"}
    await auth_client.post(
        "/api/v1/categorias",
        json={
            **base,
            "sexo_permitido": "hembra",
            "permite_estado_reproductivo": True,
            "updated_at": "2026-06-01T00:00:00Z",
        },
    )

    resp = await auth_client.post(
        "/api/v1/categorias",
        json={**base, "descripcion": "Reenvío", "updated_at": "2026-07-01T00:00:00Z"},
    )

    assert resp.status_code == 201
    data = resp.json()["data"]
    assert data["descripcion"] == "Reenvío"
    assert data["sexo_permitido"] == "hembra"
    assert data["permite_estado_reproductivo"] is True


@pytest.mark.anyio
async def test_no_se_puede_restringir_el_sexo_de_una_categoria_usada(
    auth_client, campo
):
    await _crear(auth_client, campo, sexo="hembra", categoria=campo.cat.ternero)

    resp = await auth_client.put(
        f"/api/v1/categorias/{campo.cat.ternero.id}",
        json={"sexo_permitido": "macho"},
    )

    assert resp.status_code == 409
    assert _codigo(resp) == "reglas_categoria_en_uso"
    assert resp.json()["errors"][0]["details"] == {"animales_incompatibles": 1}
    listado = await auth_client.get(
        "/api/v1/categorias", params={"establecimiento_id": str(campo.id)}
    )
    ternero = next(c for c in listado.json()["data"] if c["nombre"] == "Ternero")
    assert ternero["sexo_permitido"] == "ambos"


@pytest.mark.anyio
async def test_no_se_puede_deshabilitar_una_categoria_con_prenadas(auth_client, campo):
    await _crear(
        auth_client, campo, categoria=campo.cat.vaca, estado_reproductivo="prenada"
    )
    resp = await auth_client.put(
        f"/api/v1/categorias/{campo.cat.vaca.id}",
        json={"permite_estado_reproductivo": False},
    )
    assert resp.status_code == 409
    assert _codigo(resp) == "reglas_categoria_en_uso"


@pytest.mark.anyio
async def test_cambio_de_reglas_compatible_con_los_animales_se_guarda(
    auth_client, campo
):
    await _crear(auth_client, campo, categoria=campo.cat.vaca)
    # Sin condición registrada, deshabilitarla no invalida a nadie; ampliar el
    # sexo a "ambos" tampoco.
    resp = await auth_client.put(
        f"/api/v1/categorias/{campo.cat.vaca.id}",
        json={"sexo_permitido": "ambos", "permite_estado_reproductivo": False},
    )
    assert resp.status_code == 200
    assert resp.json()["data"]["sexo_permitido"] == "ambos"
    assert resp.json()["data"]["permite_estado_reproductivo"] is False


@pytest.mark.anyio
async def test_los_animales_borrados_no_bloquean_el_cambio_de_reglas(
    auth_client, campo
):
    animal = await _crear(
        auth_client, campo, sexo="hembra", categoria=campo.cat.ternero
    )
    await auth_client.delete(f"/api/v1/animales/{animal['id']}")

    resp = await auth_client.put(
        f"/api/v1/categorias/{campo.cat.ternero.id}",
        json={"sexo_permitido": "macho"},
    )
    assert resp.status_code == 200
