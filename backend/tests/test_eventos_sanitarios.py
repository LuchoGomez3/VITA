"""API de Sanidad (VITA-20): catálogo, alta por grupo, resultado e historial.

Cubre los criterios de ``docs/plan-backend-integracion-sanidad.md``: rechazo
atómico con campo y animal, reenvíos idempotentes, primer resultado con
conflicto, feed incremental con cursor y aislamiento por establecimiento. Los
locks y el RLS se prueban contra Postgres en ``test_eventos_sanitarios_postgres``.
"""

from datetime import UTC, date, datetime, timedelta
from uuid import UUID, uuid4

import pytest
from sqlalchemy import func, select

from api.modules.animales.models import Animal
from api.modules.establecimientos.models import Establecimiento, UsuarioEstablecimiento
from api.modules.eventos_sanitarios import service as servicio_sanitario
from api.modules.eventos_sanitarios.models import EventoSanitario
from api.modules.productos_sanitarios.models import ProductoSanitario
from api.shared.enums import (
    EstadoAnimal,
    RolUsuario,
    SexoAnimal,
    TipoEventoSanitario,
    TipoProductoSanitario,
)
from tests.factories import crear_lote

pytestmark = pytest.mark.anyio

URL = "/api/v1/eventos_sanitarios"


def _animal(est_id: UUID, n: int, **overrides) -> Animal:
    campos = {
        "id": uuid4(),
        "establecimiento_id": est_id,
        "nro_caravana_rfid": f"98200055500{n:04d}",
        "sexo": SexoAnimal.hembra,
        "raza": "Angus",
        "fecha_nacimiento": date(2024, 1, 1),
        "estado": EstadoAnimal.activo,
    }
    campos.update(overrides)
    return Animal(**campos)


@pytest.fixture
async def campo(session, usuario_actual):
    """Campo del usuario con 3 animales, un lote y productos de cada origen."""
    propio = Establecimiento(
        owner_id=usuario_actual.id,
        nombre="La Esperanza",
        nro_renspa="14.023.0.99001/00",
    )
    ajeno = Establecimiento(
        owner_id=usuario_actual.id, nombre="Ajeno", nro_renspa="14.023.0.99002/00"
    )
    session.add_all([propio, ajeno])
    await session.flush()
    session.add(
        UsuarioEstablecimiento(
            usuario_id=usuario_actual.id,
            establecimiento_id=propio.id,
            rol=RolUsuario.employee,
            activo=True,
        )
    )
    lote = crear_lote(propio.id, "Potrero Norte")
    lote_ajeno = crear_lote(ajeno.id, "Ajeno")
    animales = [_animal(propio.id, n) for n in range(1, 4)]
    vendido = _animal(propio.id, 9, estado=EstadoAnimal.vendido)
    animal_ajeno = _animal(ajeno.id, 10)
    aftosa = ProductoSanitario(
        nombre="Aftosa bivalente",
        tipo=TipoProductoSanitario.vacuna,
        periodo_carencia_dias=0,
    )
    ivermectina = ProductoSanitario(
        establecimiento_id=propio.id,
        nombre="Ivermectina 1%",
        tipo=TipoProductoSanitario.antiparasitario,
        periodo_carencia_dias=35,
    )
    retirado = ProductoSanitario(
        nombre="Vacuna retirada",
        tipo=TipoProductoSanitario.vacuna,
        deleted_at=datetime.now(UTC),
    )
    privado_ajeno = ProductoSanitario(
        establecimiento_id=ajeno.id,
        nombre="Privada de otro campo",
        tipo=TipoProductoSanitario.vacuna,
    )
    session.add_all(
        [lote, lote_ajeno, *animales, vendido, animal_ajeno]
        + [aftosa, ivermectina, retirado, privado_ajeno]
    )
    await session.commit()
    return {
        "est": propio,
        "ajeno": ajeno,
        "lote": lote,
        "lote_ajeno": lote_ajeno,
        "animales": animales,
        "vendido": vendido,
        "animal_ajeno": animal_ajeno,
        "aftosa": aftosa,
        "ivermectina": ivermectina,
        "retirado": retirado,
        "privado_ajeno": privado_ajeno,
    }


def _integrante(animal: Animal, **overrides) -> dict:
    item = {
        "id": str(uuid4()),
        "animal_id": str(animal.id),
        "caravana": animal.nro_caravana_rfid,
        "lote_id": None,
        "referencia_muestra": None,
        "created_at": "2026-11-21T13:05:00Z",
        "updated_at": "2026-11-21T13:05:00Z",
    }
    item.update(overrides)
    return item


def _alta(campo, practica="vacunacion", animales=None, **overrides) -> dict:
    datos = {
        "vacunacion": {
            "producto_id": str(campo["aftosa"].id),
            "producto_nombre": "Nombre que manda el celular",
            "dosis": "2,5",
            "unidad": "ml",
            "via": "Subcutánea",
            "serie": "L-01",
            "vencimiento": "2027-03-01",
        },
        "sangrado": {"descripcion": "Control de rutina", "tipo_muestra": "Sangre"},
        "lesion": {"descripcion": "Corte en la pata", "tipo_muestra": None},
    }.get(practica, {})
    cuerpo = {
        "id": str(uuid4()),
        "establecimiento_id": str(campo["est"].id),
        "practica_id": practica,
        "fecha_aplicacion": "2026-11-21T13:00:00Z",
        "responsable": "Operario de prueba",
        "observaciones": None,
        "datos": datos,
        "animales": animales
        if animales is not None
        else [_integrante(a) for a in campo["animales"]],
    }
    cuerpo.update(overrides)
    return cuerpo


async def _cantidad_eventos(session) -> int:
    return await session.scalar(select(func.count()).select_from(EventoSanitario))


def _error(resp) -> dict:
    return resp.json()["errors"][0]


# ---------------------------------------------------------------------- catálogo


async def test_catalogo_ofrece_productos_vigentes_del_campo(auth_client, campo):
    resp = await auth_client.get(
        f"{URL}/catalogo", params={"establecimiento_id": str(campo["est"].id)}
    )

    assert resp.status_code == 200
    data = resp.json()["data"]
    practicas = {p["id"]: p for p in data["practicas"]}
    assert practicas["vacunacion"]["modelo"] == "aplicacion"
    assert practicas["vacunacion"]["producto_ids"] == [str(campo["aftosa"].id)]
    assert practicas["desparasitacion"]["producto_ids"] == [
        str(campo["ivermectina"].id)
    ]
    assert practicas["sangrado"] == {
        "id": "sangrado",
        "nombre": "Sangrado",
        "modelo": "muestreo",
        "producto_ids": [],
    }
    assert practicas["lesion"]["modelo"] == "lesion"
    nombres = {p["nombre"] for p in data["productos"]}
    # Ni el retirado ni el privado de otro campo.
    assert nombres == {"Aftosa bivalente", "Ivermectina 1%"}


async def test_catalogo_sin_productos_igual_lista_las_practicas(
    auth_client, campo, session
):
    for producto in (campo["aftosa"], campo["ivermectina"]):
        await session.delete(producto)
    await session.commit()

    resp = await auth_client.get(
        f"{URL}/catalogo", params={"establecimiento_id": str(campo["est"].id)}
    )

    data = resp.json()["data"]
    assert data["productos"] == []
    assert len(data["practicas"]) == 7


async def test_las_cuatro_rutas_exigen_membresia(auth_client, campo):
    ajeno = str(campo["ajeno"].id)
    catalogo = await auth_client.get(
        f"{URL}/catalogo", params={"establecimiento_id": ajeno}
    )
    historial = await auth_client.get(URL, params={"establecimiento_id": ajeno})
    alta = await auth_client.post(
        URL,
        json=_alta(
            campo,
            "lesion",
            animales=[_integrante(campo["animal_ajeno"])],
            establecimiento_id=ajeno,
        ),
    )

    for resp in (catalogo, historial, alta):
        assert resp.status_code == 403
        assert _error(resp)["code"] == "establecimiento_no_autorizado"


# -------------------------------------------------------------------------- alta


async def test_alta_de_aplicacion_crea_un_evento_canonico_por_animal(
    auth_client, campo, usuario_actual, session
):
    animales = [
        _integrante(campo["animales"][0], lote_id=str(campo["lote"].id)),
        _integrante(campo["animales"][1]),
    ]
    resp = await auth_client.post(
        URL,
        json=_alta(
            campo,
            "desparasitacion",
            animales=animales,
            datos={
                "producto_id": str(campo["ivermectina"].id),
                "producto_nombre": "x",
                "dosis": "10",
                "unidad": "ml",
                "via": "Subcutánea",
                "serie": None,
                "vencimiento": None,
            },
        ),
    )

    assert resp.status_code == 201, resp.text
    eventos = resp.json()["data"]
    assert [e["id"] for e in eventos] == [a["id"] for a in animales]
    primero = eventos[0]
    assert primero["practica"] == {
        "id": "desparasitacion",
        "nombre": "Desparasitación",
        "modelo": "aplicacion",
        "producto_ids": [str(campo["ivermectina"].id)],
    }
    assert primero["datos"] == {
        "producto_id": str(campo["ivermectina"].id),
        "producto_nombre": "Ivermectina 1%",
        "dosis": "10",
        "unidad": "ml",
        "via": "Subcutánea",
        "serie": None,
        "vencimiento": None,
    }
    assert primero["lote_id"] == str(campo["lote"].id)
    assert primero["registrado_por_id"] == str(usuario_actual.id)
    assert primero["responsable"] == "Operario de prueba"
    assert primero["deleted_at"] is None
    assert primero["resultado"] is None
    assert datetime.fromisoformat(primero["fecha_aplicacion"]) == datetime(
        2026, 11, 21, 13, tzinfo=UTC
    )

    fila = await session.get(EventoSanitario, UUID(primero["id"]))
    assert fila.tipo == TipoEventoSanitario.desparasitacion
    assert fila.periodo_carencia_dias == 35
    assert fila.fecha_fin_carencia == date(2026, 12, 26)


async def test_la_dosis_decimal_con_coma_se_normaliza(auth_client, campo):
    resp = await auth_client.post(URL, json=_alta(campo))

    assert resp.status_code == 201
    assert {e["datos"]["dosis"] for e in resp.json()["data"]} == {"2.5"}
    assert resp.json()["data"][0]["datos"]["vencimiento"] == "2027-03-01"


async def test_alta_de_muestreo_conserva_la_referencia_de_cada_animal(
    auth_client, campo
):
    animales = [
        _integrante(campo["animales"][0], referencia_muestra="M-101"),
        _integrante(campo["animales"][1]),
    ]
    resp = await auth_client.post(URL, json=_alta(campo, "sangrado", animales=animales))

    assert resp.status_code == 201, resp.text
    eventos = resp.json()["data"]
    assert [e["referencia_muestra"] for e in eventos] == ["M-101", None]
    assert eventos[0]["datos"] == {
        "descripcion": "Control de rutina",
        "tipo_muestra": "Sangre",
    }
    assert eventos[0]["practica"]["producto_ids"] == []


async def test_alta_de_lesion(auth_client, campo):
    resp = await auth_client.post(
        URL, json=_alta(campo, "lesion", animales=[_integrante(campo["animales"][0])])
    )

    assert resp.status_code == 201, resp.text
    assert resp.json()["data"][0]["datos"] == {
        "descripcion": "Corte en la pata",
        "tipo_muestra": None,
    }


@pytest.mark.parametrize(
    ("cambiar", "campo_esperado"),
    [
        (lambda c, b: b.update(practica_id="inexistente"), "practica_id"),
        (lambda c, b: b.update(responsable="  "), "responsable"),
        (
            lambda c, b: b.update(fecha_aplicacion="2099-01-01T00:00:00Z"),
            "fecha_aplicacion",
        ),
        (lambda c, b: b["datos"].update(dosis="0"), "datos.dosis"),
        (lambda c, b: b["datos"].update(dosis="abc"), "datos.dosis"),
        (lambda c, b: b["datos"].update(unidad=""), "datos.unidad"),
        (lambda c, b: b["datos"].update(via=None), "datos.via"),
        (lambda c, b: b["datos"].update(vencimiento="01/03/2027"), "datos.vencimiento"),
        (
            lambda c, b: b["datos"].update(producto_id=str(c["retirado"].id)),
            "datos.producto_id",
        ),
        (
            lambda c, b: b["datos"].update(producto_id=str(c["privado_ajeno"].id)),
            "datos.producto_id",
        ),
        (
            # Un antiparasitario no es elegible para vacunación.
            lambda c, b: b["datos"].update(producto_id=str(c["ivermectina"].id)),
            "datos.producto_id",
        ),
        (lambda c, b: b.update(animales=[]), "animales"),
    ],
)
async def test_rechazos_corregibles_indican_el_campo(
    auth_client, campo, session, cambiar, campo_esperado
):
    cuerpo = _alta(campo)
    cambiar(campo, cuerpo)

    resp = await auth_client.post(URL, json=cuerpo)

    assert resp.status_code == 422, resp.text
    assert _error(resp)["code"] == "evento_sanitario_invalido"
    assert _error(resp)["details"]["campo"] == campo_esperado
    assert await _cantidad_eventos(session) == 0


async def test_un_integrante_invalido_rechaza_todo_el_grupo(
    auth_client, campo, session
):
    animales = [
        _integrante(campo["animales"][0]),
        _integrante(campo["vendido"]),
        _integrante(campo["animales"][1]),
    ]
    resp = await auth_client.post(URL, json=_alta(campo, animales=animales))

    assert resp.status_code == 422
    error = _error(resp)
    assert error["code"] == "animal_no_disponible"
    assert error["details"] == {
        "campo": "animales.1.animal_id",
        "animal_id": str(campo["vendido"].id),
    }
    assert await _cantidad_eventos(session) == 0


@pytest.mark.parametrize(
    ("integrante", "campo_esperado"),
    [
        (lambda c: _integrante(c["animal_ajeno"]), "animales.1.animal_id"),
        (
            lambda c: _integrante(c["animales"][1], lote_id=str(c["lote_ajeno"].id)),
            "animales.1.lote_id",
        ),
        (
            lambda c: _integrante(c["animales"][1], referencia_muestra="M-1"),
            "animales.1.referencia_muestra",
        ),
        (lambda c: _integrante(c["animales"][0]), "animales.1.animal_id"),
    ],
)
async def test_rechazo_por_integrante_indica_animal(
    auth_client, campo, session, integrante, campo_esperado
):
    animales = [_integrante(campo["animales"][0]), integrante(campo)]
    resp = await auth_client.post(URL, json=_alta(campo, animales=animales))

    assert resp.status_code == 422, resp.text
    assert _error(resp)["details"]["campo"] == campo_esperado
    assert _error(resp)["details"]["animal_id"] == animales[1]["animal_id"]
    assert await _cantidad_eventos(session) == 0


async def test_reenvio_identico_devuelve_los_mismos_eventos_sin_duplicar(
    auth_client, campo, session
):
    cuerpo = _alta(campo)
    primera = await auth_client.post(URL, json=cuerpo)
    segunda = await auth_client.post(URL, json=cuerpo)

    assert primera.status_code == segunda.status_code == 201
    assert primera.json()["data"] == segunda.json()["data"]
    assert await _cantidad_eventos(session) == 3


async def test_reenvio_de_operacion_aceptada_no_revalida_datos_que_cambiaron(
    auth_client, campo, session
):
    cuerpo = _alta(campo)
    await auth_client.post(URL, json=cuerpo)
    # El producto se retira y el animal se vende después de aceptar la carga.
    campo["aftosa"].deleted_at = datetime.now(UTC)
    campo["animales"][0].estado = EstadoAnimal.vendido
    session.add_all([campo["aftosa"], campo["animales"][0]])
    await session.commit()

    resp = await auth_client.post(URL, json=cuerpo)

    assert resp.status_code == 201
    assert len(resp.json()["data"]) == 3


async def test_mismo_uuid_de_operacion_con_otro_cuerpo_es_conflicto(
    auth_client, campo, session
):
    cuerpo = _alta(campo)
    await auth_client.post(URL, json=cuerpo)
    cuerpo["responsable"] = "Otro operario"

    resp = await auth_client.post(URL, json=cuerpo)

    assert resp.status_code == 409
    assert _error(resp)["code"] == "operacion_sanitaria_conflicto"
    assert await _cantidad_eventos(session) == 3


async def test_uuid_de_evento_ya_aceptado_en_otra_operacion_es_conflicto(
    auth_client, campo
):
    primera = _alta(campo, animales=[_integrante(campo["animales"][0])])
    await auth_client.post(URL, json=primera)
    otra = _alta(campo, animales=[dict(primera["animales"][0])])

    resp = await auth_client.post(URL, json=otra)

    assert resp.status_code == 409
    assert _error(resp)["code"] == "evento_sanitario_existente"
    assert _error(resp)["details"]["campo"] == "animales.0.id"


async def test_correccion_con_uuid_nuevo_conserva_los_uuid_de_eventos(
    auth_client, campo, session
):
    retenido = _integrante(campo["animales"][0])
    rechazada = _alta(campo, animales=[retenido, _integrante(campo["vendido"])])
    assert (await auth_client.post(URL, json=rechazada)).status_code == 422

    corregida = _alta(campo, animales=[retenido])
    resp = await auth_client.post(URL, json=corregida)

    assert resp.status_code == 201
    assert resp.json()["data"][0]["id"] == retenido["id"]


async def test_updated_at_nunca_queda_detras_del_reloj_del_celular(auth_client, campo):
    adelantado = (datetime.now(UTC) + timedelta(hours=2)).isoformat()
    animales = [_integrante(campo["animales"][0], updated_at=adelantado)]

    resp = await auth_client.post(URL, json=_alta(campo, "lesion", animales=animales))

    assert datetime.fromisoformat(
        resp.json()["data"][0]["updated_at"]
    ) == datetime.fromisoformat(adelantado)


# --------------------------------------------------------------------- resultado


async def _muestreo(auth_client, campo) -> dict:
    resp = await auth_client.post(
        URL,
        json=_alta(campo, "sangrado", animales=[_integrante(campo["animales"][0])]),
    )
    return resp.json()["data"][0]


def _resultado(**overrides) -> dict:
    cuerpo = {
        "id": str(uuid4()),
        "resultado": "Negativo",
        "fecha": "2026-11-21T15:00:00Z",
    }
    cuerpo.update(overrides)
    return cuerpo


async def test_primer_resultado_queda_en_el_evento(auth_client, campo, usuario_actual):
    evento = await _muestreo(auth_client, campo)

    resp = await auth_client.put(f"{URL}/{evento['id']}/resultado", json=_resultado())

    assert resp.status_code == 200, resp.text
    data = resp.json()["data"]
    assert data["resultado"] == {
        "valor": "Negativo",
        "fecha": "2026-11-21T15:00:00+00:00",
        "registrado_por_id": str(usuario_actual.id),
    }
    assert data["updated_at"] > evento["updated_at"]


async def test_reenvio_del_mismo_resultado_es_exitoso(auth_client, campo):
    evento = await _muestreo(auth_client, campo)
    cuerpo = _resultado()
    await auth_client.put(f"{URL}/{evento['id']}/resultado", json=cuerpo)

    resp = await auth_client.put(f"{URL}/{evento['id']}/resultado", json=cuerpo)

    assert resp.status_code == 200
    assert resp.json()["data"]["resultado"]["valor"] == "Negativo"


async def test_otro_resultado_recibe_conflicto_con_el_evento_vigente(
    auth_client, campo
):
    evento = await _muestreo(auth_client, campo)
    await auth_client.put(f"{URL}/{evento['id']}/resultado", json=_resultado())

    resp = await auth_client.put(
        f"{URL}/{evento['id']}/resultado", json=_resultado(resultado="Positivo")
    )

    assert resp.status_code == 409
    error = _error(resp)
    assert error["code"] == "resultado_ya_completado"
    assert error["details"]["evento"]["id"] == evento["id"]
    assert error["details"]["evento"]["resultado"]["valor"] == "Negativo"


async def test_resultado_de_una_aplicacion_se_rechaza(auth_client, campo):
    evento = (await auth_client.post(URL, json=_alta(campo))).json()["data"][0]

    resp = await auth_client.put(f"{URL}/{evento['id']}/resultado", json=_resultado())

    assert resp.status_code == 422
    assert _error(resp)["details"]["campo"] == "resultado"


@pytest.mark.parametrize(
    ("cuerpo", "campo_esperado"),
    [
        (_resultado(resultado=" "), "resultado"),
        (_resultado(fecha="2026-11-20T10:00:00Z"), "fecha"),
        (_resultado(fecha="2099-01-01T00:00:00Z"), "fecha"),
    ],
)
async def test_resultado_invalido_indica_el_campo(
    auth_client, campo, cuerpo, campo_esperado
):
    evento = await _muestreo(auth_client, campo)

    resp = await auth_client.put(f"{URL}/{evento['id']}/resultado", json=cuerpo)

    assert resp.status_code == 422
    assert _error(resp)["details"]["campo"] == campo_esperado


async def test_resultado_de_estudio_inexistente_o_ajeno_es_404(
    auth_client, campo, session
):
    ajeno = EventoSanitario(
        establecimiento_id=campo["ajeno"].id,
        animal_id=campo["animal_ajeno"].id,
        tipo=TipoEventoSanitario.analisis,
        fecha_aplicacion=datetime(2026, 11, 1, tzinfo=UTC),
        practica_id="sangrado",
        practica_nombre="Sangrado",
        practica_modelo="muestreo",
        datos={"descripcion": "x", "tipo_muestra": "Sangre"},
        version=1,
    )
    session.add(ajeno)
    await session.commit()

    for evento_id in (uuid4(), ajeno.id):
        resp = await auth_client.put(f"{URL}/{evento_id}/resultado", json=_resultado())
        assert resp.status_code == 404
        assert _error(resp)["code"] == "evento_sanitario_no_encontrado"


# --------------------------------------------------------------------- historial


async def _pagina(auth_client, campo, cursor=None):
    params = {"establecimiento_id": str(campo["est"].id)}
    if cursor is not None:
        params["cursor"] = cursor
    resp = await auth_client.get(URL, params=params)
    assert resp.status_code == 200, resp.text
    return resp.json()


async def test_historial_pagina_con_cursor_hasta_el_final(
    auth_client, campo, monkeypatch
):
    monkeypatch.setattr(servicio_sanitario, "TAMANIO_PAGINA_HISTORIAL", 2)
    await auth_client.post(URL, json=_alta(campo))

    primera = await _pagina(auth_client, campo)
    segunda = await _pagina(auth_client, campo, primera["meta"]["next_cursor"])
    ultima = await _pagina(auth_client, campo, segunda["meta"]["next_cursor"])

    assert len(primera["data"]) == 2 and primera["meta"]["has_more"] is True
    assert len(segunda["data"]) == 1 and segunda["meta"]["has_more"] is False
    assert ultima["data"] == []
    # La última página también devuelve un cursor que se puede reusar.
    assert ultima["meta"] == {
        "next_cursor": segunda["meta"]["next_cursor"],
        "has_more": False,
    }


async def test_un_resultado_vuelve_a_aparecer_despues_del_cursor(auth_client, campo):
    evento = await _muestreo(auth_client, campo)
    cursor = (await _pagina(auth_client, campo))["meta"]["next_cursor"]

    await auth_client.put(f"{URL}/{evento['id']}/resultado", json=_resultado())
    cambios = await _pagina(auth_client, campo, cursor)

    assert [e["id"] for e in cambios["data"]] == [evento["id"]]
    assert cambios["data"][0]["resultado"]["valor"] == "Negativo"
    assert int(cambios["meta"]["next_cursor"]) > int(cursor)


async def test_historial_propaga_bajas_y_omite_filas_previas_a_vita_20(
    auth_client, campo, session
):
    evento = await _muestreo(auth_client, campo)
    legado = EventoSanitario(
        establecimiento_id=campo["est"].id,
        animal_id=campo["animales"][2].id,
        tipo=TipoEventoSanitario.vacunacion,
        fecha_aplicacion=datetime(2026, 1, 1, tzinfo=UTC),
        resultado="texto viejo",
    )
    fila = await session.get(EventoSanitario, UUID(evento["id"]))
    fila.deleted_at = datetime.now(UTC)
    fila.version = 99
    session.add_all([legado, fila])
    await session.commit()

    data = (await _pagina(auth_client, campo))["data"]

    assert [e["id"] for e in data] == [evento["id"]]
    assert data[0]["deleted_at"] is not None


async def test_cursor_invalido(auth_client, campo):
    resp = await auth_client.get(
        URL, params={"establecimiento_id": str(campo["est"].id), "cursor": "abc"}
    )

    assert resp.status_code == 422
    assert _error(resp)["details"]["campo"] == "cursor"
