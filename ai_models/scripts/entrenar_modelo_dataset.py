"""Entrena un modelo de pesaje con las imágenes de ../../dataset/entrenamiento."""

import argparse
import csv
from pathlib import Path


# Estos valores corresponden a la prueba de hiperparámetros elegida en TensorBoard.
TAMANO_LOTE = 16
DROPOUT = 0.1
TASA_APRENDIZAJE = 0.01
NEURONAS = 2048
EPOCAS = 10
RAIZ = Path(__file__).resolve().parent.parent


def leer_entrenamiento(ruta_csv, carpeta_imagenes):
    """Valida las etiquetas y construye las rutas de las fotos existentes."""
    rutas = []
    pesos = []
    with ruta_csv.open(newline="", encoding="utf-8-sig") as archivo:
        lector = csv.DictReader(archivo)
        if not lector.fieldnames or not {"nombre_foto", "peso_kg"}.issubset(lector.fieldnames):
            raise ValueError("El CSV debe contener nombre_foto y peso_kg")
        for fila in lector:
            nombre = fila["nombre_foto"].strip()
            # Se admiten solo nombres simples para mantener cada foto dentro del dataset.
            if not nombre or Path(nombre).name != nombre:
                raise ValueError(f"Nombre de foto inválido: {nombre!r}")
            ruta = carpeta_imagenes / nombre
            if not ruta.is_file():
                raise FileNotFoundError(f"No existe la foto indicada en el CSV: {ruta}")
            peso = float(fila["peso_kg"])
            if peso <= 0:
                raise ValueError(f"Peso inválido para {nombre}: {peso}")
            rutas.append(str(ruta))
            pesos.append(peso)
    if not rutas:
        raise ValueError("El CSV de entrenamiento está vacío")
    return rutas, pesos


def crear_dataset(rutas, pesos, tamano_lote, es_entrenamiento=True):
    """Prepara JPEG y PNG; solo aumenta y mezcla las fotos de entrenamiento."""
    import tensorflow as tf

    def preparar_imagen(ruta, peso):
        """Lee una foto y la convierte al tamaño y escala que espera MobileNetV2."""
        contenido = tf.io.read_file(ruta)
        imagen = tf.io.decode_image(contenido, channels=3, expand_animations=False)
        imagen.set_shape((None, None, 3))
        imagen = tf.image.resize(imagen, (224, 224))
        imagen = tf.keras.applications.mobilenet_v2.preprocess_input(imagen)
        if es_entrenamiento:
            imagen = tf.image.random_flip_left_right(imagen)
        return imagen, peso

    dataset = tf.data.Dataset.from_tensor_slices((rutas, pesos))
    if es_entrenamiento:
        dataset = dataset.shuffle(len(rutas), seed=42, reshuffle_each_iteration=True)
    dataset = dataset.map(preparar_imagen, num_parallel_calls=tf.data.AUTOTUNE)
    return dataset.batch(tamano_lote).prefetch(tf.data.AUTOTUNE)


def main():
    """Crea el modelo con los hiperparámetros elegidos y lo entrena por diez épocas."""
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--dataset", type=Path, default=(RAIZ / "../../dataset").resolve())
    parser.add_argument("--epocas", type=int, default=EPOCAS)
    parser.add_argument("--modelo", type=Path, default=RAIZ / "models/modelo_pesaje_lateral_video.keras")
    parser.add_argument("--logs", type=Path, default=RAIZ / "logs/modelo_pesaje_lateral_video")
    args = parser.parse_args()
    if args.epocas < 1:
        parser.error("--epocas debe ser mayor que cero")

    rutas, pesos = leer_entrenamiento(args.dataset / "entrenamiento.csv", args.dataset / "entrenamiento")
    dataset = crear_dataset(rutas, pesos, TAMANO_LOTE)

    import tensorflow as tf

    from .model_builder import build_weight_estimation_model

    modelo = build_weight_estimation_model(
        dropout_rate=DROPOUT,
        neurons=NEURONAS,
        learning_rate=TASA_APRENDIZAJE,
    )
    args.logs.mkdir(parents=True, exist_ok=True)
    args.modelo.parent.mkdir(parents=True, exist_ok=True)
    print(f"Entrenando con {len(rutas)} fotos durante {args.epocas} épocas")
    modelo.fit(
        dataset,
        epochs=args.epocas,
        shuffle=False,  # El dataset ya mezcla las fotos antes de formar cada lote.
        verbose=2,  # Muestra un resumen por época sin llenar la terminal.
        callbacks=[tf.keras.callbacks.TensorBoard(log_dir=str(args.logs))],
    )
    modelo.save(args.modelo)
    print(f"Modelo guardado en {args.modelo}")
    print(f"Logs de TensorBoard en {args.logs}")


if __name__ == "__main__":
    main()
