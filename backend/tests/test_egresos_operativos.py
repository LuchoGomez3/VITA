"""Aceptación backend de registro y sincronización de egresos operativos."""

from datetime import UTC, date, datetime, timedelta
from uuid import UUID, uuid4

import pytest
from sqlalchemy import select

from api.modules.egresos_operativos.models import EgresoOperativo
from api.modules.establecimientos.models import Establecimiento, UsuarioEstablecimiento
from api.shared.enums import RolUsuario


@pytest.fixture
async def establecimiento_habilitado(session, usuario_actual):
    """Crea un tenant con RENSPA y membresía activa para el usuario autenticado."""
    establecimiento = Establecimiento(
        owner_id=usuario_actual.id,
        nombre="Campo de aceptación",
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
    await session.commit()
    return establecimiento


def payload(establecimiento_id, **cambios):
    """Arma un comprobante sintético válido y permite variar un criterio por prueba."""
    datos = {
        "establecimiento_id": str(establecimiento_id),
        "monto": "150000.00",
        "tipo": "costo_produccion",
        "categoria": "sanidad",
        "insumo": "Vacunas reproductivas",
        "fecha": date.today().isoformat(),
        "descripcion": "Compra para campaña anual",
        "numero_comprobante": "FC-A-0001-00000001",
    }
    datos.update(cambios)
    return datos


@pytest.mark.anyio
async def test_registro_online_persiste_y_audita(
    auth_client, session, establecimiento_habilitado, usuario_actual
):
    """El costo online queda centralizado con importe, tenant y autor del JWT."""
    respuesta = await auth_client.post(
        "/api/v1/egresos_operativos",
        json=payload(establecimiento_habilitado.id),
    )

    assert respuesta.status_code == 201
    egreso = respuesta.json()["data"]
    assert egreso["monto"] == "150000.00"
    assert egreso["cargado_por_id"] == str(usuario_actual.id)
    assert egreso["cargado_por"]["email"] == usuario_actual.email
    assert egreso["created_at"] and egreso["updated_at"]

    resultado = await session.execute(
        select(EgresoOperativo).where(EgresoOperativo.id == UUID(egreso["id"]))
    )
    assert resultado.scalar_one().establecimiento_id == establecimiento_habilitado.id


@pytest.mark.anyio
@pytest.mark.parametrize("monto", ["0", "-1"])
async def test_monto_no_positivo_es_rechazado(
    auth_client, establecimiento_habilitado, monto
):
    """Cero y negativos se bloquean con el texto definido en aceptación."""
    respuesta = await auth_client.post(
        "/api/v1/egresos_operativos",
        json=payload(establecimiento_habilitado.id, monto=monto),
    )
    assert respuesta.status_code == 422
    assert "El monto ingresado debe ser un valor mayor a cero" in respuesta.text


@pytest.mark.anyio
async def test_fecha_futura_es_rechazada(auth_client, establecimiento_habilitado):
    """La API protege la regla incluso si un cliente no limita su date picker."""
    manana = date.today() + timedelta(days=1)
    respuesta = await auth_client.post(
        "/api/v1/egresos_operativos",
        json=payload(establecimiento_habilitado.id, fecha=manana.isoformat()),
    )
    assert respuesta.status_code == 422
    assert "No se pueden registrar egresos con fecha futura" in respuesta.text


@pytest.mark.anyio
async def test_categoria_de_otro_tipo_es_rechazada(
    auth_client, establecimiento_habilitado
):
    """Combustible no puede contabilizarse accidentalmente como costo productivo."""
    respuesta = await auth_client.post(
        "/api/v1/egresos_operativos",
        json=payload(establecimiento_habilitado.id, categoria="combustible"),
    )
    assert respuesta.status_code == 422
    assert "La categoría no corresponde" in respuesta.text


@pytest.mark.anyio
async def test_datos_obligatorios_omitidos_no_persisten(
    auth_client, session, establecimiento_habilitado
):
    """Tipo, categoría e insumo faltantes producen 422 sin crear filas."""
    datos = payload(establecimiento_habilitado.id)
    for campo in ("tipo", "categoria", "insumo"):
        datos.pop(campo)
    respuesta = await auth_client.post("/api/v1/egresos_operativos", json=datos)
    assert respuesta.status_code == 422
    filas = (await session.execute(select(EgresoOperativo))).scalars().all()
    assert filas == []


@pytest.mark.anyio
async def test_establecimiento_ajeno_es_rechazado(auth_client):
    """La membresía activa es obligatoria y evita cruces multi-tenant."""
    respuesta = await auth_client.post(
        "/api/v1/egresos_operativos", json=payload(uuid4())
    )
    assert respuesta.status_code == 403
    assert respuesta.json()["errors"][0]["code"] == "establecimiento_no_autorizado"


@pytest.mark.anyio
async def test_reintento_offline_es_idempotente_y_aplica_lww(
    auth_client, session, establecimiento_habilitado
):
    """Un UUID local se sube una sola vez y la mutación más nueva gana."""
    identificador = uuid4()
    instante_viejo = datetime(2026, 1, 1, tzinfo=UTC)
    instante_nuevo = datetime(2026, 1, 2, tzinfo=UTC)
    await auth_client.post(
        "/api/v1/egresos_operativos",
        json=payload(
            establecimiento_habilitado.id,
            id=str(identificador),
            updated_at=instante_viejo.isoformat(),
        ),
    )
    respuesta = await auth_client.post(
        "/api/v1/egresos_operativos",
        json=payload(
            establecimiento_habilitado.id,
            id=str(identificador),
            monto="45000.00",
            updated_at=instante_nuevo.isoformat(),
        ),
    )
    assert respuesta.status_code == 201
    assert respuesta.json()["data"]["monto"] == "45000.00"
    filas = (
        (
            await session.execute(
                select(EgresoOperativo).where(EgresoOperativo.id == identificador)
            )
        )
        .scalars()
        .all()
    )
    assert len(filas) == 1


@pytest.mark.anyio
async def test_historial_incluye_auditoria_y_pull_delta(
    auth_client, establecimiento_habilitado, usuario_actual
):
    """El listado informa autor y admite descargar solo cambios posteriores."""
    instante = datetime.now(UTC) - timedelta(minutes=1)
    await auth_client.post(
        "/api/v1/egresos_operativos",
        json=payload(establecimiento_habilitado.id),
    )
    respuesta = await auth_client.get(
        "/api/v1/egresos_operativos",
        params={
            "establecimiento_id": str(establecimiento_habilitado.id),
            "updated_since": instante.isoformat(),
        },
    )
    assert respuesta.status_code == 200
    historial = respuesta.json()["data"]
    assert len(historial) == 1
    assert historial[0]["cargado_por"]["id"] == str(usuario_actual.id)


@pytest.mark.anyio
async def test_catalogo_esta_tipificado(auth_client, establecimiento_habilitado):
    """El cliente puede construir selectores dependientes sin duplicar reglas."""
    respuesta = await auth_client.get(
        "/api/v1/egresos_operativos/catalogo",
        params={"establecimiento_id": str(establecimiento_habilitado.id)},
    )
    assert respuesta.status_code == 200
    tipos = {item["valor"]: item for item in respuesta.json()["data"]}
    categorias_costo = {
        item["valor"] for item in tipos["costo_produccion"]["categorias"]
    }
    assert categorias_costo == {"sanidad", "alimentacion", "identificacion"}


@pytest.mark.anyio
async def test_crear_categoria_personalizada_y_usarla(
    auth_client, establecimiento_habilitado
):
    """Una categoría nueva aparece en el catálogo y puede clasificar un egreso."""
    creada = await auth_client.post(
        "/api/v1/egresos_operativos/categorias",
        json={
            "establecimiento_id": str(establecimiento_habilitado.id),
            "tipo": "costo_produccion",
            "nombre": "Mantenimiento de mangas",
        },
    )
    assert creada.status_code == 201
    assert creada.json()["data"]["valor"] == "mantenimiento_de_mangas"

    egreso = await auth_client.post(
        "/api/v1/egresos_operativos",
        json=payload(
            establecimiento_habilitado.id,
            categoria="mantenimiento_de_mangas",
            insumo="Repuestos de cepo",
        ),
    )
    assert egreso.status_code == 201
    assert egreso.json()["data"]["categoria"] == "mantenimiento_de_mangas"

    catalogo = await auth_client.get(
        "/api/v1/egresos_operativos/catalogo",
        params={"establecimiento_id": str(establecimiento_habilitado.id)},
    )
    tipos = {item["valor"]: item for item in catalogo.json()["data"]}
    personalizadas = [
        item
        for item in tipos["costo_produccion"]["categorias"]
        if item["personalizada"]
    ]
    assert personalizadas == [
        {
            "valor": "mantenimiento_de_mangas",
            "etiqueta": "Mantenimiento de mangas",
            "personalizada": True,
        }
    ]


@pytest.mark.anyio
async def test_categoria_personalizada_respeta_tipo_y_establecimiento(
    auth_client, establecimiento_habilitado
):
    """Una categoría custom no puede cruzarse de tipo ni utilizarse en otro tenant."""
    await auth_client.post(
        "/api/v1/egresos_operativos/categorias",
        json={
            "establecimiento_id": str(establecimiento_habilitado.id),
            "tipo": "gasto_administrativo",
            "nombre": "Servicios bancarios",
        },
    )
    tipo_incorrecto = await auth_client.post(
        "/api/v1/egresos_operativos",
        json=payload(
            establecimiento_habilitado.id,
            tipo="costo_produccion",
            categoria="servicios_bancarios",
        ),
    )
    assert tipo_incorrecto.status_code == 422
    assert tipo_incorrecto.json()["errors"][0]["code"] == "categoria_egreso_invalida"


@pytest.mark.anyio
async def test_categoria_personalizada_duplicada_es_rechazada(
    auth_client, establecimiento_habilitado
):
    """Mayúsculas, espacios y tildes no permiten duplicar la misma categoría."""
    datos = {
        "establecimiento_id": str(establecimiento_habilitado.id),
        "tipo": "gasto_administrativo",
        "nombre": "Reparación eléctrica",
    }
    assert (
        await auth_client.post("/api/v1/egresos_operativos/categorias", json=datos)
    ).status_code == 201
    datos["nombre"] = "  REPARACION   ELECTRICA "
    duplicada = await auth_client.post(
        "/api/v1/egresos_operativos/categorias", json=datos
    )
    assert duplicada.status_code == 409
    assert duplicada.json()["errors"][0]["code"] == "categoria_egreso_duplicada"
