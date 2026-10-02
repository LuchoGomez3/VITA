"""Garantías de ``ventas_cobros`` que solo un Postgres real puede probar (VITA-172).

El tope de cobros es un trigger plpgsql con ``for update`` y el aislamiento es
RLS sobre ``auth.uid()``: nada de eso existe en SQLite. Cada test materializa el
esquema por uno de los tres caminos del proyecto — ``create_all``, la migración
Alembic y el script espejo — y verifica que todos se comporten igual.

Se saltean si no está ``VITA_TEST_POSTGRES_URL`` (ver ``tests/postgres_helpers``).
"""

import asyncio
from contextlib import asynccontextmanager
from datetime import date, datetime, timedelta
from decimal import Decimal
import os
from pathlib import Path
import subprocess
import sys
from uuid import UUID, uuid4
from zoneinfo import ZoneInfo

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
_SCRIPT_SQL = _BACKEND / "scripts/crear_ventas_cobros.sql"
# ``create_all`` no aplica RLS. Estos scripts dejan ``ventas`` como está en
# Supabase (20260902_02 + 20260910_01), del que dependen los triggers invoker.
_SCRIPTS_RLS_VENTAS = (
    _BACKEND / "scripts/crear_ventas.sql",
    _BACKEND / "scripts/restringir_ventas_roles_comerciales.sql",
)
_REVISION_PREVIA = "20260910_02"
_REVISION = "20261001_01"
_TABLA = "ventas_cobros"

_OWNER = UUID("00000000-0000-0000-0000-00000000000a")
_ADMIN = UUID("00000000-0000-0000-0000-00000000000b")
_EMPLOYEE = UUID("00000000-0000-0000-0000-00000000000c")
_OWNER_AJENO = UUID("00000000-0000-0000-0000-00000000000d")
_INACTIVO = UUID("00000000-0000-0000-0000-00000000000e")
_CAMPO = UUID("00000000-0000-0000-0000-0000000000e1")
_CAMPO_AJENO = UUID("00000000-0000-0000-0000-0000000000e2")
_VENTA = UUID("00000000-0000-0000-0000-0000000000f1")
_VENTA_AJENA = UUID("00000000-0000-0000-0000-0000000000f2")
_MONTO_VENTA = Decimal("1000.00")
# El trigger compara contra el día de Córdoba; el CI corre en UTC.
_ZONA_PRODUCTOR = ZoneInfo("America/Argentina/Cordoba")


async def _crear_esquema_sin_cobros(url: str, *, incluir_cobros: bool) -> None:
    engine = create_async_engine(url_sqlalchemy(url))
    tablas = [
        tabla
        for tabla in SQLModel.metadata.sorted_tables
        if incluir_cobros or tabla.name != _TABLA
    ]
    try:
        async with engine.begin() as conn:
            await conn.run_sync(
                lambda sync: SQLModel.metadata.create_all(sync, tables=tablas)
            )
    finally:
        await engine.dispose()


def _alembic(url: str, *argumentos: str) -> None:
    """Corre Alembic en un proceso aparte: ``core.config`` ya se importó acá.

    ``DATABASE_URL`` del entorno le gana a ``backend/.env`` (``load_dotenv`` no
    pisa variables existentes), así que nunca toca la base configurada.
    """
    entorno = {**os.environ, "DATABASE_URL": url_sqlalchemy(url)}
    resultado = subprocess.run(
        [sys.executable, "-m", "alembic", *argumentos],
        cwd=_BACKEND,
        env=entorno,
        capture_output=True,
        text=True,
        check=False,
    )
    assert resultado.returncode == 0, resultado.stderr


async def _materializar(url: str, camino: str) -> None:
    conexion = await asyncpg.connect(url)
    try:
        await instalar_auth_supabase(conexion)
        await simular_privilegios_por_defecto(conexion)
    finally:
        await conexion.close()

    await _crear_esquema_sin_cobros(url, incluir_cobros=camino == "create_all")
    conexion = await asyncpg.connect(url)
    try:
        for script in _SCRIPTS_RLS_VENTAS:
            await conexion.execute(script.read_text(encoding="utf-8"))
    finally:
        await conexion.close()
    if camino == "create_all":
        return

    if camino == "migracion":
        _alembic(url, "stamp", _REVISION_PREVIA)
        _alembic(url, "upgrade", _REVISION)
    else:
        conexion = await asyncpg.connect(url)
        try:
            await conexion.execute(_SCRIPT_SQL.read_text(encoding="utf-8"))
        finally:
            await conexion.close()


async def _sembrar(conexion: asyncpg.Connection) -> None:
    usuarios = (_OWNER, _ADMIN, _EMPLOYEE, _OWNER_AJENO, _INACTIVO)
    for indice, usuario in enumerate(usuarios):
        await conexion.execute(
            "insert into usuarios (id, nombre, apellido, email, is_platform_admin)"
            " values ($1, 'Test', 'Sintético', $2, false)",
            usuario,
            f"usuario{indice}@example.test",
        )
    for campo, owner in ((_CAMPO, _OWNER), (_CAMPO_AJENO, _OWNER_AJENO)):
        await conexion.execute(
            "insert into establecimientos (id, owner_id, nombre) values ($1, $2, $3)",
            campo,
            owner,
            f"Campo {campo}",
        )
    membresias = (
        (_OWNER, _CAMPO, "owner", True),
        (_ADMIN, _CAMPO, "admin", True),
        (_EMPLOYEE, _CAMPO, "employee", True),
        (_INACTIVO, _CAMPO, "owner", False),
        (_OWNER_AJENO, _CAMPO_AJENO, "owner", True),
    )
    for usuario, campo, rol, activo in membresias:
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
    for venta, campo, autor in (
        (_VENTA, _CAMPO, _OWNER),
        (_VENTA_AJENA, _CAMPO_AJENO, _OWNER_AJENO),
    ):
        await conexion.execute(
            "insert into ventas (id, establecimiento_id, fecha_operacion,"
            " tipo_comprador, nombre_comprador, es_empresa, nro_dte, tipo_venta,"
            " monto_total, registrada_por_id)"
            " values ($1, $2, $3, 'frigorifico', 'Frigorífico Sintético S.A.',"
            " true, 'DTE-TEST-1', 'al_bulto', $4, $5)",
            venta,
            campo,
            date(2026, 9, 1),
            _MONTO_VENTA,
            autor,
        )


@asynccontextmanager
async def _base(camino: str):
    async with base_temporal() as url:
        await _materializar(url, camino)
        conexion = await asyncpg.connect(url)
        try:
            await _sembrar(conexion)
            yield url, conexion
        finally:
            await conexion.close()


async def _cobrar(
    conexion: asyncpg.Connection,
    monto: str,
    *,
    venta_id: UUID = _VENTA,
    autor: UUID = _OWNER,
    cobro_id: UUID | None = None,
    fecha_cobro: date = date(2026, 9, 15),
) -> UUID:
    cobro_id = cobro_id or uuid4()
    await conexion.execute(
        "insert into ventas_cobros (id, venta_id, fecha_cobro, monto, registrado_por_id)"
        " values ($1, $2, $3, $4, $5)",
        cobro_id,
        venta_id,
        fecha_cobro,
        Decimal(monto),
        autor,
    )
    return cobro_id


async def _cobrado(conexion: asyncpg.Connection, venta_id: UUID = _VENTA) -> Decimal:
    return await conexion.fetchval(
        "select coalesce(sum(monto), 0) from ventas_cobros"
        " where venta_id = $1 and deleted_at is null",
        venta_id,
    )


_CAMINOS = ("create_all", "migracion", "script")
_CAMINOS_CON_RLS = ("migracion", "script")


# --------------------------------------------------------------------------- #
# Tope de cobros
# --------------------------------------------------------------------------- #


@pytest.mark.parametrize("camino", _CAMINOS)
async def test_cobros_parciales_hasta_el_total_y_rechazo_del_sobrepago(camino):
    async with _base(camino) as (_, conexion):
        await _cobrar(conexion, "400.00")
        await _cobrar(conexion, "600.00")
        assert await _cobrado(conexion) == _MONTO_VENTA

        with pytest.raises(asyncpg.CheckViolationError, match="superan el monto"):
            await _cobrar(conexion, "0.01")
        assert await _cobrado(conexion) == _MONTO_VENTA


@pytest.mark.parametrize("camino", _CAMINOS)
async def test_un_cobro_unico_no_puede_superar_el_total(camino):
    async with _base(camino) as (_, conexion):
        with pytest.raises(asyncpg.CheckViolationError):
            await _cobrar(conexion, "1000.01")
        await _cobrar(conexion, "1000.00")


@pytest.mark.parametrize("camino", _CAMINOS)
async def test_anular_un_cobro_libera_saldo_y_reactivarlo_respeta_el_tope(camino):
    async with _base(camino) as (_, conexion):
        anulado = await _cobrar(conexion, "700.00")
        await conexion.execute(
            "update ventas_cobros set deleted_at = now() where id = $1", anulado
        )
        assert await _cobrado(conexion) == Decimal("0.00")

        await _cobrar(conexion, "500.00")
        with pytest.raises(asyncpg.CheckViolationError):
            await conexion.execute(
                "update ventas_cobros set deleted_at = null where id = $1", anulado
            )


@pytest.mark.parametrize("camino", _CAMINOS)
async def test_editar_el_monto_respeta_el_tope_sin_contarse_a_si_mismo(camino):
    async with _base(camino) as (_, conexion):
        cobro = await _cobrar(conexion, "400.00")
        await _cobrar(conexion, "100.00")

        await conexion.execute(
            "update ventas_cobros set monto = 900.00 where id = $1", cobro
        )
        with pytest.raises(asyncpg.CheckViolationError):
            await conexion.execute(
                "update ventas_cobros set monto = 900.01 where id = $1", cobro
            )


@pytest.mark.parametrize("camino", _CAMINOS)
@pytest.mark.parametrize("columna", ["id", "venta_id", "registrado_por_id"])
async def test_un_cobro_no_cambia_de_id_ni_de_venta_ni_de_autor(camino, columna):
    """El id es la clave de idempotencia del sync: cambiarlo duplicaría el cobro."""
    async with _base(camino) as (_, conexion):
        cobro = await _cobrar(conexion, "100.00")
        nuevo_valor = {
            "id": uuid4(),
            "venta_id": _VENTA_AJENA,
            "registrado_por_id": _ADMIN,
        }[columna]
        with pytest.raises(asyncpg.CheckViolationError, match="no puede cambiar"):
            await conexion.execute(
                f"update ventas_cobros set {columna} = $1 where id = $2",
                nuevo_valor,
                cobro,
            )


@pytest.mark.parametrize("camino", _CAMINOS)
async def test_una_venta_eliminada_no_recibe_cobros_nuevos(camino):
    async with _base(camino) as (_, conexion):
        existente = await _cobrar(conexion, "100.00")
        await conexion.execute(
            "update ventas set deleted_at = now() where id = $1", _VENTA
        )

        with pytest.raises(asyncpg.CheckViolationError, match="eliminada"):
            await _cobrar(conexion, "100.00")
        # El cobro previo sigue siendo editable y anulable.
        await conexion.execute(
            "update ventas_cobros set observaciones = 'transferencia' where id = $1",
            existente,
        )
        await conexion.execute(
            "update ventas_cobros set deleted_at = now() where id = $1", existente
        )


@pytest.mark.parametrize("camino", _CAMINOS)
async def test_el_monto_de_la_venta_no_baja_de_lo_cobrado(camino):
    async with _base(camino) as (_, conexion):
        await _cobrar(conexion, "800.00")

        with pytest.raises(asyncpg.CheckViolationError, match="por debajo"):
            await conexion.execute(
                "update ventas set monto_total = 799.99 where id = $1", _VENTA
            )
        await conexion.execute(
            "update ventas set monto_total = 800.00 where id = $1", _VENTA
        )
        await conexion.execute(
            "update ventas set monto_total = 1200.00 where id = $1", _VENTA
        )


@pytest.mark.parametrize("camino", _CAMINOS)
async def test_cobros_iguales_el_mismo_dia_son_validos(camino):
    """Dos pagos idénticos pueden ser operaciones reales distintas."""
    async with _base(camino) as (_, conexion):
        await _cobrar(conexion, "250.00")
        await _cobrar(conexion, "250.00")
        assert await _cobrado(conexion) == Decimal("500.00")


@pytest.mark.parametrize("camino", _CAMINOS)
async def test_reintentar_la_sincronizacion_no_duplica_el_cobro(camino):
    async with _base(camino) as (_, conexion):
        cobro = await _cobrar(conexion, "300.00")
        with pytest.raises(asyncpg.UniqueViolationError):
            await _cobrar(conexion, "300.00", cobro_id=cobro)
        assert await _cobrado(conexion) == Decimal("300.00")


def _hoy_en_cordoba() -> date:
    return datetime.now(_ZONA_PRODUCTOR).date()


@pytest.mark.parametrize("camino", _CAMINOS)
@pytest.mark.parametrize("dias", [0, -1, -365])
async def test_se_aceptan_cobros_de_hoy_y_del_pasado(camino, dias):
    async with _base(camino) as (_, conexion):
        fecha = _hoy_en_cordoba() + timedelta(days=dias)
        await _cobrar(conexion, "100.00", fecha_cobro=fecha)
        assert await _cobrado(conexion) == Decimal("100.00")


@pytest.mark.parametrize("camino", _CAMINOS)
async def test_se_rechaza_un_cobro_con_fecha_futura(camino):
    async with _base(camino) as (_, conexion):
        manana = _hoy_en_cordoba() + timedelta(days=1)
        with pytest.raises(asyncpg.CheckViolationError, match="fecha de cobro"):
            await _cobrar(conexion, "100.00", fecha_cobro=manana)


@pytest.mark.parametrize("camino", _CAMINOS)
async def test_no_se_puede_mover_un_cobro_al_futuro(camino):
    async with _base(camino) as (_, conexion):
        cobro = await _cobrar(conexion, "100.00")
        with pytest.raises(asyncpg.CheckViolationError, match="fecha de cobro"):
            await conexion.execute(
                "update ventas_cobros set fecha_cobro = $1 where id = $2",
                _hoy_en_cordoba() + timedelta(days=1),
                cobro,
            )


@pytest.mark.parametrize("camino", _CAMINOS)
async def test_el_hoy_es_el_de_cordoba_y_no_el_de_la_sesion(camino):
    """Una sesión en otra zona horaria no corre el límite del día."""
    async with _base(camino) as (_, conexion):
        await conexion.execute("set timezone = 'Pacific/Kiritimati'")  # UTC+14
        manana = _hoy_en_cordoba() + timedelta(days=1)
        with pytest.raises(asyncpg.CheckViolationError, match="fecha de cobro"):
            await _cobrar(conexion, "100.00", fecha_cobro=manana)
        await _cobrar(conexion, "100.00", fecha_cobro=_hoy_en_cordoba())


# --------------------------------------------------------------------------- #
# Concurrencia
# --------------------------------------------------------------------------- #


async def _esperar_bloqueo(conexion: asyncpg.Connection, pid: int) -> None:
    """Espera a que el backend ``pid`` quede esperando un lock de fila."""
    for _ in range(100):
        esperando = await conexion.fetchval(
            "select wait_event_type = 'Lock' from pg_stat_activity where pid = $1",
            pid,
        )
        if esperando:
            return
        await asyncio.sleep(0.05)
    raise AssertionError("La segunda transacción no quedó esperando el lock.")


@asynccontextmanager
async def _dos_dispositivos(url: str):
    primero = await asyncpg.connect(url)
    segundo = await asyncpg.connect(url)
    try:
        yield primero, segundo
    finally:
        await primero.close()
        await segundo.close()


@pytest.mark.parametrize("camino", _CAMINOS)
async def test_dos_cobros_simultaneos_no_producen_sobrepago(camino):
    """Ninguno de los dos ve al otro sin el lock: los dos entrarían por separado."""
    async with _base(camino) as (url, observador):
        async with _dos_dispositivos(url) as (primero, segundo):
            transaccion = primero.transaction()
            await transaccion.start()
            await _cobrar(primero, "600.00")

            pendiente = asyncio.create_task(_cobrar(segundo, "600.00"))
            await _esperar_bloqueo(observador, segundo.get_server_pid())
            assert not pendiente.done()

            await transaccion.commit()
            with pytest.raises(asyncpg.CheckViolationError):
                await pendiente

        assert await _cobrado(observador) == Decimal("600.00")


@pytest.mark.parametrize("camino", _CAMINOS)
async def test_si_el_primer_cobro_se_revierte_el_segundo_entra(camino):
    async with _base(camino) as (url, observador):
        async with _dos_dispositivos(url) as (primero, segundo):
            transaccion = primero.transaction()
            await transaccion.start()
            await _cobrar(primero, "600.00")

            pendiente = asyncio.create_task(_cobrar(segundo, "600.00"))
            await _esperar_bloqueo(observador, segundo.get_server_pid())

            await transaccion.rollback()
            await pendiente

        assert await _cobrado(observador) == Decimal("600.00")


@pytest.mark.parametrize("camino", _CAMINOS)
async def test_bajar_el_monto_y_cobrar_a_la_vez_no_rompe_el_invariante(camino):
    async with _base(camino) as (url, observador):
        await _cobrar(observador, "500.00")
        async with _dos_dispositivos(url) as (primero, segundo):
            transaccion = primero.transaction()
            await transaccion.start()
            await primero.execute(
                "update ventas set monto_total = 600.00 where id = $1", _VENTA
            )

            pendiente = asyncio.create_task(_cobrar(segundo, "400.00"))
            await _esperar_bloqueo(observador, segundo.get_server_pid())

            await transaccion.commit()
            with pytest.raises(asyncpg.CheckViolationError):
                await pendiente

        assert await _cobrado(observador) == Decimal("500.00")


@pytest.mark.parametrize("camino", _CAMINOS)
async def test_cobrar_y_bajar_el_monto_a_la_vez_no_rompe_el_invariante(camino):
    """Orden inverso: el cobro toma el lock y la reducción espera detrás."""
    async with _base(camino) as (url, observador):
        await _cobrar(observador, "500.00")
        async with _dos_dispositivos(url) as (primero, segundo):
            transaccion = primero.transaction()
            await transaccion.start()
            await _cobrar(primero, "400.00")

            pendiente = asyncio.create_task(
                segundo.execute(
                    "update ventas set monto_total = 600.00 where id = $1", _VENTA
                )
            )
            await _esperar_bloqueo(observador, segundo.get_server_pid())
            assert not pendiente.done()

            await transaccion.commit()
            with pytest.raises(asyncpg.CheckViolationError, match="por debajo"):
                await pendiente

        assert await _cobrado(observador) == Decimal("900.00")
        assert (
            await observador.fetchval(
                "select monto_total from ventas where id = $1", _VENTA
            )
            == _MONTO_VENTA
        )


# --------------------------------------------------------------------------- #
# RLS
# --------------------------------------------------------------------------- #


async def _contar_visibles(conexion: asyncpg.Connection) -> int:
    return await conexion.fetchval("select count(*) from ventas_cobros")


@pytest.mark.parametrize("camino", _CAMINOS_CON_RLS)
@pytest.mark.parametrize("usuario", [_OWNER, _ADMIN])
async def test_roles_comerciales_registran_consultan_y_anulan(camino, usuario):
    async with _base(camino) as (_, conexion):
        await _cobrar(conexion, "100.00")
        async with como_usuario(conexion, usuario):
            cobro = await _cobrar(conexion, "200.00", autor=usuario)
            assert await _contar_visibles(conexion) == 2
            resultado = await conexion.execute(
                "update ventas_cobros set deleted_at = now() where id = $1", cobro
            )
            assert resultado == "UPDATE 1"


@pytest.mark.parametrize("camino", _CAMINOS_CON_RLS)
@pytest.mark.parametrize("usuario", [_EMPLOYEE, _INACTIVO, _OWNER_AJENO])
async def test_sin_rol_comercial_en_el_campo_no_ve_ni_escribe_cobros(camino, usuario):
    async with _base(camino) as (_, conexion):
        existente = await _cobrar(conexion, "100.00")

        async with como_usuario(conexion, usuario):
            assert await _contar_visibles(conexion) == 0
            resultado = await conexion.execute(
                "update ventas_cobros set monto = 1.00 where id = $1", existente
            )
            assert resultado == "UPDATE 0"

        async with como_usuario(conexion, usuario):
            with pytest.raises(asyncpg.InsufficientPrivilegeError):
                await _cobrar(conexion, "50.00", autor=usuario)


@pytest.mark.parametrize("camino", _CAMINOS_CON_RLS)
async def test_no_se_puede_registrar_un_cobro_a_nombre_de_otro(camino):
    async with _base(camino) as (_, conexion):
        async with como_usuario(conexion, _ADMIN):
            with pytest.raises(asyncpg.InsufficientPrivilegeError):
                await _cobrar(conexion, "50.00", autor=_OWNER)


@pytest.mark.parametrize("camino", _CAMINOS_CON_RLS)
async def test_el_owner_ajeno_solo_ve_los_cobros_de_su_campo(camino):
    async with _base(camino) as (_, conexion):
        await _cobrar(conexion, "100.00")
        await _cobrar(conexion, "100.00", venta_id=_VENTA_AJENA, autor=_OWNER_AJENO)

        async with como_usuario(conexion, _OWNER_AJENO):
            ventas = await conexion.fetch("select venta_id from ventas_cobros")
            assert [fila["venta_id"] for fila in ventas] == [_VENTA_AJENA]


@pytest.mark.parametrize("camino", _CAMINOS_CON_RLS)
async def test_el_borrado_fisico_esta_bloqueado(camino):
    async with _base(camino) as (_, conexion):
        cobro = await _cobrar(conexion, "100.00")
        async with como_usuario(conexion, _OWNER):
            with pytest.raises(asyncpg.InsufficientPrivilegeError):
                await conexion.execute("delete from ventas_cobros where id = $1", cobro)


@pytest.mark.parametrize("camino", _CAMINOS_CON_RLS)
async def test_anon_no_accede(camino):
    async with _base(camino) as (_, conexion):
        async with como_usuario(conexion, None):
            with pytest.raises(asyncpg.InsufficientPrivilegeError):
                await _contar_visibles(conexion)


async def _rechazo_de_cobro_ajeno(
    conexion: asyncpg.Connection, monto: str, venta_id: UUID
) -> str:
    async with como_usuario(conexion, _OWNER):
        with pytest.raises(asyncpg.InsufficientPrivilegeError) as error:
            await _cobrar(conexion, monto, venta_id=venta_id)
    return error.value.sqlstate + " " + str(error.value)


@pytest.mark.parametrize("camino", _CAMINOS_CON_RLS)
async def test_cobrar_una_venta_ajena_no_revela_saldo_ni_estado(camino):
    """Los triggers BEFORE corren antes del WITH CHECK del RLS.

    Si leyeran la venta con privilegios, el error distinguiría sobrepago, venta
    eliminada o saldo disponible de un tenant ajeno. Todos los intentos tienen
    que recibir exactamente el mismo rechazo de autorización.
    """
    async with _base(camino) as (_, conexion):
        await _cobrar(conexion, "900.00", venta_id=_VENTA_AJENA, autor=_OWNER_AJENO)

        rechazos = {
            "sobrepago": await _rechazo_de_cobro_ajeno(
                conexion, "200.00", _VENTA_AJENA
            ),
            "dentro_del_saldo": await _rechazo_de_cobro_ajeno(
                conexion, "50.00", _VENTA_AJENA
            ),
            "venta_inexistente": await _rechazo_de_cobro_ajeno(
                conexion, "50.00", uuid4()
            ),
        }
        await conexion.execute(
            "update ventas set deleted_at = now() where id = $1", _VENTA_AJENA
        )
        rechazos["venta_eliminada"] = await _rechazo_de_cobro_ajeno(
            conexion, "50.00", _VENTA_AJENA
        )

        assert len(set(rechazos.values())) == 1, rechazos
        assert next(iter(rechazos.values())).startswith("42501 ")


# --------------------------------------------------------------------------- #
# Equivalencia de artefactos y migración sobre base existente
# --------------------------------------------------------------------------- #

_CONSULTAS_ESTRUCTURA = {
    "columnas": """
        select column_name, data_type, numeric_precision, numeric_scale,
               is_nullable, column_default
          from information_schema.columns
         where table_schema = 'public' and table_name = 'ventas_cobros'
         order by column_name
    """,
    "restricciones": """
        select conname, contype, pg_get_constraintdef(oid)
          from pg_constraint
         where conrelid = 'public.ventas_cobros'::regclass
         order by conname
    """,
    "indices": """
        select indexname, indexdef from pg_indexes
         where schemaname = 'public' and tablename = 'ventas_cobros'
         order by indexname
    """,
    "triggers": """
        select tgname, pg_get_triggerdef(oid) from pg_trigger
         where not tgisinternal
           and tgrelid in ('public.ventas'::regclass, 'public.ventas_cobros'::regclass)
         order by tgname
    """,
    "funciones": """
        select proname, prosrc, prosecdef, proconfig from pg_proc
         where proname in ('validar_fecha_cobro',
                           'validar_tope_cobros_venta',
                           'validar_monto_venta_cubre_cobros')
         order by proname
    """,
}

_CONSULTAS_SEGURIDAD = {
    "rls": """
        select relrowsecurity from pg_class
         where oid = 'public.ventas_cobros'::regclass
    """,
    "politicas": """
        select policyname, cmd, roles, qual, with_check from pg_policies
         where schemaname = 'public' and tablename = 'ventas_cobros'
         order by policyname
    """,
    "privilegios": """
        select grantee, privilege_type from information_schema.role_table_grants
         where table_schema = 'public' and table_name = 'ventas_cobros'
           and grantee in ('anon', 'authenticated')
         order by grantee, privilege_type
    """,
}


async def _foto(camino: str, consultas: dict[str, str]) -> dict[str, list[tuple]]:
    async with _base(camino) as (_, conexion):
        return {
            nombre: [tuple(fila) for fila in await conexion.fetch(sql)]
            for nombre, sql in consultas.items()
        }


async def test_los_tres_caminos_producen_la_misma_estructura():
    fotos = {camino: await _foto(camino, _CONSULTAS_ESTRUCTURA) for camino in _CAMINOS}

    assert fotos["migracion"] == fotos["create_all"]
    assert fotos["script"] == fotos["create_all"]
    assert len(fotos["create_all"]["triggers"]) == 3
    assert len(fotos["create_all"]["funciones"]) == 3
    # Ninguna función se salta el RLS de quien escribe.
    assert not any(seguridad for _, _, seguridad, _ in fotos["create_all"]["funciones"])


async def test_migracion_y_script_aplican_la_misma_seguridad():
    migracion = await _foto("migracion", _CONSULTAS_SEGURIDAD)
    script = await _foto("script", _CONSULTAS_SEGURIDAD)

    assert migracion == script
    assert migracion["rls"] == [(True,)]
    assert {nombre for nombre, *_ in migracion["politicas"]} == {
        "ventas_cobros_select_miembros",
        "ventas_cobros_insert_miembros",
        "ventas_cobros_update_miembros",
    }
    assert migracion["privilegios"] == [
        ("authenticated", "INSERT"),
        ("authenticated", "SELECT"),
        ("authenticated", "UPDATE"),
    ]


async def test_la_migracion_corre_sobre_una_base_que_ya_tiene_los_cobros():
    """Sin baseline, la migración debe tolerar objetos creados por el script."""
    async with base_temporal() as url:
        await _materializar(url, "script")
        _alembic(url, "stamp", _REVISION_PREVIA)
        _alembic(url, "upgrade", _REVISION)


async def test_downgrade_elimina_tabla_triggers_y_funciones():
    async with base_temporal() as url:
        await _materializar(url, "migracion")
        _alembic(url, "downgrade", _REVISION_PREVIA)

        conexion = await asyncpg.connect(url)
        try:
            assert (
                await conexion.fetchval("select to_regclass('public.ventas_cobros')")
                is None
            )
            assert (
                await conexion.fetchval(
                    "select count(*) from pg_trigger where tgname like '%cobros%'"
                )
                == 0
            )
            assert (
                await conexion.fetchval(
                    "select count(*) from pg_proc where proname in"
                    " ('validar_fecha_cobro', 'validar_tope_cobros_venta',"
                    " 'validar_monto_venta_cubre_cobros')"
                )
                == 0
            )
            # La venta sigue siendo editable sin el trigger.
            await _sembrar(conexion)
            await conexion.execute(
                "update ventas set monto_total = 1.00 where id = $1", _VENTA
            )
        finally:
            await conexion.close()

        _alembic(url, "upgrade", _REVISION)
