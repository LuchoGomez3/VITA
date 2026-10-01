"""Contrato del modelo de cobros de ventas (VITA-172).

Cubre lo que la base garantiza por sí sola en cualquier dialecto. El tope de
cobros, la concurrencia y el RLS se prueban contra Postgres en
``test_ventas_cobros_postgres.py``.
"""

from datetime import date
from decimal import Decimal
from uuid import UUID, uuid4

import pytest
from sqlalchemy import Numeric, func, select
from sqlalchemy.exc import IntegrityError

from api.modules.establecimientos.models import Establecimiento
from api.modules.ventas.models import Venta, VentaCobro
from api.shared.enums import TipoComprador, TipoVenta


@pytest.fixture
async def venta_id(session, usuario_actual) -> UUID:
    """Devuelve el id y no la entidad: un rollback expira los objetos del ORM."""
    campo = Establecimiento(owner_id=usuario_actual.id, nombre="La Esperanza")
    session.add(campo)
    await session.flush()
    venta = Venta(
        establecimiento_id=campo.id,
        fecha_operacion=date(2026, 9, 1),
        tipo_comprador=TipoComprador.frigorifico,
        nombre_comprador="Frigorífico Sintético S.A.",
        es_empresa=True,
        nro_dte="DTE-2026-000777",
        tipo_venta=TipoVenta.al_bulto,
        monto_total=Decimal("1000.00"),
        registrada_por_id=usuario_actual.id,
    )
    session.add(venta)
    await session.commit()
    return venta.id


def _cobro(venta: UUID, usuario: UUID, **overrides) -> VentaCobro:
    datos = {
        "venta_id": venta,
        "fecha_cobro": date(2026, 9, 15),
        "monto": Decimal("400.00"),
        "registrado_por_id": usuario,
    }
    datos.update(overrides)
    return VentaCobro(**datos)


async def _cobrado(session, venta_id: UUID) -> Decimal:
    """Suma de cobros activos: la base de saldo y estado, que no se almacenan."""
    total = await session.scalar(
        select(func.coalesce(func.sum(VentaCobro.monto), 0)).where(
            VentaCobro.venta_id == venta_id, VentaCobro.deleted_at.is_(None)
        )
    )
    return Decimal(total)


@pytest.mark.anyio
async def test_cobro_conserva_uuid_de_cliente_y_decimales(
    session, venta_id, usuario_actual
):
    id_generado_en_mobile = uuid4()
    session.add(
        _cobro(
            venta_id,
            usuario_actual.id,
            id=id_generado_en_mobile,
            monto=Decimal("333.33"),
            observaciones="Transferencia",
        )
    )
    await session.commit()

    guardado = await session.get(VentaCobro, id_generado_en_mobile)
    assert guardado is not None
    assert guardado.monto == Decimal("333.33")
    assert guardado.deleted_at is None
    assert guardado.created_at is not None


@pytest.mark.anyio
@pytest.mark.parametrize("monto", [Decimal("0.00"), Decimal("-1.00")])
async def test_monto_debe_ser_positivo(session, venta_id, usuario_actual, monto):
    session.add(_cobro(venta_id, usuario_actual.id, monto=monto))
    with pytest.raises(IntegrityError):
        await session.commit()
    await session.rollback()


@pytest.mark.anyio
@pytest.mark.parametrize(
    "campo", ["venta_id", "fecha_cobro", "monto", "registrado_por_id"]
)
async def test_campos_obligatorios(session, venta_id, usuario_actual, campo):
    session.add(_cobro(venta_id, usuario_actual.id, **{campo: None}))
    with pytest.raises(IntegrityError):
        await session.commit()
    await session.rollback()


@pytest.mark.anyio
async def test_dos_cobros_con_igual_fecha_y_monto_son_validos(
    session, venta_id, usuario_actual
):
    session.add_all(
        [_cobro(venta_id, usuario_actual.id), _cobro(venta_id, usuario_actual.id)]
    )
    await session.commit()

    assert await _cobrado(session, venta_id) == Decimal("800.00")


@pytest.mark.anyio
async def test_el_saldo_se_calcula_y_anular_lo_recalcula(
    session, venta_id, usuario_actual
):
    """Pendiente → parcial → cobrada → parcial otra vez al anular un cobro."""
    venta = await session.get(Venta, venta_id)
    assert await _cobrado(session, venta_id) == Decimal("0")

    primero = _cobro(venta_id, usuario_actual.id, monto=Decimal("400.00"))
    session.add(primero)
    await session.commit()
    assert venta.monto_total - await _cobrado(session, venta_id) == Decimal("600.00")

    session.add(_cobro(venta_id, usuario_actual.id, monto=Decimal("600.00")))
    await session.commit()
    assert await _cobrado(session, venta_id) == venta.monto_total

    primero.deleted_at = func.now()
    await session.commit()
    assert venta.monto_total - await _cobrado(session, venta_id) == Decimal("400.00")


def test_tipos_y_claves_foraneas():
    tabla = VentaCobro.__table__
    monto = tabla.c.monto.type
    assert isinstance(monto, Numeric)
    assert (monto.precision, monto.scale) == (14, 2)
    assert {fk.target_fullname for fk in tabla.c.venta_id.foreign_keys} == {"ventas.id"}
    assert {fk.target_fullname for fk in tabla.c.registrado_por_id.foreign_keys} == {
        "usuarios.id"
    }
    assert "deleted_at" in VentaCobro.model_fields


def test_indices_de_consulta_y_sincronizacion():
    indices = {
        i.name: [c.name for c in i.columns] for i in VentaCobro.__table__.indexes
    }

    assert indices == {
        "ix_ventas_cobros_sync": ["venta_id", "updated_at"],
        "ix_ventas_cobros_fecha_cobro": ["fecha_cobro"],
        "ix_ventas_cobros_registrado_por_id": ["registrado_por_id"],
        "ix_ventas_cobros_updated_at": ["updated_at"],
    }
    # Ninguna unicidad: dos pagos iguales pueden ser operaciones distintas.
    assert not any(i.unique for i in VentaCobro.__table__.indexes)
