"""Contrato de la estructura de datos de ventas de hacienda (VITA-127).

Cubre las restricciones que la base garantiza por sí sola, sin depender de la
capa de servicio, y el acuerdo entre los tres artefactos que describen el
esquema: el modelo SQLModel, la migración Alembic y el script SQL de respaldo.
"""

from datetime import date
from decimal import Decimal
from pathlib import Path
import re
from uuid import UUID, uuid4

import pytest
from sqlalchemy import select
from sqlalchemy.exc import IntegrityError

from api.modules.animales.models import Animal
from api.modules.establecimientos.models import Establecimiento
from api.modules.ventas.models import Venta, VentaDetalle
from api.shared.enums import SexoAnimal, TipoComprador, TipoVenta

_BACKEND = Path(__file__).parent.parent
_SCRIPT_SQL = _BACKEND / "scripts/crear_ventas.sql"
_MIGRACION = _BACKEND / "alembic/versions/20260902_02_crear_ventas.py"


@pytest.fixture
async def campo_id(session, usuario_actual) -> UUID:
    """Devuelve el id y no la entidad: un rollback expira los objetos del ORM."""
    establecimiento = Establecimiento(
        owner_id=usuario_actual.id,
        nombre="La Esperanza",
        nro_renspa="11.222.3.44444/00",
    )
    session.add(establecimiento)
    await session.commit()
    return establecimiento.id


@pytest.fixture
async def usuario_id(usuario_actual) -> UUID:
    return usuario_actual.id


@pytest.fixture
async def animales_ids(session, campo_id) -> list[UUID]:
    lote = [
        Animal(
            establecimiento_id=campo_id,
            nro_caravana_rfid=f"98200000000000{indice}",
            sexo=SexoAnimal.macho,
        )
        for indice in range(2)
    ]
    session.add_all(lote)
    await session.commit()
    return [animal.id for animal in lote]


def _venta(campo_id: UUID, usuario_id: UUID, **overrides) -> Venta:
    """Venta al bulto válida; cada test sobrescribe solo lo que quiere probar."""
    datos = {
        "establecimiento_id": campo_id,
        "fecha_operacion": date(2026, 8, 20),
        "tipo_comprador": TipoComprador.frigorifico,
        "nombre_comprador": "Frigorífico Rioplatense S.A.",
        "tipo_venta": TipoVenta.al_bulto,
        "monto_total": Decimal("4500000.00"),
        "registrada_por_id": usuario_id,
    }
    datos.update(overrides)
    return Venta(**datos)


async def _rechaza(session, entidad) -> None:
    session.add(entidad)
    with pytest.raises(IntegrityError):
        await session.commit()
    await session.rollback()


@pytest.mark.anyio
async def test_venta_al_bulto_conserva_uuid_de_cliente_y_decimales(
    session, campo_id, usuario_id
):
    """El alta offline llega con su UUID y los importes no pasan por float."""
    id_generado_en_mobile = uuid4()
    venta = _venta(
        campo_id,
        usuario_id,
        id=id_generado_en_mobile,
        monto_total=Decimal("4500000.55"),
    )
    session.add(venta)
    await session.commit()

    guardada = await session.get(Venta, id_generado_en_mobile)
    assert guardada is not None
    assert guardada.monto_total == Decimal("4500000.55")
    # La venta se sincroniza y su borrado se propaga como soft delete.
    assert guardada.deleted_at is None
    assert guardada.created_at is not None


@pytest.mark.anyio
async def test_venta_al_bulto_admite_dte_y_apellido_ausentes(
    session, campo_id, usuario_id
):
    """Escenario de campo: se cierra el trato sin señal y el DTe todavía no existe.

    El comprador es una razón social, así que tampoco tiene apellido.
    """
    venta = _venta(campo_id, usuario_id, nro_dte=None, apellido_comprador=None)
    session.add(venta)
    await session.commit()

    assert venta.nro_dte is None
    assert venta.apellido_comprador is None
    assert venta.peso_total_kg is None
    assert venta.precio_por_kg is None


@pytest.mark.anyio
async def test_venta_por_kilo_exige_peso_y_precio(session, campo_id, usuario_id):
    """El monto por kilo solo es reconstruible si están sus dos factores."""
    await _rechaza(
        session,
        _venta(
            campo_id,
            usuario_id,
            tipo_venta=TipoVenta.por_kilo,
            peso_total_kg=None,
            precio_por_kg=None,
        ),
    )

    completa = _venta(
        campo_id,
        usuario_id,
        tipo_venta=TipoVenta.por_kilo,
        peso_total_kg=Decimal("12500.500"),
        precio_por_kg=Decimal("2400.00"),
        monto_total=Decimal("30001200.00"),
    )
    session.add(completa)
    await session.commit()
    assert completa.peso_total_kg == Decimal("12500.500")


@pytest.mark.anyio
@pytest.mark.parametrize(
    ("campos", "motivo"),
    [
        ({"monto_total": Decimal("0.00")}, "monto en cero"),
        ({"monto_total": Decimal("-1.00")}, "monto negativo"),
        ({"nombre_comprador": "   "}, "comprador en blanco"),
        ({"tipo_comprador": "cooperativa"}, "tipo de comprador fuera del enum"),
        ({"tipo_venta": "por_cabeza"}, "modalidad fuera del enum"),
        ({"peso_total_kg": Decimal("0.000")}, "peso en cero"),
        ({"precio_por_kg": Decimal("0.00")}, "precio por kilo en cero"),
    ],
)
async def test_restricciones_rechazan_datos_invalidos(
    session, campo_id, usuario_id, campos, motivo
):
    assert motivo  # describe el caso en el reporte de pytest
    await _rechaza(session, _venta(campo_id, usuario_id, **campos))


@pytest.mark.anyio
async def test_un_animal_no_puede_repetirse_en_la_misma_venta(
    session, campo_id, usuario_id, animales_ids
):
    venta = _venta(campo_id, usuario_id)
    session.add(venta)
    await session.flush()
    venta_id = venta.id
    session.add(VentaDetalle(venta_id=venta_id, animal_id=animales_ids[0]))
    await session.commit()

    await _rechaza(session, VentaDetalle(venta_id=venta_id, animal_id=animales_ids[0]))


@pytest.mark.anyio
async def test_el_mismo_animal_puede_estar_en_ventas_distintas(
    session, campo_id, usuario_id, animales_ids
):
    """La unicidad es por venta, no global.

    Reingresar un animal al stock y volver a venderlo es una operación válida
    que la base no debe bloquear.
    """
    for _ in range(2):
        venta = _venta(campo_id, usuario_id)
        session.add(venta)
        await session.flush()
        session.add(VentaDetalle(venta_id=venta.id, animal_id=animales_ids[0]))
        await session.commit()

    detalles = await session.execute(
        select(VentaDetalle).where(VentaDetalle.animal_id == animales_ids[0])
    )
    assert len(detalles.scalars().all()) == 2


def test_detalle_no_se_sincroniza_por_separado():
    """La venta es un agregado atómico: sus detalles viajan dentro de su payload."""
    assert "deleted_at" in Venta.model_fields
    assert "deleted_at" not in VentaDetalle.model_fields


def test_indices_de_consulta_estan_declarados():
    """Protege los índices que sostienen el pull delta y el chequeo de reventa."""
    indice_sync = next(i for i in Venta.__table__.indexes if i.name == "ix_ventas_sync")
    assert [c.name for c in indice_sync.columns] == [
        "establecimiento_id",
        "updated_at",
    ]

    indices_detalle = {i.name for i in VentaDetalle.__table__.indexes}
    assert "ix_ventas_detalles_animal_id" in indices_detalle


def _valores_de_check(contenido: str, restriccion: str) -> set[str]:
    """Extrae los literales de un ``CHECK <col> in (...)`` asociado a una restricción.

    El script SQL nombra la restricción antes del predicado y la migración
    después, así que se acepta cualquiera de los dos órdenes.
    """
    patrones = (
        rf"{restriccion}[^(]*\(\s*\w+ in \(([^)]+)\)",
        rf"\w+ in \(([^)]+)\)[^)]*\)?\s*,\s*name=\"{restriccion}\"",
    )
    for patron in patrones:
        coincidencia = re.search(patron, contenido, re.IGNORECASE | re.DOTALL)
        if coincidencia:
            return {
                valor.strip().strip("'").strip('"')
                for valor in coincidencia.group(1).split(",")
            }
    raise AssertionError(f"No se encontró la restricción {restriccion}")


@pytest.mark.parametrize(
    ("restriccion", "enum"),
    [
        ("ck_ventas_tipo_comprador_valido", TipoComprador),
        ("ck_ventas_tipo_venta_valido", TipoVenta),
    ],
)
def test_enums_coinciden_entre_modelo_migracion_y_script(restriccion, enum):
    """Los tres artefactos que describen el esquema no pueden divergir.

    El modelo deriva los literales del enum; la migración y el script los
    escriben a mano, así que este test es el que evita que se desalineen.
    """
    esperados = {miembro.value for miembro in enum}
    assert _valores_de_check(_SCRIPT_SQL.read_text(encoding="utf-8"), restriccion) == (
        esperados
    )
    assert _valores_de_check(_MIGRACION.read_text(encoding="utf-8"), restriccion) == (
        esperados
    )
