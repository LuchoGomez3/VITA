"""Calcula y aplica un intervalo empírico para predicciones de peso."""

import math


def calcular_margen_por_animal(rutas, pesos_reales, pesos_estimados, identificador, cobertura=0.9):
    """Calcula el cuantil conformal del peor error de cada animal.

    Cada animal aporta un único error máximo para que varias fotos o cuadros de
    video del mismo bovino no cuenten como observaciones independientes.
    """
    if not 0 < cobertura < 1:
        raise ValueError("La cobertura debe estar entre cero y uno")
    if not rutas or len(rutas) != len(pesos_reales) or len(rutas) != len(pesos_estimados):
        raise ValueError("Las listas de calibración deben tener igual longitud y no estar vacías")

    errores_por_animal = {}
    for ruta, real, estimado in zip(rutas, pesos_reales, pesos_estimados, strict=True):
        if not math.isfinite(real) or not math.isfinite(estimado):
            raise ValueError("Los pesos de calibración deben ser finitos")
        animal = identificador(ruta)
        errores_por_animal[animal] = max(
            errores_por_animal.get(animal, 0.0), abs(real - estimado)
        )

    errores_ordenados = sorted(errores_por_animal.values())
    posicion = math.ceil((len(errores_ordenados) + 1) * cobertura)
    if posicion > len(errores_ordenados):
        raise ValueError("Se necesitan más animales para la cobertura solicitada")
    return errores_ordenados[posicion - 1], len(errores_ordenados)


def aplicar_intervalo(peso_estimado, margen):
    """Devuelve límites en kg y evita un límite inferior físicamente negativo."""
    if not math.isfinite(peso_estimado) or not math.isfinite(margen) or margen < 0:
        raise ValueError("Peso estimado o margen inválido")
    return max(0.0, peso_estimado - margen), peso_estimado + margen
