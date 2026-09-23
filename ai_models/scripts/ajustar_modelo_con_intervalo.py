"""Ajusta las últimas capas visuales y compara su intervalo con el modelo base."""

import argparse
import hashlib
import json
from pathlib import Path

import tensorflow as tf

from .entrenar_modelo_con_intervalo import guardar_predicciones
from .entrenar_modelo_dataset import RAIZ, crear_dataset, leer_entrenamiento
from .evaluar_modelo_dataset import calcular_metricas, crear_dataset_prueba
from .intervalo_peso import aplicar_intervalo, calcular_margen_por_animal
from .optimizar_hiperparametros import dividir_validacion, identificador_animal


def configurar_ajuste_fino(modelo, ultimas_capas, tasa_aprendizaje):
    """Descongela solo el final de MobileNetV2 y mantiene fijas sus BatchNorm.

    Las capas BatchNorm conservan sus estadísticas originales. Si se actualizaran
    con pocos animales, podrían cambiar bruscamente las predicciones.
    """
    if ultimas_capas < 1 or tasa_aprendizaje <= 0:
        raise ValueError("Cantidad de capas o tasa de aprendizaje inválida")
    indice_cabeza = next(
        (indice for indice, capa in enumerate(modelo.layers) if isinstance(capa, tf.keras.layers.GlobalAveragePooling2D)),
        None,
    )
    if indice_cabeza is None:
        raise ValueError("El modelo no tiene la cabeza de regresión esperada")
    capas_base = modelo.layers[:indice_cabeza]
    inicio_ajuste = max(0, len(capas_base) - ultimas_capas)
    for indice, capa in enumerate(capas_base):
        capa.trainable = indice >= inicio_ajuste and not isinstance(
            capa, tf.keras.layers.BatchNormalization
        )
    for capa in modelo.layers[indice_cabeza:]:
        capa.trainable = True
    modelo.compile(
        optimizer=tf.keras.optimizers.Adam(learning_rate=tasa_aprendizaje),
        loss="mse",
        metrics=["mae"],
    )
    return sum(capa.trainable for capa in capas_base)


def resumir_cobertura(rutas, reales, estimados, margen):
    """Mide por foto y exige que todas las fotos de cada animal queden cubiertas."""
    fotos_cubiertas = 0
    animales_cubiertos = {}
    for ruta, real, estimado in zip(rutas, reales, estimados, strict=True):
        inferior, superior = aplicar_intervalo(estimado, margen)
        cubierta = inferior <= real <= superior
        fotos_cubiertas += cubierta
        animal = identificador_animal(ruta)
        animales_cubiertos[animal] = animales_cubiertos.get(animal, True) and cubierta
    return fotos_cubiertas / len(rutas), sum(animales_cubiertos.values()), len(animales_cubiertos)


def main():
    """Continúa un modelo existente sin usar calibración durante el ajuste."""
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--dataset", type=Path, default=(RAIZ / "../../dataset").resolve())
    parser.add_argument("--modelo-base", type=Path, default=RAIZ / "models/modelo_pesaje_con_intervalo.keras")
    parser.add_argument("--calibracion-base", type=Path, default=RAIZ / "models/modelo_pesaje_con_intervalo.json")
    parser.add_argument("--modelo", type=Path, default=RAIZ / "models/modelo_pesaje_ajuste_fino.keras")
    parser.add_argument("--calibracion", type=Path, default=RAIZ / "models/modelo_pesaje_ajuste_fino.json")
    parser.add_argument("--resultados", type=Path, default=RAIZ / "results/modelo_ajuste_fino_prueba.csv")
    parser.add_argument("--epocas", type=int, default=4)
    parser.add_argument("--ultimas-capas", type=int, default=30)
    parser.add_argument("--tasa-aprendizaje", type=float, default=0.00001)
    args = parser.parse_args()
    dataset = args.dataset
    modelo_base = args.modelo_base
    ruta_calibracion_base = args.calibracion_base
    ruta_modelo = args.modelo
    ruta_calibracion = args.calibracion
    ruta_resultados = args.resultados
    if args.epocas < 1:
        parser.error("Las épocas deben ser positivas")
    configuracion_base = json.loads(ruta_calibracion_base.read_text(encoding="utf-8"))
    if hashlib.sha256(modelo_base.read_bytes()).hexdigest() != configuracion_base["sha256_modelo"]:
        parser.error("El modelo base no coincide con su calibración")

    rutas, pesos = leer_entrenamiento(dataset / "entrenamiento.csv", dataset / "entrenamiento")
    rutas_prueba, pesos_prueba = leer_entrenamiento(dataset / "prueba.csv", dataset / "prueba")
    if {identificador_animal(ruta) for ruta in rutas} & {identificador_animal(ruta) for ruta in rutas_prueba}:
        parser.error("Hay animales compartidos entre entrenamiento y prueba")
    entrenamiento, calibracion = dividir_validacion(
        rutas, pesos, 0.2, configuracion_base["semilla"]
    )
    rutas_entrenamiento, pesos_entrenamiento = zip(*entrenamiento, strict=True)
    rutas_calibracion, pesos_calibracion = zip(*calibracion, strict=True)

    tf.keras.utils.set_random_seed(configuracion_base["semilla"])
    modelo = tf.keras.models.load_model(modelo_base)
    capas_ajustables = configurar_ajuste_fino(
        modelo, args.ultimas_capas, args.tasa_aprendizaje
    )
    print(f"Ajustando {capas_ajustables} capas visuales con {len(entrenamiento)} fotos")
    datos_entrenamiento = crear_dataset(
        list(rutas_entrenamiento), list(pesos_entrenamiento), 16
    )
    modelo.fit(datos_entrenamiento, epochs=args.epocas, shuffle=False, verbose=2)

    # Se calcula un margen nuevo porque ajustar la red cambia todos sus errores.
    estimados_calibracion = modelo.predict(
        crear_dataset_prueba(list(rutas_calibracion), 16), verbose=0
    ).reshape(-1).tolist()
    margen, animales_calibracion = calcular_margen_por_animal(
        rutas_calibracion,
        pesos_calibracion,
        estimados_calibracion,
        identificador_animal,
        configuracion_base["cobertura_objetivo"],
    )
    ruta_modelo.parent.mkdir(parents=True, exist_ok=True)
    ruta_calibracion.parent.mkdir(parents=True, exist_ok=True)
    modelo.save(ruta_modelo)
    ruta_calibracion.write_text(
        json.dumps(
            {
                "modelo": ruta_modelo.name,
                "sha256_modelo": hashlib.sha256(ruta_modelo.read_bytes()).hexdigest(),
                "cobertura_objetivo": configuracion_base["cobertura_objetivo"],
                "margen_kg": margen,
                "animales_calibracion": animales_calibracion,
                "fotos_calibracion": len(calibracion),
                "semilla": configuracion_base["semilla"],
                "metodo": "cuantil_del_error_maximo_por_animal",
                "modelo_base": modelo_base.name,
                "capas_visuales_ajustables": capas_ajustables,
                "epocas_ajuste": args.epocas,
                "tasa_aprendizaje": args.tasa_aprendizaje,
            },
            indent=2,
        ),
        encoding="utf-8",
    )

    estimados_prueba = modelo.predict(
        crear_dataset_prueba(rutas_prueba, 16), verbose=0
    ).reshape(-1).tolist()
    mae, rmse = calcular_metricas(pesos_prueba, estimados_prueba)
    cobertura_fotos, animales_cubiertos, animales_prueba = resumir_cobertura(
        rutas_prueba, pesos_prueba, estimados_prueba, margen
    )
    guardar_predicciones(
        ruta_resultados, rutas_prueba, pesos_prueba, estimados_prueba, margen
    )
    print(f"Modelo: {ruta_modelo}; calibración: {ruta_calibracion}")
    print(f"Margen: ±{margen:.2f} kg")
    print(f"Prueba: MAE {mae:.2f} kg; RMSE {rmse:.2f} kg; cobertura por foto {cobertura_fotos:.1%}")
    print(f"Animales cubiertos en todas sus fotos: {animales_cubiertos}/{animales_prueba}")


if __name__ == "__main__":
    main()
