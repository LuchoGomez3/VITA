"""Pruebas de persistencia del agregado venta, todavía sin capa HTTP."""

from datetime import UTC, date, datetime
from decimal import Decimal
from uuid import UUID, uuid4

import pytest
from sqlalchemy import func, select

from api.modules.animales.models import Animal
from api.modules.establecimientos.models import Establecimiento
from api.modules.ventas.exceptions import (
    AccesoComercialDenegadoError,
    AnimalesNoDisponiblesVentaError,
    VentaIdEnConflictoError,
)
from api.modules.ventas.models import Venta, VentaDetalle
from api.modules.ventas.repository import VentaRepository
from api.shared.enums import EstadoAnimal, SexoAnimal, TipoComprador, TipoVenta


@pytest.fixture
async def datos_venta(session, usuario_actual):
    establecimiento = Establecimiento(
        owner_id=usuario_actual.id,
        nombre="La Esperanza",
        nro_renspa="11.222.3.44444/00",
    )
    establecimiento_ajeno = Establecimiento(
        owner_id=usuario_actual.id,
        nombre="Campo Ajeno",
        nro_renspa="22.333.4.55555/00",
    )
    session.add_all([establecimiento, establecimiento_ajeno])
    await session.flush()

    animales = [
        Animal(
            establecimiento_id=establecimiento.id,
            nro_caravana_rfid=f"98200000000000{indice}",
            sexo=SexoAnimal.macho,
        )
        for indice in range(1, 4)
    ]
    animal_ajeno = Animal(
        establecimiento_id=establecimiento_ajeno.id,
        nro_caravana_rfid="982000000000004",
        sexo=SexoAnimal.hembra,
    )
    animal_borrado = Animal(
        establecimiento_id=establecimiento.id,
        nro_caravana_rfid="982000000000005",
        sexo=SexoAnimal.hembra,
        deleted_at=datetime.now(UTC),
    )
    session.add_all([*animales, animal_ajeno, animal_borrado])
    await session.commit()
    return establecimiento, animales, animal_ajeno, animal_borrado


def crear_venta(establecimiento_id: UUID, usuario_id: UUID) -> Venta:
    return Venta(
        id=uuid4(),
        establecimiento_id=establecimiento_id,
        fecha_operacion=date(2026, 9, 1),
        tipo_comprador=TipoComprador.frigorifico,
        nombre_comprador="Frigorífico del Centro S.A.",
        es_empresa=True,
        apellido_comprador=None,
        nro_dte="0012345678",
        tipo_venta=TipoVenta.al_bulto,
        monto_total=Decimal("4500000.00"),
        registrada_por_id=usuario_id,
    )


@pytest.mark.anyio
async def test_guarda_y_recupera_venta_con_sus_detalles(
    session, usuario_actual, datos_venta
):
    establecimiento, animales, _, _ = datos_venta
    repository = VentaRepository(session)
    venta = crear_venta(establecimiento.id, usuario_actual.id)
    animal_ids = [animal.id for animal in animales[:2]]

    await repository.save(venta)
    await repository.add_detalles(venta.id, animal_ids)
    await session.flush()

    recuperada = await repository.get_including_deleted(venta.id)
    detalles = await repository.list_animal_ids(venta.id)
    assert recuperada == venta
    assert set(detalles) == set(animal_ids)


@pytest.mark.anyio
async def test_busqueda_limita_animales_al_establecimiento_y_excluye_borrados(
    session, datos_venta, monkeypatch
):
    establecimiento, animales, animal_ajeno, animal_borrado = datos_venta
    animales[1].estado = EstadoAnimal.vendido
    await session.commit()
    repository = VentaRepository(session)
    consultas = []
    ejecutar = session.execute

    async def capturar_consulta(consulta, *args, **kwargs):
        consultas.append(consulta)
        return await ejecutar(consulta, *args, **kwargs)

    monkeypatch.setattr(session, "execute", capturar_consulta)
    encontrados = await repository.list_animales_para_venta(
        establecimiento.id,
        [
            animales[0].id,
            animales[1].id,
            animal_ajeno.id,
            animal_borrado.id,
            uuid4(),
        ],
    )

    # El repository mantiene el vendido para que el service pueda informar el
    # conflicto, pero nunca devuelve filas borradas o pertenecientes a otro tenant.
    assert {animal.id for animal in encontrados} == {
        animales[0].id,
        animales[1].id,
    }
    assert consultas[0]._for_update_arg is not None


@pytest.mark.anyio
async def test_cambio_de_stock_y_detalles_se_revierten_juntos(
    session, usuario_actual, datos_venta
):
    establecimiento, animales, _, _ = datos_venta
    repository = VentaRepository(session)
    venta = crear_venta(establecimiento.id, usuario_actual.id)
    seleccionados = animales[:2]

    await repository.save(venta)
    await repository.add_detalles(venta.id, [animal.id for animal in seleccionados])
    for animal in seleccionados:
        animal.estado = EstadoAnimal.vendido
    await repository.save_animales(seleccionados)
    await session.rollback()

    ventas = await session.scalar(select(func.count()).select_from(Venta))
    detalles = await session.scalar(select(func.count()).select_from(VentaDetalle))
    assert ventas == 0
    assert detalles == 0
    for animal in seleccionados:
        await session.refresh(animal)
        assert animal.estado == EstadoAnimal.activo


def test_excepciones_exponen_codigos_y_detalles_estables():
    animal_ids = [uuid4(), uuid4()]
    acceso = AccesoComercialDenegadoError()
    animales = AnimalesNoDisponiblesVentaError(animal_ids)
    id_conflictivo = VentaIdEnConflictoError()

    assert acceso.status_code == 403
    assert acceso.code == "acceso_comercial_denegado"
    assert animales.status_code == 409
    assert animales.details == {
        "animal_ids": [str(animal_id) for animal_id in animal_ids]
    }
    assert id_conflictivo.status_code == 409
    assert id_conflictivo.code == "venta_id_en_conflicto"
