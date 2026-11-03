"""Constructores de datos de prueba compartidos entre módulos de test.

Existen para que un cambio en un campo obligatorio se arregle en un solo lugar
en vez de en cada fixture que arma la misma entidad.
"""

from decimal import Decimal
from uuid import UUID

from api.modules.lotes.models import Lote

EXTENSION_LIENZO = 1000.0

# Grilla de cuadrados que no se superponen, misma que usa el backfill de la
# migración: paso 245 con lados de 225 deja 20 de separación entre lotes.
_COLUMNAS = 4
_PASO = 245.0
_LADO = 225.0
_MARGEN = 20.0


def geometria_cuadrado(indice: int = 0) -> dict:
    """Polígono válido en la celda ``indice`` de la grilla.

    Dos índices distintos nunca se superponen, así que sirven para armar varios
    lotes en un mismo establecimiento sin disparar ``lotes_superpuestos``.
    """
    x0 = _MARGEN + (indice % _COLUMNAS) * _PASO
    y0 = _MARGEN + (indice // _COLUMNAS) * _PASO
    return geometria_rectangulo(x0, y0, x0 + _LADO, y0 + _LADO)


def geometria_rectangulo(x0: float, y0: float, x1: float, y1: float) -> dict:
    """Rectángulo arbitrario, para los tests que necesitan una posición exacta."""
    return poligono(
        [(x0, y0), (x1, y0), (x1, y1), (x0, y1)],
    )


def poligono(vertices: list[tuple[float, float]]) -> dict:
    """Envuelve una lista de vértices en el formato del contrato."""
    return {
        "type": "LocalPolygon",
        "coordinate_space": "establishment_canvas_v1",
        "version": 1,
        "extent": {"width": EXTENSION_LIENZO, "height": EXTENSION_LIENZO},
        # El primer vértice no se repite al final.
        "vertices": [{"x": x, "y": y} for x, y in vertices],
    }


def crear_lote(
    establecimiento_id: UUID,
    nombre: str = "Lote 1",
    *,
    indice_geometria: int = 0,
    superficie_ha: str = "45.5",
    **overrides,
) -> Lote:
    """Lote válido con geometría, listo para persistir."""
    campos = {
        "establecimiento_id": establecimiento_id,
        "nombre": nombre,
        "geometria_local": geometria_cuadrado(indice_geometria),
        "superficie_ha": Decimal(superficie_ha),
    }
    campos.update(overrides)
    return Lote(**campos)
