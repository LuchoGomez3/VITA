"""Tests del módulo calibraciones_ml (dataset de calibración del modelo de visión).

Es módulo crítico (sync offline-first + aislamiento multi-tenant + un flujo que
cruza dos sistemas sin transacción compartida), así que los tests cubren los
criterios de aceptación de VITA-156 uno por uno: autorización, validación,
idempotencia, fallos parciales y exportación.

Ninguno toca la red: el almacén de objetos se reemplaza por un doble en memoria.
"""

import io
from datetime import UTC, date, datetime, timedelta
from decimal import Decimal
from pathlib import Path
from uuid import UUID, uuid4

import pytest
from PIL import Image
from sqlalchemy import select

from api.modules.animales.models import Animal
from api.modules.calibraciones_ml.exportacion import (
    asignar_split,
    exportar_dataset,
)
from api.modules.calibraciones_ml.exceptions import (
    ImagenDemasiadoGrandeError,
    ImagenNoEsJpegError,
)
from api.modules.calibraciones_ml.imagen import normalizar_jpeg
from api.modules.calibraciones_ml.models import MuestraCalibracion
from api.modules.calibraciones_ml.repository import MuestraCalibracionRepository
from api.modules.establecimientos.models import (
    Establecimiento,
    UsuarioEstablecimiento,
)
from api.shared.enums import (
    EstadoAnimal,
    EstadoMuestraCalibracion,
    RolUsuario,
    SexoAnimal,
)
from core.config import settings
from core.storage import StorageError, get_storage_calibraciones

# --------------------------------------------------------------------- dobles


class FakeStorage:
    """Almacén de objetos en memoria que registra lo que se le pidió.

    Guardar las claves en un dict es lo que hace verificable la idempotencia: si
    dos subidas de la misma muestra dejaran dos objetos, ``len(objetos)`` sería 2.
    """

    def __init__(self) -> None:
        self.objetos: dict[str, bytes] = {}
        self.subidas: list[str] = []
        self.borrados: list[str] = []
        self.falla_al_subir = False
        self.falla_al_borrar = False
        self.falla_al_descargar: set[str] = set()

    async def subir_jpeg(self, clave: str, datos: bytes) -> None:
        if self.falla_al_subir:
            raise StorageError("sin red")
        self.subidas.append(clave)
        self.objetos[clave] = datos

    async def descargar(self, clave: str) -> bytes:
        if clave in self.falla_al_descargar:
            raise StorageError("objeto inexistente")
        return self.objetos[clave]

    async def borrar(self, clave: str) -> None:
        self.borrados.append(clave)
        if self.falla_al_borrar:
            raise StorageError("sin red")
        self.objetos.pop(clave, None)


@pytest.fixture
def storage(app) -> FakeStorage:
    doble = FakeStorage()
    app.dependency_overrides[get_storage_calibraciones] = lambda: doble
    return doble


# -------------------------------------------------------------------- helpers


def _jpeg(ancho: int = 640, alto: int = 480, *, exif: bool = False) -> bytes:
    """JPEG real (no bytes arbitrarios): tiene que pasar el decode de Pillow."""
    imagen = Image.new("RGB", (ancho, alto), color=(90, 140, 70))
    buffer = io.BytesIO()
    if exif:
        datos_exif = Image.Exif()
        # 0x0110 = Model. Alcanza para comprobar que el re-encode lo descarta.
        datos_exif[0x0110] = "VITA-TEST"
        imagen.save(buffer, format="JPEG", exif=datos_exif)
    else:
        imagen.save(buffer, format="JPEG")
    return buffer.getvalue()


def _png() -> bytes:
    buffer = io.BytesIO()
    Image.new("RGB", (32, 32), color=(10, 10, 10)).save(buffer, format="PNG")
    return buffer.getvalue()


def _archivo(datos: bytes, nombre: str = "lateral.jpg") -> dict:
    return {"imagen": (nombre, datos, "image/jpeg")}


async def _crear_establecimiento(
    session, usuario_actual, nombre, renspa, *, miembro=True
):
    est = Establecimiento(owner_id=usuario_actual.id, nombre=nombre, nro_renspa=renspa)
    session.add(est)
    await session.flush()
    if miembro:
        session.add(
            UsuarioEstablecimiento(
                usuario_id=usuario_actual.id,
                establecimiento_id=est.id,
                rol=RolUsuario.owner,
                activo=True,
            )
        )
    return est


async def _crear_animal(session, establecimiento_id, caravana):
    animal = Animal(
        id=uuid4(),
        establecimiento_id=establecimiento_id,
        nro_caravana_rfid=caravana,
        sexo=SexoAnimal.macho,
        raza="Angus",
        fecha_nacimiento=date(2023, 1, 1),
        estado=EstadoAnimal.activo,
    )
    session.add(animal)
    return animal


@pytest.fixture
async def establecimiento_con_animal(session, usuario_actual):
    """Establecimiento con membresía activa del usuario actual + un animal."""
    est = await _crear_establecimiento(
        session, usuario_actual, "Estancia Calibracion", "01.002.3.04567"
    )
    animal = await _crear_animal(session, est.id, "123456789012345")
    await session.commit()
    return est, animal


def _payload(est_id, animal_id, **overrides) -> dict:
    base = {
        "establecimiento_id": str(est_id),
        "animal_id": str(animal_id),
        "peso_real_kg": "410.500",
        "fecha_captura": "2026-09-20T14:30:00+00:00",
    }
    base.update(overrides)
    return base


async def _crear_muestra(auth_client, est_id, animal_id, **overrides) -> dict:
    resp = await auth_client.post(
        "/api/v1/calibraciones_ml", json=_payload(est_id, animal_id, **overrides)
    )
    assert resp.status_code == 201, resp.text
    return resp.json()["data"]


# ------------------------------------------------------------ alta (metadata)


@pytest.mark.anyio
async def test_crear_muestra_nace_pendiente_de_imagen(
    auth_client, establecimiento_con_animal, usuario_actual
):
    """La metadata puede existir sin la foto: es el paso 1 del alta en dos tramos."""
    est, animal = establecimiento_con_animal
    data = await _crear_muestra(auth_client, est.id, animal.id)

    assert data["estado"] == EstadoMuestraCalibracion.pendiente_imagen.value
    assert data["imagen_key"] is None
    assert Decimal(data["peso_real_kg"]) == Decimal("410.5")
    # El responsable sale del JWT, no del payload.
    assert data["responsable_id"] == str(usuario_actual.id)


@pytest.mark.anyio
@pytest.mark.parametrize("peso", ["0", "-1", "-0.001"])
async def test_peso_real_no_positivo_se_rechaza(
    auth_client, establecimiento_con_animal, peso
):
    est, animal = establecimiento_con_animal
    resp = await auth_client.post(
        "/api/v1/calibraciones_ml", json=_payload(est.id, animal.id, peso_real_kg=peso)
    )
    assert resp.status_code == 422


@pytest.mark.anyio
async def test_animal_de_otro_establecimiento_se_rechaza(
    auth_client, session, establecimiento_con_animal, usuario_actual
):
    est, _ = establecimiento_con_animal
    otro = await _crear_establecimiento(
        session, usuario_actual, "Otro campo", "09.008.7.06543"
    )
    animal_ajeno = await _crear_animal(session, otro.id, "543210987654321")
    await session.commit()

    resp = await auth_client.post(
        "/api/v1/calibraciones_ml", json=_payload(est.id, animal_ajeno.id)
    )
    assert resp.status_code == 422
    assert resp.json()["errors"][0]["code"] == "animal_no_pertenece_establecimiento"


@pytest.mark.anyio
async def test_sin_membresia_se_deniega_y_no_se_crea_nada(
    auth_client, session, usuario_actual, storage
):
    """Criterio de aceptación: sin acceso no se crea ni objeto ni registro."""
    ajeno = await _crear_establecimiento(
        session, usuario_actual, "Campo ajeno", "11.022.3.04567", miembro=False
    )
    animal = await _crear_animal(session, ajeno.id, "999888777666555")
    await session.commit()

    resp = await auth_client.post(
        "/api/v1/calibraciones_ml", json=_payload(ajeno.id, animal.id)
    )
    assert resp.status_code == 403
    assert resp.json()["errors"][0]["code"] == "establecimiento_no_autorizado"

    filas = await session.execute(select(MuestraCalibracion))
    assert filas.scalars().all() == []
    assert storage.objetos == {}


@pytest.mark.anyio
async def test_reenviar_el_mismo_uuid_no_duplica_la_muestra(
    auth_client, session, establecimiento_con_animal
):
    """Idempotencia del replay de la cola offline."""
    est, animal = establecimiento_con_animal
    muestra_id = str(uuid4())
    ahora = datetime.now(UTC)

    primero = await _crear_muestra(
        auth_client,
        est.id,
        animal.id,
        id=muestra_id,
        updated_at=ahora.isoformat(),
    )
    segundo = await _crear_muestra(
        auth_client,
        est.id,
        animal.id,
        id=muestra_id,
        peso_real_kg="415.000",
        updated_at=(ahora + timedelta(minutes=5)).isoformat(),
    )

    assert primero["id"] == segundo["id"] == muestra_id
    # El reenvío más nuevo corrige el peso (last-write-wins).
    assert Decimal(segundo["peso_real_kg"]) == Decimal("415")

    filas = await session.execute(select(MuestraCalibracion))
    assert len(filas.scalars().all()) == 1


@pytest.mark.anyio
async def test_un_alta_rancia_no_pisa_lo_persistido(
    auth_client, establecimiento_con_animal
):
    est, animal = establecimiento_con_animal
    muestra_id = str(uuid4())
    ahora = datetime.now(UTC)

    await _crear_muestra(
        auth_client, est.id, animal.id, id=muestra_id, updated_at=ahora.isoformat()
    )
    rancio = await _crear_muestra(
        auth_client,
        est.id,
        animal.id,
        id=muestra_id,
        peso_real_kg="100.000",
        updated_at=(ahora - timedelta(hours=1)).isoformat(),
    )

    assert Decimal(rancio["peso_real_kg"]) == Decimal("410.5")


# ------------------------------------------------------------------- imagen


@pytest.mark.anyio
async def test_adjuntar_imagen_completa_la_muestra(
    auth_client, establecimiento_con_animal, storage
):
    est, animal = establecimiento_con_animal
    muestra = await _crear_muestra(auth_client, est.id, animal.id)

    resp = await auth_client.post(
        f"/api/v1/calibraciones_ml/{muestra['id']}/imagen", files=_archivo(_jpeg())
    )
    assert resp.status_code == 200, resp.text
    data = resp.json()["data"]

    clave_esperada = f"{est.id}/{muestra['id']}.jpg"
    assert data["imagen_key"] == clave_esperada
    assert data["estado"] == EstadoMuestraCalibracion.completa.value
    assert data["imagen_bytes"] == len(storage.objetos[clave_esperada])
    # La clave no depende del nombre del archivo ni de la caravana.
    assert "lateral" not in data["imagen_key"]
    assert animal.nro_caravana_rfid not in data["imagen_key"]


@pytest.mark.anyio
async def test_reenviar_la_imagen_no_duplica_el_objeto(
    auth_client, establecimiento_con_animal, storage
):
    """Criterio de aceptación: el mismo UUID no duplica la imagen."""
    est, animal = establecimiento_con_animal
    muestra = await _crear_muestra(auth_client, est.id, animal.id)
    url = f"/api/v1/calibraciones_ml/{muestra['id']}/imagen"

    assert (await auth_client.post(url, files=_archivo(_jpeg()))).status_code == 200
    assert (await auth_client.post(url, files=_archivo(_jpeg()))).status_code == 200

    assert len(storage.objetos) == 1
    assert len(storage.subidas) == 2  # se reintentó, pero sobre la misma clave


@pytest.mark.anyio
async def test_adjuntar_imagen_sin_acceso_no_toca_el_almacen(
    auth_client, session, usuario_actual, storage
):
    """Se autoriza ANTES de subir: nadie sin acceso escribe en el bucket."""
    ajeno = await _crear_establecimiento(
        session, usuario_actual, "Campo ajeno", "11.022.3.04567", miembro=False
    )
    animal = await _crear_animal(session, ajeno.id, "999888777666555")
    muestra = MuestraCalibracion(
        id=uuid4(),
        establecimiento_id=ajeno.id,
        animal_id=animal.id,
        peso_real_kg=Decimal("400"),
        fecha_captura=datetime.now(UTC),
    )
    session.add(muestra)
    await session.commit()

    resp = await auth_client.post(
        f"/api/v1/calibraciones_ml/{muestra.id}/imagen", files=_archivo(_jpeg())
    )
    assert resp.status_code == 403
    assert storage.subidas == []
    assert storage.objetos == {}


@pytest.mark.anyio
async def test_imagen_inexistente_devuelve_404(
    auth_client, establecimiento_con_animal, storage
):
    resp = await auth_client.post(
        f"/api/v1/calibraciones_ml/{uuid4()}/imagen", files=_archivo(_jpeg())
    )
    assert resp.status_code == 404
    assert storage.subidas == []


@pytest.mark.anyio
async def test_un_png_disfrazado_de_jpeg_se_rechaza(
    auth_client, establecimiento_con_animal, storage
):
    """El content_type lo declara el cliente: hay que mirar los bytes."""
    est, animal = establecimiento_con_animal
    muestra = await _crear_muestra(auth_client, est.id, animal.id)

    resp = await auth_client.post(
        f"/api/v1/calibraciones_ml/{muestra['id']}/imagen",
        files=_archivo(_png(), "mentira.jpg"),
    )
    assert resp.status_code == 422
    assert resp.json()["errors"][0]["code"] == "imagen_no_es_jpeg"
    assert storage.subidas == []


@pytest.mark.anyio
async def test_un_jpeg_truncado_se_rechaza(
    auth_client, establecimiento_con_animal, storage
):
    est, animal = establecimiento_con_animal
    muestra = await _crear_muestra(auth_client, est.id, animal.id)

    # Arranca con el magic byte correcto pero el decode falla.
    truncado = _jpeg()[:120]
    resp = await auth_client.post(
        f"/api/v1/calibraciones_ml/{muestra['id']}/imagen", files=_archivo(truncado)
    )
    assert resp.status_code == 422
    assert resp.json()["errors"][0]["code"] == "imagen_no_es_jpeg"
    assert storage.subidas == []


@pytest.mark.anyio
async def test_una_imagen_fuera_del_limite_se_rechaza(
    auth_client, establecimiento_con_animal, storage, monkeypatch
):
    est, animal = establecimiento_con_animal
    muestra = await _crear_muestra(auth_client, est.id, animal.id)
    # Bajar el techo en vez de fabricar 8 MB de JPEG.
    monkeypatch.setattr(settings, "CALIBRACION_IMAGEN_MAX_BYTES", 512)

    resp = await auth_client.post(
        f"/api/v1/calibraciones_ml/{muestra['id']}/imagen", files=_archivo(_jpeg())
    )
    assert resp.status_code == 422
    assert resp.json()["errors"][0]["code"] == "imagen_demasiado_grande"
    assert storage.subidas == []


@pytest.mark.anyio
async def test_un_archivo_vacio_se_rechaza(
    auth_client, establecimiento_con_animal, storage
):
    est, animal = establecimiento_con_animal
    muestra = await _crear_muestra(auth_client, est.id, animal.id)

    resp = await auth_client.post(
        f"/api/v1/calibraciones_ml/{muestra['id']}/imagen", files=_archivo(b"")
    )
    assert resp.status_code == 422
    assert resp.json()["errors"][0]["code"] == "imagen_vacia"
    assert storage.subidas == []


def test_normalizar_rechaza_por_bytes_reales_aunque_el_header_mienta(monkeypatch):
    """El Content-Length lo pone el cliente: el techo real se aplica a los bytes."""
    monkeypatch.setattr(settings, "CALIBRACION_IMAGEN_MAX_BYTES", 512)
    with pytest.raises(ImagenDemasiadoGrandeError):
        normalizar_jpeg(_jpeg())


def test_normalizar_rechaza_un_formato_que_arranca_con_magic_de_jpeg():
    """Los 3 bytes del SOI no alcanzan: tiene que decodificar como JPEG."""
    with pytest.raises(ImagenNoEsJpegError):
        normalizar_jpeg(b"\xff\xd8\xff" + b"no soy una imagen" * 10)


@pytest.mark.anyio
async def test_si_falla_la_subida_la_muestra_queda_pendiente(
    auth_client, session, establecimiento_con_animal, storage
):
    """Criterio de aceptación: la muestra sigue disponible para reintentar.

    El cliente recibe un 5xx (que su cola sí reintenta, a diferencia de un 4xx) y
    el registro no queda marcado como completo.
    """
    est, animal = establecimiento_con_animal
    muestra = await _crear_muestra(auth_client, est.id, animal.id)
    url = f"/api/v1/calibraciones_ml/{muestra['id']}/imagen"

    storage.falla_al_subir = True
    resp = await auth_client.post(url, files=_archivo(_jpeg()))
    assert resp.status_code == 502
    assert resp.json()["errors"][0]["code"] == "subida_de_imagen_fallida"

    persistida = await MuestraCalibracionRepository(session).get_by_id(
        UUID(muestra["id"])
    )
    # ``==`` y no ``is``: la columna es String, así que la base la devuelve como
    # str. El Enum hereda de str, con lo que la comparación sigue siendo exacta.
    assert persistida.estado == EstadoMuestraCalibracion.pendiente_imagen
    assert persistida.imagen_key is None

    # Vuelve la red: el reintento completa la muestra.
    storage.falla_al_subir = False
    assert (await auth_client.post(url, files=_archivo(_jpeg()))).status_code == 200


@pytest.mark.anyio
async def test_si_falla_la_persistencia_se_borra_el_objeto_subido(
    auth_client, establecimiento_con_animal, storage, monkeypatch
):
    """Criterio de aceptación: fallo parcial compensado, sin objetos huérfanos."""
    est, animal = establecimiento_con_animal
    muestra = await _crear_muestra(auth_client, est.id, animal.id)

    async def _explota(self, muestra):  # noqa: ANN001
        raise RuntimeError("la base se cayó justo después de subir")

    monkeypatch.setattr(MuestraCalibracionRepository, "save", _explota)

    with pytest.raises(RuntimeError):
        await auth_client.post(
            f"/api/v1/calibraciones_ml/{muestra['id']}/imagen", files=_archivo(_jpeg())
        )

    clave = f"{est.id}/{muestra['id']}.jpg"
    assert storage.subidas == [clave]
    assert storage.borrados == [clave]
    assert storage.objetos == {}


@pytest.mark.anyio
async def test_si_la_compensacion_falla_igual_propaga_el_error_original(
    auth_client, establecimiento_con_animal, storage, monkeypatch
):
    """El objeto huérfano se loguea, pero no se traga el error que ve el cliente."""
    est, animal = establecimiento_con_animal
    muestra = await _crear_muestra(auth_client, est.id, animal.id)

    async def _explota(self, muestra):  # noqa: ANN001
        raise RuntimeError("la base se cayó justo después de subir")

    monkeypatch.setattr(MuestraCalibracionRepository, "save", _explota)
    storage.falla_al_borrar = True

    with pytest.raises(RuntimeError):
        await auth_client.post(
            f"/api/v1/calibraciones_ml/{muestra['id']}/imagen", files=_archivo(_jpeg())
        )

    clave = f"{est.id}/{muestra['id']}.jpg"
    assert storage.borrados == [clave]
    # Quedó huérfano: es justamente el caso que el log tiene que delatar.
    assert clave in storage.objetos


# ------------------------------------------------- lectura, sync y edición


@pytest.mark.anyio
async def test_pull_delta_y_soft_delete(
    auth_client, establecimiento_con_animal, storage
):
    est, animal = establecimiento_con_animal
    vieja = await _crear_muestra(auth_client, est.id, animal.id)
    corte = datetime.now(UTC)
    nueva = await _crear_muestra(
        auth_client,
        est.id,
        animal.id,
        updated_at=(corte + timedelta(minutes=1)).isoformat(),
    )

    resp = await auth_client.get(
        "/api/v1/calibraciones_ml",
        params={"establecimiento_id": str(est.id), "updated_since": corte.isoformat()},
    )
    assert resp.status_code == 200
    assert [m["id"] for m in resp.json()["data"]] == [nueva["id"]]

    borrado = await auth_client.delete(f"/api/v1/calibraciones_ml/{vieja['id']}")
    assert borrado.status_code == 200
    assert borrado.json()["data"]["deleted_at"] is not None

    visibles = await auth_client.get(
        "/api/v1/calibraciones_ml", params={"establecimiento_id": str(est.id)}
    )
    assert vieja["id"] not in [m["id"] for m in visibles.json()["data"]]

    # El borrado tiene que poder viajar al cliente para que lo replique local.
    con_borrados = await auth_client.get(
        "/api/v1/calibraciones_ml",
        params={"establecimiento_id": str(est.id), "include_deleted": True},
    )
    assert vieja["id"] in [m["id"] for m in con_borrados.json()["data"]]


@pytest.mark.anyio
async def test_detalle_de_otro_tenant_devuelve_404_y_no_403(
    auth_client, session, usuario_actual
):
    """Un 403 confirmaría que la muestra existe en otro establecimiento."""
    ajeno = await _crear_establecimiento(
        session, usuario_actual, "Campo ajeno", "11.022.3.04567", miembro=False
    )
    animal = await _crear_animal(session, ajeno.id, "999888777666555")
    muestra = MuestraCalibracion(
        id=uuid4(),
        establecimiento_id=ajeno.id,
        animal_id=animal.id,
        peso_real_kg=Decimal("400"),
        fecha_captura=datetime.now(UTC),
    )
    session.add(muestra)
    await session.commit()

    resp = await auth_client.get(f"/api/v1/calibraciones_ml/{muestra.id}")
    assert resp.status_code == 404


@pytest.mark.anyio
async def test_detalle_y_filtro_por_animal(
    auth_client, session, establecimiento_con_animal
):
    est, animal = establecimiento_con_animal
    otro_animal = await _crear_animal(session, est.id, "111222333444555")
    await session.commit()

    propia = await _crear_muestra(auth_client, est.id, animal.id)
    await _crear_muestra(auth_client, est.id, otro_animal.id)

    detalle = await auth_client.get(f"/api/v1/calibraciones_ml/{propia['id']}")
    assert detalle.status_code == 200
    assert detalle.json()["data"]["animal_id"] == str(animal.id)

    # El historial de un animal: qué muestras aportó al dataset.
    filtrado = await auth_client.get(
        "/api/v1/calibraciones_ml",
        params={"establecimiento_id": str(est.id), "animal_id": str(animal.id)},
    )
    assert [m["id"] for m in filtrado.json()["data"]] == [propia["id"]]


@pytest.mark.anyio
async def test_corregir_una_muestra_aplica_los_campos_provistos(
    auth_client, establecimiento_con_animal
):
    """El caso real: se anotó mal el peso de la balanza y hay que corregirlo."""
    est, animal = establecimiento_con_animal
    muestra = await _crear_muestra(auth_client, est.id, animal.id)

    resp = await auth_client.put(
        f"/api/v1/calibraciones_ml/{muestra['id']}",
        json={
            "peso_real_kg": "425.250",
            "peso_estimado_kg": "398.000",
            "fecha_captura": "2026-09-21T08:00:00+00:00",
            "observaciones": "peso releido en la balanza",
            "updated_at": datetime.now(UTC).isoformat(),
        },
    )
    assert resp.status_code == 200
    data = resp.json()["data"]
    assert Decimal(data["peso_real_kg"]) == Decimal("425.25")
    assert Decimal(data["peso_estimado_kg"]) == Decimal("398")
    assert data["observaciones"] == "peso releido en la balanza"


@pytest.mark.anyio
async def test_peso_estimado_no_positivo_se_rechaza(
    auth_client, establecimiento_con_animal
):
    est, animal = establecimiento_con_animal
    alta = await auth_client.post(
        "/api/v1/calibraciones_ml",
        json=_payload(est.id, animal.id, peso_estimado_kg="0"),
    )
    assert alta.status_code == 422

    muestra = await _crear_muestra(auth_client, est.id, animal.id)
    edicion = await auth_client.put(
        f"/api/v1/calibraciones_ml/{muestra['id']}",
        json={"peso_estimado_kg": "-5", "updated_at": datetime.now(UTC).isoformat()},
    )
    assert edicion.status_code == 422


@pytest.mark.anyio
async def test_una_edicion_rancia_no_pisa_lo_persistido(
    auth_client, establecimiento_con_animal
):
    est, animal = establecimiento_con_animal
    muestra = await _crear_muestra(
        auth_client, est.id, animal.id, updated_at=datetime.now(UTC).isoformat()
    )

    resp = await auth_client.put(
        f"/api/v1/calibraciones_ml/{muestra['id']}",
        json={
            "peso_real_kg": "1.000",
            "updated_at": (datetime.now(UTC) - timedelta(days=1)).isoformat(),
        },
    )
    assert resp.status_code == 200
    assert Decimal(resp.json()["data"]["peso_real_kg"]) == Decimal("410.5")


@pytest.mark.anyio
async def test_operar_sobre_una_muestra_inexistente_devuelve_404(auth_client):
    inexistente = uuid4()
    for llamada in (
        auth_client.get(f"/api/v1/calibraciones_ml/{inexistente}"),
        auth_client.put(
            f"/api/v1/calibraciones_ml/{inexistente}", json={"peso_real_kg": "400.000"}
        ),
        auth_client.delete(f"/api/v1/calibraciones_ml/{inexistente}"),
    ):
        assert (await llamada).status_code == 404


@pytest.mark.anyio
async def test_el_cliente_no_puede_marcar_una_muestra_como_completa(
    auth_client, establecimiento_con_animal
):
    """Si pudiera, colaría en el dataset una muestra sin foto."""
    est, animal = establecimiento_con_animal
    muestra = await _crear_muestra(auth_client, est.id, animal.id)

    resp = await auth_client.put(
        f"/api/v1/calibraciones_ml/{muestra['id']}",
        json={"estado": "completa", "updated_at": datetime.now(UTC).isoformat()},
    )
    assert resp.status_code == 422


@pytest.mark.anyio
async def test_el_cliente_puede_descartar_una_muestra(
    auth_client, establecimiento_con_animal
):
    est, animal = establecimiento_con_animal
    muestra = await _crear_muestra(auth_client, est.id, animal.id)

    resp = await auth_client.put(
        f"/api/v1/calibraciones_ml/{muestra['id']}",
        json={"estado": "descartada", "updated_at": datetime.now(UTC).isoformat()},
    )
    assert resp.status_code == 200
    assert resp.json()["data"]["estado"] == EstadoMuestraCalibracion.descartada.value


# ------------------------------------------------- normalización de imagen


@pytest.mark.anyio
async def test_normalizar_jpeg_reduce_el_lado_mayor_y_descarta_el_exif():
    """Lo que protege el 1 GB del plan free y el GPS del productor."""
    original = _jpeg(4000, 3000, exif=True)
    normalizada = normalizar_jpeg(original)

    with Image.open(io.BytesIO(normalizada)) as imagen:
        assert max(imagen.size) <= settings.CALIBRACION_IMAGEN_LADO_MAX
        # Relación de aspecto preservada: el modelo infiere sobre la proporción
        # del cuerpo del animal.
        assert imagen.size[0] / imagen.size[1] == pytest.approx(4000 / 3000, abs=0.01)
        assert not dict(imagen.getexif())

    assert len(normalizada) < len(original)


@pytest.mark.anyio
async def test_normalizar_jpeg_no_agranda_una_foto_chica():
    chica = _jpeg(320, 240)
    with Image.open(io.BytesIO(normalizar_jpeg(chica))) as imagen:
        assert imagen.size == (320, 240)


# ------------------------------------------------------------- exportación


def test_asignar_split_es_estable_y_reparte_los_tres_conjuntos():
    animal = uuid4()
    assert asignar_split(animal) == asignar_split(animal)

    repartos = {asignar_split(uuid4()) for _ in range(300)}
    assert repartos == {"train", "validation", "test"}


@pytest.mark.anyio
async def test_exportar_no_mezcla_establecimientos_ni_parte_un_animal(
    session, usuario_actual, tmp_path: Path
):
    """Criterio de aceptación de la salida para entrenamiento.

    Dos establecimientos, y un animal con tres fotos: el CSV tiene que traer solo
    el establecimiento pedido y las tres fotos del animal en el MISMO split (si
    no, el modelo vería en validación un animal que ya memorizó).
    """
    propio = await _crear_establecimiento(
        session, usuario_actual, "Propio", "01.002.3.04567"
    )
    ajeno = await _crear_establecimiento(
        session, usuario_actual, "Ajeno", "09.008.7.06543"
    )
    animal_propio = await _crear_animal(session, propio.id, "123456789012345")
    animal_ajeno = await _crear_animal(session, ajeno.id, "543210987654321")
    await session.flush()

    storage = FakeStorage()
    esperadas = []
    for indice in range(3):
        muestra = MuestraCalibracion(
            id=uuid4(),
            establecimiento_id=propio.id,
            animal_id=animal_propio.id,
            peso_real_kg=Decimal("410.500"),
            fecha_captura=datetime.now(UTC) + timedelta(minutes=indice),
            imagen_key=f"{propio.id}/foto-{indice}.jpg",
            estado=EstadoMuestraCalibracion.completa,
        )
        storage.objetos[muestra.imagen_key] = _jpeg(64, 64)
        session.add(muestra)
        esperadas.append(muestra)

    # Ruido que NO debe aparecer: otro tenant, una pendiente y una borrada.
    for establecimiento, animal, estado, borrada in (
        (ajeno, animal_ajeno, EstadoMuestraCalibracion.completa, False),
        (propio, animal_propio, EstadoMuestraCalibracion.pendiente_imagen, False),
        (propio, animal_propio, EstadoMuestraCalibracion.completa, True),
    ):
        ruido = MuestraCalibracion(
            id=uuid4(),
            establecimiento_id=establecimiento.id,
            animal_id=animal.id,
            peso_real_kg=Decimal("380"),
            fecha_captura=datetime.now(UTC),
            imagen_key=f"{establecimiento.id}/ruido-{uuid4()}.jpg",
            estado=estado,
            deleted_at=datetime.now(UTC) if borrada else None,
        )
        storage.objetos[ruido.imagen_key] = _jpeg(64, 64)
        session.add(ruido)
    await session.commit()

    muestras = await MuestraCalibracionRepository(session).list_exportables(propio.id)
    assert {m.id for m in muestras} == {m.id for m in esperadas}

    resumen = await exportar_dataset(muestras, storage, tmp_path / "ds")
    assert resumen.exportadas == 3
    assert resumen.fallidas == []

    filas = resumen.ruta_csv.read_text(encoding="utf-8").strip().splitlines()
    assert filas[0] == "ruta_local,peso_real_kg,animal_id,split"
    assert len(filas) == 4

    splits = set()
    for fila in filas[1:]:
        ruta, peso, animal_id, split = fila.split(",")
        assert animal_id == str(animal_propio.id)
        assert peso == "410.500"
        # La ruta es relativa y el archivo existe: el pipeline lee disco local.
        assert (resumen.directorio / ruta).is_file()
        splits.add(split)
    assert len(splits) == 1


@pytest.mark.anyio
async def test_exportar_respeta_el_rango_de_fechas(session, usuario_actual):
    """``--desde/--hasta`` sirve para reentrenar solo con la campaña nueva."""
    est = await _crear_establecimiento(
        session, usuario_actual, "Propio", "01.002.3.04567"
    )
    animal = await _crear_animal(session, est.id, "123456789012345")
    await session.flush()

    vieja, nueva = (
        datetime(2026, 5, 1, tzinfo=UTC),
        datetime(2026, 9, 1, tzinfo=UTC),
    )
    for fecha in (vieja, nueva):
        session.add(
            MuestraCalibracion(
                id=uuid4(),
                establecimiento_id=est.id,
                animal_id=animal.id,
                peso_real_kg=Decimal("400"),
                fecha_captura=fecha,
                imagen_key=f"{est.id}/{fecha:%Y%m%d}.jpg",
                estado=EstadoMuestraCalibracion.completa,
            )
        )
    await session.commit()

    repo = MuestraCalibracionRepository(session)
    desde_julio = await repo.list_exportables(
        est.id, desde=datetime(2026, 7, 1, tzinfo=UTC)
    )
    assert [m.fecha_captura.date() for m in desde_julio] == [nueva.date()]

    hasta_julio = await repo.list_exportables(
        est.id, hasta=datetime(2026, 7, 1, tzinfo=UTC)
    )
    assert [m.fecha_captura.date() for m in hasta_julio] == [vieja.date()]


@pytest.mark.anyio
async def test_exportar_omite_la_imagen_que_no_baja_y_sigue(
    session, usuario_actual, tmp_path: Path
):
    """Una foto borrada a mano no debe impedir entrenar con el resto."""
    est = await _crear_establecimiento(
        session, usuario_actual, "Propio", "01.002.3.04567"
    )
    animal = await _crear_animal(session, est.id, "123456789012345")
    await session.flush()

    storage = FakeStorage()
    muestras = []
    for indice in range(2):
        muestra = MuestraCalibracion(
            id=uuid4(),
            establecimiento_id=est.id,
            animal_id=animal.id,
            peso_real_kg=Decimal("400"),
            fecha_captura=datetime.now(UTC) + timedelta(minutes=indice),
            imagen_key=f"{est.id}/foto-{indice}.jpg",
            estado=EstadoMuestraCalibracion.completa,
        )
        storage.objetos[muestra.imagen_key] = _jpeg(64, 64)
        session.add(muestra)
        muestras.append(muestra)
    await session.commit()

    storage.falla_al_descargar = {muestras[0].imagen_key}
    resumen = await exportar_dataset(muestras, storage, tmp_path / "ds")

    assert resumen.exportadas == 1
    assert resumen.fallidas == [muestras[0].id]
    filas = resumen.ruta_csv.read_text(encoding="utf-8").strip().splitlines()
    assert len(filas) == 2
