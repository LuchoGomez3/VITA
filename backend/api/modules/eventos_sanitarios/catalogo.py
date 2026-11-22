"""Prácticas sanitarias que la app sabe registrar.

Las prácticas son fijas y viven en el código: el celular las guarda por ``id``
para trabajar sin señal, así que esos ids no pueden cambiar. Lo que varía por
establecimiento son los productos (globales o propios del campo).

``modelo`` elige el formulario en el celular (``aplicacion``, ``muestreo`` o
``lesion``); ``tipo`` es la clasificación sanitaria que ya usaba la tabla.
"""

from dataclasses import dataclass

from api.shared.enums import TipoEventoSanitario, TipoProductoSanitario

MODELO_APLICACION = "aplicacion"
MODELO_MUESTREO = "muestreo"
MODELO_LESION = "lesion"


@dataclass(frozen=True)
class Practica:
    id: str
    nombre: str
    modelo: str
    tipo: TipoEventoSanitario
    # Productos que se pueden aplicar (solo en ``aplicacion``).
    tipos_producto: tuple[TipoProductoSanitario, ...] = ()


PRACTICAS: tuple[Practica, ...] = (
    Practica(
        "vacunacion",
        "Vacunación",
        MODELO_APLICACION,
        TipoEventoSanitario.vacunacion,
        (TipoProductoSanitario.vacuna,),
    ),
    Practica(
        "desparasitacion",
        "Desparasitación",
        MODELO_APLICACION,
        TipoEventoSanitario.desparasitacion,
        (TipoProductoSanitario.antiparasitario,),
    ),
    Practica(
        "tratamiento",
        "Tratamiento",
        MODELO_APLICACION,
        TipoEventoSanitario.tratamiento,
        (
            TipoProductoSanitario.antibiotico,
            TipoProductoSanitario.reproductivo,
            TipoProductoSanitario.otro,
        ),
    ),
    Practica("sangrado", "Sangrado", MODELO_MUESTREO, TipoEventoSanitario.analisis),
    Practica(
        "raspaje_prepucial",
        "Raspaje prepucial",
        MODELO_MUESTREO,
        TipoEventoSanitario.analisis,
    ),
    Practica(
        "materia_fecal",
        "Muestra de materia fecal",
        MODELO_MUESTREO,
        TipoEventoSanitario.analisis,
    ),
    Practica("lesion", "Lesión", MODELO_LESION, TipoEventoSanitario.diagnostico),
)

PRACTICAS_POR_ID: dict[str, Practica] = {p.id: p for p in PRACTICAS}
