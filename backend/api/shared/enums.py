"""Enums de dominio compartidos por los módulos del backend.

Todos heredan de ``(str, Enum)`` para serializar al valor textual. Las columnas
los almacenan como VARCHAR (``sa_type=String``); el Enum solo valida en Python.
"""

from enum import Enum


class RolUsuario(str, Enum):
    admin = "admin"
    owner = "owner"
    employee = "employee"


class SexoAnimal(str, Enum):
    macho = "macho"
    hembra = "hembra"


class EstadoAnimal(str, Enum):
    activo = "activo"
    vendido = "vendido"
    muerto = "muerto"
    baja = "baja"


class MetodoPesaje(str, Enum):
    manual = "manual"
    balanza_bluetooth = "balanza_bluetooth"
    estimacion_ia = "estimacion_ia"


class TipoProductoSanitario(str, Enum):
    vacuna = "vacuna"
    antiparasitario = "antiparasitario"
    antibiotico = "antibiotico"
    reproductivo = "reproductivo"
    otro = "otro"


class TipoEventoSanitario(str, Enum):
    vacunacion = "vacunacion"
    tratamiento = "tratamiento"
    desparasitacion = "desparasitacion"
    diagnostico = "diagnostico"
    analisis = "analisis"


class TipoEgreso(str, Enum):
    """Motivo de salida física NO comercial de un animal del establecimiento.

    La salida por venta no se modela acá: es una operación comercial con
    comprador, DTe y monto, y vive en la tabla ``ventas``.
    """

    muerte = "muerte"
    baja = "baja"
    traslado_externo = "traslado_externo"


class TipoVenta(str, Enum):
    """Modalidad con la que se pacta el monto de una venta de hacienda."""

    por_kilo = "por_kilo"
    al_bulto = "al_bulto"


class TipoComprador(str, Enum):
    """Canal comercial por el que sale la hacienda."""

    frigorifico = "frigorifico"
    remate = "remate"
    particular = "particular"


class TipoEgresoOperativo(str, Enum):
    """Clasificación contable principal de un egreso monetario del campo."""

    costo_produccion = "costo_produccion"
    gasto_administrativo = "gasto_administrativo"


class CategoriaEgresoOperativo(str, Enum):
    """Categorías cerradas que permiten calcular márgenes de forma consistente."""

    sanidad = "sanidad"
    alimentacion = "alimentacion"
    identificacion = "identificacion"
    combustible = "combustible"
    estructura = "estructura"
    honorarios = "honorarios"


class EstadoLote(str, Enum):
    """Estado operativo de un lote (potrero).

    Los cuatro estados ocupan espacio en el lienzo del establecimiento: un lote
    en descanso o mantenimiento sigue siendo una división física y no puede
    superponerse con otro. Solo ``activo`` admite el ingreso de animales.
    """

    activo = "activo"
    descanso = "descanso"
    mantenimiento = "mantenimiento"
    inactivo = "inactivo"


class RecursoForrajero(str, Enum):
    """Recurso forrajero predominante del lote.

    Es un catálogo de códigos estables, no una etiqueta visible: la traducción a
    texto para el usuario la resuelve el cliente.
    """

    pasto_natural = "pasto_natural"
    alfalfa = "alfalfa"
    sorgo = "sorgo"
    maiz = "maiz"
    avena = "avena"
    otro = "otro"
