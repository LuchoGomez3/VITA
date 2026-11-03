"""Personalización del propio perfil: color de la cabecera y foto (adr-0011).

El bucket se reemplaza por un doble en memoria: ningún test toca Supabase.
"""

import io

from PIL import Image
import pytest
from sqlalchemy import select

from api.auth.dependencies import get_current_user
from api.auth.providers.local_provider import LocalAuthProvider
from api.modules.usuarios.avatar import leer_con_limite, normalizar_avatar
from api.modules.usuarios.exceptions import ImagenDemasiadoGrandeError
from api.modules.usuarios.models import Usuario
from core.config import settings
from core.storage import StorageError, get_storage_avatares

_PERFIL = "/api/v1/usuarios/me"
_AVATAR = "/api/v1/usuarios/me/avatar"

# Tag EXIF de la orientación y del bloque GPS.
_EXIF_ORIENTACION = 0x0112
_EXIF_GPS = 0x8825


class _StorageEnMemoria:
    """Doble del bucket: guarda los objetos en un dict."""

    def __init__(self) -> None:
        self.objetos: dict[str, bytes] = {}
        self.falla = False

    async def subir_jpeg(self, clave: str, datos: bytes) -> None:
        if self.falla:
            raise StorageError("caído")
        self.objetos[clave] = datos

    async def descargar(self, clave: str) -> bytes:
        if self.falla or clave not in self.objetos:
            raise StorageError("no está")
        return self.objetos[clave]

    async def borrar(self, clave: str) -> None:
        if self.falla:
            raise StorageError("caído")
        self.objetos.pop(clave, None)


@pytest.fixture
def storage(app) -> _StorageEnMemoria:
    doble = _StorageEnMemoria()
    app.dependency_overrides[get_storage_avatares] = lambda: doble
    return doble


def _jpeg(ancho: int = 1200, alto: int = 800, *, con_exif: bool = True) -> bytes:
    """Foto sintética como la de una cámara: con orientación y GPS en el EXIF."""
    imagen = Image.new("RGB", (ancho, alto), (46, 125, 50))
    salida = io.BytesIO()
    if con_exif:
        exif = Image.Exif()
        exif[_EXIF_ORIENTACION] = 6
        exif[_EXIF_GPS] = {1: "S", 2: (33.0, 7.0, 0.0)}
        imagen.save(salida, format="JPEG", exif=exif)
    else:
        imagen.save(salida, format="JPEG")
    return salida.getvalue()


def _archivo(datos: bytes, tipo: str = "image/jpeg") -> dict:
    return {"archivo": ("foto.jpg", datos, tipo)}


async def _usuario_en_base(session_maker, usuario_id) -> Usuario:
    async with session_maker() as s:
        return (
            await s.execute(select(Usuario).where(Usuario.id == usuario_id))
        ).scalar_one()


# ------------------------------------------------------------------ color


@pytest.mark.anyio
@pytest.mark.parametrize(
    ("enviado", "guardado"), [("#2e7d32", "#2E7D32"), (" #A1B2C3 ", "#A1B2C3")]
)
async def test_guarda_el_color_normalizado(
    auth_client, usuario_actual, session_maker, enviado, guardado
):
    resp = await auth_client.patch(_PERFIL, json={"color_cabecera": enviado})

    assert resp.status_code == 200
    assert resp.json()["data"]["color_cabecera"] == guardado
    assert (
        await _usuario_en_base(session_maker, usuario_actual.id)
    ).color_cabecera == guardado


@pytest.mark.anyio
async def test_null_vuelve_al_color_por_defecto(
    auth_client, usuario_actual, session_maker
):
    await auth_client.patch(_PERFIL, json={"color_cabecera": "#123456"})

    resp = await auth_client.patch(_PERFIL, json={"color_cabecera": None})

    assert resp.status_code == 200
    assert resp.json()["data"]["color_cabecera"] is None
    assert (
        await _usuario_en_base(session_maker, usuario_actual.id)
    ).color_cabecera is None


@pytest.mark.anyio
@pytest.mark.parametrize(
    "color", ["verde", "#12345", "#1234567", "#GG0000", "123456", ""]
)
async def test_rechaza_un_color_mal_escrito(auth_client, color):
    resp = await auth_client.patch(_PERFIL, json={"color_cabecera": color})

    assert resp.status_code == 422
    assert "#RRGGBB" in resp.text


@pytest.mark.anyio
async def test_el_color_es_obligatorio_en_el_body(auth_client):
    """Un body vacío no es "volver al verde": se tiene que mandar ``null``."""
    resp = await auth_client.patch(_PERFIL, json={})

    assert resp.status_code == 422


# ------------------------------------------------------------------ foto


@pytest.mark.anyio
async def test_sube_la_foto_cuadrada_chica_y_sin_metadatos(
    auth_client, usuario_actual, storage, session_maker
):
    resp = await auth_client.put(_AVATAR, files=_archivo(_jpeg()))

    assert resp.status_code == 200
    assert resp.json()["data"]["avatar_actualizado_en"] is not None
    assert list(storage.objetos) == [f"{usuario_actual.id}.jpg"]
    subida = storage.objetos[f"{usuario_actual.id}.jpg"]
    assert len(subida) < 1024 * 1024
    with Image.open(io.BytesIO(subida)) as imagen:
        assert imagen.format == "JPEG"
        assert imagen.size == (512, 512)
        # Sin EXIF: ni la orientación (ya aplicada) ni el GPS.
        assert len(imagen.getexif()) == 0
    usuario = await _usuario_en_base(session_maker, usuario_actual.id)
    assert usuario.avatar_actualizado_en is not None


@pytest.mark.anyio
async def test_una_foto_chica_no_se_agranda(auth_client, usuario_actual, storage):
    await auth_client.put(_AVATAR, files=_archivo(_jpeg(300, 200, con_exif=False)))

    with Image.open(io.BytesIO(storage.objetos[f"{usuario_actual.id}.jpg"])) as imagen:
        assert imagen.size == (200, 200)


@pytest.mark.anyio
async def test_subir_otra_foto_reemplaza_la_anterior(
    auth_client, usuario_actual, storage
):
    primera = await auth_client.put(_AVATAR, files=_archivo(_jpeg()))
    segunda = await auth_client.put(
        _AVATAR, files=_archivo(_jpeg(900, 900, con_exif=False))
    )

    assert segunda.status_code == 200
    assert list(storage.objetos) == [f"{usuario_actual.id}.jpg"]
    assert (
        segunda.json()["data"]["avatar_actualizado_en"]
        > primera.json()["data"]["avatar_actualizado_en"]
    )


@pytest.mark.anyio
@pytest.mark.parametrize(
    ("datos", "codigo"),
    [
        (b"", "imagen_vacia"),
        (b"GIF89a" + b"0" * 100, "avatar_formato_invalido"),
        (b"\x89PNG\r\n\x1a\n" + b"0" * 100, "avatar_formato_invalido"),
        (b"\xff\xd8\xff" + b"truncado", "avatar_formato_invalido"),
    ],
)
async def test_rechaza_lo_que_no_es_una_foto_valida(
    auth_client, storage, datos, codigo
):
    resp = await auth_client.put(_AVATAR, files=_archivo(datos))

    assert resp.status_code == 422
    assert resp.json()["errors"][0]["code"] == codigo
    assert storage.objetos == {}


@pytest.mark.anyio
async def test_rechaza_otro_formato_con_un_mensaje_claro(auth_client, storage):
    salida = io.BytesIO()
    Image.new("RGB", (64, 64)).save(salida, format="GIF")

    resp = await auth_client.put(
        _AVATAR, files=_archivo(salida.getvalue(), "image/gif")
    )

    assert resp.status_code == 422
    assert (
        resp.json()["errors"][0]["message"] == "La foto tiene que ser JPEG, PNG o WebP."
    )


@pytest.mark.anyio
async def test_un_png_con_transparencia_se_guarda_como_jpeg_sobre_blanco(
    auth_client, usuario_actual, storage
):
    # Mitad izquierda transparente, mitad derecha roja opaca.
    imagen = Image.new("RGBA", (600, 600), (0, 0, 0, 0))
    imagen.paste((200, 0, 0, 255), (300, 0, 600, 600))
    salida = io.BytesIO()
    imagen.save(salida, format="PNG")

    resp = await auth_client.put(
        _AVATAR, files=_archivo(salida.getvalue(), "image/png")
    )

    assert resp.status_code == 200
    with Image.open(
        io.BytesIO(storage.objetos[f"{usuario_actual.id}.jpg"])
    ) as guardada:
        assert guardada.format == "JPEG"
        assert guardada.mode == "RGB"
        assert guardada.size == (512, 512)
        izquierda = guardada.getpixel((50, 256))
        derecha = guardada.getpixel((460, 256))
    # Lo transparente queda blanco (no negro) y lo opaco conserva su color.
    assert min(izquierda) > 240
    assert derecha[0] > 180 and derecha[1] < 40


@pytest.mark.anyio
async def test_un_webp_se_guarda_como_jpeg(auth_client, usuario_actual, storage):
    salida = io.BytesIO()
    Image.new("RGB", (700, 500), (21, 101, 192)).save(salida, format="WEBP")

    resp = await auth_client.put(
        _AVATAR, files=_archivo(salida.getvalue(), "image/webp")
    )

    assert resp.status_code == 200
    with Image.open(
        io.BytesIO(storage.objetos[f"{usuario_actual.id}.jpg"])
    ) as guardada:
        assert guardada.format == "JPEG"
        assert guardada.size == (500, 500)


@pytest.mark.anyio
async def test_rechaza_una_foto_demasiado_grande(auth_client, storage, monkeypatch):
    monkeypatch.setattr(settings, "AVATAR_IMAGEN_MAX_BYTES", 1000)

    resp = await auth_client.put(_AVATAR, files=_archivo(_jpeg()))

    assert resp.status_code == 413
    assert resp.json()["errors"][0]["code"] == "imagen_demasiado_grande"
    assert storage.objetos == {}


def test_el_limite_tambien_se_aplica_a_los_bytes_reales(monkeypatch):
    """El ``Content-Length`` lo pone el cliente: el control que manda es este."""
    monkeypatch.setattr(settings, "AVATAR_IMAGEN_MAX_BYTES", 1000)

    with pytest.raises(ImagenDemasiadoGrandeError):
        normalizar_avatar(_jpeg())


@pytest.mark.anyio
async def test_rechaza_una_foto_liviana_con_dimensiones_enormes(
    auth_client, storage, monkeypatch
):
    """Un PNG liso pesa pocos KB aunque mida 13.000 px por lado: se rechaza por
    las dimensiones del encabezado, antes de decodificarlo."""
    monkeypatch.setattr(settings, "AVATAR_IMAGEN_MAX_PIXELES", 100 * 100)
    salida = io.BytesIO()
    Image.new("RGB", (101, 100), (46, 125, 50)).save(salida, format="PNG")

    resp = await auth_client.put(
        _AVATAR, files=_archivo(salida.getvalue(), "image/png")
    )

    assert resp.status_code == 422
    assert resp.json()["errors"][0]["code"] == "avatar_dimensiones_excesivas"
    assert storage.objetos == {}


class _ArchivoSubido:
    """Doble de ``UploadFile`` que registra cuánto se le pidió leer."""

    def __init__(self, datos: bytes) -> None:
        self._datos = datos
        self.pedidos: list[int] = []

    async def read(self, size: int = -1) -> bytes:
        self.pedidos.append(size)
        return self._datos if size < 0 else self._datos[:size]


@pytest.mark.anyio
async def test_lee_el_archivo_sin_pasar_del_limite(monkeypatch):
    """Sin ``Content-Length`` el archivo se lee con tope, nunca entero."""
    monkeypatch.setattr(settings, "AVATAR_IMAGEN_MAX_BYTES", 1000)
    archivo = _ArchivoSubido(b"x" * 5000)

    with pytest.raises(ImagenDemasiadoGrandeError):
        await leer_con_limite(archivo)

    assert archivo.pedidos == [1001]


@pytest.mark.anyio
async def test_el_middleware_de_camel_case_no_lee_los_archivos():
    """Si el middleware leyera el multipart, la foto entera pasaría a memoria
    antes de que el endpoint aplique su límite."""
    from starlette.requests import Request

    from core.middlewares import camel_case_to_snake_case_middleware

    async def receive():
        raise AssertionError("el middleware leyó el cuerpo del multipart")

    request = Request(
        {
            "type": "http",
            "method": "PUT",
            "path": _AVATAR,
            "headers": [(b"content-type", b"multipart/form-data; boundary=x")],
        },
        receive,
    )

    async def call_next(_request):
        return "siguiente"

    assert await camel_case_to_snake_case_middleware(request, call_next) == "siguiente"


@pytest.mark.anyio
async def test_si_storage_falla_no_cambia_la_fecha(
    auth_client, usuario_actual, storage, session_maker
):
    storage.falla = True

    resp = await auth_client.put(_AVATAR, files=_archivo(_jpeg()))

    assert resp.status_code == 502
    assert resp.json()["errors"][0]["code"] == "almacenamiento_de_avatar_fallido"
    # Sin detalle del proveedor en la respuesta.
    assert "caído" not in resp.text
    assert (
        await _usuario_en_base(session_maker, usuario_actual.id)
    ).avatar_actualizado_en is None


@pytest.mark.anyio
async def test_get_sin_foto_devuelve_404(auth_client, storage):
    resp = await auth_client.get(_AVATAR)

    assert resp.status_code == 404
    assert resp.json()["errors"][0]["code"] == "avatar_no_encontrado"


@pytest.mark.anyio
async def test_get_devuelve_la_foto_guardada(auth_client, usuario_actual, storage):
    await auth_client.put(_AVATAR, files=_archivo(_jpeg()))

    resp = await auth_client.get(_AVATAR)

    assert resp.status_code == 200
    assert resp.headers["content-type"] == "image/jpeg"
    assert resp.headers["cache-control"].startswith("private")
    assert resp.content == storage.objetos[f"{usuario_actual.id}.jpg"]


@pytest.mark.anyio
async def test_delete_borra_la_foto_y_es_idempotente(
    auth_client, usuario_actual, storage, session_maker
):
    await auth_client.put(_AVATAR, files=_archivo(_jpeg()))

    primera = await auth_client.delete(_AVATAR)
    segunda = await auth_client.delete(_AVATAR)

    assert primera.status_code == segunda.status_code == 200
    assert primera.json()["data"]["avatar_actualizado_en"] is None
    assert storage.objetos == {}
    assert (
        await _usuario_en_base(session_maker, usuario_actual.id)
    ).avatar_actualizado_en is None


@pytest.mark.anyio
async def test_delete_borra_una_foto_huerfana_sin_fecha(
    auth_client, usuario_actual, storage
):
    """Si una subida llegó al bucket pero no a la base, "Quitar foto" la borra."""
    storage.objetos[f"{usuario_actual.id}.jpg"] = b"foto-huerfana"

    resp = await auth_client.delete(_AVATAR)

    assert resp.status_code == 200
    assert storage.objetos == {}


@pytest.mark.anyio
@pytest.mark.parametrize(
    ("metodo", "ruta"),
    [("PATCH", _PERFIL), ("PUT", _AVATAR), ("GET", _AVATAR), ("DELETE", _AVATAR)],
)
async def test_exige_autenticacion(client, storage, metodo, ruta):
    resp = await client.request(metodo, ruta)

    assert resp.status_code == 401


# ------------------------------------------------------------------ sesión


@pytest.mark.anyio
async def test_me_y_refresh_devuelven_la_personalizacion(
    client, auth_client, usuario_actual, storage
):
    await auth_client.patch(_PERFIL, json={"color_cabecera": "#1565C0"})
    await auth_client.put(_AVATAR, files=_archivo(_jpeg()))
    token = LocalAuthProvider().create_token_for(usuario_actual.id)
    # ``auth_client`` sobreescribe ``get_current_user`` en la app compartida.
    client._transport.app.dependency_overrides.pop(get_current_user)

    me = await client.get("/api/auth/me", headers={"Authorization": f"Bearer {token}"})
    refresh = await client.post(
        "/api/auth/refresh",
        json={
            "refresh_token": LocalAuthProvider().create_refresh_token_for(
                usuario_actual.id
            )
        },
    )

    assert me.json()["data"]["color_cabecera"] == "#1565C0"
    assert me.json()["data"]["avatar_actualizado_en"] is not None
    sesion = refresh.json()["data"]["usuario"]
    assert sesion["color_cabecera"] == "#1565C0"
    assert sesion["avatar_actualizado_en"] is not None


@pytest.mark.anyio
async def test_un_usuario_sin_personalizar_recibe_nulls(client, usuario_actual):
    token = LocalAuthProvider().create_token_for(usuario_actual.id)

    me = await client.get("/api/auth/me", headers={"Authorization": f"Bearer {token}"})

    assert me.json()["data"]["color_cabecera"] is None
    assert me.json()["data"]["avatar_actualizado_en"] is None
