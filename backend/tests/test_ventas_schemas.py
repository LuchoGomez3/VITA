"""Validaciones del contrato HTTP para registrar ventas de hacienda."""

from datetime import datetime, timedelta
from decimal import Decimal
from uuid import uuid4

import pytest
from pydantic import ValidationError

from api.modules.ventas.schemas import VentaCreate, ZONA_HORARIA_NEGOCIO
from api.shared.enums import CondicionCobro, EstadoCobro, MedioCobro


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


def cobro_valido(**overrides):
    datos = {
        "id": uuid4(),
        "fecha_cobro": datetime.now(ZONA_HORARIA_NEGOCIO).date(),
        "monto": "4500000.00",
        "medio_cobro": MedioCobro.transferencia,
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


def test_venta_por_kilo_acepta_el_total_calculado_con_datos_comerciales():
    venta = VentaCreate.model_validate(
        payload_valido(
            tipo_venta="por_kilo",
            peso_total_kg="10",
            precio_por_kg="1000",
            monto_total="10000",
        )
    )

    assert venta.peso_total_kg == Decimal("10.000")
    assert venta.precio_por_kg == Decimal("1000.00")
    assert venta.monto_total == Decimal("10000.00")


def test_venta_por_kilo_rechaza_total_calculado_con_pesos_historicos():
    assert "peso de venta multiplicado" in mensaje_error(
        payload_valido(
            tipo_venta="por_kilo",
            peso_total_kg="10",
            precio_por_kg="1000",
            monto_total="1610000",
        )
    )


def test_venta_por_kilo_conserva_precio_y_redondea_solo_el_total():
    venta = VentaCreate.model_validate(
        payload_valido(
            tipo_venta="por_kilo",
            peso_total_kg="10.125",
            precio_por_kg="123.456",
            monto_total="1249.99",
        )
    )

    assert venta.peso_total_kg == Decimal("10.125")
    assert venta.precio_por_kg == Decimal("123.456000")
    assert venta.monto_total == Decimal("1249.99")


def test_precio_por_kilo_con_mas_de_seis_decimales_se_rechaza_sin_redondear():
    assert "admite hasta 6 decimales" in mensaje_error(
        payload_valido(
            tipo_venta="por_kilo",
            peso_total_kg="10",
            precio_por_kg="123.4567891",
            monto_total="1234.57",
        )
    )


def test_pago_total_requiere_cobro_por_el_monto_completo():
    assert "obligatorio para un pago total" in mensaje_error(
        payload_valido(condicion_cobro=CondicionCobro.total)
    )
    assert "coincidir con el total" in mensaje_error(
        payload_valido(
            condicion_cobro=CondicionCobro.total,
            cobro_inicial=cobro_valido(monto="1000"),
        )
    )

    venta = VentaCreate.model_validate(
        payload_valido(
            condicion_cobro=CondicionCobro.total,
            cobro_inicial=cobro_valido(),
        )
    )
    assert venta.cobro_inicial is not None
    assert venta.cobro_inicial.monto == venta.monto_total


def test_pago_pendiente_no_admite_cobro_inicial():
    assert "no debe incluir un cobro inicial" in mensaje_error(
        payload_valido(
            condicion_cobro=CondicionCobro.pendiente,
            cobro_inicial=cobro_valido(),
        )
    )


def test_pago_parcial_requiere_monto_menor_que_total():
    assert "obligatorio para un pago parcial" in mensaje_error(
        payload_valido(condicion_cobro=CondicionCobro.parcial)
    )
    assert "menor que el total" in mensaje_error(
        payload_valido(
            condicion_cobro=CondicionCobro.parcial,
            cobro_inicial=cobro_valido(),
        )
    )

    venta = VentaCreate.model_validate(
        payload_valido(
            condicion_cobro=CondicionCobro.parcial,
            cobro_inicial=cobro_valido(monto="1500000.00"),
        )
    )
    assert venta.cobro_inicial is not None
    assert venta.cobro_inicial.monto == Decimal("1500000.00")


def test_cobro_inicial_requiere_monto_positivo_y_fecha_no_futura():
    assert "monto cobrado debe ser mayor" in mensaje_error(
        payload_valido(
            condicion_cobro=CondicionCobro.parcial,
            cobro_inicial=cobro_valido(monto="0"),
        )
    )
    manana = datetime.now(ZONA_HORARIA_NEGOCIO).date() + timedelta(days=1)
    assert "fecha de cobro no puede ser futura" in mensaje_error(
        payload_valido(
            condicion_cobro=CondicionCobro.parcial,
            cobro_inicial=cobro_valido(
                monto="1500000.00",
                fecha_cobro=manana,
            ),
        )
    )


def test_estado_cobro_expone_valores_estables_para_el_cliente():
    assert {estado.value for estado in EstadoCobro} == {
        "pendiente",
        "parcial",
        "cobrada",
    }
