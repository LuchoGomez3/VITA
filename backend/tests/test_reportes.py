"""Tests de PRO-14: generación de documentación SENASA (CSV/PDF)."""

import csv
import io
from datetime import UTC, date, datetime

import pytest

from api.modules.animales.models import Animal
from api.modules.categorias.models import Categoria
from api.modules.egresos.models import Egreso, EgresoDetalle
from api.modules.establecimientos.models import (
    Establecimiento,
    UsuarioEstablecimiento,
)
from api.modules.eventos_sanitarios.models import EventoSanitario
from api.modules.lotes.models import Lote
from api.shared.enums import (
    EstadoAnimal,
    RolUsuario,
    SexoAnimal,
    TipoEgreso,
    TipoEventoSanitario,
)

CARAVANA_OK = "123456789012345"


@pytest.fixture
async def datos_reporte(session, usuario_actual):
    """Establecimiento con un animal completo y eventos (vacunación + egreso)."""
    est = Establecimiento(
        owner_id=usuario_actual.id,
        nombre="Estancia Reporte",
        nro_renspa="01.002.3.04567",
    )
    session.add(est)
    await session.flush()
    session.add(
        UsuarioEstablecimiento(
            usuario_id=usuario_actual.id,
            establecimiento_id=est.id,
            rol=RolUsuario.owner,
            activo=True,
        )
    )
    categoria = Categoria(establecimiento_id=est.id, nombre="Ternero")
    lote = Lote(establecimiento_id=est.id, nombre="Lote 1")
    session.add(categoria)
    session.add(lote)
    await session.flush()

    animal = Animal(
        establecimiento_id=est.id,
        nro_caravana_rfid=CARAVANA_OK,
        sexo=SexoAnimal.hembra,
        raza="Angus",
        fecha_nacimiento=date(2024, 1, 1),
        categoria_id=categoria.id,
        lote_id=lote.id,
        estado=EstadoAnimal.activo,
    )
    session.add(animal)
    await session.flush()

    session.add(
        EventoSanitario(
            establecimiento_id=est.id,
            animal_id=animal.id,
            tipo=TipoEventoSanitario.vacunacion,
            fecha_aplicacion=datetime(2026, 5, 1, 10, 0, tzinfo=UTC),
        )
    )
    egreso = Egreso(
        establecimiento_id=est.id,
        tipo=TipoEgreso.venta,
        fecha=datetime(2026, 5, 10, 9, 0, tzinfo=UTC),
    )
    session.add(egreso)
    await session.flush()
    session.add(EgresoDetalle(egreso_id=egreso.id, animal_id=animal.id))
    await session.commit()
    return est, lote, animal


def _parse_csv(text: str) -> list[dict]:
    return list(csv.DictReader(io.StringIO(text)))


@pytest.mark.anyio
async def test_csv_con_datos_completos(auth_client, datos_reporte):
    est, _, _ = datos_reporte
    resp = await auth_client.get(
        f"/api/v1/reportes/senasa?establecimiento_id={est.id}&formato=csv"
    )
    assert resp.status_code == 200
    assert resp.headers["content-type"].startswith("text/csv")
    assert "attachment" in resp.headers["content-disposition"]
    assert CARAVANA_OK in resp.text
    assert est.nro_renspa in resp.text
    # Hay dos eventos: vacunación + egreso.
    filas = _parse_csv(resp.text)
    assert len(filas) == 2
    tipos = {f["Tipo de evento"] for f in filas}
    assert {"vacunacion", "egreso"} == tipos


@pytest.mark.anyio
async def test_pdf_con_datos_completos(auth_client, datos_reporte):
    est, _, _ = datos_reporte
    resp = await auth_client.get(
        f"/api/v1/reportes/senasa?establecimiento_id={est.id}&formato=pdf"
    )
    assert resp.status_code == 200
    assert resp.headers["content-type"] == "application/pdf"
    assert resp.content[:5] == b"%PDF-"


@pytest.mark.anyio
async def test_filtro_por_tipo_evento(auth_client, datos_reporte):
    est, _, _ = datos_reporte
    resp = await auth_client.get(
        f"/api/v1/reportes/senasa?establecimiento_id={est.id}"
        "&formato=csv&tipo_evento=vacunacion"
    )
    assert resp.status_code == 200
    filas = _parse_csv(resp.text)
    assert len(filas) == 1
    assert filas[0]["Tipo de evento"] == "vacunacion"


@pytest.mark.anyio
async def test_validacion_bloquea_con_animal_incompleto(
    auth_client, session, datos_reporte
):
    est, lote, _ = datos_reporte
    # Animal sin categoría y con caravana inválida → debe bloquear.
    session.add(
        Animal(
            establecimiento_id=est.id,
            nro_caravana_rfid="123",  # no son 15 dígitos
            sexo=SexoAnimal.macho,
            raza="Hereford",
            fecha_nacimiento=date(2024, 2, 2),
            lote_id=lote.id,
            estado=EstadoAnimal.activo,
        )
    )
    await session.commit()

    resp = await auth_client.get(
        f"/api/v1/reportes/senasa?establecimiento_id={est.id}&formato=csv"
    )
    assert resp.status_code == 422
    error = resp.json()["errors"][0]
    assert error["code"] == "datos_incompletos_para_reporte"
    incompletos = error["details"]["animales_incompletos"]
    assert len(incompletos) == 1
    assert "nro_caravana_rfid" in incompletos[0]["faltante"]
    assert "categoria_id" in incompletos[0]["faltante"]


@pytest.mark.anyio
async def test_reporte_sin_acceso(auth_client):
    from uuid import uuid4

    resp = await auth_client.get(
        f"/api/v1/reportes/senasa?establecimiento_id={uuid4()}&formato=csv"
    )
    assert resp.status_code == 403
    assert resp.json()["errors"][0]["code"] == "establecimiento_no_autorizado"
