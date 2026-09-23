"""Pruebas de la división de fotos y sus etiquetas."""

import csv
import tempfile
import unittest
from pathlib import Path

from scripts.preparar_dataset import buscar_fotos, dividir_grupos, guardar_particion


class PrepararDatasetTest(unittest.TestCase):
    """Comprueba que cada foto conserve su peso y su grupo de origen."""

    def test_division_y_csv_coinciden_con_las_fotos(self):
        """Las vistas del mismo animal permanecen juntas y cada CSV apunta a una foto."""
        with tempfile.TemporaryDirectory() as temporal:
            raiz = Path(temporal)
            fotos_1 = raiz / "fotos_1"
            fotos_2 = raiz / "fotos_2"
            fotos_video = raiz / "fotos_video"
            fotos_1.mkdir()
            fotos_2.mkdir()
            fotos_video.mkdir()
            (fotos_2 / "side view").mkdir()
            (fotos_2 / "back view").mkdir()
            csv_1 = raiz / "dataset_1.csv"
            csv_2 = raiz / "measurements.csv"
            with csv_1.open("w", newline="", encoding="utf-8") as archivo:
                escritor = csv.DictWriter(archivo, fieldnames=["sku", "weight_in_kg"])
                escritor.writeheader()
                for numero in range(4):
                    identificador = f"BLF{numero}"
                    escritor.writerow({"sku": identificador, "weight_in_kg": str(300 + numero)})
                    carpeta = fotos_1 / identificador
                    carpeta.mkdir()
                    for vista in range(4):
                        (carpeta / f"{identificador}_{vista}.jpg").write_bytes(b"foto")
                    carpeta_video = fotos_video / identificador
                    carpeta_video.mkdir()
                    for cuadro in (3, 7, 20):
                        (carpeta_video / f"{identificador}_{cuadro}.jpg").write_bytes(b"video")
            with csv_2.open("w", newline="", encoding="utf-8") as archivo:
                escritor = csv.DictWriter(archivo, fieldnames=["Num", "Body weight (kg)"])
                escritor.writeheader()
                escritor.writerow({"Num": "1", "Body weight (kg)": "450"})
            (fotos_2 / "side view" / "1.png").write_bytes(b"lateral")
            (fotos_2 / "back view" / "1.png").write_bytes(b"trasera")

            grupos = buscar_fotos(fotos_1, fotos_2, csv_1, csv_2, fotos_video)
            entrenamiento, prueba = dividir_grupos(grupos, 42)
            self.assertEqual(set(entrenamiento) | set(prueba), set(grupos))
            self.assertFalse(set(entrenamiento) & set(prueba))
            self.assertEqual(len(grupos["2:1"]), 1)
            self.assertEqual(len(grupos["1:BLF0"]), 5)
            self.assertEqual(
                {nombre for _, nombre, _ in grupos["1:BLF0"] if nombre.startswith("video_")},
                {"video_BLF0_3.jpg", "video_BLF0_7.jpg"},
            )

            for nombre, particion in (("entrenamiento", entrenamiento), ("prueba", prueba)):
                carpeta = raiz / "salida" / nombre
                etiquetas = raiz / "salida" / f"{nombre}.csv"
                cantidad = guardar_particion(particion, carpeta, etiquetas)
                with etiquetas.open(newline="", encoding="utf-8") as archivo:
                    filas = list(csv.DictReader(archivo))
                self.assertEqual(len(filas), cantidad)
                self.assertEqual({fila["nombre_foto"] for fila in filas}, {ruta.name for ruta in carpeta.iterdir()})
                for fila in filas:
                    self.assertTrue(fila["peso_kg"])
            nombres_segundo_conjunto = {nombre for _, nombre, _ in grupos["2:1"]}
            self.assertEqual(nombres_segundo_conjunto, {"lateral_1.png"})


if __name__ == "__main__":
    unittest.main()
