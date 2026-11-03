"""Cascada de observaciones cuando la base rechaza la escritura del animal (VITA-173).

La cascada solo modifica las observaciones en la sesión, y las persiste el
``save`` del animal. Si la base rechaza ese flush, el rechazo se traduce a su
error de dominio y el rollback revierte también las observaciones. La traducción
reconoce los diagnósticos de asyncpg, así que estos tests necesitan Postgres
real. Reusan el entorno de ``test_reglas_reproductivas_postgres``.

Se saltean si no está ``VITA_TEST_POSTGRES_URL`` (ver ``tests/postgres_helpers``).
"""

from datetime import UTC, datetime
from uuid import UUID, uuid4

import asyncpg
import pytest

from api.modules.animales import service as modulo_animales
from api.modules.animales.exceptions import (
    CaravanaDuplicadaError,
    CategoriaIncompatibleConSexoError,
)
from tests.postgres_helpers import requiere_postgres
from tests.test_reglas_reproductivas_postgres import (
    _CAMPO,
    _OWNER,
    _VACA,
    _alta_servicio,
    _service_sobre_postgres,
)

pytestmark = [requiere_postgres, pytest.mark.anyio]


async def _nota(conexion: asyncpg.Connection, animal_id: UUID) -> UUID:
    nota_id = uuid4()
    await conexion.execute(
        "insert into observaciones_animales"
        " (id, animal_id, establecimiento_id, texto, fecha, autor_id)"
        " values ($1, $2, $3, 'Nota', now(), $4)",
        nota_id,
        animal_id,
        _CAMPO,
        _OWNER,
    )
    return nota_id


async def _borrada(conexion: asyncpg.Connection, tabla: str, fila_id: UUID):
    return await conexion.fetchval(
        f"select deleted_at from {tabla} where id = $1", fila_id
    )


async def test_un_borrado_rechazado_por_la_base_no_deja_la_cascada_aplicada():
    """El reenvío del alta borra el animal pero también le pone la caravana de
    otro: la unicidad lo rechaza en el flush."""
    async with _service_sobre_postgres() as (session, usuario, conexion):
        servicio = modulo_animales.AnimalService(session)
        alta = _alta_servicio(id=uuid4(), updated_at="2026-06-01T00:00:00Z")
        otra = _alta_servicio()
        await servicio.crear(usuario, alta)
        await servicio.crear(usuario, otra)
        await session.commit()
        nota = await _nota(conexion, alta.id)

        reenvio = alta.model_copy(
            update={
                "nro_caravana_rfid": otra.nro_caravana_rfid,
                "deleted_at": datetime(2026, 9, 20, 12, tzinfo=UTC),
                "updated_at": datetime(2030, 1, 1, tzinfo=UTC),
            }
        )
        with pytest.raises(CaravanaDuplicadaError):
            await servicio.crear(usuario, reenvio)

        assert await _borrada(conexion, "animales", alta.id) is None
        assert await _borrada(conexion, "observaciones_animales", nota) is None


async def test_una_restauracion_rechazada_por_el_trigger_no_restaura_observaciones(
    monkeypatch,
):
    """Otra escritura cambia las cosas entre la validación del service y el flush:
    el trigger rechaza restaurar el animal con un sexo incompatible. Las
    observaciones borradas en cascada siguen borradas."""
    async with _service_sobre_postgres() as (session, usuario, conexion):
        servicio = modulo_animales.AnimalService(session)
        alta = _alta_servicio(
            id=uuid4(), categoria_id=_VACA, updated_at="2026-06-01T00:00:00Z"
        )
        await servicio.crear(usuario, alta)
        await session.commit()
        nota = await _nota(conexion, alta.id)
        await servicio.borrar(
            usuario, alta.id, deleted_at=datetime(2026, 9, 20, 12, tzinfo=UTC)
        )
        await session.commit()
        assert await _borrada(conexion, "observaciones_animales", nota) is not None

        monkeypatch.setattr(modulo_animales, "validar_combinacion", lambda *_: None)
        restauracion = alta.model_copy(
            update={
                "sexo": "macho",
                "deleted_at": None,
                "updated_at": datetime(2030, 1, 1, tzinfo=UTC),
            }
        )
        with pytest.raises(CategoriaIncompatibleConSexoError):
            await servicio.crear(usuario, restauracion)

        assert await _borrada(conexion, "animales", alta.id) is not None
        assert await _borrada(conexion, "observaciones_animales", nota) is not None


async def test_el_trigger_funciona_en_un_postgres_sin_supabase():
    """Fuera de Supabase no existe ``auth.uid()``. La regla de "solo el autor
    edita" del trigger no puede romper las escrituras del backend ahí (Postgres
    local con ``create_all``)."""
    async with _service_sobre_postgres() as (session, usuario, conexion):
        assert await conexion.fetchval("select to_regnamespace('auth')") is None, (
            "este test necesita una base sin el esquema auth"
        )
        servicio = modulo_animales.AnimalService(session)
        alta = _alta_servicio(id=uuid4())
        await servicio.crear(usuario, alta)
        await session.commit()
        nota = await _nota(conexion, alta.id)

        await conexion.execute(
            "update observaciones_animales set texto = 'Editada', fecha = now()"
            " where id = $1",
            nota,
        )
        assert (
            await conexion.fetchval(
                "select texto from observaciones_animales where id = $1", nota
            )
            == "Editada"
        )
