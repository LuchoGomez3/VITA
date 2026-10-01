"""Validación de la geometría esquemática del lote.

Módulo puro: no conoce FastAPI, la sesión ni el modelo persistente, así que se
puede testear sin base de datos.

El polígono NO es geografía. Vive en un plano cartesiano común a los lotes de un
establecimiento, con extensión lógica 1000x1000, que es lo que permite dibujar el
campo en la manga sin mapa, sin GPS y sin señal. Interpretar ``x``/``y`` como
longitud/latitud sería un error: no hay ninguna transformación definida entre
este lienzo y WGS84.

La validación replica exactamente la del cliente
(``mobile/lib/features/field/data/mappers/lot_boundary_local_json_mapper.dart``),
que es estricta: rechaza cualquier ``type``, ``coordinate_space``, ``version`` o
``extent`` distinto del acordado. Si el backend fuera más permisivo, aceptaría
polígonos que el cliente después no puede releer.
"""

from typing import Any, Literal

from pydantic import BaseModel, ConfigDict, Field
from shapely.geometry import Polygon

TIPO_POLIGONO_LOCAL = "LocalPolygon"
ESPACIO_COORDENADAS = "establishment_canvas_v1"
VERSION_GEOMETRIA = 1
EXTENSION_LIENZO = 1000.0

# Tolerancia del área de intersección. Dos lotes que comparten un vértice o un
# borde se intersecan en una geometría de área cero; el ruido de punto flotante
# puede volverla un épsilon positivo. Solo un solapamiento real supera esto.
TOLERANCIA_AREA = 1e-9

# Área mínima para considerar que el polígono encierra superficie. Filtra los
# degenerados (vértices colineales) que shapely construye sin protestar.
AREA_MINIMA = 1e-9


class VerticeLocal(BaseModel):
    """Vértice del polígono en el lienzo del establecimiento."""

    model_config = ConfigDict(extra="forbid")

    x: float = Field(ge=0.0, le=EXTENSION_LIENZO)
    y: float = Field(ge=0.0, le=EXTENSION_LIENZO)


class ExtensionLienzo(BaseModel):
    """Extensión lógica del lienzo. Fija en 1000x1000 para la versión 1."""

    model_config = ConfigDict(extra="forbid")

    width: Literal[EXTENSION_LIENZO]
    height: Literal[EXTENSION_LIENZO]


class PoligonoLocal(BaseModel):
    """Polígono esquemático de un lote.

    El primer vértice no se repite al final: el anillo lo cierra quien lo
    consume, no la representación.
    """

    model_config = ConfigDict(extra="forbid")

    type: Literal[TIPO_POLIGONO_LOCAL]
    coordinate_space: Literal[ESPACIO_COORDENADAS]
    version: Literal[VERSION_GEOMETRIA]
    extent: ExtensionLienzo
    vertices: list[VerticeLocal] = Field(min_length=3)


class GeometriaInvalidaError(ValueError):
    """La geometría no describe un polígono utilizable.

    Es un error de valor, no de dominio: el service lo traduce a
    ``GeometriaLoteInvalidaError`` para no acoplar este módulo a la capa HTTP.
    """


def parsear(geometria: Any) -> PoligonoLocal:
    """Valida la estructura del JSON recibido y devuelve el polígono tipado."""
    if not isinstance(geometria, dict):
        raise GeometriaInvalidaError("La geometría debe ser un objeto JSON")
    try:
        return PoligonoLocal.model_validate(geometria)
    except Exception as exc:  # pydantic.ValidationError y derivados
        raise GeometriaInvalidaError(f"Geometría local inválida: {exc}") from exc


def a_shapely(poligono: PoligonoLocal) -> Polygon:
    """Convierte el polígono validado en una geometría de shapely."""
    return Polygon([(vertice.x, vertice.y) for vertice in poligono.vertices])


def validar_forma(poligono: PoligonoLocal) -> Polygon:
    """Exige que el polígono encierre superficie y no se cruce a sí mismo.

    Devuelve la geometría de shapely ya construida para no rehacer el trabajo en
    la validación de superposición.
    """
    distintos = {(vertice.x, vertice.y) for vertice in poligono.vertices}
    if len(distintos) < 3:
        raise GeometriaInvalidaError(
            "El polígono necesita al menos tres vértices distintos"
        )

    forma = a_shapely(poligono)
    if not forma.is_valid:
        # ``is_valid`` es falso, entre otras causas, cuando el borde se cruza
        # consigo mismo, que es el caso que el contrato nombra explícitamente.
        raise GeometriaInvalidaError(
            "El polígono es inválido o tiene auto-intersecciones"
        )
    if forma.area <= AREA_MINIMA:
        raise GeometriaInvalidaError("El polígono no encierra un área positiva")
    return forma


def hay_superposicion(una: Polygon, otra: Polygon) -> bool:
    """Indica si dos lotes se pisan con área positiva.

    Compartir un vértice, un borde o ser adyacentes es válido y esperado en un
    campo dividido en potreros: esas intersecciones tienen área cero.
    """
    if not una.intersects(otra):
        return False
    return una.intersection(otra).area > TOLERANCIA_AREA
