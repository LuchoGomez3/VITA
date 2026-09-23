"""Pruebas de la partición interna usada por AutoML."""

import unittest

from scripts.optimizar_hiperparametros import dividir_validacion, identificador_animal


class OptimizarHiperparametrosTest(unittest.TestCase):
    """Comprueba que el ajuste y la validación separen animales completos."""

    def test_identifica_fotos_fijas_videos_y_segundo_dataset(self):
        """Las distintas fotos del mismo animal reciben la misma clave."""
        self.assertEqual(identificador_animal("/tmp/BLF2001_0.jpg"), "1:BLF2001")
        self.assertEqual(identificador_animal("/tmp/video_BLF2001_7.jpg"), "1:BLF2001")
        self.assertEqual(identificador_animal("/tmp/BLF 2342_3.jpg"), "1:BLF 2342")
        self.assertEqual(identificador_animal("/tmp/lateral_62.png"), "2:62")

    def test_division_reproducible_sin_animales_compartidos(self):
        """Fotos fijas y capturas de cada animal quedan juntas con una semilla fija."""
        rutas = [
            "/tmp/BLF1_0.jpg",
            "/tmp/video_BLF1_3.jpg",
            "/tmp/BLF2_0.jpg",
            "/tmp/video_BLF2_7.jpg",
            "/tmp/BLF3_0.jpg",
            "/tmp/lateral_1.png",
        ]
        pesos = [300, 300, 400, 400, 500, 600]
        primera = dividir_validacion(rutas, pesos, 0.33, 42)
        segunda = dividir_validacion(rutas, pesos, 0.33, 42)
        self.assertEqual(primera, segunda)
        entrenamiento, validacion = primera
        self.assertFalse(
            {identificador_animal(ruta) for ruta, _ in entrenamiento}
            & {identificador_animal(ruta) for ruta, _ in validacion}
        )
        self.assertEqual(len(entrenamiento) + len(validacion), len(rutas))


if __name__ == "__main__":
    unittest.main()
