"""Garantías de ``observaciones_animales`` que solo Postgres puede probar (VITA-173).

El trigger de pertenencia e inmutabilidad y el RLS sobre ``auth.uid()`` no
existen en SQLite. La migración y el script espejo se aplican sobre una base con
animales que ya tienen ``animales.observaciones``, para probar también la
migración de datos.

Se saltean si no está ``VITA_TEST_POSTGRES_URL`` (ver ``tests/postgres_helpers``).
"""

from contextlib import asynccontextmanager
from datetime import UTC, datetime
import importlib.util
import os
from pathlib import Path
import subprocess
import sys
from uuid import UUID, uuid4

import asyncpg
import pytest
from sqlalchemy.ext.asyncio import create_async_engine
from sqlmodel import SQLModel

import api.modules  # noqa: F401  -- registra todas las tablas en la metadata
from tests.postgres_helpers import (
    base_temporal,
    como_usuario,
    instalar_auth_supabase,
    requiere_postgres,
    simular_privilegios_por_defecto,
    url_sqlalchemy,
)

pytestmark = [requiere_postgres, pytest.mark.anyio]

_BACKEND = Path(__file__).parent.parent
_MIGRACION = _BACKEND / "alembic/versions/20261001_03_crear_observaciones_animales.py"
_SCRIPT_SQL = _BACKEND / "scripts/crear_observaciones_animales.sql"
_REVISION_PREVIA = "20261001_02"
_REVISION = "20261001_03"
_TABLA = "observaciones_animales"

_MIEMBRO = UUID("00000000-0000-0000-0000-00000000000a")
_AJENO = UUID("00000000-0000-0000-0000-00000000000d")
_INACTIVO = UUID("00000000-0000-0000-0000-00000000000e")
# Más miembros del campo, para los permisos de edición y borrado.
_OTRO_EMPLEADO = UUID("00000000-0000-0000-0000-00000000000f")
_DUENO = UUID("00000000-0000-0000-0000-000000000010")
_ADMIN = UUID("00000000-0000-0000-0000-000000000011")
_CAMPO = UUID("00000000-0000-0000-0000-0000000000e1")
_CAMPO_AJENO = UUID("00000000-0000-0000-0000-0000000000e2")

_ALTA = datetime(2026, 3, 15, 9, 30, tzinfo=UTC)
_NOTA_LARGA = "Cojea de la pata trasera.\n  Revisar el viernes; ojo: 'casco' partido."


def _cargar_migracion():
    spec = importlib.util.spec_from_file_location("migracion_obs", _MIGRACION)
    assert spec is not None and spec.loader is not None
    modulo = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(modulo)
    return modulo


_MODULO_MIGRACION = _cargar_migracion()


async def _crear_esquema(url: str, *, incluir_observaciones: bool) -> None:
    engine = create_async_engine(url_sqlalchemy(url))
    tablas = [
        tabla
        for tabla in SQLModel.metadata.sorted_tables
        if incluir_observaciones or tabla.name != _TABLA
    ]
    try:
        async with engine.begin() as conn:
            await conn.run_sync(
                lambda sync: SQLModel.metadata.create_all(sync, tables=tablas)
            )
    finally:
        await engine.dispose()


def _alembic(url: str, *argumentos: str) -> subprocess.CompletedProcess:
    """Corre Alembic en un proceso aparte con la base descartable del test.

    ``DATABASE_URL`` del entorno le gana a ``backend/.env``, así que nunca toca
    la base configurada.
    """
    assert "supabase" not in url, "Nunca correr estos tests contra Supabase"
    entorno = {**os.environ, "DATABASE_URL": url_sqlalchemy(url)}
    return subprocess.run(
        [sys.executable, "-m", "alembic", *argumentos],
        cwd=_BACKEND,
        env=entorno,
        capture_output=True,
        text=True,
        check=False,
    )


async def _sembrar(conexion: asyncpg.Connection) -> dict[str, UUID]:
    """Usuarios, membresías y animales con todas las variantes de nota legacy."""
    for indice, usuario in enumerate(
        (_MIEMBRO, _AJENO, _INACTIVO, _OTRO_EMPLEADO, _DUENO, _ADMIN)
    ):
        await conexion.execute(
            "insert into usuarios (id, nombre, apellido, email, is_platform_admin)"
            " values ($1, 'Test', 'Sintético', $2, false)",
            usuario,
            f"usuario{indice}@example.test",
        )
    for campo, owner in ((_CAMPO, _MIEMBRO), (_CAMPO_AJENO, _AJENO)):
        await conexion.execute(
            "insert into establecimientos (id, owner_id, nombre) values ($1, $2, $3)",
            campo,
            owner,
            f"Campo {campo}",
        )
    for usuario, campo, rol, activo in (
        (_MIEMBRO, _CAMPO, "employee", True),
        (_INACTIVO, _CAMPO, "employee", False),
        (_OTRO_EMPLEADO, _CAMPO, "employee", True),
        (_DUENO, _CAMPO, "owner", True),
        (_ADMIN, _CAMPO, "admin", True),
        (_AJENO, _CAMPO_AJENO, "employee", True),
    ):
        await conexion.execute(
            "insert into usuarios_establecimientos"
            " (id, usuario_id, establecimiento_id, rol, activo)"
            " values ($1, $2, $3, $4, $5)",
            uuid4(),
            usuario,
            campo,
            rol,
            activo,
        )

    animales = {
        "con_nota": (_CAMPO, _NOTA_LARGA, None),
        "borrado_con_nota": (_CAMPO, "Murió en la seca", _ALTA),
        "nota_en_blanco": (_CAMPO, "   ", None),
        "sin_nota": (_CAMPO, None, None),
        "ajeno": (_CAMPO_AJENO, "Nota del vecino", None),
    }
    ids = {}
    for nombre, (campo, nota, borrado) in animales.items():
        ids[nombre] = uuid4()
        await conexion.execute(
            "insert into animales (id, establecimiento_id, sexo, estado,"
            " observaciones, created_at, updated_at, deleted_at)"
            " values ($1, $2, 'hembra', 'activo', $3, $4, $4, $5)",
            ids[nombre],
            campo,
            nota,
            _ALTA,
            borrado,
        )
    return ids


async def _materializar(url: str, camino: str) -> dict[str, UUID]:
    conexion = await asyncpg.connect(url)
    try:
        await instalar_auth_supabase(conexion)
        await simular_privilegios_por_defecto(conexion)
    finally:
        await conexion.close()

    await _crear_esquema(url, incluir_observaciones=camino == "create_all")
    conexion = await asyncpg.connect(url)
    try:
        # Estado real de Supabase: RLS activo sin policies en las tablas que lee
        # el trigger. Un cliente directo no ve ningún animal; el backend, todos.
        await conexion.execute("alter table animales enable row level security")
        ids = await _sembrar(conexion)
        if camino == "script":
            await conexion.execute(_SCRIPT_SQL.read_text(encoding="utf-8"))
    finally:
        await conexion.close()

    if camino == "migracion":
        assert _alembic(url, "stamp", _REVISION_PREVIA).returncode == 0
        resultado = _alembic(url, "upgrade", _REVISION)
        assert resultado.returncode == 0, resultado.stderr
    return ids


@asynccontextmanager
async def _base(camino: str):
    async with base_temporal() as url:
        ids = await _materializar(url, camino)
        conexion = await asyncpg.connect(url)
        try:
            yield url, conexion, ids
        finally:
            await conexion.close()


async def _insertar(
    conexion: asyncpg.Connection,
    animal_id: UUID,
    *,
    establecimiento_id: UUID = _CAMPO,
    autor_id: UUID | None = _MIEMBRO,
    texto: str = "Nota",
) -> UUID:
    observacion_id = uuid4()
    await conexion.execute(
        f"insert into {_TABLA} (id, animal_id, establecimiento_id, texto, fecha,"
        " autor_id) values ($1, $2, $3, $4, now(), $5)",
        observacion_id,
        animal_id,
        establecimiento_id,
        texto,
        autor_id,
    )
    return observacion_id


# ----------------------------------------------------- migración de datos


@pytest.mark.parametrize("camino", ("migracion", "script"))
async def test_migra_cada_nota_no_vacia_sin_inventar_autor_ni_fecha(camino):
    async with _base(camino) as (_, conexion, ids):
        filas = await conexion.fetch(
            f"select id, animal_id, texto, fecha, autor_id, deleted_at,"
            f" updated_at from {_TABLA}"
        )

    por_animal = {f["animal_id"]: f for f in filas}
    assert set(por_animal) == {ids["con_nota"], ids["borrado_con_nota"], ids["ajeno"]}

    nota = por_animal[ids["con_nota"]]
    assert nota["texto"] == _NOTA_LARGA
    assert nota["autor_id"] is None
    assert nota["fecha"] == _ALTA
    assert nota["deleted_at"] is None
    # Las bajan los clientes en su próximo pull delta.
    assert nota["updated_at"] > _ALTA
    assert nota["id"] == _MODULO_MIGRACION.id_observacion_legacy(ids["con_nota"])

    assert por_animal[ids["borrado_con_nota"]]["deleted_at"] == _ALTA


@pytest.mark.parametrize("camino", ("migracion", "script"))
async def test_reejecutar_la_migracion_de_datos_no_duplica(camino):
    async with _base(camino) as (url, conexion, _):
        antes = await conexion.fetchval(f"select count(*) from {_TABLA}")
        if camino == "script":
            await conexion.execute(_SCRIPT_SQL.read_text(encoding="utf-8"))
        else:
            assert _alembic(url, "stamp", _REVISION_PREVIA).returncode == 0
            resultado = _alembic(url, "upgrade", _REVISION)
            assert resultado.returncode == 0, resultado.stderr
        despues = await conexion.fetchval(f"select count(*) from {_TABLA}")
    assert antes == despues == 3


async def test_migracion_y_script_generan_los_mismos_ids():
    async with _base("migracion") as (_, conexion, _ids):
        por_migracion = {
            r["animal_id"]: r["id"]
            for r in await conexion.fetch(f"select animal_id, id from {_TABLA}")
        }
        por_sql = {
            r["id"]: r["legacy"]
            for r in await conexion.fetch(
                "select id, md5('observacion_legacy:' || id::text)::uuid as legacy"
                " from animales"
            )
        }
    for animal_id, observacion_id in por_migracion.items():
        assert por_sql[animal_id] == observacion_id


async def test_migracion_tiene_downgrade():
    async with _base("migracion") as (url, conexion, _):
        resultado = _alembic(url, "downgrade", _REVISION_PREVIA)
        assert resultado.returncode == 0, resultado.stderr
        existe = await conexion.fetchval(f"select to_regclass('public.{_TABLA}')")
        notas = await conexion.fetchval(
            "select count(*) from animales where observaciones is not null"
        )
    assert existe is None
    # La columna vieja nunca se tocó.
    assert notas == 4


# --------------------------------------------------------------- trigger

_CAMINOS = ("create_all", "migracion", "script")


@pytest.mark.parametrize("camino", _CAMINOS)
async def test_animal_y_observacion_del_mismo_establecimiento(camino):
    async with _base(camino) as (_, conexion, ids):
        with pytest.raises(asyncpg.CheckViolationError, match="otro establecimiento"):
            await _insertar(conexion, ids["ajeno"], establecimiento_id=_CAMPO)


@pytest.mark.parametrize("camino", _CAMINOS)
async def test_animal_establecimiento_y_autor_son_inmutables(camino):
    async with _base(camino) as (_, conexion, ids):
        observacion_id = await _insertar(conexion, ids["con_nota"])
        for columna, valor in (
            ("animal_id", ids["sin_nota"]),
            ("establecimiento_id", _CAMPO_AJENO),
            ("autor_id", _AJENO),
        ):
            with pytest.raises(asyncpg.CheckViolationError, match="no puede cambiar"):
                await conexion.execute(
                    f"update {_TABLA} set {columna} = $2 where id = $1",
                    observacion_id,
                    valor,
                )
        # El texto y la fecha sí se editan.
        await conexion.execute(
            f"update {_TABLA} set texto = 'Editada' where id = $1", observacion_id
        )


@pytest.mark.parametrize("camino", _CAMINOS)
@pytest.mark.parametrize("texto", ["", "   "])
async def test_texto_vacio_se_rechaza(camino, texto):
    async with _base(camino) as (_, conexion, ids):
        with pytest.raises(asyncpg.CheckViolationError):
            await _insertar(conexion, ids["con_nota"], texto=texto)


# -------------------------------------------------------------------- RLS


@pytest.mark.parametrize("camino", ("migracion", "script"))
async def test_miembro_lee_solo_las_de_su_establecimiento(camino):
    async with _base(camino) as (_, conexion, ids):
        async with como_usuario(conexion, _MIEMBRO) as cliente:
            animales = {
                r["animal_id"] for r in await cliente.fetch(f"select * from {_TABLA}")
            }
        async with como_usuario(conexion, _INACTIVO) as cliente:
            inactivo = await cliente.fetch(f"select * from {_TABLA}")
        async with como_usuario(conexion, None) as cliente:
            with pytest.raises(asyncpg.InsufficientPrivilegeError):
                await cliente.fetch(f"select * from {_TABLA}")

    assert animales == {ids["con_nota"], ids["borrado_con_nota"]}
    assert inactivo == []


@pytest.mark.parametrize("camino", ("migracion", "script"))
async def test_miembro_escribe_como_si_mismo_y_no_en_campo_ajeno(camino):
    async with _base(camino) as (_, conexion, ids):
        async with como_usuario(conexion, _MIEMBRO) as cliente:
            await _insertar(cliente, ids["con_nota"], autor_id=_MIEMBRO)

        async with como_usuario(conexion, _MIEMBRO) as cliente:
            with pytest.raises(asyncpg.InsufficientPrivilegeError):
                await _insertar(cliente, ids["con_nota"], autor_id=_AJENO)

        async with como_usuario(conexion, _MIEMBRO) as cliente:
            with pytest.raises(asyncpg.InsufficientPrivilegeError):
                await _insertar(
                    cliente,
                    ids["ajeno"],
                    establecimiento_id=_CAMPO_AJENO,
                    autor_id=_MIEMBRO,
                )

        async with como_usuario(conexion, _AJENO) as cliente:
            editadas = await cliente.execute(
                f"update {_TABLA} set texto = 'Pisada' where establecimiento_id = $1",
                _CAMPO,
            )
        assert editadas == "UPDATE 0"


async def _actualizar(conexion, usuario, observacion_id, asignacion) -> str:
    """Corre un UPDATE como cliente directo; devuelve el resultado o el SQLSTATE."""
    async with como_usuario(conexion, usuario) as cliente:
        try:
            return await cliente.execute(
                f"update {_TABLA} set {asignacion} where id = $1", observacion_id
            )
        except asyncpg.PostgresError as exc:
            return exc.sqlstate


@pytest.mark.parametrize("camino", ("migracion", "script"))
async def test_rls_solo_el_autor_edita(camino):
    async with _base(camino) as (_, conexion, ids):
        nota = await _insertar(conexion, ids["sin_nota"], autor_id=_MIEMBRO)
        texto = "texto = 'Pisada'"
        resultados = {
            # El RLS ni siquiera le muestra la fila para actualizar.
            "otro employee": await _actualizar(conexion, _OTRO_EMPLEADO, nota, texto),
            # Owner y admin pueden actualizarla (para borrarla), pero no editarla.
            "owner": await _actualizar(conexion, _DUENO, nota, texto),
            "admin": await _actualizar(conexion, _ADMIN, nota, texto),
            "autor": await _actualizar(conexion, _MIEMBRO, nota, "texto = 'Mía'"),
        }

    assert resultados == {
        "otro employee": "UPDATE 0",
        "owner": "42501",
        "admin": "42501",
        "autor": "UPDATE 1",
    }


@pytest.mark.parametrize("camino", ("migracion", "script"))
async def test_rls_nadie_edita_una_nota_migrada(camino):
    async with _base(camino) as (_, conexion, ids):
        migrada = await conexion.fetchval(
            f"select id from {_TABLA} where animal_id = $1", ids["con_nota"]
        )
        resultados = [
            await _actualizar(conexion, usuario, migrada, "fecha = now()")
            for usuario in (_MIEMBRO, _DUENO, _ADMIN)
        ]
    assert resultados == ["UPDATE 0", "42501", "42501"]


@pytest.mark.parametrize("camino", ("migracion", "script"))
async def test_rls_borrado_logico_por_autor_owner_y_admin(camino):
    async with _base(camino) as (_, conexion, ids):
        migrada = await conexion.fetchval(
            f"select id from {_TABLA} where animal_id = $1", ids["con_nota"]
        )
        borrar = "deleted_at = now(), updated_at = now()"
        notas = [
            await _insertar(conexion, ids["sin_nota"], autor_id=_MIEMBRO)
            for _ in range(4)
        ]
        resultados = {
            "otro employee, ajena": await _actualizar(
                conexion, _OTRO_EMPLEADO, notas[0], borrar
            ),
            "employee, migrada": await _actualizar(conexion, _MIEMBRO, migrada, borrar),
            "autor, propia": await _actualizar(conexion, _MIEMBRO, notas[1], borrar),
            "owner, ajena": await _actualizar(conexion, _DUENO, notas[2], borrar),
            "admin, ajena": await _actualizar(conexion, _ADMIN, notas[3], borrar),
            "owner, migrada": await _actualizar(conexion, _DUENO, migrada, borrar),
        }
        async with como_usuario(conexion, _DUENO) as cliente:
            with pytest.raises(asyncpg.InsufficientPrivilegeError):
                await cliente.execute(f"delete from {_TABLA}")

    assert resultados == {
        "otro employee, ajena": "UPDATE 0",
        "employee, migrada": "UPDATE 0",
        "autor, propia": "UPDATE 1",
        "owner, ajena": "UPDATE 1",
        "admin, ajena": "UPDATE 1",
        "owner, migrada": "UPDATE 1",
    }


@pytest.mark.parametrize("camino", ("migracion", "script"))
async def test_un_miembro_no_aprende_nada_de_animales_ajenos(camino):
    """El trigger corre antes que el WITH CHECK del RLS: no puede revelar animales.

    Un miembro del campo A carga una observación apuntando a animales que no le
    pertenecen. Sea de otro establecimiento, inexistente, o con el
    establecimiento ajeno declarado, el rechazo tiene que ser siempre el mismo:
    el del RLS.
    """
    async with _base(camino) as (_, conexion, ids):
        intentos = (
            ("animal ajeno en mi campo", ids["ajeno"], _CAMPO),
            ("animal inexistente en mi campo", uuid4(), _CAMPO),
            ("animal ajeno en su campo", ids["ajeno"], _CAMPO_AJENO),
            ("animal inexistente en campo ajeno", uuid4(), _CAMPO_AJENO),
            ("animal mío declarado en campo ajeno", ids["con_nota"], _CAMPO_AJENO),
        )
        errores = {}
        for nombre, animal_id, campo in intentos:
            async with como_usuario(conexion, _MIEMBRO) as cliente:
                try:
                    await _insertar(cliente, animal_id, establecimiento_id=campo)
                except asyncpg.PostgresError as exc:
                    errores[nombre] = (exc.sqlstate, str(exc))
                else:
                    errores[nombre] = ("sin error", "")

        # Con un animal propio, el mismo cliente sí puede.
        async with como_usuario(conexion, _MIEMBRO) as cliente:
            await _insertar(cliente, ids["con_nota"])

    assert {estado for estado, _ in errores.values()} == {"42501"}, errores
    assert len({mensaje for _, mensaje in errores.values()}) == 1, errores


@pytest.mark.parametrize("camino", ("migracion", "script"))
async def test_la_funcion_de_pertenencia_no_sirve_para_sondear(camino):
    """La función que usa la policy es invocable por ``authenticated``: fuera de
    sus propios establecimientos, siempre responde falso."""
    async with _base(camino) as (_, conexion, ids):
        consulta = "select public.animal_pertenece_a_establecimiento($1, $2)"
        async with como_usuario(conexion, _MIEMBRO) as cliente:
            propio = await cliente.fetchval(consulta, ids["con_nota"], _CAMPO)
            ajeno = await cliente.fetchval(consulta, ids["ajeno"], _CAMPO_AJENO)
        async with como_usuario(conexion, None) as cliente:
            with pytest.raises(asyncpg.InsufficientPrivilegeError):
                await cliente.fetchval(consulta, ids["ajeno"], _CAMPO_AJENO)

    assert propio is True
    assert ajeno is False
