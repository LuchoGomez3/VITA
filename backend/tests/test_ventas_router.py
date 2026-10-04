"""Aceptación HTTP del registro offline e idempotente de ventas."""

from datetime import datetime
from uuid import UUID, uuid4

import pytest
from sqlalchemy import func, select, update

from api.modules.animales.models import Animal
from api.modules.establecimientos.models import (
    Establecimiento,
    UsuarioEstablecimiento,
)
from api.modules.ventas.models import Venta, VentaCobro, VentaDetalle
from api.modules.ventas.schemas import ZONA_HORARIA_NEGOCIO
from api.shared.enums import EstadoAnimal, RolUsuario, SexoAnimal

BASE = "/api/v1/ventas"


@pytest.fixture
async def escenario_http(session, usuario_actual):
    establecimiento = Establecimiento(
        owner_id=usuario_actual.id,
        nombre="Campo HTTP",
        nro_renspa="11.222.3.44444/00",
    )
    session.add(establecimiento)
    await session.flush()
    session.add(
        UsuarioEstablecimiento(
            usuario_id=usuario_actual.id,
            establecimiento_id=establecimiento.id,
            rol=RolUsuario.owner,
            activo=True,
        )
    )
    animales = [
        Animal(
            establecimiento_id=establecimiento.id,
            nro_caravana_rfid=f"98200000000200{indice}",
            sexo=SexoAnimal.hembra,
        )
        for indice in range(2)
    ]
    session.add_all(animales)
    await session.commit()
    return establecimiento, animales


def payload_venta(establecimiento_id, animal_ids, **overrides):
    datos = {
        "id": str(uuid4()),
        "establecimiento_id": str(establecimiento_id),
        "fecha_operacion": datetime.now(ZONA_HORARIA_NEGOCIO).date().isoformat(),
        "tipo_comprador": "frigorifico",
        "nombre_comprador": "Frigorífico del Centro S.A.",
        "es_empresa": True,
        "apellido_comprador": None,
        "nro_dte": "001234567-8",
        "tipo_venta": "al_bulto",
        "monto_total": "10000.00",
        "animal_ids": [str(animal_id) for animal_id in animal_ids],
        "condicion_cobro": "pendiente",
    }
    datos.update(overrides)
    return datos


def cobro_inicial(monto: str, **overrides):
    datos = {
        "id": str(uuid4()),
        "fecha_cobro": datetime.now(ZONA_HORARIA_NEGOCIO).date().isoformat(),
        "monto": monto,
        "medio_cobro": "transferencia",
    }
    datos.update(overrides)
    return datos


@pytest.mark.anyio
async def test_registra_venta_pendiente_y_actualiza_stock(
    auth_client, session, escenario_http
):
    establecimiento, animales = escenario_http
    respuesta = await auth_client.post(
        BASE,
        json=payload_venta(establecimiento.id, [animal.id for animal in animales]),
    )

    assert respuesta.status_code == 201
    cuerpo = respuesta.json()
    assert cuerpo["success"] is True
    assert set(cuerpo["data"]["animal_ids"]) == {str(animal.id) for animal in animales}
    assert cuerpo["data"]["monto_cobrado"] == "0.00"
    assert cuerpo["data"]["saldo_pendiente"] == "10000.00"
    assert cuerpo["data"]["estado_cobro"] == "pendiente"

    for animal in animales:
        await session.refresh(animal)
        assert animal.estado == EstadoAnimal.vendido


@pytest.mark.anyio
async def test_registra_venta_por_kilo_con_cobro_total(
    auth_client, session, escenario_http
):
    establecimiento, animales = escenario_http
    cobro = cobro_inicial("1234.56", medio_cobro="tarjeta")
    respuesta = await auth_client.post(
        BASE,
        json=payload_venta(
            establecimiento.id,
            [animales[0].id],
            tipo_venta="por_kilo",
            peso_total_kg="10",
            precio_por_kg="123.456789",
            monto_total="1234.56",
            condicion_cobro="total",
            cobro_inicial=cobro,
        ),
    )

    assert respuesta.status_code == 201
    venta = respuesta.json()["data"]
    assert venta["precio_por_kg"] == "123.456789"
    assert venta["monto_total"] == "1234.56"
    assert venta["monto_cobrado"] == "1234.56"
    assert venta["saldo_pendiente"] == "0.00"
    assert venta["estado_cobro"] == "cobrada"

    guardado = await session.get(VentaCobro, UUID(cobro["id"]))
    assert guardado is not None
    assert guardado.medio_cobro == "tarjeta"


@pytest.mark.anyio
async def test_reintento_http_no_duplica_el_agregado(
    auth_client, session, escenario_http
):
    establecimiento, animales = escenario_http
    payload = payload_venta(establecimiento.id, [animales[0].id])

    primera = await auth_client.post(BASE, json=payload)
    segunda = await auth_client.post(BASE, json=payload)

    assert primera.status_code == 201
    assert segunda.status_code == 201
    assert await session.scalar(select(func.count()).select_from(Venta)) == 1
    assert await session.scalar(select(func.count()).select_from(VentaDetalle)) == 1
    assert await session.scalar(select(func.count()).select_from(VentaCobro)) == 0


@pytest.mark.anyio
async def test_employee_no_puede_registrar_ventas(
    auth_client, session, escenario_http, usuario_actual
):
    establecimiento, animales = escenario_http
    await session.execute(
        update(UsuarioEstablecimiento)
        .where(
            UsuarioEstablecimiento.usuario_id == usuario_actual.id,
            UsuarioEstablecimiento.establecimiento_id == establecimiento.id,
        )
        .values(rol=RolUsuario.employee)
    )
    await session.commit()

    respuesta = await auth_client.post(
        BASE,
        json=payload_venta(establecimiento.id, [animales[0].id]),
    )

    assert respuesta.status_code == 403
    assert respuesta.json()["errors"][0]["code"] == "acceso_comercial_denegado"
    assert await session.scalar(select(func.count()).select_from(Venta)) == 0


@pytest.mark.anyio
async def test_total_por_kilo_inconsistente_se_rechaza_antes_de_persistir(
    auth_client, session, escenario_http
):
    establecimiento, animales = escenario_http
    respuesta = await auth_client.post(
        BASE,
        json=payload_venta(
            establecimiento.id,
            [animales[0].id],
            tipo_venta="por_kilo",
            peso_total_kg="10",
            precio_por_kg="1000",
            monto_total="1610000",
        ),
    )

    assert respuesta.status_code == 422
    assert await session.scalar(select(func.count()).select_from(Venta)) == 0
