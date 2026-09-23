"""Validaciones del contrato HTTP para registrar ventas de hacienda."""

from datetime import datetime, timedelta
from decimal import Decimal
from uuid import uuid4

import pytest
from pydantic import ValidationError

from api.modules.ventas.schemas import VentaCreate, ZONA_HORARIA_NEGOCIO
from api.shared.enums import CondicionCobro, EstadoCobro


def payload_valido(**overrides):
    datos = {
        "id": uuid4(),
        "establecimiento_id": uuid4(),
        "fecha_operacion": datetime.now(ZONA_HORARIA_NEGOCIO).date(),
        "tipo_comprador": "particular",
        "nombre_comprador": "María José",
        "es_empresa": False,
        "apellido_comprador": "Núñez Acosta",
        "nro_dte": "0012345678",
        "tipo_venta": "al_bulto",
        "monto_total": "4500000.00",
        "animal_ids": [uuid4(), uuid4()],
        "condicion_cobro": "pendiente",
    }
    datos.update(overrides)
    return datos


def mensaje_error(datos) -> str:
    with pytest.raises(ValidationError) as error:
        VentaCreate.model_validate(datos)
    return str(error.value)


def test_admite_persona_fisica_con_nombres_compuestos_y_acentos():
    venta = VentaCreate.model_validate(payload_valido())

    assert venta.nombre_comprador == "María José"
    assert venta.apellido_comprador == "Núñez Acosta"
    assert venta.nro_dte == "0012345678"


@pytest.mark.parametrize("nombre", ["Juan3", "Juan@", "Juan-Pablo"])
def test_persona_fisica_rechaza_numeros_y_simbolos_en_nombre(nombre):
    assert "solamente letras" in mensaje_error(payload_valido(nombre_comprador=nombre))


@pytest.mark.parametrize("apellido", ["Pérez2", "Pérez@", "Pérez-Gómez"])
def test_persona_fisica_rechaza_numeros_y_simbolos_en_apellido(apellido):
    assert "solamente letras" in mensaje_error(
        payload_valido(apellido_comprador=apellido)
    )


def test_persona_fisica_requiere_apellido():
    assert "apellido es obligatorio" in mensaje_error(
        payload_valido(apellido_comprador=None)
    )


def test_empresa_admite_numeros_y_simbolos_en_razon_social():
    venta = VentaCreate.model_validate(
        payload_valido(
            tipo_comprador="frigorifico",
            nombre_comprador="Los Álamos S.A. 2",
            es_empresa=True,
            apellido_comprador=None,
        )
    )

    assert venta.nombre_comprador == "Los Álamos S.A. 2"


def test_empresa_rechaza_apellido():
    assert "apellido no corresponde" in mensaje_error(
        payload_valido(es_empresa=True, apellido_comprador="Pérez")
    )


@pytest.mark.parametrize("nro_dte", ["", "12 34", "DTE123", "123-456"])
def test_dte_requiere_solamente_digitos(nro_dte):
    assert "solamente dígitos" in mensaje_error(payload_valido(nro_dte=nro_dte))


def test_fecha_futura_es_rechazada():
    manana = datetime.now(ZONA_HORARIA_NEGOCIO).date() + timedelta(days=1)

    assert "fecha futura" in mensaje_error(payload_valido(fecha_operacion=manana))


@pytest.mark.parametrize("monto", ["0", "-1"])
def test_monto_total_debe_ser_positivo(monto):
    assert "mayor a cero" in mensaje_error(payload_valido(monto_total=monto))


@pytest.mark.parametrize("monto", ["NaN", "Infinity"])
def test_monto_total_debe_ser_finito(monto):
    assert "finite number" in mensaje_error(payload_valido(monto_total=monto))


def test_venta_requiere_animales_sin_repetir():
    animal_id = uuid4()

    assert "at least 1 item" in mensaje_error(payload_valido(animal_ids=[]))
    assert "IDs repetidos" in mensaje_error(
        payload_valido(animal_ids=[animal_id, animal_id])
    )


def test_venta_al_bulto_rechaza_peso_o_precio_por_kilo():
    assert "no debe incluir peso" in mensaje_error(payload_valido(peso_total_kg="1500"))


def test_pago_total_no_recibe_casilla_de_monto_parcial():
    venta = VentaCreate.model_validate(
        payload_valido(condicion_cobro=CondicionCobro.total)
    )
    assert venta.monto_cobrado_inicial is None

    assert "solo corresponde a un pago parcial" in mensaje_error(
        payload_valido(
            condicion_cobro=CondicionCobro.total,
            monto_cobrado_inicial="1000",
        )
    )


def test_pago_pendiente_no_admite_monto_cobrado():
    assert "solo corresponde a un pago parcial" in mensaje_error(
        payload_valido(
            condicion_cobro=CondicionCobro.pendiente,
            monto_cobrado_inicial="1000",
        )
    )


def test_pago_parcial_requiere_monto_menor_que_total():
    assert "obligatorio para un pago parcial" in mensaje_error(
        payload_valido(condicion_cobro=CondicionCobro.parcial)
    )
    assert "menor que el total" in mensaje_error(
        payload_valido(
            condicion_cobro=CondicionCobro.parcial,
            monto_cobrado_inicial="4500000.00",
        )
    )

    venta = VentaCreate.model_validate(
        payload_valido(
            condicion_cobro=CondicionCobro.parcial,
            monto_cobrado_inicial="1500000.00",
        )
    )
    assert venta.monto_cobrado_inicial == Decimal("1500000.00")


def test_estado_cobro_expone_valores_estables_para_el_cliente():
    assert {estado.value for estado in EstadoCobro} == {
        "pendiente",
        "parcial",
        "cobrada",
    }
