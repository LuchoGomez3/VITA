"""Pruebas de las métricas y el CSV de evaluación."""

import csv
import tempfile
import unittest
from pathlib import Path

from scripts.evaluar_modelo_dataset import calcular_metricas, guardar_resultados


class EvaluarModeloDatasetTest(unittest.TestCase):
    """Verifica que los errores informados correspondan a las predicciones."""

    def test_metricas_y_resultados_por_foto(self):
        """El error promedio y las filas del CSV usan los mismos pesos."""
        reales = [300.0, 400.0]
        estimados = [310.0, 380.0]
        mae, rmse = calcular_metricas(reales, estimados)
        self.assertEqual(mae, 15.0)
        self.assertAlmostEqual(rmse, (250.0) ** 0.5)

        with tempfile.TemporaryDirectory() as temporal:
            salida = Path(temporal) / "resultados.csv"
            guardar_resultados(salida, ["/fotos/uno.jpg", "/fotos/dos.png"], reales, estimados)
            with salida.open(newline="", encoding="utf-8") as archivo:
                filas = list(csv.DictReader(archivo))
            self.assertEqual([fila["nombre_foto"] for fila in filas], ["uno.jpg", "dos.png"])
            self.assertEqual([fila["error_absoluto_kg"] for fila in filas], ["10.00", "20.00"])


if __name__ == "__main__":
    unittest.main()
