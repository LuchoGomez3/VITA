"""Comprueba la calibración por animal y los límites reportados."""

import unittest

from scripts.intervalo_peso import aplicar_intervalo, calcular_margen_por_animal


class IntervaloPesoTests(unittest.TestCase):
    """Verifica que los cuadros repetidos no agranden la muestra efectiva."""

    def test_cuantil_usa_el_maximo_de_cada_animal(self):
        """El animal con dos fotos aporta su peor error una sola vez."""
        rutas = ["a_1", "a_2", "b_1", "c_1", "d_1", "e_1", "f_1", "g_1", "h_1", "i_1"]
        reales = [100.0] * len(rutas)
        estimados = [99.0, 90.0, 98.0, 97.0, 96.0, 95.0, 94.0, 93.0, 92.0, 89.0]
        margen, animales = calcular_margen_por_animal(
            rutas, reales, estimados, lambda ruta: ruta.split("_")[0], 0.8
        )
        self.assertEqual(animales, 9)
        self.assertEqual(margen, 10.0)

    def test_rechaza_cobertura_imposible_y_limita_a_cero(self):
        """Una muestra pequeña no justifica cualquier cobertura objetivo."""
        with self.assertRaises(ValueError):
            calcular_margen_por_animal(["a"], [100.0], [90.0], lambda ruta: ruta, 0.9)
        self.assertEqual(aplicar_intervalo(8.0, 10.0), (0.0, 18.0))


if __name__ == "__main__":
    unittest.main()
