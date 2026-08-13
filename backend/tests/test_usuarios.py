"""Tests de PRO-15: registro de dueño de campo."""

import pytest
from sqlalchemy import select

from api.modules.usuarios.models import Usuario
from api.modules.usuarios.utils import validar_cuit

CUIT_VALIDO = "20111111112"


def _payload(**overrides):
    base = {
        "nombre": "Juan",
        "apellido": "Pérez",
        "cuit": CUIT_VALIDO,
        "email": "juan@campo.com",
        "password": "Segura123",
    }
    base.update(overrides)
    return base


@pytest.mark.anyio
async def test_registro_exitoso(client, session):
    resp = await client.post("/api/v1/usuarios/registro", json=_payload())
    assert resp.status_code == 201
    body = resp.json()
    assert body["success"] is True
    assert body["data"]["usuario"]["email"] == "juan@campo.com"
    assert body["data"]["access_token"]
    assert body["data"]["token_type"] == "bearer"
    # El password no se expone.
    assert "password" not in body["data"]["usuario"]

    # El perfil quedó persistido en la DB.
    result = await session.execute(
        select(Usuario).where(Usuario.email == "juan@campo.com")
    )
    usuario = result.scalar_one()
    assert usuario.cuit == CUIT_VALIDO


@pytest.mark.anyio
async def test_registro_flujo_feliz_token_autentica(client):
    """Flujo feliz con conexión: el token emitido al registrarse abre la sesión.

    El registro es un endpoint online (crea credenciales en el proveedor). El
    token que devuelve debe autenticar de inmediato el resto de la API, sin un
    login extra: es la definición de "cuenta creada con éxito".
    """
    resp = await client.post("/api/v1/usuarios/registro", json=_payload())
    assert resp.status_code == 201
    access_token = resp.json()["data"]["access_token"]

    me = await client.get(
        "/api/auth/me", headers={"Authorization": f"Bearer {access_token}"}
    )
    assert me.status_code == 200
    assert me.json()["data"]["email"] == "juan@campo.com"


@pytest.mark.anyio
async def test_registro_devuelve_sesion_completa(client):
    """El registro devuelve refresh_token + expires_in, igual que /auth/login.

    Necesario para que el cliente pueda seguir operando (p. ej. registrar su
    establecimiento) sin pedir un login aparte apenas creada la cuenta.
    """
    resp = await client.post("/api/v1/usuarios/registro", json=_payload())
    assert resp.status_code == 201
    data = resp.json()["data"]
    assert data["refresh_token"]
    assert data["expires_in"] and data["expires_in"] > 0


@pytest.mark.anyio
async def test_registro_normaliza_cuit_con_guiones(client, session):
    """Un CUIT con guiones/espacios se normaliza a 11 dígitos y se persiste así."""
    resp = await client.post(
        "/api/v1/usuarios/registro",
        json=_payload(cuit="20-11111111-2"),
    )
    assert resp.status_code == 201

    result = await session.execute(
        select(Usuario).where(Usuario.email == "juan@campo.com")
    )
    assert result.scalar_one().cuit == CUIT_VALIDO


@pytest.mark.anyio
async def test_registro_email_duplicado(client):
    await client.post("/api/v1/usuarios/registro", json=_payload())
    # Mismo email, distinto CUIT válido.
    resp = await client.post(
        "/api/v1/usuarios/registro",
        json=_payload(cuit="20111111120"),
    )
    assert resp.status_code == 409
    assert resp.json()["errors"][0]["code"] == "email_ya_registrado"


@pytest.mark.anyio
async def test_registro_email_duplicado_case_insensitive(client):
    """El email es único sin distinguir mayúsculas: 'Juan@' == 'juan@'."""
    await client.post("/api/v1/usuarios/registro", json=_payload())
    resp = await client.post(
        "/api/v1/usuarios/registro",
        json=_payload(email="JUAN@campo.com", cuit="20111111120"),
    )
    assert resp.status_code == 409
    assert resp.json()["errors"][0]["code"] == "email_ya_registrado"


@pytest.mark.anyio
@pytest.mark.parametrize(
    "email",
    [
        "no-es-email",
        "sin-arroba.com",
        "arroba@",
        "@sindominio.com",
        "espacio @campo.com",
        "",
    ],
)
async def test_registro_email_formato_invalido(client, email):
    """Correos con formato inválido se rechazan en el schema (422), sin tocar la DB."""
    resp = await client.post(
        "/api/v1/usuarios/registro",
        json=_payload(email=email),
    )
    assert resp.status_code == 422


@pytest.mark.anyio
@pytest.mark.parametrize("cuit", ["123", "2011111111", "201111111123", "2011111111a"])
async def test_registro_cuit_formato_invalido(client, cuit):
    """CUIT que no son 11 dígitos (corto, largo, con letras) se rechazan en el schema."""
    resp = await client.post(
        "/api/v1/usuarios/registro",
        json=_payload(cuit=cuit),
    )
    assert resp.status_code == 422


@pytest.mark.anyio
async def test_registro_cuit_duplicado(client):
    await client.post("/api/v1/usuarios/registro", json=_payload())
    resp = await client.post(
        "/api/v1/usuarios/registro",
        json=_payload(email="otro@campo.com"),
    )
    assert resp.status_code == 409
    assert resp.json()["errors"][0]["code"] == "cuit_ya_registrado"


@pytest.mark.anyio
async def test_registro_cuit_invalido(client):
    # 11 dígitos (pasa el schema) pero dígito verificador incorrecto.
    resp = await client.post(
        "/api/v1/usuarios/registro",
        json=_payload(cuit="20111111113"),
    )
    assert resp.status_code == 422
    assert resp.json()["errors"][0]["code"] == "cuit_invalido"


@pytest.mark.anyio
async def test_registro_campo_obligatorio_vacio(client):
    resp = await client.post(
        "/api/v1/usuarios/registro",
        json=_payload(nombre=""),
    )
    assert resp.status_code == 422


@pytest.mark.anyio
async def test_registro_password_debil(client):
    resp = await client.post(
        "/api/v1/usuarios/registro",
        json=_payload(password="corta"),
    )
    assert resp.status_code == 422


@pytest.mark.anyio
async def test_registro_password_solo_numero_sin_mayuscula(client):
    """Un número sin mayúscula ya no alcanza: se exigen ambos."""
    resp = await client.post(
        "/api/v1/usuarios/registro",
        json=_payload(password="segura123"),
    )
    assert resp.status_code == 422


@pytest.mark.anyio
async def test_registro_password_solo_mayuscula_sin_numero(client):
    """Una mayúscula sin número ya no alcanza: se exigen ambos."""
    resp = await client.post(
        "/api/v1/usuarios/registro",
        json=_payload(password="SeguraSinNumero"),
    )
    assert resp.status_code == 422


@pytest.mark.anyio
async def test_registro_password_excede_longitud_maxima(client):
    resp = await client.post(
        "/api/v1/usuarios/registro",
        json=_payload(password="Segura123" + "a" * 42),  # 51 caracteres
    )
    assert resp.status_code == 422


@pytest.mark.anyio
async def test_registro_password_longitud_maxima_permitida(client):
    """Exactamente 50 caracteres es el límite permitido (no se rechaza)."""
    resp = await client.post(
        "/api/v1/usuarios/registro",
        json=_payload(password="Segura123" + "a" * 41),  # 50 caracteres
    )
    assert resp.status_code == 201


@pytest.mark.anyio
async def test_registro_nombre_excede_longitud_maxima(client):
    resp = await client.post(
        "/api/v1/usuarios/registro",
        json=_payload(nombre="a" * 51),
    )
    assert resp.status_code == 422


@pytest.mark.anyio
async def test_registro_apellido_excede_longitud_maxima(client):
    resp = await client.post(
        "/api/v1/usuarios/registro",
        json=_payload(apellido="a" * 51),
    )
    assert resp.status_code == 422


# --- Algoritmo de control del CUIT/CUIL (mod-11) — validaciones generales ---


@pytest.mark.parametrize(
    "cuit",
    [
        "20111111112",  # persona física (prefijo 20)
        "20000000001",  # prefijo 20, dígito verificador = 1
        "27000000006",  # CUIL femenino (prefijo 27)
        "24000000007",  # persona física (prefijo 24)
        "23000000000",  # CUIL (prefijo 23), verificador = 0
        "20000000060",  # verificador = 0 por resto == 0 (rama 11 -> 0)
        "30000000007",  # empresa (prefijo 30)
        "33000000006",  # empresa (prefijo 33)
    ],
)
def test_validar_cuit_validos(cuit):
    assert validar_cuit(cuit) is True


@pytest.mark.parametrize(
    "cuit",
    [
        "20111111113",  # mismos 10 dígitos que un válido, verificador equivocado
        "20000000002",  # verificador equivocado (el correcto es 1)
        "20000000010",  # cuerpo cuyo verificador calculado es 10 -> inválido
    ],
)
def test_validar_cuit_digito_verificador_incorrecto(cuit):
    assert validar_cuit(cuit) is False


@pytest.mark.parametrize(
    "cuit",
    [
        "",  # vacío
        "123",  # muy corto
        "2011111111",  # 10 dígitos
        "201111111123",  # 12 dígitos
        "2011111111a",  # contiene una letra
        "20-11111111-2",  # con guiones: validar_cuit exige solo dígitos
        "abcdefghijk",  # sin dígitos
    ],
)
def test_validar_cuit_formato_invalido(cuit):
    assert validar_cuit(cuit) is False
