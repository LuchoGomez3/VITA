"""Tests de la geometría esquemática del lote.

Unitarios y sin base de datos: validan el módulo puro ``lotes.geometria``, que es
donde vive la regla más delicada del contrato — dos lotes pueden tocarse pero no
pisarse.
"""

import pytest

from api.modules.lotes import geometria as geo
from tests.factories import geometria_rectangulo, poligono

# --------------------------------------------------------------- estructura


def test_poligono_valido_se_parsea():
    resultado = geo.parsear(geometria_rectangulo(0, 0, 100, 100))
    assert resultado.type == "LocalPolygon"
    assert resultado.coordinate_space == "establishment_canvas_v1"
    assert len(resultado.vertices) == 4


def test_geometria_que_no_es_objeto_se_rechaza():
    with pytest.raises(geo.GeometriaInvalidaError):
        geo.parsear("no soy un objeto")


def test_espacio_de_coordenadas_desconocido_se_rechaza():
    invalido = geometria_rectangulo(0, 0, 100, 100)
    invalido["coordinate_space"] = "wgs84"
    with pytest.raises(geo.GeometriaInvalidaError):
        geo.parsear(invalido)


def test_version_desconocida_se_rechaza():
    invalido = geometria_rectangulo(0, 0, 100, 100)
    invalido["version"] = 2
    with pytest.raises(geo.GeometriaInvalidaError):
        geo.parsear(invalido)


def test_extension_distinta_del_lienzo_se_rechaza():
    invalido = geometria_rectangulo(0, 0, 100, 100)
    invalido["extent"] = {"width": 500.0, "height": 500.0}
    with pytest.raises(geo.GeometriaInvalidaError):
        geo.parsear(invalido)


def test_tipo_distinto_se_rechaza():
    invalido = geometria_rectangulo(0, 0, 100, 100)
    invalido["type"] = "Polygon"
    with pytest.raises(geo.GeometriaInvalidaError):
        geo.parsear(invalido)


def test_menos_de_tres_vertices_se_rechaza():
    with pytest.raises(geo.GeometriaInvalidaError):
        geo.parsear(poligono([(0, 0), (100, 0)]))


def test_vertice_fuera_del_lienzo_se_rechaza():
    with pytest.raises(geo.GeometriaInvalidaError):
        geo.parsear(poligono([(0, 0), (1500, 0), (100, 100)]))


def test_coordenada_negativa_se_rechaza():
    with pytest.raises(geo.GeometriaInvalidaError):
        geo.parsear(poligono([(0, 0), (-10, 50), (100, 100)]))


# ------------------------------------------------------------------- forma


def test_forma_valida_devuelve_area_positiva():
    forma = geo.validar_forma(geo.parsear(geometria_rectangulo(0, 0, 100, 100)))
    assert forma.area == pytest.approx(10_000.0)


def test_auto_interseccion_se_rechaza():
    # Un "moño": los bordes se cruzan en el medio.
    mono = poligono([(0, 0), (100, 100), (100, 0), (0, 100)])
    with pytest.raises(geo.GeometriaInvalidaError, match="auto-intersecciones"):
        geo.validar_forma(geo.parsear(mono))


def test_vertices_colineales_se_rechazan():
    """Tres puntos en línea no encierran superficie, así que no son un lote.

    Shapely los clasifica como polígono inválido antes de que el chequeo de área
    llegue a correr; lo que importa del contrato es que se rechacen.
    """
    linea = poligono([(0, 0), (50, 50), (100, 100)])
    with pytest.raises(geo.GeometriaInvalidaError):
        geo.validar_forma(geo.parsear(linea))


def test_tres_vertices_pero_dos_repetidos_se_rechaza():
    degenerado = poligono([(0, 0), (100, 100), (100, 100), (0, 0)])
    with pytest.raises(geo.GeometriaInvalidaError, match="tres vértices distintos"):
        geo.validar_forma(geo.parsear(degenerado))


# ----------------------------------------------------------- superposición


def _forma(x0, y0, x1, y1):
    return geo.validar_forma(geo.parsear(geometria_rectangulo(x0, y0, x1, y1)))


def test_lotes_separados_no_se_superponen():
    assert not geo.hay_superposicion(_forma(0, 0, 100, 100), _forma(200, 200, 300, 300))


def test_solapamiento_parcial_se_detecta():
    assert geo.hay_superposicion(_forma(0, 0, 100, 100), _forma(50, 50, 150, 150))


def test_contencion_total_se_detecta():
    assert geo.hay_superposicion(_forma(0, 0, 200, 200), _forma(50, 50, 100, 100))


def test_geometrias_identicas_se_detectan():
    assert geo.hay_superposicion(_forma(0, 0, 100, 100), _forma(0, 0, 100, 100))


def test_borde_compartido_es_valido():
    """Dos potreros pegados comparten un alambrado: es lo normal en un campo."""
    assert not geo.hay_superposicion(_forma(0, 0, 100, 100), _forma(100, 0, 200, 100))


def test_vertice_compartido_es_valido():
    """Cuatro potreros que se tocan en una esquina tampoco se pisan."""
    assert not geo.hay_superposicion(_forma(0, 0, 100, 100), _forma(100, 100, 200, 200))


def test_borde_compartido_parcial_es_valido():
    # Adyacencia sobre parte del lado, no sobre todo: sigue siendo área cero.
    assert not geo.hay_superposicion(_forma(0, 0, 100, 100), _forma(100, 40, 200, 60))
