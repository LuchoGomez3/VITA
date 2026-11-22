"""Equipo del establecimiento: miembros, invitaciones por email y canje (adr-0012).

Cada test arma sus usuarios y campos con datos sintéticos y cambia de sesión con
``_como``: el flujo real involucra a dos personas (quien invita y quien canjea).
"""

from datetime import UTC, datetime, timedelta
import re
from uuid import UUID, uuid4

import pytest
from httpx import ASGITransport, AsyncBaseTransport, AsyncClient, ReadTimeout
from sqlalchemy import select, update

from api.auth.dependencies import get_current_user
from api.modules.equipo.models import InvitacionEstablecimiento
from api.modules.establecimientos.models import Establecimiento, UsuarioEstablecimiento
from api.modules.usuarios.models import Usuario
from api.shared.enums import EstadoInvitacion, RolUsuario
from core.config import settings
from core.email import Email, EmailEnvioError, get_email_sender

pytestmark = pytest.mark.anyio

_CODIGO = re.compile(r"código de invitación es: ([2-9A-Z]{3}-[2-9A-Z]{3})")


class _EmailsFalsos:
    """Doble del ``EmailSender``: guarda lo enviado y puede simular una caída."""

    def __init__(self) -> None:
        self.enviados: list[Email] = []
        self.fallar = False

    async def enviar(self, email: Email) -> None:
        if self.fallar:
            raise EmailEnvioError("smtp caído")
        self.enviados.append(email)

    def ultimo_codigo(self) -> str:
        """Código de la última invitación enviada (salta los avisos de aceptación)."""
        for email in reversed(self.enviados):
            if coincidencia := _CODIGO.search(email.texto):
                return coincidencia.group(1)
        raise AssertionError("no se envió ninguna invitación")


@pytest.fixture
def emails(app) -> _EmailsFalsos:
    falsos = _EmailsFalsos()
    app.dependency_overrides[get_email_sender] = lambda: falsos
    return falsos


def _como(app, usuario: Usuario) -> None:
    async def _override():
        return usuario

    app.dependency_overrides[get_current_user] = _override


async def _usuario(session, email: str, nombre: str = "Persona") -> Usuario:
    usuario = Usuario(id=uuid4(), nombre=nombre, apellido="Sintética", email=email)
    session.add(usuario)
    await session.commit()
    return usuario


async def _miembro(
    session, usuario: Usuario, campo: Establecimiento, rol: RolUsuario
) -> UsuarioEstablecimiento:
    membresia = UsuarioEstablecimiento(
        usuario_id=usuario.id, establecimiento_id=campo.id, rol=rol, activo=True
    )
    session.add(membresia)
    await session.commit()
    return membresia


async def _campo(
    session, titular: Usuario, nombre: str = "La Sirena"
) -> Establecimiento:
    campo = Establecimiento(owner_id=titular.id, nombre=nombre)
    session.add(campo)
    await session.commit()
    await _miembro(session, titular, campo, RolUsuario.owner)
    return campo


@pytest.fixture
async def escenario(app, session, auth_client, emails):
    """Titular dueño de un campo, logueado, y una persona por invitar."""
    titular = await _usuario(session, "ceci@campo.example.com", "Cecilia")
    campo = await _campo(session, titular)
    invitada = await _usuario(session, "mariano@campo.example.com", "Mariano")
    _como(app, titular)
    return {"titular": titular, "campo": campo, "invitada": invitada}


def _url(campo: Establecimiento, recurso: str = "invitaciones") -> str:
    return f"/api/v1/establecimientos/{campo.id}/{recurso}"


async def _invitar(client, campo, email="mariano@campo.example.com", rol="employee"):
    return await client.post(_url(campo), json={"email": email, "rol": rol})


# ─── Invitar ────────────────────────────────────────────────────────────────


async def test_el_dueno_invita_por_email_y_en_la_base_solo_queda_el_hash(
    auth_client, session, escenario, emails
):
    respuesta = await _invitar(
        auth_client, escenario["campo"], email="  Mariano@Campo.Example.COM "
    )

    assert respuesta.status_code == 201
    datos = respuesta.json()["data"]
    assert datos["email"] == "mariano@campo.example.com"
    assert datos["rol"] == "employee"
    assert datos["estado"] == "pendiente"
    assert datos["email_enviado"] is True
    assert datos["vencida"] is False
    assert "codigo_hash" not in datos

    email = emails.enviados[-1]
    assert email.destinatario == "mariano@campo.example.com"
    assert "La Sirena" in email.asunto
    assert "Empleado" in email.texto
    codigo = emails.ultimo_codigo()

    assert datos["codigo"] == codigo
    guardada = await session.get(InvitacionEstablecimiento, UUID(datos["id"]))
    assert codigo.replace("-", "") not in guardada.codigo_hash
    assert len(guardada.codigo_hash) == 64
    expira = datetime.fromisoformat(datos["expira_en"])
    assert timedelta(days=6, hours=23) < expira - datetime.now(UTC) <= timedelta(days=7)


async def test_las_invitaciones_pendientes_aparecen_en_la_lista(auth_client, escenario):
    await _invitar(auth_client, escenario["campo"])
    await _invitar(
        auth_client,
        escenario["campo"],
        email="otra@campo.example.com",
        rol="veterinarian",
    )

    respuesta = await auth_client.get(_url(escenario["campo"]))

    assert respuesta.status_code == 200
    emails_listados = [i["email"] for i in respuesta.json()["data"]]
    assert emails_listados == ["mariano@campo.example.com", "otra@campo.example.com"]


async def test_no_se_duplica_una_invitacion_pendiente(auth_client, escenario):
    await _invitar(auth_client, escenario["campo"])

    respuesta = await _invitar(auth_client, escenario["campo"], rol="admin")

    assert respuesta.status_code == 409
    assert respuesta.json()["errors"][0]["code"] == "invitacion_pendiente_duplicada"


async def test_una_invitacion_vencida_se_recicla_con_codigo_y_rol_nuevos(
    auth_client, session, escenario, emails
):
    primera = (await _invitar(auth_client, escenario["campo"])).json()["data"]
    codigo_viejo = emails.ultimo_codigo()
    await session.execute(
        update(InvitacionEstablecimiento)
        .where(InvitacionEstablecimiento.id == UUID(primera["id"]))
        .values(expira_en=datetime.now(UTC) - timedelta(minutes=1))
    )
    await session.commit()

    respuesta = await _invitar(auth_client, escenario["campo"], rol="veterinarian")

    assert respuesta.status_code == 201
    datos = respuesta.json()["data"]
    assert datos["id"] == primera["id"]
    assert datos["rol"] == "veterinarian"
    assert datos["vencida"] is False
    assert emails.ultimo_codigo() != codigo_viejo


async def test_no_se_invita_a_quien_ya_es_miembro(auth_client, session, escenario):
    await _miembro(
        session, escenario["invitada"], escenario["campo"], RolUsuario.employee
    )

    respuesta = await _invitar(auth_client, escenario["campo"])

    assert respuesta.status_code == 409
    assert respuesta.json()["errors"][0]["code"] == "ya_es_miembro"


async def test_si_el_email_no_sale_la_invitacion_queda_y_se_puede_reenviar(
    auth_client, escenario, emails
):
    emails.fallar = True
    respuesta = await _invitar(auth_client, escenario["campo"])

    assert respuesta.status_code == 201
    invitacion = respuesta.json()["data"]
    assert invitacion["email_enviado"] is False
    listadas = (await auth_client.get(_url(escenario["campo"]))).json()["data"]
    assert [i["id"] for i in listadas] == [invitacion["id"]]

    emails.fallar = False
    reenvio = await auth_client.post(
        f"{_url(escenario['campo'])}/{invitacion['id']}/reenvios"
    )

    assert reenvio.status_code == 200
    assert reenvio.json()["data"]["email_enviado"] is True
    assert len(emails.enviados) == 1


async def test_el_email_rechaza_un_formato_invalido(auth_client, escenario):
    respuesta = await _invitar(auth_client, escenario["campo"], email="no-es-un-email")

    assert respuesta.status_code == 422


# ─── Permisos ───────────────────────────────────────────────────────────────


@pytest.mark.parametrize("rol", [RolUsuario.employee, RolUsuario.veterinarian])
async def test_quien_no_gestiona_puede_ver_el_equipo_pero_no_invitar(
    app, auth_client, session, escenario, rol
):
    miembro = await _usuario(session, f"{rol.value}@campo.example.com")
    await _miembro(session, miembro, escenario["campo"], rol)
    _como(app, miembro)

    lista = await auth_client.get(_url(escenario["campo"], "usuarios"))
    invitar = await _invitar(auth_client, escenario["campo"])

    assert lista.status_code == 200
    assert invitar.status_code == 403
    assert invitar.json()["errors"][0]["code"] == "equipo_sin_permiso"


async def test_un_admin_invita_pero_no_puede_invitar_un_dueno(
    app, auth_client, session, escenario
):
    admin = await _usuario(session, "admin@campo.example.com")
    await _miembro(session, admin, escenario["campo"], RolUsuario.admin)
    _como(app, admin)

    a_dueno = await _invitar(auth_client, escenario["campo"], rol="owner")
    a_vet = await _invitar(auth_client, escenario["campo"], rol="veterinarian")

    assert a_dueno.status_code == 403
    assert a_dueno.json()["errors"][0]["code"] == "rol_no_asignable"
    assert a_vet.status_code == 201


async def test_un_admin_no_cancela_ni_reenvia_la_invitacion_de_un_dueno(
    app, auth_client, session, escenario
):
    invitacion = (await _invitar(auth_client, escenario["campo"], rol="owner")).json()[
        "data"
    ]
    admin = await _usuario(session, "admin@campo.example.com")
    await _miembro(session, admin, escenario["campo"], RolUsuario.admin)
    _como(app, admin)

    url = f"{_url(escenario['campo'])}/{invitacion['id']}"
    cancelar = await auth_client.delete(url)
    reenviar = await auth_client.post(f"{url}/reenvios")

    assert cancelar.status_code == 403
    assert reenviar.status_code == 403


async def test_quien_no_es_miembro_no_ve_que_el_campo_existe(
    app, auth_client, session, escenario
):
    ajeno = await _usuario(session, "ajeno@otro.example.com")
    _como(app, ajeno)

    for respuesta in (
        await auth_client.get(_url(escenario["campo"], "usuarios")),
        await auth_client.get(_url(escenario["campo"])),
        await _invitar(auth_client, escenario["campo"]),
    ):
        assert respuesta.status_code == 404
        assert respuesta.json()["errors"][0]["code"] == "establecimiento_no_encontrado"


async def test_el_equipo_no_mezcla_establecimientos(
    app, auth_client, session, escenario
):
    otro_titular = await _usuario(session, "otro@otro.example.com")
    otro_campo = await _campo(session, otro_titular, "El Algarrobo")
    await _miembro(session, escenario["invitada"], otro_campo, RolUsuario.employee)
    _como(app, otro_titular)
    await _invitar(auth_client, otro_campo, email="tercero@otro.example.com")
    _como(app, escenario["titular"])

    miembros = (await auth_client.get(_url(escenario["campo"], "usuarios"))).json()[
        "data"
    ]
    invitaciones = (await auth_client.get(_url(escenario["campo"]))).json()["data"]

    assert [m["email"] for m in miembros] == ["ceci@campo.example.com"]
    assert invitaciones == []


# ─── Canje ──────────────────────────────────────────────────────────────────


async def _invitar_y_cambiar_a_la_invitada(
    app, client, escenario, emails, rol="employee"
):
    await _invitar(client, escenario["campo"], rol=rol)
    _como(app, escenario["invitada"])
    return emails.ultimo_codigo()


async def test_la_invitada_previsualiza_y_se_suma_con_el_codigo(
    app, auth_client, escenario, emails
):
    codigo = await _invitar_y_cambiar_a_la_invitada(
        app, auth_client, escenario, emails, rol="veterinarian"
    )

    previa = await auth_client.post(
        "/api/v1/invitaciones/validaciones", json={"codigo": codigo}
    )
    assert previa.status_code == 200
    assert previa.json()["data"]["establecimiento_nombre"] == "La Sirena"
    assert previa.json()["data"]["rol"] == "veterinarian"
    assert previa.json()["data"]["invitado_por"] == "Cecilia Sintética"

    # Minúsculas y sin guion: se dicta o se copia como venga.
    aceptada = await auth_client.post(
        "/api/v1/invitaciones/aceptaciones",
        json={"codigo": codigo.replace("-", " ").lower()},
    )
    assert aceptada.status_code == 201
    assert aceptada.json()["data"]["id"] == str(escenario["campo"].id)
    assert aceptada.json()["data"]["rol"] == "veterinarian"

    mis_campos = (await auth_client.get("/api/v1/establecimientos")).json()["data"]
    assert [(c["nombre"], c["rol"]) for c in mis_campos] == [
        ("La Sirena", "veterinarian")
    ]

    _como(app, escenario["titular"])
    miembros = (await auth_client.get(_url(escenario["campo"], "usuarios"))).json()[
        "data"
    ]
    assert {(m["email"], m["rol"], m["es_titular"]) for m in miembros} == {
        ("ceci@campo.example.com", "owner", True),
        ("mariano@campo.example.com", "veterinarian", False),
    }
    assert (await auth_client.get(_url(escenario["campo"]))).json()["data"] == []


async def test_la_previsualizacion_no_consume_el_codigo(
    app, auth_client, escenario, emails
):
    codigo = await _invitar_y_cambiar_a_la_invitada(app, auth_client, escenario, emails)

    for _ in range(2):
        previa = await auth_client.post(
            "/api/v1/invitaciones/validaciones", json={"codigo": codigo}
        )
        assert previa.status_code == 200


async def test_acceptance_retry_returns_current_access_without_repeating_effects(
    app, auth_client, session, escenario, emails
):
    code = await _invitar_y_cambiar_a_la_invitada(app, auth_client, escenario, emails)
    first = await auth_client.post(
        "/api/v1/invitaciones/aceptaciones", json={"codigo": code}
    )
    email_count = len(emails.enviados)
    second = await auth_client.post(
        "/api/v1/invitaciones/aceptaciones", json={"codigo": code}
    )
    assert first.status_code == second.status_code == 201
    assert second.json()["data"] == first.json()["data"]
    assert len(emails.enviados) == email_count
    memberships = (
        (
            await session.execute(
                select(UsuarioEstablecimiento).where(
                    UsuarioEstablecimiento.usuario_id == escenario["invitada"].id
                )
            )
        )
        .scalars()
        .all()
    )
    assert len(memberships) == 1


async def test_el_codigo_exige_la_sesion_del_email_invitado(
    app, auth_client, session, escenario, emails
):
    codigo = await _invitar_y_cambiar_a_la_invitada(app, auth_client, escenario, emails)
    _como(app, await _usuario(session, "intruso@campo.example.com"))

    respuesta = await auth_client.post(
        "/api/v1/invitaciones/aceptaciones", json={"codigo": codigo}
    )

    assert respuesta.status_code == 403
    assert respuesta.json()["errors"][0]["code"] == "codigo_de_otro_email"


async def test_un_codigo_vencido_no_sirve(app, auth_client, session, escenario, emails):
    codigo = await _invitar_y_cambiar_a_la_invitada(app, auth_client, escenario, emails)
    await session.execute(
        update(InvitacionEstablecimiento).values(
            expira_en=datetime.now(UTC) - timedelta(seconds=1)
        )
    )
    await session.commit()

    respuesta = await auth_client.post(
        "/api/v1/invitaciones/aceptaciones", json={"codigo": codigo}
    )

    assert respuesta.status_code == 422
    assert respuesta.json()["errors"][0]["code"] == "codigo_vencido"


async def test_reenviar_invalida_el_codigo_anterior(
    app, auth_client, escenario, emails
):
    invitacion = (await _invitar(auth_client, escenario["campo"])).json()["data"]
    codigo_viejo = emails.ultimo_codigo()
    await auth_client.post(f"{_url(escenario['campo'])}/{invitacion['id']}/reenvios")
    codigo_nuevo = emails.ultimo_codigo()
    _como(app, escenario["invitada"])

    viejo = await auth_client.post(
        "/api/v1/invitaciones/aceptaciones", json={"codigo": codigo_viejo}
    )
    nuevo = await auth_client.post(
        "/api/v1/invitaciones/aceptaciones", json={"codigo": codigo_nuevo}
    )

    assert codigo_viejo != codigo_nuevo
    assert viejo.status_code == 422
    assert viejo.json()["errors"][0]["code"] == "codigo_invalido"
    assert nuevo.status_code == 201


async def test_cancelar_revoca_el_codigo(app, auth_client, escenario, emails):
    invitacion = (await _invitar(auth_client, escenario["campo"])).json()["data"]
    codigo = emails.ultimo_codigo()

    cancelar = await auth_client.delete(
        f"{_url(escenario['campo'])}/{invitacion['id']}"
    )
    de_nuevo = await auth_client.delete(
        f"{_url(escenario['campo'])}/{invitacion['id']}"
    )
    listadas = (await auth_client.get(_url(escenario["campo"]))).json()["data"]
    _como(app, escenario["invitada"])
    canje = await auth_client.post(
        "/api/v1/invitaciones/aceptaciones", json={"codigo": codigo}
    )

    assert cancelar.status_code == 204
    assert de_nuevo.status_code == 409
    assert listadas == []
    assert canje.status_code == 422
    assert canje.json()["errors"][0]["code"] == "codigo_revocado"


async def test_una_invitacion_de_otro_campo_no_se_gestiona_desde_este(
    app, auth_client, session, escenario
):
    invitacion = (await _invitar(auth_client, escenario["campo"])).json()["data"]
    propio = await _campo(session, escenario["titular"], "Otro campo")

    respuesta = await auth_client.delete(f"{_url(propio)}/{invitacion['id']}")

    assert respuesta.status_code == 404
    assert respuesta.json()["errors"][0]["code"] == "invitacion_no_encontrada"


@pytest.mark.parametrize("codigo", ["", "ABC", "0000-0000", "IIII-LLLL"])
async def test_un_codigo_mal_formado_se_rechaza(app, auth_client, escenario, codigo):
    _como(app, escenario["invitada"])

    respuesta = await auth_client.post(
        "/api/v1/invitaciones/aceptaciones", json={"codigo": codigo}
    )

    assert respuesta.status_code == 422


async def test_los_intentos_de_codigo_se_limitan_por_usuario(
    app, auth_client, escenario, monkeypatch
):
    monkeypatch.setattr(settings, "INVITACION_CODIGO_RATE_LIMIT", 3)
    _como(app, escenario["invitada"])

    respuestas = [
        await auth_client.post(
            "/api/v1/invitaciones/validaciones", json={"codigo": "234-567"}
        )
        for _ in range(4)
    ]

    assert [r.status_code for r in respuestas] == [422, 422, 422, 429]
    # La app muestra "Te quedan N intentos" con este dato.
    restantes = [
        r.json()["errors"][0]["details"]["intentos_restantes"] for r in respuestas[:3]
    ]
    assert restantes == [2, 1, 0]


# ─── Quitar ─────────────────────────────────────────────────────────────────


async def test_quitar_a_un_miembro_y_volver_a_sumarlo_reactiva_su_membresia(
    app, auth_client, session, escenario, emails
):
    campo, invitada = escenario["campo"], escenario["invitada"]
    await _miembro(session, invitada, campo, RolUsuario.employee)

    quitar = await auth_client.delete(f"{_url(campo, 'usuarios')}/{invitada.id}")
    miembros = (await auth_client.get(_url(campo, "usuarios"))).json()["data"]
    assert quitar.status_code == 204
    assert [m["email"] for m in miembros] == ["ceci@campo.example.com"]

    codigo = await _invitar_y_cambiar_a_la_invitada(app, auth_client, escenario, emails)
    aceptada = await auth_client.post(
        "/api/v1/invitaciones/aceptaciones", json={"codigo": codigo}
    )

    assert aceptada.status_code == 201
    filas = (
        (
            await session.execute(
                select(UsuarioEstablecimiento).where(
                    UsuarioEstablecimiento.usuario_id == invitada.id
                )
            )
        )
        .scalars()
        .all()
    )
    assert [(f.rol, f.activo) for f in filas] == [("employee", True)]


async def test_reglas_para_quitar_miembros(app, auth_client, session, escenario):
    campo, titular = escenario["campo"], escenario["titular"]
    admin = await _usuario(session, "admin@campo.example.com")
    otro_admin = await _usuario(session, "admin2@campo.example.com")
    empleado = await _usuario(session, "peon@campo.example.com")
    for usuario, rol in (
        (admin, RolUsuario.admin),
        (otro_admin, RolUsuario.admin),
        (empleado, RolUsuario.employee),
    ):
        await _miembro(session, usuario, campo, rol)
    url = _url(campo, "usuarios")

    assert (await auth_client.delete(f"{url}/{titular.id}")).status_code == 422
    _como(app, admin)
    titular_resp = await auth_client.delete(f"{url}/{titular.id}")
    admin_resp = await auth_client.delete(f"{url}/{otro_admin.id}")
    ajeno_resp = await auth_client.delete(f"{url}/{uuid4()}")
    empleado_resp = await auth_client.delete(f"{url}/{empleado.id}")

    assert titular_resp.json()["errors"][0]["code"] == "titular_no_removible"
    assert admin_resp.json()["errors"][0]["code"] == "rol_no_asignable"
    assert ajeno_resp.json()["errors"][0]["code"] == "miembro_no_encontrado"
    assert empleado_resp.status_code == 204


async def test_un_dueno_puede_quitar_a_otro_dueno_que_no_es_titular(
    app, auth_client, session, escenario
):
    socio = await _usuario(session, "socio@campo.example.com")
    await _miembro(session, socio, escenario["campo"], RolUsuario.owner)

    respuesta = await auth_client.delete(
        f"{_url(escenario['campo'], 'usuarios')}/{socio.id}"
    )

    assert respuesta.status_code == 204


async def test_con_varios_roles_se_muestra_el_de_mayor_jerarquia(
    auth_client, session, escenario
):
    socio = await _usuario(session, "socio@campo.example.com")
    await _miembro(session, socio, escenario["campo"], RolUsuario.employee)
    await _miembro(session, socio, escenario["campo"], RolUsuario.admin)

    miembros = (await auth_client.get(_url(escenario["campo"], "usuarios"))).json()[
        "data"
    ]

    assert {m["email"]: m["rol"] for m in miembros}[
        "socio@campo.example.com"
    ] == "admin"


async def test_el_estado_aceptada_queda_registrado(
    app, auth_client, session, escenario, emails
):
    codigo = await _invitar_y_cambiar_a_la_invitada(app, auth_client, escenario, emails)
    await auth_client.post("/api/v1/invitaciones/aceptaciones", json={"codigo": codigo})

    invitacion = (await session.execute(select(InvitacionEstablecimiento))).scalar_one()
    await session.refresh(invitacion)

    assert invitacion.estado == EstadoInvitacion.aceptada
    assert invitacion.aceptada_por_id == escenario["invitada"].id
    assert invitacion.aceptada_en is not None


# ─── Lo que pide el diseño de la invitación ─────────────────────────────────


async def test_invitar_y_reenviar_devuelven_el_codigo_una_sola_vez(
    auth_client, session, escenario, emails
):
    creada = (await _invitar(auth_client, escenario["campo"])).json()["data"]

    assert creada["codigo"] == emails.ultimo_codigo()
    assert re.fullmatch(r"[2-9A-Z]{3}-[2-9A-Z]{3}", creada["codigo"])
    listada = (await auth_client.get(_url(escenario["campo"]))).json()["data"][0]
    assert "codigo" not in listada

    reenvio = await auth_client.post(
        f"{_url(escenario['campo'])}/{creada['id']}/reenvios"
    )
    assert reenvio.json()["data"]["codigo"] == emails.ultimo_codigo()
    assert reenvio.json()["data"]["codigo"] != creada["codigo"]


async def test_la_previsualizacion_trae_lo_que_muestra_la_confirmacion(
    app, auth_client, session, escenario, emails
):
    campo = escenario["campo"]
    campo.nro_renspa = "07.123.0.00456/01"
    campo.localidad = "Coronel Moldes"
    campo.provincia = "Córdoba"
    session.add(campo)
    await session.commit()
    codigo = await _invitar_y_cambiar_a_la_invitada(app, auth_client, escenario, emails)

    previa = (
        await auth_client.post(
            "/api/v1/invitaciones/validaciones", json={"codigo": codigo}
        )
    ).json()["data"]

    assert previa["establecimiento_renspa"] == "07.123.0.00456/01"
    assert previa["establecimiento_localidad"] == "Coronel Moldes"
    assert previa["establecimiento_provincia"] == "Córdoba"
    assert previa["invitado_por_rol"] == "owner"
    assert previa["email"] == "mariano@campo.example.com"


async def test_al_sumarse_se_le_avisa_a_quien_invito(
    app, auth_client, escenario, emails
):
    codigo = await _invitar_y_cambiar_a_la_invitada(app, auth_client, escenario, emails)

    await auth_client.post("/api/v1/invitaciones/aceptaciones", json={"codigo": codigo})

    aviso = emails.enviados[-1]
    assert aviso.destinatario == "ceci@campo.example.com"
    assert "Mariano Sintética" in aviso.asunto
    assert "como Empleado" in aviso.texto


async def test_si_el_aviso_no_sale_el_canje_igual_funciona(
    app, auth_client, escenario, emails
):
    codigo = await _invitar_y_cambiar_a_la_invitada(app, auth_client, escenario, emails)
    emails.fallar = True

    respuesta = await auth_client.post(
        "/api/v1/invitaciones/aceptaciones", json={"codigo": codigo}
    )

    assert respuesta.status_code == 201


class _LostAcceptanceResponse(AsyncBaseTransport):
    """Ejecuta y confirma el endpoint antes de perder la primera respuesta."""

    def __init__(self, app):
        self.transport = ASGITransport(app=app)
        self.dropped = False

    async def handle_async_request(self, request):
        response = await self.transport.handle_async_request(request)
        if not self.dropped and request.url.path.endswith("/aceptaciones"):
            self.dropped = True
            assert response.status_code == 201
            await response.aclose()
            raise ReadTimeout("Response lost after commit", request=request)
        return response


async def test_retry_recovers_an_acceptance_committed_before_transport_error(
    app, auth_client, session, escenario, emails
):
    code = await _invitar_y_cambiar_a_la_invitada(app, auth_client, escenario, emails)
    async with AsyncClient(
        transport=_LostAcceptanceResponse(app), base_url="http://test"
    ) as client:
        with pytest.raises(ReadTimeout):
            await client.post(
                "/api/v1/invitaciones/aceptaciones", json={"codigo": code}
            )
        invitation = (
            await session.execute(select(InvitacionEstablecimiento))
        ).scalar_one()
        await session.refresh(invitation)
        assert invitation.aceptada_por_id == escenario["invitada"].id
        email_count = len(emails.enviados)
        recovered = await client.post(
            "/api/v1/invitaciones/aceptaciones", json={"codigo": code}
        )
        assert recovered.status_code == 201
        assert recovered.json()["data"]["id"] == str(escenario["campo"].id)
        assert len(emails.enviados) == email_count
        preview = await client.post(
            "/api/v1/invitaciones/validaciones", json={"codigo": code}
        )
        assert preview.status_code == 200


@pytest.mark.parametrize("same_email", [False, True])
async def test_used_code_is_not_recoverable_by_another_account(
    app, auth_client, session, escenario, emails, same_email
):
    code = await _invitar_y_cambiar_a_la_invitada(app, auth_client, escenario, emails)
    await auth_client.post("/api/v1/invitaciones/aceptaciones", json={"codigo": code})
    # Misma casilla pero otra identidad también debe rechazarse.
    other = Usuario(
        id=uuid4(),
        nombre="Other",
        apellido="Synthetic",
        email=escenario["invitada"].email if same_email else "other@example.com",
    )
    _como(app, other)
    for endpoint in ("aceptaciones", "validaciones"):
        result = await auth_client.post(
            f"/api/v1/invitaciones/{endpoint}", json={"codigo": code}
        )
        assert result.status_code == 409
        assert result.json()["errors"][0]["code"] == "codigo_usado"


async def test_retry_does_not_reactivate_revoked_access(
    app, auth_client, session, escenario, emails
):
    code = await _invitar_y_cambiar_a_la_invitada(app, auth_client, escenario, emails)
    await auth_client.post("/api/v1/invitaciones/aceptaciones", json={"codigo": code})
    await session.execute(
        update(UsuarioEstablecimiento)
        .where(UsuarioEstablecimiento.usuario_id == escenario["invitada"].id)
        .values(activo=False)
    )
    await session.commit()
    for endpoint in ("aceptaciones", "validaciones"):
        result = await auth_client.post(
            f"/api/v1/invitaciones/{endpoint}", json={"codigo": code}
        )
        assert result.status_code == 409
    active = (
        (
            await session.execute(
                select(UsuarioEstablecimiento).where(
                    UsuarioEstablecimiento.usuario_id == escenario["invitada"].id,
                    UsuarioEstablecimiento.activo.is_(True),
                )
            )
        )
        .scalars()
        .all()
    )
    assert active == []


async def test_retry_reports_current_role_without_restoring_invited_role(
    app, auth_client, session, escenario, emails
):
    code = await _invitar_y_cambiar_a_la_invitada(
        app, auth_client, escenario, emails, rol="admin"
    )
    await auth_client.post("/api/v1/invitaciones/aceptaciones", json={"codigo": code})
    await session.execute(
        update(UsuarioEstablecimiento)
        .where(UsuarioEstablecimiento.usuario_id == escenario["invitada"].id)
        .values(rol="employee")
    )
    await session.commit()
    email_count = len(emails.enviados)
    for endpoint in ("aceptaciones", "validaciones"):
        result = await auth_client.post(
            f"/api/v1/invitaciones/{endpoint}", json={"codigo": code}
        )
        assert result.status_code in (200, 201)
        assert result.json()["data"]["rol"] == "employee"
    assert len(emails.enviados) == email_count
