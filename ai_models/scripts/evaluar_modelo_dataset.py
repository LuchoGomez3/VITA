"""Evalúa el modelo de pesaje con las fotos reservadas para prueba."""

import argparse
import csv
import math
from pathlib import Path

from .entrenar_modelo_dataset import RAIZ, TAMANO_LOTE, leer_entrenamiento


def crear_dataset_prueba(rutas, tamano_lote):
    """Procesa las fotos en orden, sin mezcla ni aumentos aleatorios."""
    import tensorflow as tf

    def preparar_imagen(ruta):
        """Aplica el mismo tamaño y escala usados durante el entrenamiento."""
        contenido = tf.io.read_file(ruta)
        imagen = tf.io.decode_image(contenido, channels=3, expand_animations=False)
        imagen.set_shape((None, None, 3))
        imagen = tf.image.resize(imagen, (224, 224))
        return tf.keras.applications.mobilenet_v2.preprocess_input(imagen)

    dataset = tf.data.Dataset.from_tensor_slices(rutas)
    dataset = dataset.map(preparar_imagen, num_parallel_calls=tf.data.AUTOTUNE)
    return dataset.batch(tamano_lote).prefetch(tf.data.AUTOTUNE)


def calcular_metricas(pesos_reales, pesos_estimados):
    """Calcula el error absoluto y cuadrático medio en kilogramos."""
    if not pesos_reales or len(pesos_reales) != len(pesos_estimados):
        raise ValueError("Las listas de pesos deben tener la misma longitud y no estar vacías")
    errores = [estimado - real for real, estimado in zip(pesos_reales, pesos_estimados, strict=True)]
    mae = sum(abs(error) for error in errores) / len(errores)
    rmse = math.sqrt(sum(error**2 for error in errores) / len(errores))
    return mae, rmse


def guardar_resultados(ruta_csv, rutas, pesos_reales, pesos_estimados):
    """Guarda cada predicción junto al peso conocido y su error absoluto."""
    ruta_csv.parent.mkdir(parents=True, exist_ok=True)
    with ruta_csv.open("w", newline="", encoding="utf-8") as archivo:
        escritor = csv.writer(archivo)
        escritor.writerow(("nombre_foto", "peso_real_kg", "peso_estimado_kg", "error_absoluto_kg"))
        for ruta, real, estimado in zip(rutas, pesos_reales, pesos_estimados, strict=True):
            escritor.writerow((Path(ruta).name, f"{real:.2f}", f"{estimado:.2f}", f"{abs(estimado - real):.2f}"))


def main():
    """Carga el modelo entrenado, evalúa el conjunto de prueba e informa el error."""
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--dataset", type=Path, default=(RAIZ / "../../dataset").resolve())
    parser.add_argument("--modelo", type=Path, default=RAIZ / "models/modelo_pesaje_lateral_video.keras")
    parser.add_argument("--resultados", type=Path, default=RAIZ / "results/modelo_lateral_video_prueba_ampliada.csv")
    args = parser.parse_args()
    if not args.modelo.is_file():
        parser.error(f"No existe el modelo: {args.modelo}")

    rutas, pesos_reales = leer_entrenamiento(args.dataset / "prueba.csv", args.dataset / "prueba")
    dataset = crear_dataset_prueba(rutas, TAMANO_LOTE)

    import tensorflow as tf

    modelo = tf.keras.models.load_model(args.modelo)
    predicciones = modelo.predict(dataset, verbose=0).reshape(-1).tolist()
    mae, rmse = calcular_metricas(pesos_reales, predicciones)
    guardar_resultados(args.resultados, rutas, pesos_reales, predicciones)
    print(f"Fotos evaluadas: {len(rutas)}")
    print(f"MAE: {mae:.2f} kg")
    print(f"RMSE: {rmse:.2f} kg")
    print(f"Predicciones guardadas en: {args.resultados}")


if __name__ == "__main__":
    main()
