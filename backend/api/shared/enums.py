"""Enums de dominio compartidos por los módulos del backend.

Todos heredan de ``(str, Enum)`` para serializar al valor textual. Las columnas
los almacenan como VARCHAR (``sa_type=String``); el Enum solo valida en Python.
"""

from enum import Enum


class RolUsuario(str, Enum):
    administrator = "administrator"
    owner = "owner"
    veterinarian = "veterinarian"
    capataz = "capataz"
    asset_manager = "asset_manager"
    external_buyer = "external_buyer"


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
    venta = "venta"
    muerte = "muerte"
    baja = "baja"
    traslado_externo = "traslado_externo"
