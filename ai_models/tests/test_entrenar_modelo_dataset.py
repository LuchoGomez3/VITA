"""Pruebas del lector y del procesamiento de fotos del entrenamiento."""

import csv
import tempfile
import unittest
from pathlib import Path

from scripts.entrenar_modelo_dataset import crear_dataset, leer_entrenamiento


class EntrenarModeloDatasetTest(unittest.TestCase):
    """Comprueba que los pesos del CSV lleguen al dataset de TensorFlow."""

    def test_lee_jpeg_y_png_con_sus_pesos(self):
        """La entrada admite los dos formatos que contiene el dataset real."""
        import tensorflow as tf

        with tempfile.TemporaryDirectory() as temporal:
            raiz = Path(temporal)
            fotos = raiz / "entrenamiento"
            fotos.mkdir()
            imagen = tf.zeros((4, 4, 3), dtype=tf.uint8)
            (fotos / "animal.jpg").write_bytes(tf.io.encode_jpeg(imagen).numpy())
            (fotos / "animal.png").write_bytes(tf.io.encode_png(imagen).numpy())
            etiquetas = raiz / "entrenamiento.csv"
            with etiquetas.open("w", newline="", encoding="utf-8") as archivo:
                escritor = csv.writer(archivo)
                escritor.writerow(("nombre_foto", "peso_kg"))
                escritor.writerow(("animal.jpg", "300"))
                escritor.writerow(("animal.png", "450"))

            rutas, pesos = leer_entrenamiento(etiquetas, fotos)
            dataset = crear_dataset(rutas, pesos, 2)
            imagenes, etiquetas_tensor = next(iter(dataset))
            self.assertEqual(imagenes.shape, (2, 224, 224, 3))
            self.assertEqual(sorted(etiquetas_tensor.numpy().tolist()), [300.0, 450.0])


if __name__ == "__main__":
    unittest.main()
