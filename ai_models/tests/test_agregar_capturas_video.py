"""Pruebas para incorporar capturas sin mezclar animales entre particiones."""

import csv
import tempfile
import unittest
from pathlib import Path

from scripts.agregar_capturas_video import agregar_capturas


class AgregarCapturasVideoTest(unittest.TestCase):
    """Verifica la partición, el peso y la repetición segura del proceso."""

    def test_capturas_siguen_a_su_animal(self):
        """Dos cuadros tempranos se copian junto a las fotos fijas del mismo animal."""
        with tempfile.TemporaryDirectory() as temporal:
            raiz = Path(temporal)
            dataset = raiz / "dataset"
            videos = raiz / "videos"
            dataset.mkdir()
            videos.mkdir()
            metadatos = raiz / "pesos.csv"
            with metadatos.open("w", newline="", encoding="utf-8") as archivo:
                escritor = csv.writer(archivo)
                escritor.writerow(("sku", "weight_in_kg"))
                escritor.writerows((("BLF1", "300"), ("BLF2", "400")))
            for particion, identificador, peso in (("entrenamiento", "BLF1", "300"), ("prueba", "BLF2", "400")):
                carpeta = dataset / particion
                carpeta.mkdir()
                (carpeta / f"{identificador}_0.jpg").write_bytes(b"foto")
                with (dataset / f"{particion}.csv").open("w", newline="", encoding="utf-8") as archivo:
                    escritor = csv.writer(archivo)
                    escritor.writerow(("nombre_foto", "peso_kg"))
                    escritor.writerow((f"{identificador}_0.jpg", peso))
                carpeta_video = videos / identificador
                carpeta_video.mkdir()
                for cuadro in (3, 7, 20):
                    (carpeta_video / f"{identificador}_{cuadro}.jpg").write_bytes(b"video")

            self.assertEqual(agregar_capturas(dataset, videos, metadatos), {"entrenamiento": 2, "prueba": 2})
            self.assertEqual(agregar_capturas(dataset, videos, metadatos), {"entrenamiento": 0, "prueba": 0})
            for particion, identificador, peso in (("entrenamiento", "BLF1", "300"), ("prueba", "BLF2", "400")):
                with (dataset / f"{particion}.csv").open(newline="", encoding="utf-8") as archivo:
                    filas = list(csv.DictReader(archivo))
                nombres = {fila["nombre_foto"] for fila in filas}
                self.assertEqual(nombres, {f"{identificador}_0.jpg", f"video_{identificador}_3.jpg", f"video_{identificador}_7.jpg"})
                self.assertEqual({fila["peso_kg"] for fila in filas}, {peso})
                self.assertEqual(nombres, {ruta.name for ruta in (dataset / particion).iterdir()})


if __name__ == "__main__":
    unittest.main()
