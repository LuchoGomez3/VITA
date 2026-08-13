"""Tests de PRO-14: declaración electrónica de dispositivos ante SENASA."""

from datetime import UTC, date, datetime, timedelta

import pytest
from sqlalchemy import select

from api.modules.animales.models import Animal
from api.modules.categorias.models import Categoria
from api.modules.establecimientos.models import (
    Establecimiento,
    UsuarioEstablecimiento,
)
from api.modules.lotes.models import Lote
from api.reportes.service import _codigo_sexo, _nombre_archivo
from api.shared.enums import EstadoAnimal, RolUsuario, SexoAnimal

CARAVANA_OK = "123456789012345"


def test_codigo_sexo_admite_enum_y_texto_persistido():
    """La exportación acepta tanto el enum en memoria como el texto de SQL."""
    assert _codigo_sexo(SexoAnimal.macho) == "M"
    assert _codigo_sexo("macho") == "M"
    assert _codigo_sexo(SexoAnimal.hembra) == "H"
    assert _codigo_sexo("hembra") == "H"


def test_nombre_archivo_personalizado_y_predeterminado():
    """El nombre se normaliza y el vacío incorpora la fecha actual."""
    assert _nombre_archivo("Acta agosto.pdf", "txt") == "Acta_agosto.txt"
    assert _nombre_archivo("", "pdf") == (
        f"reporte_senasa_{date.today().isoformat()}.pdf"
    )


@pytest.fixture
async def datos_reporte(session, usuario_actual):
    """Establecimiento con un animal listo para declarar en SIGSA."""
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
        raza="Aberdeen Angus",
        fecha_nacimiento=date(2024, 1, 1),
        categoria_id=categoria.id,
        lote_id=lote.id,
        estado=EstadoAnimal.activo,
    )
    session.add(animal)
    await session.flush()

    await session.commit()
    return est, lote, animal


def _solicitud_declaracion(establecimiento_id, **cambios):
    """Construye el cuerpo mínimo del endpoint oficial para simplificar tests."""
    datos = {"establecimiento_id": str(establecimiento_id)}
    datos.update(cambios)
    return datos


@pytest.mark.anyio
async def test_txt_con_datos_completos(auth_client, datos_reporte):
    est, _, _ = datos_reporte
    resp = await auth_client.post(
        "/api/v1/reportes/senasa/declaraciones_dispositivos",
        json=_solicitud_declaracion(est.id),
    )
    assert resp.status_code == 200
    assert resp.headers["content-type"].startswith("text/plain")
    assert (
        f'filename="reporte_senasa_{date.today().isoformat()}.txt"'
        in resp.headers["content-disposition"]
    )
    assert "attachment" in resp.headers["content-disposition"]
    assert resp.text == f"{CARAVANA_OK}-H-AA-01/2024"


@pytest.mark.anyio
async def test_exportacion_se_lista_y_se_descarga_sin_recalcular(
    auth_client, session, datos_reporte
):
    """El historial conserva los bytes aunque luego cambien datos del animal."""
    est, _, animal = datos_reporte
    generado = await auth_client.post(
        "/api/v1/reportes/senasa/declaraciones_dispositivos",
        json=_solicitud_declaracion(est.id, nombre_archivo="declaracion_agosto"),
    )
    contenido_original = generado.content

    historial = await auth_client.get(
        f"/api/v1/reportes/senasa/exportaciones?establecimiento_id={est.id}"
    )
    assert historial.status_code == 200
    exportaciones = historial.json()["data"]
    assert len(exportaciones) == 1
    assert exportaciones[0]["nombre_archivo"] == "declaracion_agosto.txt"
    assert exportaciones[0]["cantidad_animales"] == 1
    assert exportaciones[0]["tipo_exportacion"] == "declaracion_identificacion"
    assert len(exportaciones[0]["hash_sha256"]) == 64

    # El dato vivo cambia, pero la descarga debe seguir siendo evidencia exacta.
    animal.raza = "Hereford"
    await session.commit()
    descarga = await auth_client.get(
        f"/api/v1/reportes/senasa/exportaciones/{exportaciones[0]['id']}/descarga"
    )
    assert descarga.status_code == 200
    assert descarga.content == contenido_original
    assert (
        'filename="declaracion_agosto.txt"' in descarga.headers["content-disposition"]
    )


@pytest.mark.anyio
async def test_novedad_filtra_por_creacion_y_no_por_nacimiento(
    auth_client, session, datos_reporte
):
    """Un animal nacido hace años entra si fue caravaneado recientemente."""
    est, _, animal = datos_reporte
    animal.created_at = datetime.now(UTC)
    animal.fecha_nacimiento = date(2020, 1, 1)
    await session.commit()
    desde = (datetime.now(UTC) - timedelta(days=1)).isoformat().replace("+00:00", "Z")

    respuesta = await auth_client.post(
        "/api/v1/reportes/senasa/declaraciones_dispositivos",
        json=_solicitud_declaracion(est.id, desde=desde),
    )

    assert respuesta.status_code == 200
    assert respuesta.text == f"{CARAVANA_OK}-H-AA-01/2020"


@pytest.mark.anyio
async def test_descarga_no_revela_exportacion_de_otro_establecimiento(
    auth_client, session, datos_reporte, usuario_actual
):
    """Una exportación ajena responde 404 para preservar el aislamiento tenant."""
    est, _, _ = datos_reporte
    generado = await auth_client.post(
        "/api/v1/reportes/senasa/declaraciones_dispositivos",
        json=_solicitud_declaracion(est.id),
    )
    assert generado.status_code == 200
    historial = await auth_client.get(
        f"/api/v1/reportes/senasa/exportaciones?establecimiento_id={est.id}"
    )
    exportacion_id = historial.json()["data"][0]["id"]

    # Se desactiva la membresía del usuario para simular un archivo ajeno.
    resultado = await session.execute(
        select(UsuarioEstablecimiento).where(
            UsuarioEstablecimiento.usuario_id == usuario_actual.id,
            UsuarioEstablecimiento.establecimiento_id == est.id,
        )
    )
    membresia = resultado.scalar_one()
    membresia.activo = False
    await session.commit()

    descarga = await auth_client.get(
        f"/api/v1/reportes/senasa/exportaciones/{exportacion_id}/descarga"
    )
    assert descarga.status_code == 404


@pytest.mark.anyio
async def test_pdf_con_datos_completos(auth_client, datos_reporte):
    est, _, _ = datos_reporte
    resp = await auth_client.get(
        f"/api/v1/reportes/senasa?establecimiento_id={est.id}&formato=pdf"
    )
    assert resp.status_code == 200
    assert resp.headers["content-type"] == "application/pdf"
    assert resp.content[:5] == b"%PDF-"
    # ReportLab identifica como XObject de imagen al logo incrustado en el PDF.
    assert b"/Subtype /Image" in resp.content


@pytest.mark.anyio
async def test_acta_vacunacion_ya_no_es_una_exportacion_admitida(
    auth_client, datos_reporte
):
    """El adaptador anterior rechaza actas porque VITA no puede emitirlas."""
    est, _, _ = datos_reporte
    resp = await auth_client.get(
        f"/api/v1/reportes/senasa?establecimiento_id={est.id}"
        "&formato=txt&tipo_evento=acta_vacunacion"
        "&desde=2026-05-01T00:00:00Z&hasta=2026-05-01T23:59:59Z"
    )
    assert resp.status_code == 422


@pytest.mark.anyio
async def test_txt_separa_dispositivos_con_punto_y_coma(
    auth_client, session, datos_reporte
):
    est, lote, _ = datos_reporte
    session.add(
        Animal(
            establecimiento_id=est.id,
            nro_caravana_rfid="032010000000001",
            sexo=SexoAnimal.macho,
            raza="Hereford",
            fecha_nacimiento=date(2025, 8, 1),
            lote_id=lote.id,
            estado=EstadoAnimal.activo,
        )
    )
    await session.commit()

    resp = await auth_client.post(
        "/api/v1/reportes/senasa/declaraciones_dispositivos",
        json=_solicitud_declaracion(est.id),
    )

    assert resp.status_code == 200
    assert resp.text == (f"032010000000001-M-H-08/2025;{CARAVANA_OK}-H-AA-01/2024")


@pytest.mark.anyio
async def test_validacion_bloquea_con_animal_incompleto(
    auth_client, session, datos_reporte
):
    est, lote, _ = datos_reporte
    # Un RFID inválido impide generar parcialmente un archivo oficial.
    session.add(
        Animal(
            establecimiento_id=est.id,
            nro_caravana_rfid="12345678901234A",  # longitud válida, no numérico
            sexo=SexoAnimal.macho,
            raza="Raza sin código",
            fecha_nacimiento=date(2024, 2, 2),
            lote_id=lote.id,
            estado=EstadoAnimal.activo,
        )
    )
    await session.commit()

    resp = await auth_client.post(
        "/api/v1/reportes/senasa/declaraciones_dispositivos",
        json=_solicitud_declaracion(est.id),
    )
    assert resp.status_code == 422
    error = resp.json()["errors"][0]
    assert error["code"] == "datos_incompletos_para_reporte"
    incompletos = error["details"]["animales_incompletos"]
    assert len(incompletos) == 1
    assert "nro_caravana_rfid" in incompletos[0]["faltante"]
    assert "raza" in incompletos[0]["faltante"]


@pytest.mark.anyio
async def test_reporte_sin_acceso(auth_client):
    from uuid import uuid4

    resp = await auth_client.post(
        "/api/v1/reportes/senasa/declaraciones_dispositivos",
        json=_solicitud_declaracion(uuid4()),
    )
    assert resp.status_code == 403
    assert resp.json()["errors"][0]["code"] == "establecimiento_no_autorizado"


@pytest.mark.anyio
async def test_validacion_no_crea_una_exportacion(auth_client, datos_reporte):
    """La vista previa verifica datos sin contaminar el historial auditable."""
    est, _, _ = datos_reporte
    validacion = await auth_client.post(
        "/api/v1/reportes/senasa/declaraciones_dispositivos/validacion",
        json=_solicitud_declaracion(est.id),
    )
    historial = await auth_client.get(
        f"/api/v1/reportes/senasa/exportaciones?establecimiento_id={est.id}"
    )

    assert validacion.status_code == 200
    assert validacion.json()["data"] == {
        "cantidad_exportable": 1,
        "animales_incompletos": [],
    }
    assert historial.json()["data"] == []
