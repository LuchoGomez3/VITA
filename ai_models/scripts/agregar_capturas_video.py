"""Agrega capturas laterales al dataset respetando la partición de cada animal."""

import argparse
import csv
import shutil
from pathlib import Path

from .preparar_dataset import CUADROS_VIDEO, FOTOS_VIDEO, RAIZ, leer_pesos


def leer_particiones(raiz_dataset, pesos):
    """Ubica cada animal BLF en su partición actual y valida sus etiquetas."""
    particiones = {}
    nombres_por_particion = {}
    for particion in ("entrenamiento", "prueba"):
        ruta_csv = raiz_dataset / f"{particion}.csv"
        with ruta_csv.open(newline="", encoding="utf-8-sig") as archivo:
            lector = csv.DictReader(archivo)
            if lector.fieldnames != ["nombre_foto", "peso_kg"]:
                raise ValueError(f"Columnas inesperadas en {ruta_csv}")
            filas = list(lector)
        nombres = {fila["nombre_foto"] for fila in filas}
        if len(nombres) != len(filas):
            raise ValueError(f"Hay nombres repetidos en {ruta_csv}")
        nombres_por_particion[particion] = nombres
        for fila in filas:
            identificador, separador, vista = Path(fila["nombre_foto"]).stem.rpartition("_")
            if separador and vista in {"0", "1", "3"} and identificador in pesos:
                if identificador in particiones and particiones[identificador] != particion:
                    raise ValueError(f"El animal {identificador} aparece en ambas particiones")
                if float(fila["peso_kg"]) != float(pesos[identificador]):
                    raise ValueError(f"Peso inconsistente para {identificador}")
                particiones[identificador] = particion
    return particiones, nombres_por_particion


def agregar_capturas(raiz_dataset, raiz_video, csv_pesos):
    """Copia dos cuadros de perfil por animal y añade sus pesos al CSV correcto."""
    pesos = leer_pesos(csv_pesos, "sku", "weight_in_kg")
    particiones, nombres_por_particion = leer_particiones(raiz_dataset, pesos)
    if not raiz_video.is_dir():
        raise FileNotFoundError(f"No se encuentra {raiz_video}")
    pendientes = {"entrenamiento": [], "prueba": []}

    # La división aleatoria ya existe; cada captura sigue al animal para evitar filtración.
    for identificador, particion in sorted(particiones.items()):
        for numero in CUADROS_VIDEO:
            origen = raiz_video / identificador / f"{identificador}_{numero}.jpg"
            if not origen.is_file():
                continue
            nombre = f"video_{origen.name}"
            destino = raiz_dataset / particion / nombre
            if nombre in nombres_por_particion[particion]:
                if not destino.is_file():
                    raise FileNotFoundError(f"El CSV indica una copia faltante: {destino}")
                continue
            if destino.exists():
                raise FileExistsError(f"Existe una copia sin etiqueta: {destino}")
            pendientes[particion].append((origen, destino, nombre, pesos[identificador]))

    for particion, capturas in pendientes.items():
        for origen, destino, _, _ in capturas:
            shutil.copy2(origen, destino)
        with (raiz_dataset / f"{particion}.csv").open("a", newline="", encoding="utf-8") as archivo:
            escritor = csv.writer(archivo)
            escritor.writerows((nombre, peso) for _, _, nombre, peso in capturas)
    return {particion: len(capturas) for particion, capturas in pendientes.items()}


def main():
    """Añade las capturas al entrenamiento y prueba existentes."""
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--dataset", type=Path, default=(RAIZ / "../../dataset").resolve())
    parser.add_argument("--fotos-video", type=Path, default=FOTOS_VIDEO)
    parser.add_argument("--csv-pesos", type=Path, default=RAIZ / "datasets/dataset_1.csv")
    args = parser.parse_args()
    cantidades = agregar_capturas(args.dataset, args.fotos_video, args.csv_pesos)
    for particion, cantidad in cantidades.items():
        print(f"{particion}: {cantidad} capturas laterales agregadas")


if __name__ == "__main__":
    main()
