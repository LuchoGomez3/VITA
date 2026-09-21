"""Prueba la selección de capas y el conteo de cobertura por animal."""

import unittest

import tensorflow as tf

from scripts.ajustar_modelo_con_intervalo import (
    configurar_ajuste_fino,
    resumir_cobertura,
)


class AjusteFinoTests(unittest.TestCase):
    """Comprueba las dos decisiones que afectan al ajuste y la evaluación."""

    def test_batchnorm_queda_congelada(self):
        """La cabeza aprende, mientras BatchNorm mantiene sus estadísticas."""
        entrada = tf.keras.Input(shape=(4,))
        base = tf.keras.layers.Dense(4, name="base")(entrada)
        normalizada = tf.keras.layers.BatchNormalization(name="normalizacion")(base)
        promedio = tf.keras.layers.GlobalAveragePooling2D()(
            tf.keras.layers.Reshape((2, 2, 1))(normalizada)
        )
        salida = tf.keras.layers.Dense(1, name="salida")(promedio)
        modelo = tf.keras.Model(entrada, salida)
        cantidad = configurar_ajuste_fino(modelo, 3, 0.00001)
        self.assertEqual(cantidad, 2)
        self.assertFalse(modelo.get_layer("normalizacion").trainable)
        self.assertTrue(modelo.get_layer("salida").trainable)

    def test_cobertura_exige_todas_las_fotos_de_un_animal(self):
        """Una sola foto fuera del intervalo deja al animal sin cobertura total."""
        rutas = ["BLF1_0.jpg", "BLF1_1.jpg", "BLF2_0.jpg"]
        cobertura, cubiertos, animales = resumir_cobertura(
            rutas, [100, 120, 100], [100, 100, 100], 10
        )
        self.assertAlmostEqual(cobertura, 2 / 3)
        self.assertEqual((cubiertos, animales), (1, 2))


if __name__ == "__main__":
    unittest.main()
