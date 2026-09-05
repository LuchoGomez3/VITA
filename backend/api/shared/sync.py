"""Utilidades del patrón de sincronización offline-first.

Las comparten todos los módulos sincronizables (animales, lotes, movimientos):
la resolución de conflictos tiene que comportarse igual en todos o el cliente
vería reglas distintas según la entidad.
"""

from datetime import UTC, datetime


def as_utc(dt: datetime | None) -> datetime | None:
    """Normaliza a UTC-aware para comparar timestamps de forma robusta.

    Postgres devuelve datetimes aware; SQLite (tests) puede devolverlos naive.
    Asumimos UTC en los naive para no romper la comparación del last-write-wins.
    """
    if dt is None:
        return None
    return dt if dt.tzinfo is not None else dt.replace(tzinfo=UTC)


def gana_el_entrante(entrante: datetime | None, persistido: datetime | None) -> bool:
    """¿El cambio que llega es más nuevo que el que ya está guardado?

    Last-write-wins por ``updated_at``. El empate lo gana el servidor: ante dos
    versiones con el mismo timestamp no hay forma de saber cuál es posterior, y
    conservar lo persistido es la opción estable (el resultado no depende del
    orden en que lleguen los reintentos).
    """
    if entrante is None:
        return False
    actual = as_utc(persistido)
    if actual is None:
        return True
    return as_utc(entrante) > actual
