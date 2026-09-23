"""Reglas del service base de ventas antes de integrar cobros y HTTP."""

from datetime import datetime
from uuid import uuid4

import pytest
from sqlalchemy import func, select

from api.modules.animales.models import Animal
from api.modules.establecimientos.models import (
    Establecimiento,
    UsuarioEstablecimiento,
)
from api.modules.ventas.exceptions import (
    AccesoComercialDenegadoError,
    AnimalesNoDisponiblesVentaError,
    VentaIdEnConflictoError,
)
from api.modules.ventas.models import Venta, VentaDetalle
from api.modules.ventas.schemas import VentaCreate, ZONA_HORARIA_NEGOCIO
from api.modules.ventas.service import VentaService
from api.shared.enums import EstadoAnimal, RolUsuario, SexoAnimal
from api.shared.exceptions import EstablecimientoNoAutorizadoError


@pytest.fixture
async def escenario_venta(session, usuario_actual):
    establecimiento = Establecimiento(
        owner_id=usuario_actual.id,
        nombre="La Esperanza",
        nro_renspa="11.222.3.44444/00",
    )
    session.add(establecimiento)
    await session.flush()
    membresia = UsuarioEstablecimiento(
        usuario_id=usuario_actual.id,
        establecimiento_id=establecimiento.id,
        rol=RolUsuario.owner,
        activo=True,
    )
    animales = [
        Animal(
            establecimiento_id=establecimiento.id,
            nro_caravana_rfid=f"98200000000100{indice}",
            sexo=SexoAnimal.macho,
        )
        for indice in range(2)
    ]
    session.add_all([membresia, *animales])
    await session.commit()
    return establecimiento, membresia, animales


def crear_datos(establecimiento_id, animal_ids, **overrides) -> VentaCreate:
    datos = {
        "id": uuid4(),
        "establecimiento_id": establecimiento_id,
        "fecha_operacion": datetime.now(ZONA_HORARIA_NEGOCIO).date(),
        "tipo_comprador": "frigorifico",
        "nombre_comprador": "Frigorífico del Centro S.A.",
        "es_empresa": True,
        "apellido_comprador": None,
        "nro_dte": "0012345678",
        "tipo_venta": "al_bulto",
        "monto_total": "4500000.00",
        "animal_ids": animal_ids,
        "condicion_cobro": "pendiente",
    }
    datos.update(overrides)
    return VentaCreate.model_validate(datos)


@pytest.mark.anyio
@pytest.mark.parametrize("rol", [RolUsuario.owner, RolUsuario.admin])
async def test_owner_y_admin_pueden_crear_venta_base(
    session, usuario_actual, escenario_venta, rol
):
    establecimiento, membresia, animales = escenario_venta
    membresia.rol = rol
    await session.commit()
    datos = crear_datos(establecimiento.id, [animal.id for animal in animales])

    venta = await VentaService(session).crear_base(usuario_actual, datos)

    assert venta.registrada_por_id == usuario_actual.id
    assert venta.id == datos.id
    for animal in animales:
        await session.refresh(animal)
        assert animal.estado == EstadoAnimal.vendido
    detalles = await session.scalar(select(func.count()).select_from(VentaDetalle))
    assert detalles == 2


@pytest.mark.anyio
async def test_employee_no_puede_registrar_venta(
    session, usuario_actual, escenario_venta
):
    establecimiento, membresia, animales = escenario_venta
    membresia.rol = RolUsuario.employee
    await session.commit()
    datos = crear_datos(establecimiento.id, [animales[0].id])

    with pytest.raises(AccesoComercialDenegadoError):
        await VentaService(session).crear_base(usuario_actual, datos)

    assert await session.scalar(select(func.count()).select_from(Venta)) == 0


@pytest.mark.anyio
async def test_usuario_sin_membresia_no_puede_registrar_venta(session, usuario_actual):
    datos = crear_datos(uuid4(), [uuid4()])

    with pytest.raises(EstablecimientoNoAutorizadoError):
        await VentaService(session).crear_base(usuario_actual, datos)


@pytest.mark.anyio
async def test_un_animal_no_activo_rechaza_toda_la_venta(
    session, usuario_actual, escenario_venta
):
    establecimiento, _, animales = escenario_venta
    animales[1].estado = EstadoAnimal.muerto
    await session.commit()
    datos = crear_datos(establecimiento.id, [animal.id for animal in animales])

    with pytest.raises(AnimalesNoDisponiblesVentaError) as error:
        await VentaService(session).crear_base(usuario_actual, datos)

    assert error.value.details == {"animal_ids": [str(animales[1].id)]}
    assert await session.scalar(select(func.count()).select_from(Venta)) == 0
    await session.refresh(animales[0])
    assert animales[0].estado == EstadoAnimal.activo


@pytest.mark.anyio
async def test_animal_ajeno_o_inexistente_no_revela_otro_tenant(
    session, usuario_actual, escenario_venta
):
    establecimiento, _, animales = escenario_venta
    ajeno = Establecimiento(
        owner_id=usuario_actual.id,
        nombre="Campo Ajeno",
        nro_renspa="22.333.4.55555/00",
    )
    session.add(ajeno)
    await session.flush()
    animal_ajeno = Animal(
        establecimiento_id=ajeno.id,
        nro_caravana_rfid="982000000009999",
        sexo=SexoAnimal.hembra,
    )
    session.add(animal_ajeno)
    await session.commit()
    inexistente = uuid4()
    datos = crear_datos(
        establecimiento.id,
        [animales[0].id, animal_ajeno.id, inexistente],
    )

    with pytest.raises(AnimalesNoDisponiblesVentaError) as error:
        await VentaService(session).crear_base(usuario_actual, datos)

    assert error.value.details == {
        "animal_ids": [str(animal_ajeno.id), str(inexistente)]
    }


@pytest.mark.anyio
async def test_reintento_identico_no_duplica_venta_ni_detalles(
    session, usuario_actual, escenario_venta
):
    establecimiento, _, animales = escenario_venta
    ids = [animal.id for animal in animales]
    datos = crear_datos(establecimiento.id, ids)
    service = VentaService(session)

    primera = await service.crear_base(usuario_actual, datos)
    # El orden no forma parte de la identidad semántica de la venta.
    reintento = crear_datos(
        establecimiento.id,
        list(reversed(ids)),
        id=datos.id,
    )
    segunda = await service.crear_base(usuario_actual, reintento)

    assert segunda.id == primera.id
    assert await session.scalar(select(func.count()).select_from(Venta)) == 1
    assert await session.scalar(select(func.count()).select_from(VentaDetalle)) == 2


@pytest.mark.anyio
async def test_mismo_uuid_con_datos_distintos_informa_conflicto(
    session, usuario_actual, escenario_venta
):
    establecimiento, _, animales = escenario_venta
    datos = crear_datos(establecimiento.id, [animal.id for animal in animales])
    service = VentaService(session)
    await service.crear_base(usuario_actual, datos)
    diferente = crear_datos(
        establecimiento.id,
        [animal.id for animal in animales],
        id=datos.id,
        monto_total="4600000.00",
    )

    with pytest.raises(VentaIdEnConflictoError):
        await service.crear_base(usuario_actual, diferente)
