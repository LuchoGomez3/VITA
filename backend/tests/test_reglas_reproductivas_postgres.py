"""Garantías de sexo y condición reproductiva que solo Postgres puede probar (VITA-173).

La compatibilidad del animal con su categoría es un trigger plpgsql entre
tablas; SQLite no lo ejecuta. Cada test materializa el esquema por uno de los
tres caminos del proyecto —``create_all``, la migración Alembic y el script
espejo— y verifica que los tres se comporten igual. La migración y el script se
aplican sobre un esquema "legacy" (sin las columnas nuevas) con los datos que hoy
tiene Supabase, para probar también la clasificación y los abortos.

Se saltean si no está ``VITA_TEST_POSTGRES_URL`` (ver ``tests/postgres_helpers``).
"""

from contextlib import asynccontextmanager
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
from tests.postgres_helpers import base_temporal, requiere_postgres, url_sqlalchemy

pytestmark = [requiere_postgres, pytest.mark.anyio]

_BACKEND = Path(__file__).parent.parent
_SCRIPT_SQL = _BACKEND / "scripts/agregar_reglas_reproductivas_categorias.sql"
_REVISION_PREVIA = "20260910_02"
_REVISION = "20261001_02"

_OWNER = UUID("00000000-0000-0000-0000-00000000000a")
_CAMPO = UUID("00000000-0000-0000-0000-0000000000e1")
_CAMPO_AJENO = UUID("00000000-0000-0000-0000-0000000000e2")

# Mismos ids que las categorías de Supabase que clasifica la migración.
_TERNERO = UUID("550e8400-e29b-41d4-a716-446655440030")
_NOVILLO = UUID("550e8400-e29b-41d4-a716-446655440031")
_VACA = UUID("550e8400-e29b-41d4-a716-446655440032")
_TORO = UUID("550e8400-e29b-41d4-a716-446655440033")
_ENGORDE = UUID("550e8400-e29b-41d4-a716-446655440034")

# Catálogo global sembrado por la migración: las categorías del front.
_G_TERNERA = UUID("d37e62fb-96db-4ff1-a26b-0e3b2c3b36d8")
_G_TERNERO = UUID("b9a6e57b-20ae-49b1-a7bb-17c71af546f3")
_G_VAQUILLONA = UUID("b6d6440c-88c6-48cc-9003-0ad2cc05f3d5")
_G_VACA = UUID("ef69117b-c979-4665-b13f-2b26ff0f19b3")
_G_NOVILLO = UUID("41da4271-bd25-4ba0-ba34-24dc6586f0f2")
_G_TORO = UUID("b5e8ea91-9789-4f7e-9dad-10262f1920f4")
_CATALOGO_GLOBAL = {
    _G_TERNERA: ("Ternera", "hembra", False),
    _G_TERNERO: ("Ternero", "macho", False),
    _G_VAQUILLONA: ("Vaquillona", "hembra", True),
    _G_VACA: ("Vaca", "hembra", True),
    _G_NOVILLO: ("Novillo", "macho", False),
    _G_TORO: ("Toro", "macho", False),
}

_CAMINOS = ("create_all", "migracion", "script")

# Deshace lo que agrega 20261001_02 para reconstruir el esquema anterior.
_A_ESQUEMA_LEGACY = (
    "drop trigger if exists trg_animales_categoria_compatible on animales",
    "drop trigger if exists trg_categorias_reglas_compatibles on categorias",
    "drop function if exists validar_categoria_animal()",
    "drop function if exists validar_reglas_categoria()",
    "alter table animales drop constraint ck_animales_estado_reproductivo_valido",
    "alter table animales drop constraint ck_animales_estado_reproductivo_solo_hembras",
    "alter table animales drop column estado_reproductivo",
    "alter table categorias drop constraint ck_categorias_sexo_permitido_valido",
    "alter table categorias drop column sexo_permitido",
    "alter table categorias drop column permite_estado_reproductivo",
)


async def _crear_esquema(url: str) -> None:
    engine = create_async_engine(url_sqlalchemy(url))
    try:
        async with engine.begin() as conn:
            await conn.run_sync(SQLModel.metadata.create_all)
    finally:
        await engine.dispose()


def _alembic(url: str, *argumentos: str) -> subprocess.CompletedProcess:
    """Corre Alembic en un proceso aparte con la base descartable del test.

    ``DATABASE_URL`` del entorno le gana a ``backend/.env`` (``load_dotenv`` no
    pisa variables existentes), así que nunca toca la base configurada.
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


async def _sembrar_base(conexion: asyncpg.Connection) -> None:
    await conexion.execute(
        "insert into usuarios (id, nombre, apellido, email, is_platform_admin)"
        " values ($1, 'Test', 'Sintético', 'owner@example.test', false)",
        _OWNER,
    )
    for campo in (_CAMPO, _CAMPO_AJENO):
        await conexion.execute(
            "insert into establecimientos (id, owner_id, nombre) values ($1, $2, $3)",
            campo,
            _OWNER,
            f"Campo {campo}",
        )


async def _sembrar_categorias_legacy(
    conexion: asyncpg.Connection, extra: tuple[tuple[UUID, str], ...] = ()
) -> None:
    """Las cinco categorías de Supabase, todavía sin reglas."""
    categorias = (
        (_TERNERO, "Ternero"),
        (_NOVILLO, "Novillo"),
        (_VACA, "Vaca"),
        (_TORO, "Toro"),
        (_ENGORDE, "Engorde Rápido"),
        *extra,
    )
    for categoria_id, nombre in categorias:
        await conexion.execute(
            "insert into categorias (id, establecimiento_id, nombre)"
            " values ($1, $2, $3)",
            categoria_id,
            _CAMPO,
            nombre,
        )


async def _insertar_animal(
    conexion: asyncpg.Connection,
    sexo: str,
    categoria_id: UUID | None,
    *,
    estado_reproductivo: str | None = None,
    establecimiento_id: UUID = _CAMPO,
    legacy: bool = False,
) -> UUID:
    animal_id = uuid4()
    columnas = "id, establecimiento_id, sexo, categoria_id, estado"
    valores = "$1, $2, $3, $4, 'activo'"
    parametros = [animal_id, establecimiento_id, sexo, categoria_id]
    if not legacy:
        columnas += ", estado_reproductivo"
        valores += ", $5"
        parametros.append(estado_reproductivo)
    await conexion.execute(
        f"insert into animales ({columnas}) values ({valores})", *parametros
    )
    return animal_id


async def _sembrar_animales_legacy(conexion: asyncpg.Connection) -> None:
    """Réplica de los datos de Supabase: Ternero tiene 2 hembras."""
    for sexo, categoria, cantidad in (
        ("hembra", _TERNERO, 2),
        ("macho", _NOVILLO, 5),
        ("hembra", _VACA, 4),
        ("macho", _TORO, 3),
    ):
        for _ in range(cantidad):
            await _insertar_animal(conexion, sexo, categoria, legacy=True)


async def _materializar(url: str, camino: str) -> None:
    await _crear_esquema(url)
    conexion = await asyncpg.connect(url)
    try:
        await _sembrar_base(conexion)
        if camino == "create_all":
            await conexion.execute(
                "insert into categorias (id, establecimiento_id, nombre,"
                " sexo_permitido, permite_estado_reproductivo) values"
                " ($1, $6, 'Ternero', 'ambos', false),"
                " ($2, $6, 'Novillo', 'macho', false),"
                " ($3, $6, 'Vaca', 'hembra', true),"
                " ($4, $6, 'Toro', 'macho', false),"
                " ($5, $6, 'Engorde Rápido', 'ambos', false)",
                _TERNERO,
                _NOVILLO,
                _VACA,
                _TORO,
                _ENGORDE,
                _CAMPO,
            )
            # create_all no siembra datos: se cargan a mano para que los tres
            # caminos partan del mismo catálogo.
            for categoria_id, (nombre, sexo, permite) in _CATALOGO_GLOBAL.items():
                await conexion.execute(
                    "insert into categorias (id, establecimiento_id, nombre,"
                    " sexo_permitido, permite_estado_reproductivo)"
                    " values ($1, null, $2, $3, $4)",
                    categoria_id,
                    nombre,
                    sexo,
                    permite,
                )
            return
        for sentencia in _A_ESQUEMA_LEGACY:
            await conexion.execute(sentencia)
        await _sembrar_categorias_legacy(conexion)
        await _sembrar_animales_legacy(conexion)
        if camino == "script":
            await conexion.execute(_SCRIPT_SQL.read_text(encoding="utf-8"))
    finally:
        await conexion.close()

    if camino == "migracion":
        assert _alembic(url, "stamp", _REVISION_PREVIA).returncode == 0
        resultado = _alembic(url, "upgrade", _REVISION)
        assert resultado.returncode == 0, resultado.stderr


@asynccontextmanager
async def _base(camino: str):
    async with base_temporal() as url:
        await _materializar(url, camino)
        conexion = await asyncpg.connect(url)
        try:
            yield url, conexion
        finally:
            await conexion.close()


async def _reglas(conexion: asyncpg.Connection) -> dict[UUID, tuple[str, bool]]:
    filas = await conexion.fetch(
        "select id, sexo_permitido, permite_estado_reproductivo from categorias"
    )
    return {
        f["id"]: (f["sexo_permitido"], f["permite_estado_reproductivo"]) for f in filas
    }


# ------------------------------------------------------ clasificación


@pytest.mark.parametrize("camino", ("migracion", "script"))
async def test_clasifica_las_categorias_de_supabase(camino):
    async with _base(camino) as (_, conexion):
        reglas = await _reglas(conexion)

    assert reglas == {
        **{
            cid: (sexo, permite) for cid, (_, sexo, permite) in _CATALOGO_GLOBAL.items()
        },
        # Datos de prueba heredados. El "Ternero" de prueba queda en ambos porque
        # tiene hembras asignadas; el del catálogo es solo macho.
        _TERNERO: ("ambos", False),
        _NOVILLO: ("macho", False),
        _VACA: ("hembra", True),
        _TORO: ("macho", False),
        _ENGORDE: ("ambos", False),
    }


@pytest.mark.parametrize("camino", ("migracion", "script"))
async def test_ternero_conserva_sus_hembras_y_sigue_editable(camino):
    async with _base(camino) as (_, conexion):
        hembras = await conexion.fetch(
            "select id from animales where categoria_id = $1 and sexo = 'hembra'",
            _TERNERO,
        )
        assert len(hembras) == 2
        # El trigger no las rechaza: la clasificación es compatible con los datos.
        await conexion.execute(
            "update animales set sexo = sexo, categoria_id = categoria_id"
            " where categoria_id = $1",
            _TERNERO,
        )
        # Pero un ternero no se preña.
        with pytest.raises(asyncpg.CheckViolationError, match="no admite"):
            await conexion.execute(
                "update animales set estado_reproductivo = 'prenada' where id = $1",
                hembras[0]["id"],
            )


async def test_script_es_reejecutable():
    async with _base("script") as (_, conexion):
        await conexion.execute(
            "update categorias set sexo_permitido = 'ambos' where id = $1", _TORO
        )
        await conexion.execute(_SCRIPT_SQL.read_text(encoding="utf-8"))
        # No pisa una clasificación posterior ni duplica el catálogo.
        assert (await _reglas(conexion))[_TORO] == ("ambos", False)
        globales = await conexion.fetchval(
            "select count(*) from categorias where establecimiento_id is null"
        )
    assert globales == len(_CATALOGO_GLOBAL)


@pytest.mark.parametrize("camino", ("migracion", "script"))
async def test_siembra_el_catalogo_global_del_front(camino):
    async with _base(camino) as (_, conexion):
        filas = await conexion.fetch(
            "select id, nombre, sexo_permitido, permite_estado_reproductivo,"
            " deleted_at from categorias where establecimiento_id is null"
        )

    assert {
        f["id"]: (f["nombre"], f["sexo_permitido"], f["permite_estado_reproductivo"])
        for f in filas
    } == _CATALOGO_GLOBAL
    assert all(f["deleted_at"] is None for f in filas)


@pytest.mark.parametrize("camino", ("migracion", "script"))
async def test_global_preexistente_se_clasifica_sin_duplicarse(camino):
    async with base_temporal() as url:
        await _crear_esquema(url)
        conexion = await asyncpg.connect(url)
        try:
            await _sembrar_base(conexion)
            for sentencia in _A_ESQUEMA_LEGACY:
                await conexion.execute(sentencia)
            await _sembrar_categorias_legacy(conexion)
            # La Vaca global ya existía, sin reglas y con otro nombre visible.
            await conexion.execute(
                "insert into categorias (id, establecimiento_id, nombre)"
                " values ($1, null, 'Vaca adulta')",
                _G_VACA,
            )
            if camino == "script":
                await conexion.execute(_SCRIPT_SQL.read_text(encoding="utf-8"))
        finally:
            await conexion.close()

        if camino == "migracion":
            assert _alembic(url, "stamp", _REVISION_PREVIA).returncode == 0
            resultado = _alembic(url, "upgrade", _REVISION)
            assert resultado.returncode == 0, resultado.stderr

        conexion = await asyncpg.connect(url)
        try:
            fila = await conexion.fetchrow(
                "select nombre, sexo_permitido, permite_estado_reproductivo"
                " from categorias where id = $1",
                _G_VACA,
            )
            globales = await conexion.fetchval(
                "select count(*) from categorias where establecimiento_id is null"
            )
        finally:
            await conexion.close()

    # Conserva su nombre: la siembra no pisa una fila existente.
    assert tuple(fila) == ("Vaca adulta", "hembra", True)
    assert globales == len(_CATALOGO_GLOBAL)


def _bloque_de_limpieza() -> str:
    """El paso manual del script, sin los comentarios que lo desactivan."""
    script = _SCRIPT_SQL.read_text(encoding="utf-8")
    bloque = script[
        script.index("-- INICIO LIMPIEZA") : script.index("-- FIN LIMPIEZA")
    ].splitlines()[1:]
    return "\n".join(linea.removeprefix("--").removeprefix(" ") for linea in bloque)


async def test_limpieza_manual_de_datos_de_prueba():
    async with _base("script") as (_, conexion):
        for _ in range(2):  # Idempotente: la segunda pasada no cambia nada.
            await conexion.execute(_bloque_de_limpieza())

        en_ternero_prueba = await conexion.fetch(
            "select sexo from animales where categoria_id = $1", _TERNERO
        )
        en_ternera = await conexion.fetchval(
            "select count(*) from animales where categoria_id = $1", _G_TERNERA
        )
        engorde = await conexion.fetchval(
            "select deleted_at from categorias where id = $1", _ENGORDE
        )

    assert en_ternero_prueba == []
    assert en_ternera == 2
    assert engorde is not None


async def test_limpieza_no_borra_engorde_si_tiene_animales():
    async with _base("script") as (_, conexion):
        await _insertar_animal(conexion, "macho", _ENGORDE)
        await conexion.execute(_bloque_de_limpieza())
        engorde = await conexion.fetchval(
            "select deleted_at from categorias where id = $1", _ENGORDE
        )
    assert engorde is None


async def test_migracion_aborta_con_una_categoria_sin_clasificar():
    async with base_temporal() as url:
        await _crear_esquema(url)
        conexion = await asyncpg.connect(url)
        try:
            await _sembrar_base(conexion)
            for sentencia in _A_ESQUEMA_LEGACY:
                await conexion.execute(sentencia)
            await _sembrar_categorias_legacy(
                conexion, extra=((uuid4(), "Recría nueva"),)
            )
        finally:
            await conexion.close()

        assert _alembic(url, "stamp", _REVISION_PREVIA).returncode == 0
        resultado = _alembic(url, "upgrade", _REVISION)

    assert resultado.returncode != 0
    assert "Recría nueva" in resultado.stderr
    assert "_CLASIFICACION" in resultado.stderr


@pytest.mark.parametrize("camino", ("migracion", "script"))
async def test_aborta_si_la_clasificacion_deja_animales_incompatibles(camino):
    async with base_temporal() as url:
        await _crear_esquema(url)
        conexion = await asyncpg.connect(url)
        try:
            await _sembrar_base(conexion)
            for sentencia in _A_ESQUEMA_LEGACY:
                await conexion.execute(sentencia)
            await _sembrar_categorias_legacy(conexion)
            # Un macho en "Vaca": dato inválido que hay que resolver a mano.
            await _insertar_animal(conexion, "macho", _VACA, legacy=True)
            if camino == "script":
                with pytest.raises(asyncpg.RaiseError, match="sexo incompatible"):
                    await conexion.execute(_SCRIPT_SQL.read_text(encoding="utf-8"))
                # El script es transaccional: tras el rollback que hace el
                # cliente, no quedan columnas a medio crear.
                await conexion.execute("rollback")
                columnas = await conexion.fetch(
                    "select column_name from information_schema.columns"
                    " where table_name = 'categorias'"
                    " and column_name = 'sexo_permitido'"
                )
                assert columnas == []
                return
        finally:
            await conexion.close()

        assert _alembic(url, "stamp", _REVISION_PREVIA).returncode == 0
        resultado = _alembic(url, "upgrade", _REVISION)

    assert resultado.returncode != 0
    assert "1 macho(s) en 'Vaca'" in resultado.stderr


async def test_migracion_tiene_downgrade():
    async with _base("migracion") as (url, conexion):
        resultado = _alembic(url, "downgrade", _REVISION_PREVIA)
        assert resultado.returncode == 0, resultado.stderr
        columnas = await conexion.fetch(
            "select table_name, column_name from information_schema.columns"
            " where column_name in ('sexo_permitido',"
            " 'permite_estado_reproductivo', 'estado_reproductivo')"
        )
        triggers = await conexion.fetch(
            "select tgname from pg_trigger where tgname like 'trg_%_compatible%'"
        )
    assert columnas == []
    assert triggers == []


# ----------------------------------------------------------- triggers


@pytest.mark.parametrize("camino", _CAMINOS)
async def test_un_macho_nunca_queda_prenado(camino):
    async with _base(camino) as (_, conexion):
        with pytest.raises(asyncpg.CheckViolationError):
            await _insertar_animal(
                conexion, "macho", _TERNERO, estado_reproductivo="prenada"
            )


@pytest.mark.parametrize("camino", _CAMINOS)
async def test_hembra_en_categoria_habilitada_puede_estar_prenada(camino):
    async with _base(camino) as (_, conexion):
        animal_id = await _insertar_animal(conexion, "hembra", _VACA)
        await conexion.execute(
            "update animales set estado_reproductivo = 'prenada' where id = $1",
            animal_id,
        )
        estado = await conexion.fetchval(
            "select estado_reproductivo from animales where id = $1", animal_id
        )
    assert estado == "prenada"


@pytest.mark.parametrize("camino", _CAMINOS)
async def test_escritura_directa_con_categoria_de_otro_sexo_se_rechaza(camino):
    async with _base(camino) as (_, conexion):
        with pytest.raises(asyncpg.CheckViolationError, match="no es compatible"):
            await _insertar_animal(conexion, "macho", _VACA)

        animal_id = await _insertar_animal(conexion, "hembra", _VACA)
        with pytest.raises(asyncpg.CheckViolationError, match="no es compatible"):
            await conexion.execute(
                "update animales set categoria_id = $2 where id = $1",
                animal_id,
                _TORO,
            )
        categoria = await conexion.fetchval(
            "select categoria_id from animales where id = $1", animal_id
        )
    assert categoria == _VACA


@pytest.mark.parametrize("camino", _CAMINOS)
async def test_condicion_sin_categoria_solo_sin_determinar(camino):
    async with _base(camino) as (_, conexion):
        await _insertar_animal(
            conexion, "hembra", None, estado_reproductivo="sin_determinar"
        )
        with pytest.raises(asyncpg.CheckViolationError, match="requiere"):
            await _insertar_animal(
                conexion, "hembra", None, estado_reproductivo="vacia"
            )


@pytest.mark.parametrize("camino", _CAMINOS)
async def test_valor_reproductivo_desconocido_se_rechaza(camino):
    async with _base(camino) as (_, conexion):
        with pytest.raises(asyncpg.CheckViolationError):
            await _insertar_animal(
                conexion, "hembra", _VACA, estado_reproductivo="servida"
            )


@pytest.mark.parametrize("camino", _CAMINOS)
async def test_no_se_asigna_categoria_borrada_ni_ajena(camino):
    async with _base(camino) as (_, conexion):
        await conexion.execute(
            "update categorias set deleted_at = now() where id = $1", _ENGORDE
        )
        with pytest.raises(asyncpg.CheckViolationError, match="eliminada"):
            await _insertar_animal(conexion, "macho", _ENGORDE)
        with pytest.raises(asyncpg.CheckViolationError, match="otro establecimiento"):
            await _insertar_animal(
                conexion, "macho", _TORO, establecimiento_id=_CAMPO_AJENO
            )


@pytest.mark.parametrize("camino", _CAMINOS)
async def test_no_se_restringe_una_categoria_con_animales_incompatibles(camino):
    async with _base(camino) as (_, conexion):
        await _insertar_animal(conexion, "hembra", _TERNERO)
        with pytest.raises(asyncpg.CheckViolationError, match="incompatibles"):
            await conexion.execute(
                "update categorias set sexo_permitido = 'macho' where id = $1",
                _TERNERO,
            )

        await _insertar_animal(conexion, "hembra", _VACA, estado_reproductivo="vacia")
        with pytest.raises(asyncpg.CheckViolationError, match="incompatibles"):
            await conexion.execute(
                "update categorias set permite_estado_reproductivo = false"
                " where id = $1",
                _VACA,
            )

        # Sin animales afectados, el cambio de reglas se acepta.
        await conexion.execute(
            "update categorias set sexo_permitido = 'macho' where id = $1", _ENGORDE
        )
        assert (await _reglas(conexion))[_ENGORDE] == ("macho", False)


@pytest.mark.parametrize("camino", _CAMINOS)
async def test_sexo_permitido_desconocido_se_rechaza(camino):
    async with _base(camino) as (_, conexion):
        with pytest.raises(asyncpg.CheckViolationError):
            await conexion.execute(
                "update categorias set sexo_permitido = 'otro' where id = $1",
                _ENGORDE,
            )


async def test_restaurar_un_animal_revalida_su_categoria():
    """Un animal borrado no bloquea cambiar reglas, pero al restaurarlo se valida."""
    async with _base("create_all") as (_, conexion):
        animal_id = await _insertar_animal(conexion, "hembra", _TERNERO)
        await conexion.execute(
            "update animales set deleted_at = now() where id = $1", animal_id
        )
        await conexion.execute(
            "update categorias set sexo_permitido = 'macho' where id = $1", _TERNERO
        )
        with pytest.raises(asyncpg.CheckViolationError, match="no es compatible"):
            await conexion.execute(
                "update animales set deleted_at = null where id = $1", animal_id
            )


# ------------------------------------------------------- catálogo global


@pytest.mark.parametrize("camino", _CAMINOS)
async def test_ternero_global_es_solo_macho(camino):
    async with _base(camino) as (_, conexion):
        await _insertar_animal(conexion, "macho", _G_TERNERO)
        with pytest.raises(asyncpg.CheckViolationError, match="no es compatible"):
            await _insertar_animal(conexion, "hembra", _G_TERNERO)


@pytest.mark.parametrize("camino", _CAMINOS)
async def test_macho_en_ternera_se_rechaza(camino):
    async with _base(camino) as (_, conexion):
        with pytest.raises(asyncpg.CheckViolationError, match="no es compatible"):
            await _insertar_animal(conexion, "macho", _G_TERNERA)


@pytest.mark.parametrize("camino", _CAMINOS)
async def test_vaquillona_global_admite_prenada_en_cualquier_establecimiento(camino):
    async with _base(camino) as (_, conexion):
        for campo in (_CAMPO, _CAMPO_AJENO):
            animal_id = await _insertar_animal(
                conexion,
                "hembra",
                _G_VAQUILLONA,
                estado_reproductivo="prenada",
                establecimiento_id=campo,
            )
            estado = await conexion.fetchval(
                "select estado_reproductivo from animales where id = $1", animal_id
            )
            assert estado == "prenada"


@pytest.mark.parametrize("camino", _CAMINOS)
async def test_ternera_global_no_admite_condicion(camino):
    async with _base(camino) as (_, conexion):
        with pytest.raises(asyncpg.CheckViolationError, match="no admite"):
            await _insertar_animal(
                conexion, "hembra", _G_TERNERA, estado_reproductivo="vacia"
            )
