"""Enums de dominio compartidos por los módulos del backend.

Todos heredan de ``(str, Enum)`` para serializar al valor textual. Las columnas
los almacenan como VARCHAR (``sa_type=String``); el Enum solo valida en Python.
"""

from enum import Enum


class RolUsuario(str, Enum):
    admin = "admin"
    owner = "owner"
    employee = "employee"
    # Por ahora opera como ``employee``: no ve finanzas ni gestiona el equipo.
    # Acotarlo al módulo Sanidad queda para una historia aparte.
    veterinarian = "veterinarian"


class EstadoInvitacion(str, Enum):
    """Ciclo de vida de una invitación al equipo de un establecimiento.

    El vencimiento no es un estado: se calcula contra ``expira_en``, así una
    invitación pendiente vencida se puede reenviar sin cambiar de estado.
    """

    pendiente = "pendiente"
    aceptada = "aceptada"
    cancelada = "cancelada"


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


class MedioCobro(str, Enum):
    """Instrumento con el que se recibió un cobro de venta."""

    efectivo = "efectivo"
    transferencia = "transferencia"
    cheque = "cheque"
    tarjeta = "tarjeta"


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
    texto para el usuario la resuelve el cliente. Los seis primeros son los
    originales; el resto cubre pasturas, verdeos y rastrojos de la zona.
    """

    pasto_natural = "pasto_natural"
    alfalfa = "alfalfa"
    sorgo = "sorgo"
    maiz = "maiz"
    avena = "avena"
    otro = "otro"
    pastura_consociada = "pastura_consociada"
    festuca = "festuca"
    agropiro = "agropiro"
    raigras = "raigras"
    cebada = "cebada"
    centeno = "centeno"
    triticale = "triticale"
    moha = "moha"
    gatton_panic = "gatton_panic"
    grama_rhodes = "grama_rhodes"
    rastrojo_maiz = "rastrojo_maiz"
    rastrojo_sorgo = "rastrojo_sorgo"
    rastrojo_soja = "rastrojo_soja"
    verdeo_verano = "verdeo_verano"


class TipoRegistroAlimentacion(str, Enum):
    """Qué se le dio al animal además del pastoreo del potrero.

    ``suplemento`` es un agregado puntual o temporal (grano en sequía, sales);
    ``dieta`` es un régimen que reemplaza o define su alimentación (engorde,
    recría a corral).
    """

    suplemento = "suplemento"
    dieta = "dieta"


class UnidadAlimento(str, Enum):
    """Unidad en la que se mide una cantidad de alimento."""

    kg = "kg"
    g = "g"
    l = "l"  # noqa: E741 - litros; el código es estable y lo comparte el cliente.
    fardo = "fardo"
    rollo = "rollo"
    bolsa = "bolsa"


class BaseCantidadAlimento(str, Enum):
    """A qué se refiere la cantidad de un registro de alimentación.

    ``por_animal_dia``: cada animal recibe esa cantidad por día.
    ``grupo_dia``: es lo que recibe todo el grupo por día.
    """

    por_animal_dia = "por_animal_dia"
    grupo_dia = "grupo_dia"


class CategoriaAlimento(str, Enum):
    """Categoría de un alimento del catálogo del establecimiento."""

    grano = "grano"
    concentrado = "concentrado"
    heno = "heno"
    silaje = "silaje"
    subproducto = "subproducto"
    mineral = "mineral"
    otro = "otro"


class EstadoReproductivo(str, Enum):
    """Condición reproductiva de una hembra, independiente de ``EstadoAnimal``.

    Un animal puede estar ``activo`` y ``prenada`` a la vez. ``null`` en la columna
    significa que no corresponde (por ejemplo, un macho).
    """

    sin_determinar = "sin_determinar"
    vacia = "vacia"
    prenada = "prenada"


class SexoPermitido(str, Enum):
    """Sexo de los animales que admite una categoría."""

    macho = "macho"
    hembra = "hembra"
    ambos = "ambos"
