"""Lectura estructurada de los rechazos de la base de datos.

Un ``IntegrityError`` de SQLAlchemy envuelve la excepción del driver. Para
traducirlo a un error de dominio hay que mirar el SQLSTATE y el nombre de la
restricción (o el que un trigger informa con ``raise ... using constraint``),
nunca el texto del mensaje, que cambia con el idioma y la versión de Postgres.
"""

from dataclasses import dataclass

from sqlalchemy.exc import DBAPIError

# Clase 23 de SQLSTATE: violaciones de integridad.
VIOLACION_NOT_NULL = "23502"
VIOLACION_FK = "23503"
VIOLACION_UNICIDAD = "23505"
VIOLACION_CHECK = "23514"


@dataclass(frozen=True)
class RechazoBase:
    sqlstate: str | None
    restriccion: str | None
    tabla: str | None
    detalle: str | None


def inspeccionar(exc: DBAPIError) -> RechazoBase:
    """Extrae los diagnósticos del driver recorriendo la cadena de causas.

    Con asyncpg, ``exc.orig`` es el adaptador de SQLAlchemy (expone ``sqlstate``)
    y su ``__cause__`` es la excepción de asyncpg (expone la restricción, la
    tabla y el detalle). Otros drivers (SQLite) no informan nada: todo queda en
    ``None`` y quien llama decide qué hacer con un rechazo que no reconoce.
    """
    datos: dict[str, str | None] = {
        "sqlstate": None,
        "restriccion": None,
        "tabla": None,
        "detalle": None,
    }
    atributos = {
        "sqlstate": ("sqlstate", "pgcode"),
        "restriccion": ("constraint_name",),
        "tabla": ("table_name",),
        "detalle": ("detail",),
    }
    error: BaseException | None = exc.orig
    vistos: set[int] = set()
    while error is not None and id(error) not in vistos:
        vistos.add(id(error))
        for campo, nombres in atributos.items():
            if datos[campo] is not None:
                continue
            for nombre in nombres:
                valor = getattr(error, nombre, None)
                if isinstance(valor, str) and valor:
                    datos[campo] = valor
                    break
        error = error.__cause__
    return RechazoBase(**datos)
