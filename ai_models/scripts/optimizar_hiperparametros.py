"""Busca hiperparámetros por MAE de validación y entrena un modelo final."""

import argparse
import csv
import hashlib
import json
import random
from collections import defaultdict
from pathlib import Path

import keras_tuner as kt
import tensorflow as tf

from .entrenar_modelo_dataset import RAIZ, crear_dataset, leer_entrenamiento
from .evaluar_modelo_dataset import calcular_metricas, crear_dataset_prueba, guardar_resultados
from .model_builder import build_weight_estimation_model


def identificador_animal(ruta):
    """Recupera el animal común a fotos fijas y capturas de un mismo video."""
    nombre = Path(ruta).name
    if nombre.startswith("lateral_") and nombre.lower().endswith(".png"):
        return f"2:{Path(nombre).stem.removeprefix('lateral_')}"
    if nombre.startswith("video_"):
        nombre = nombre.removeprefix("video_")
    identificador, separador, vista = Path(nombre).stem.rpartition("_")
    if not separador or not vista.isdigit() or not identificador.startswith("BLF"):
        raise ValueError(f"No se puede identificar el animal de {ruta}")
    return f"1:{identificador}"


def dividir_validacion(rutas, pesos, fraccion, semilla):
    """Aparta animales completos para validación con una semilla reproducible."""
    if len(rutas) != len(pesos) or not 0 < fraccion < 1:
        raise ValueError("Rutas, pesos o fracción de validación inválidos")
    grupos = defaultdict(list)
    for ruta, peso in zip(rutas, pesos, strict=True):
        grupos[identificador_animal(ruta)].append((ruta, peso))
    if len(grupos) < 2:
        raise ValueError("Se necesitan al menos dos animales para separar validación")

    claves = sorted(grupos)
    random.Random(semilla).shuffle(claves)
    objetivo = round(len(rutas) * fraccion)
    claves_validacion = set()
    cantidad = 0
    for clave in claves:
        if cantidad < objetivo and len(claves_validacion) < len(claves) - 1:
            claves_validacion.add(clave)
            cantidad += len(grupos[clave])

    entrenamiento = [par for clave in claves if clave not in claves_validacion for par in grupos[clave]]
    validacion = [par for clave in claves if clave in claves_validacion for par in grupos[clave]]
    return entrenamiento, validacion


def guardar_manifiesto(ruta_csv, pares):
    """Deja una lista reproducible de fotos y pesos de cada partición interna."""
    ruta_csv.parent.mkdir(parents=True, exist_ok=True)
    with ruta_csv.open("w", newline="", encoding="utf-8") as archivo:
        escritor = csv.writer(archivo)
        escritor.writerow(("nombre_foto", "peso_kg"))
        escritor.writerows((Path(ruta).name, peso) for ruta, peso in pares)


class ModeloPesajeBuscable(kt.HyperModel):
    """Define el espacio de modelos y el tamaño de lote de cada prueba."""

    def build(self, hp):
        """Crea MobileNetV2 con una combinación candidata de tres parámetros."""
        return build_weight_estimation_model(
            dropout_rate=hp.Choice("dropout", [0.0, 0.1, 0.2, 0.3, 0.4]),
            neurons=hp.Choice("neurons", [256, 512, 1024, 2048]),
            learning_rate=hp.Choice("learning_rate", [0.0001, 0.0003, 0.001, 0.003, 0.01]),
        )

    def fit(self, hp, model, rutas, pesos, validation_data, **kwargs):
        """Arma lotes propios; validación no mezcla ni modifica las imágenes."""
        tamano_lote = hp.Choice("batch_size", [8, 16, 32])
        rutas_validacion, pesos_validacion = validation_data
        entrenamiento = crear_dataset(rutas, pesos, tamano_lote, es_entrenamiento=True)
        validacion = crear_dataset(
            rutas_validacion,
            pesos_validacion,
            tamano_lote,
            es_entrenamiento=False,
        )
        return model.fit(entrenamiento, validation_data=validacion, shuffle=False, **kwargs)


def main():
    """Busca por validación, reentrena con todas las fotos y evalúa al final."""
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--dataset", type=Path, default=(RAIZ / "../../dataset").resolve())
    parser.add_argument("--salida", type=Path, default=RAIZ / "models/modelo_pesaje_auto_ml.keras")
    parser.add_argument("--directorio-busqueda", type=Path, default=RAIZ / "logs/auto_ml")
    parser.add_argument("--resultados", type=Path, default=RAIZ / "results/modelo_auto_ml_prueba.csv")
    parser.add_argument("--max-epocas", type=int, default=8)
    parser.add_argument("--epocas-final", type=int, default=10)
    parser.add_argument("--fraccion-validacion", type=float, default=0.2)
    parser.add_argument("--semilla", type=int, default=42)
    args = parser.parse_args()
    if args.max_epocas < 2 or args.epocas_final < 1 or not 0 < args.fraccion_validacion < 1:
        parser.error("Revisá épocas y fracción de validación")

    rutas, pesos = leer_entrenamiento(args.dataset / "entrenamiento.csv", args.dataset / "entrenamiento")
    rutas_prueba, pesos_prueba = leer_entrenamiento(args.dataset / "prueba.csv", args.dataset / "prueba")
    animales_entrenamiento = {identificador_animal(ruta) for ruta in rutas}
    animales_prueba = {identificador_animal(ruta) for ruta in rutas_prueba}
    if animales_entrenamiento & animales_prueba:
        parser.error("Un animal aparece en entrenamiento y prueba")
    entrenamiento, validacion = dividir_validacion(rutas, pesos, args.fraccion_validacion, args.semilla)
    rutas_entrenamiento, pesos_entrenamiento = zip(*entrenamiento, strict=True)
    rutas_validacion, pesos_validacion = zip(*validacion, strict=True)

    # El resumen impide reanudar una búsqueda con otro dataset o partición.
    configuracion = {
        "semilla": args.semilla,
        "fraccion_validacion": args.fraccion_validacion,
        "max_epocas": args.max_epocas,
        "huella_dataset": hashlib.sha256(
            json.dumps(sorted(zip(rutas, pesos, strict=True))).encode("utf-8")
        ).hexdigest(),
    }
    args.directorio_busqueda.mkdir(parents=True, exist_ok=True)
    ruta_configuracion = args.directorio_busqueda / "configuracion.json"
    if ruta_configuracion.exists():
        if json.loads(ruta_configuracion.read_text(encoding="utf-8")) != configuracion:
            parser.error("La búsqueda existente usa otros datos o parámetros; elegí otro --directorio-busqueda")
    else:
        ruta_configuracion.write_text(json.dumps(configuracion, indent=2), encoding="utf-8")
    guardar_manifiesto(args.directorio_busqueda / "entrenamiento.csv", entrenamiento)
    guardar_manifiesto(args.directorio_busqueda / "validacion.csv", validacion)

    tf.keras.utils.set_random_seed(args.semilla)
    tuner = kt.Hyperband(
        hypermodel=ModeloPesajeBuscable(),
        objective=kt.Objective("val_mae", direction="min"),
        max_epochs=args.max_epocas,
        factor=3,
        hyperband_iterations=1,
        directory=str(args.directorio_busqueda),
        project_name="peso_lateral",
        overwrite=False,
        seed=args.semilla,
    )
    print(f"Búsqueda: {len(entrenamiento)} fotos para ajustar y {len(validacion)} para validar")
    tuner.search(
        list(rutas_entrenamiento),
        list(pesos_entrenamiento),
        validation_data=(list(rutas_validacion), list(pesos_validacion)),
        epochs=args.max_epocas,
        callbacks=[tf.keras.callbacks.EarlyStopping(monitor="val_mae", patience=2)],
        verbose=2,
    )

    mejor = tuner.get_best_hyperparameters(1)[0]
    mejor_prueba = tuner.oracle.get_best_trials(1)[0]
    parametros = {clave: mejor.get(clave) for clave in ("batch_size", "dropout", "learning_rate", "neurons")}
    resumen = {
        "parametros": parametros,
        "mejor_mae_validacion_kg": mejor_prueba.score,
        "fotos_busqueda": len(entrenamiento),
        "fotos_validacion": len(validacion),
        "animales_busqueda": len({identificador_animal(ruta) for ruta, _ in entrenamiento}),
        "animales_validacion": len({identificador_animal(ruta) for ruta, _ in validacion}),
    }
    ruta_resumen = args.directorio_busqueda / "mejores_parametros.json"
    ruta_resumen.write_text(json.dumps(resumen, indent=2), encoding="utf-8")
    print(f"Mejores parámetros: {parametros}; MAE de validación: {mejor_prueba.score:.2f} kg")

    # El modelo final usa todas las fotos de entrenamiento, incluida la validación interna.
    tf.keras.utils.set_random_seed(args.semilla)
    modelo = build_weight_estimation_model(
        dropout_rate=parametros["dropout"],
        neurons=parametros["neurons"],
        learning_rate=parametros["learning_rate"],
    )
    dataset_final = crear_dataset(rutas, pesos, parametros["batch_size"], es_entrenamiento=True)
    modelo.fit(
        dataset_final,
        epochs=args.epocas_final,
        shuffle=False,
        verbose=2,
        callbacks=[tf.keras.callbacks.TensorBoard(log_dir=str(args.directorio_busqueda / "modelo_final"))],
    )
    args.salida.parent.mkdir(parents=True, exist_ok=True)
    modelo.save(args.salida)

    # La prueba reservada se usa una sola vez, después de fijar los hiperparámetros.
    dataset_prueba = crear_dataset_prueba(rutas_prueba, parametros["batch_size"])
    predicciones = modelo.predict(dataset_prueba, verbose=0).reshape(-1).tolist()
    mae, rmse = calcular_metricas(pesos_prueba, predicciones)
    guardar_resultados(args.resultados, rutas_prueba, pesos_prueba, predicciones)
    print(f"Modelo: {args.salida}")
    print(f"Prueba ({len(rutas_prueba)} fotos): MAE {mae:.2f} kg; RMSE {rmse:.2f} kg")


if __name__ == "__main__":
    main()
