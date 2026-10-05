"""Traducción de los rechazos de la base sobre ``animales`` a errores de dominio.

El service valida todo antes de escribir, pero una escritura concurrente (por
ejemplo, otro dispositivo que cambia las reglas de la categoría entre la
validación y el flush) puede hacer que la base rechace igual. Ese rechazo tiene
que llegar al cliente con el mismo código que la validación del service, no como
``caravana_duplicada`` ni como un 500.
"""

from collections.abc import Callable

from sqlalchemy.exc import IntegrityError

from api.modules.animales.exceptions import (
    AnimalReferenciaInvalidaError,
    CaravanaDuplicadaError,
    CategoriaIncompatibleConSexoError,
    EstadoReproductivoInvalidoError,
)
from api.shared.exceptions import DomainException
from api.shared.rechazos_base import (
    VIOLACION_CHECK,
    VIOLACION_FK,
    VIOLACION_UNICIDAD,
    inspeccionar,
)

_MENSAJE_CATEGORIA_NO_ADMITE = (
    "La categoría del animal no admite registrar condición reproductiva"
)

# Nombres que informa el trigger ``validar_categoria_animal`` (``raise ... using
# constraint``) y los CHECK de la tabla. Mismo código que la validación del service.
_POR_RESTRICCION: dict[str, Callable[[], DomainException]] = {
    "animales_categoria_admite_sexo": CategoriaIncompatibleConSexoError,
    "animales_categoria_asignable": lambda: AnimalReferenciaInvalidaError("categoria"),
    "animales_categoria_admite_estado_reproductivo": lambda: (
        EstadoReproductivoInvalidoError(_MENSAJE_CATEGORIA_NO_ADMITE)
    ),
    "animales_estado_reproductivo_requiere_categoria": lambda: (
        EstadoReproductivoInvalidoError(
            "Asigne al animal una categoría que admita condición reproductiva "
            "antes de registrarla"
        )
    ),
    "ck_animales_estado_reproductivo_solo_hembras": lambda: (
        EstadoReproductivoInvalidoError(
            "Un macho no puede tener condición reproductiva"
        )
    ),
    "ck_animales_estado_reproductivo_valido": lambda: EstadoReproductivoInvalidoError(
        "La condición reproductiva no es válida"
    ),
}

# FK de ``animales`` → campo que se informa en ``referencia_invalida``. Son los
# nombres que Postgres genera por defecto (``<tabla>_<columna>_fkey``).
_CAMPO_POR_FK = {
    "animales_categoria_id_fkey": "categoria",
    "animales_lote_id_fkey": "lote",
    "animales_madre_id_fkey": "madre",
    "animales_padre_id_fkey": "padre",
    "animales_establecimiento_id_fkey": "establecimiento",
}


def traducir_rechazo(
    exc: IntegrityError, nro_caravana_rfid: str | None
) -> DomainException | None:
    """Error de dominio equivalente al rechazo, o ``None`` si no se reconoce.

    ``caravana_duplicada`` sale solo ante la violación de unicidad real sobre
    ``animales``; una colisión de clave primaria (dos reenvíos simultáneos del
    mismo alta) no es una caravana repetida y no se traduce.
    """
    rechazo = inspeccionar(exc)
    if rechazo.sqlstate == VIOLACION_CHECK and rechazo.restriccion in _POR_RESTRICCION:
        return _POR_RESTRICCION[rechazo.restriccion]()
    if rechazo.sqlstate == VIOLACION_FK and rechazo.restriccion in _CAMPO_POR_FK:
        return AnimalReferenciaInvalidaError(_CAMPO_POR_FK[rechazo.restriccion])
    if (
        rechazo.sqlstate == VIOLACION_UNICIDAD
        and rechazo.tabla == "animales"
        and rechazo.restriccion is not None
        and not rechazo.restriccion.endswith("_pkey")
    ):
        return CaravanaDuplicadaError(nro_caravana_rfid or "")
    return None
