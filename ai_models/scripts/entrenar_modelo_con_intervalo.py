"""Entrena con animales separados y calibra un intervalo de peso."""

import argparse
import csv
import hashlib
import json
from pathlib import Path

import tensorflow as tf

from .entrenar_modelo_dataset import RAIZ, crear_dataset, leer_entrenamiento
from .evaluar_modelo_dataset import calcular_metricas, crear_dataset_prueba
from .intervalo_peso import aplicar_intervalo, calcular_margen_por_animal
from .model_builder import build_weight_estimation_model
from .optimizar_hiperparametros import dividir_validacion, identificador_animal


def guardar_predicciones(ruta_csv, rutas, reales, estimados, margen):
    """Escribe el peso y los dos límites para revisar cada foto de prueba."""
    ruta_csv.parent.mkdir(parents=True, exist_ok=True)
    with ruta_csv.open("w", newline="", encoding="utf-8") as archivo:
        escritor = csv.writer(archivo)
        escritor.writerow(("nombre_foto", "peso_real_kg", "peso_estimado_kg", "limite_inferior_kg", "limite_superior_kg", "dentro_intervalo"))
        for ruta, real, estimado in zip(rutas, reales, estimados, strict=True):
            inferior, superior = aplicar_intervalo(estimado, margen)
            escritor.writerow((Path(ruta).name, f"{real:.2f}", f"{estimado:.2f}", f"{inferior:.2f}", f"{superior:.2f}", inferior <= real <= superior))


def main():
    """Ajusta una nueva red, calibra el margen y mide su prueba por animal."""
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--dataset", type=Path, default=(RAIZ / "../../dataset").resolve())
    parser.add_argument("--parametros", type=Path, default=RAIZ / "logs/auto_ml/mejores_parametros.json")
    parser.add_argument("--modelo", type=Path, default=RAIZ / "models/modelo_pesaje_con_intervalo.keras")
    parser.add_argument("--calibracion", type=Path, default=RAIZ / "models/modelo_pesaje_con_intervalo.json")
    parser.add_argument("--resultados", type=Path, default=RAIZ / "results/modelo_con_intervalo_prueba.csv")
    parser.add_argument("--epocas", type=int, default=10)
    parser.add_argument("--cobertura", type=float, default=0.9)
    parser.add_argument("--semilla", type=int, default=137)
    args = parser.parse_args()
    if args.epocas < 1 or not 0 < args.cobertura < 1:
        parser.error("Las épocas y la cobertura deben ser válidas")

    rutas, pesos = leer_entrenamiento(args.dataset / "entrenamiento.csv", args.dataset / "entrenamiento")
    rutas_prueba, pesos_prueba = leer_entrenamiento(args.dataset / "prueba.csv", args.dataset / "prueba")
    if {identificador_animal(ruta) for ruta in rutas} & {identificador_animal(ruta) for ruta in rutas_prueba}:
        parser.error("Hay animales compartidos entre entrenamiento y prueba")
    entrenamiento, calibracion = dividir_validacion(rutas, pesos, 0.2, args.semilla)
    rutas_entrenamiento, pesos_entrenamiento = zip(*entrenamiento, strict=True)
    rutas_calibracion, pesos_calibracion = zip(*calibracion, strict=True)
    parametros = json.loads(args.parametros.read_text(encoding="utf-8"))["parametros"]

    # La red nueva nunca recibe las fotos usadas después para medir su error.
    tf.keras.utils.set_random_seed(args.semilla)
    modelo = build_weight_estimation_model(
        dropout_rate=parametros["dropout"],
        neurons=parametros["neurons"],
        learning_rate=parametros["learning_rate"],
    )
    datos_entrenamiento = crear_dataset(
        list(rutas_entrenamiento), list(pesos_entrenamiento), parametros["batch_size"]
    )
    print(f"Entrenamiento: {len(entrenamiento)} fotos; calibración: {len(calibracion)} fotos")
    modelo.fit(datos_entrenamiento, epochs=args.epocas, shuffle=False, verbose=2)

    # Las predicciones de calibración no usan aumentos aleatorios de imagen.
    datos_calibracion = crear_dataset_prueba(list(rutas_calibracion), parametros["batch_size"])
    estimados_calibracion = modelo.predict(datos_calibracion, verbose=0).reshape(-1).tolist()
    margen, cantidad_animales = calcular_margen_por_animal(
        rutas_calibracion,
        pesos_calibracion,
        estimados_calibracion,
        identificador_animal,
        args.cobertura,
    )
    args.modelo.parent.mkdir(parents=True, exist_ok=True)
    args.calibracion.parent.mkdir(parents=True, exist_ok=True)
    modelo.save(args.modelo)
    huella_modelo = hashlib.sha256(args.modelo.read_bytes()).hexdigest()
    args.calibracion.write_text(
        json.dumps(
            {
                "modelo": args.modelo.name,
                "sha256_modelo": huella_modelo,
                "cobertura_objetivo": args.cobertura,
                "margen_kg": margen,
                "animales_calibracion": cantidad_animales,
                "fotos_calibracion": len(calibracion),
                "semilla": args.semilla,
                "metodo": "cuantil_del_error_maximo_por_animal",
            },
            indent=2,
        ),
        encoding="utf-8",
    )

    # La prueba describe el rendimiento observado; sus fotos no ajustan el margen.
    estimados_prueba = modelo.predict(
        crear_dataset_prueba(rutas_prueba, parametros["batch_size"]), verbose=0
    ).reshape(-1).tolist()
    mae, rmse = calcular_metricas(pesos_prueba, estimados_prueba)
    cubiertos = 0
    animales_cubiertos = {}
    for ruta, real, estimado in zip(rutas_prueba, pesos_prueba, estimados_prueba, strict=True):
        inferior, superior = aplicar_intervalo(estimado, margen)
        esta_cubierto = inferior <= real <= superior
        cubiertos += esta_cubierto
        animal = identificador_animal(ruta)
        animales_cubiertos[animal] = animales_cubiertos.get(animal, True) and esta_cubierto
    guardar_predicciones(args.resultados, rutas_prueba, pesos_prueba, estimados_prueba, margen)
    print(f"Modelo: {args.modelo}; calibración: {args.calibracion}")
    print(f"Margen: ±{margen:.2f} kg ({cantidad_animales} animales de calibración)")
    print(f"Prueba: MAE {mae:.2f} kg; RMSE {rmse:.2f} kg; cobertura por foto {cubiertos / len(rutas_prueba):.1%}")
    print(f"Animales de prueba cubiertos en todas sus fotos: {sum(animales_cubiertos.values())}/{len(animales_cubiertos)}")


if __name__ == "__main__":
    main()
