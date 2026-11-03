"""Quién edita y quién borra una observación (VITA-173, decisión de Ernesto en #56).

- Editar: solo el autor. Las notas migradas no tienen autor: nadie las edita.
- Borrar: el autor, las suyas. Owner y admin, cualquiera del establecimiento,
  incluidas las migradas. Un employee que no es el autor, no.
"""

from datetime import UTC, date, datetime
from uuid import UUID, uuid4

import pytest

from api.auth.dependencies import get_current_user
from api.modules.animales.models import Animal
from api.modules.establecimientos.models import (
    Establecimiento,
    UsuarioEstablecimiento,
)
from api.modules.observaciones_animales.models import ObservacionAnimal
from api.modules.usuarios.models import Usuario
from api.shared.enums import RolUsuario, SexoAnimal

_RUTA = "/api/v1/observaciones_animales"


def _usuario(nombre: str, cuit: str) -> Usuario:
    return Usuario(
        id=uuid4(),
        nombre=nombre,
        apellido="Sintético",
        email=f"{nombre.lower()}@vita.test",
        cuit=cuit,
    )


@pytest.fixture
async def campo(session, usuario_actual):
    """Establecimiento con un autor (employee), otro employee, un owner y un admin."""
    otro = _usuario("Otro", "20222222223")
    owner = _usuario("Duena", "27333333334")
    admin = _usuario("Admin", "20444444445")
    session.add_all([otro, owner, admin])
    await session.flush()
    est = Establecimiento(owner_id=owner.id, nombre="Estancia Test")
    session.add(est)
    await session.flush()
    for usuario, rol in (
        (usuario_actual, RolUsuario.employee),
        (otro, RolUsuario.employee),
        (owner, RolUsuario.owner),
        (admin, RolUsuario.admin),
    ):
        session.add(
            UsuarioEstablecimiento(
                usuario_id=usuario.id,
                establecimiento_id=est.id,
                rol=rol,
                activo=True,
            )
        )
    animal = Animal(
        establecimiento_id=est.id,
        nro_caravana_rfid="300000000000001",
        sexo=SexoAnimal.hembra,
        raza="Angus",
        fecha_nacimiento=date(2022, 3, 10),
    )
    session.add(animal)
    await session.flush()
    # Nota migrada desde animales.observaciones: sin autor.
    migrada = ObservacionAnimal(
        establecimiento_id=est.id,
        animal_id=animal.id,
        texto="Nota legacy",
        fecha=datetime(2026, 3, 15, tzinfo=UTC),
        autor_id=None,
    )
    session.add(migrada)
    await session.commit()
    return {
        "est": est.id,
        "animal": animal.id,
        "migrada": migrada.id,
        "autor": usuario_actual,
        "otro": otro,
        "owner": owner,
        "admin": admin,
    }


@pytest.fixture
def como(app):
    """Cambia el usuario autenticado del cliente."""

    def _como(usuario: Usuario) -> None:
        async def _override():
            return usuario

        app.dependency_overrides[get_current_user] = _override

    return _como


async def _nota_del_autor(client, campo) -> dict:
    resp = await client.post(
        _RUTA,
        json={
            "id": str(uuid4()),
            "establecimiento_id": str(campo["est"]),
            "animal_id": str(campo["animal"]),
            "texto": "Escrita por el autor",
            "updated_at": "2026-09-01T10:00:00Z",
        },
    )
    assert resp.status_code == 201
    return resp.json()["data"]


async def _texto_y_borrado(session, observacion_id):
    session.expire_all()
    obs = await session.get(ObservacionAnimal, UUID(str(observacion_id)))
    return obs.texto, obs.deleted_at


def _codigo(resp) -> str:
    return resp.json()["errors"][0]["code"]


# ------------------------------------------------------------------ editar


@pytest.mark.anyio
async def test_el_autor_edita_su_observacion(auth_client, campo):
    nota = await _nota_del_autor(auth_client, campo)
    resp = await auth_client.put(f"{_RUTA}/{nota['id']}", json={"texto": "Corregida"})
    assert resp.status_code == 200
    assert resp.json()["data"]["texto"] == "Corregida"


@pytest.mark.anyio
@pytest.mark.parametrize("quien", ["otro", "owner", "admin"])
async def test_nadie_mas_edita_una_observacion_ajena(
    auth_client, session, campo, como, quien
):
    nota = await _nota_del_autor(auth_client, campo)
    como(campo[quien])

    put = await auth_client.put(f"{_RUTA}/{nota['id']}", json={"texto": "Pisada"})
    reenvio = await auth_client.post(
        _RUTA,
        json={
            "id": nota["id"],
            "establecimiento_id": str(campo["est"]),
            "animal_id": str(campo["animal"]),
            "texto": "Pisada",
            "updated_at": "2030-01-01T00:00:00Z",
        },
    )

    for resp in (put, reenvio):
        assert resp.status_code == 403
        assert _codigo(resp) == "observacion_solo_autor"
    assert (await _texto_y_borrado(session, nota["id"]))[0] == "Escrita por el autor"


@pytest.mark.anyio
@pytest.mark.parametrize("quien", ["autor", "otro", "owner", "admin"])
async def test_nadie_edita_una_nota_migrada(auth_client, session, campo, como, quien):
    como(campo[quien])
    resp = await auth_client.put(
        f"{_RUTA}/{campo['migrada']}", json={"fecha": "2026-01-01T00:00:00Z"}
    )
    assert resp.status_code == 403
    assert _codigo(resp) == "observacion_solo_autor"


@pytest.mark.anyio
async def test_un_reintento_identico_de_otro_miembro_no_es_una_edicion(
    auth_client, campo, como
):
    """Reenviar el alta sin cambios (por ejemplo, la cola de otro dispositivo
    sincronizando lo que bajó) no edita nada y no debe fallar."""
    nota = await _nota_del_autor(auth_client, campo)
    como(campo["otro"])
    resp = await auth_client.post(
        _RUTA,
        json={
            "id": nota["id"],
            "establecimiento_id": str(campo["est"]),
            "animal_id": str(campo["animal"]),
            "texto": "Escrita por el autor",
            "updated_at": "2026-09-01T10:00:00Z",
        },
    )
    assert resp.status_code == 201


# ------------------------------------------------------------------ borrar


@pytest.mark.anyio
async def test_el_autor_borra_su_observacion(auth_client, session, campo):
    nota = await _nota_del_autor(auth_client, campo)
    resp = await auth_client.delete(f"{_RUTA}/{nota['id']}")
    assert resp.status_code == 200
    assert (await _texto_y_borrado(session, nota["id"]))[1] is not None


@pytest.mark.anyio
async def test_un_employee_no_borra_la_de_otro(auth_client, session, campo, como):
    nota = await _nota_del_autor(auth_client, campo)
    como(campo["otro"])

    delete = await auth_client.delete(f"{_RUTA}/{nota['id']}")
    put = await auth_client.put(
        f"{_RUTA}/{nota['id']}", json={"deleted_at": "2030-01-01T00:00:00Z"}
    )
    reenvio = await auth_client.post(
        _RUTA,
        json={
            "id": nota["id"],
            "establecimiento_id": str(campo["est"]),
            "animal_id": str(campo["animal"]),
            "texto": "Escrita por el autor",
            "deleted_at": "2030-01-01T00:00:00Z",
            "updated_at": "2030-01-01T00:00:00Z",
        },
    )

    for resp in (delete, put, reenvio):
        assert resp.status_code == 403
        assert _codigo(resp) == "observacion_borrado_no_permitido"
    assert (await _texto_y_borrado(session, nota["id"]))[1] is None


@pytest.mark.anyio
async def test_un_employee_no_borra_una_nota_migrada(auth_client, campo):
    resp = await auth_client.delete(f"{_RUTA}/{campo['migrada']}")
    assert resp.status_code == 403
    assert _codigo(resp) == "observacion_borrado_no_permitido"


@pytest.mark.anyio
@pytest.mark.parametrize("quien", ["owner", "admin"])
async def test_owner_y_admin_borran_cualquiera(
    auth_client, session, campo, como, quien
):
    nota = await _nota_del_autor(auth_client, campo)
    como(campo[quien])

    ajena = await auth_client.delete(f"{_RUTA}/{nota['id']}")
    migrada = await auth_client.delete(f"{_RUTA}/{campo['migrada']}")

    assert ajena.status_code == migrada.status_code == 200
    assert (await _texto_y_borrado(session, nota["id"]))[1] is not None
    assert (await _texto_y_borrado(session, campo["migrada"]))[1] is not None


@pytest.mark.anyio
async def test_el_rol_se_evalua_en_el_establecimiento_de_la_observacion(
    auth_client, session, campo, como
):
    """Ser owner de otro establecimiento no habilita a borrar en este."""
    ajeno = _usuario("Vecino", "20555555556")
    session.add(ajeno)
    await session.flush()
    otro_campo = Establecimiento(owner_id=ajeno.id, nombre="Campo Vecino")
    session.add(otro_campo)
    await session.flush()
    for establecimiento_id, rol in (
        (otro_campo.id, RolUsuario.owner),
        (campo["est"], RolUsuario.employee),
    ):
        session.add(
            UsuarioEstablecimiento(
                usuario_id=ajeno.id,
                establecimiento_id=establecimiento_id,
                rol=rol,
                activo=True,
            )
        )
    await session.commit()
    nota = await _nota_del_autor(auth_client, campo)
    como(ajeno)

    resp = await auth_client.delete(f"{_RUTA}/{nota['id']}")
    assert resp.status_code == 403
