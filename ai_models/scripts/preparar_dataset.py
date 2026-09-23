"""Copia fotos laterales etiquetadas y crea una partición 80/20 por animal."""

import argparse
import csv
import random
import shutil
from collections import defaultdict
from pathlib import Path


# Las rutas predeterminadas apuntan a los datos fuente del proyecto.
RAIZ = Path(__file__).resolve().parent.parent
ORIGEN = Path.home() / "Documents/dataset_vita_ai"
FOTOS_1 = ORIGEN / "images_1/images"
FOTOS_2 = ORIGEN / "images_2/Cattle side and back view images"
FOTOS_VIDEO = Path.home() / "Downloads/yt_images/yt_images"
EXTENSIONES = {".jpg", ".jpeg", ".png"}
CUADROS_VIDEO = (3, 7)


def leer_pesos(ruta_csv, columna_id, columna_peso):
    """Relaciona cada identificador con su peso y rechaza valores inválidos."""
    pesos = {}
    with ruta_csv.open(newline="", encoding="utf-8-sig") as archivo:
        lector = csv.DictReader(archivo)
        if not lector.fieldnames or columna_id not in lector.fieldnames or columna_peso not in lector.fieldnames:
            raise ValueError(f"Faltan columnas en {ruta_csv}: {columna_id}, {columna_peso}")
        for fila in lector:
            identificador = fila[columna_id].strip()
            if not identificador:
                continue
            peso = float(fila[columna_peso])
            if peso <= 0:
                raise ValueError(f"Peso inválido para {identificador} en {ruta_csv}")
            if identificador in pesos:
                raise ValueError(f"Identificador repetido: {identificador} en {ruta_csv}")
            pesos[identificador] = fila[columna_peso].strip()
    return pesos


def buscar_fotos(raiz_fotos_1, raiz_fotos_2, csv_1, csv_2, raiz_video=None):
    """Busca vistas laterales, incluidas capturas de video, con peso conocido."""
    pesos_1 = leer_pesos(csv_1, "sku", "weight_in_kg")
    pesos_2 = leer_pesos(csv_2, "Num", "Body weight (kg)")
    grupos = defaultdict(list)

    # En el primer conjunto, el nombre de la carpeta identifica al animal.
    if not raiz_fotos_1.is_dir() or not raiz_fotos_2.is_dir():
        raise FileNotFoundError("No se encuentra una de las carpetas de imágenes")
    for carpeta in sorted(raiz_fotos_1.iterdir()):
        if not carpeta.is_dir() or carpeta.name not in pesos_1:
            continue
        for foto in sorted(carpeta.iterdir()):
            # La vista _2 muestra principalmente la parte trasera del animal.
            es_lateral = foto.stem != f"{carpeta.name}_2"
            if foto.is_file() and foto.suffix.lower() in EXTENSIONES and not foto.name.startswith("._") and es_lateral:
                grupos[f"1:{carpeta.name}"].append((foto, foto.name, pesos_1[carpeta.name]))

    # Del segundo conjunto se usan únicamente las imágenes de perfil.
    carpeta_lateral = raiz_fotos_2 / "side view"
    if not carpeta_lateral.is_dir():
        raise FileNotFoundError(f"No se encuentra {carpeta_lateral}")
    for foto in sorted(carpeta_lateral.iterdir()):
        if foto.is_file() and foto.suffix.lower() in EXTENSIONES and foto.stem in pesos_2:
            grupos[f"2:{foto.stem}"].append((foto, f"lateral_{foto.name}", pesos_2[foto.stem]))

    # Dos cuadros tempranos y separados reducen repeticiones y evitan la parte trasera del video.
    if raiz_video is not None:
        if not raiz_video.is_dir():
            raise FileNotFoundError(f"No se encuentra {raiz_video}")
        for carpeta in sorted(raiz_video.iterdir()):
            clave = f"1:{carpeta.name}"
            if not carpeta.is_dir() or clave not in grupos:
                continue
            for numero in CUADROS_VIDEO:
                foto = carpeta / f"{carpeta.name}_{numero}.jpg"
                if foto.is_file():
                    grupos[clave].append((foto, f"video_{foto.name}", pesos_1[carpeta.name]))
    return grupos


def dividir_grupos(grupos, semilla):
    """Separa animales completos, procurando que el 20 % de fotos sea de prueba."""
    claves = sorted(grupos)
    random.Random(semilla).shuffle(claves)
    objetivo_prueba = round(sum(len(grupos[clave]) for clave in claves) * 0.2)
    prueba = set()
    cantidad_prueba = 0
    for clave in claves:
        if cantidad_prueba < objetivo_prueba and len(prueba) < len(claves) - 1:
            prueba.add(clave)
            cantidad_prueba += len(grupos[clave])
    return {clave: grupos[clave] for clave in claves if clave not in prueba}, {clave: grupos[clave] for clave in claves if clave in prueba}


def guardar_particion(grupos, carpeta, ruta_csv):
    """Copia las imágenes y escribe un CSV cuyo nombre apunta a cada copia."""
    carpeta.mkdir(parents=True, exist_ok=True)
    ruta_csv.parent.mkdir(parents=True, exist_ok=True)
    nombres = set()
    filas = []
    for fotos in grupos.values():
        for origen, nombre, peso in fotos:
            if nombre in nombres or (carpeta / nombre).exists():
                raise ValueError(f"Nombre de imagen duplicado en {carpeta}: {nombre}")
            nombres.add(nombre)
            filas.append((origen, nombre, peso))
    for origen, nombre, _ in filas:
        shutil.copy2(origen, carpeta / nombre)
    with ruta_csv.open("w", newline="", encoding="utf-8") as archivo:
        escritor = csv.writer(archivo)
        escritor.writerow(("nombre_foto", "peso_kg"))
        escritor.writerows((nombre, peso) for _, nombre, peso in filas)
    return len(filas)


def main():
    """Lee rutas configurables y genera las carpetas y etiquetas de entrenamiento y prueba."""
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--fotos-1", type=Path, default=FOTOS_1)
    parser.add_argument("--fotos-2", type=Path, default=FOTOS_2)
    parser.add_argument("--fotos-video", type=Path, default=FOTOS_VIDEO)
    parser.add_argument("--csv-1", type=Path, default=RAIZ / "datasets/dataset_1.csv")
    parser.add_argument("--csv-2", type=Path, default=RAIZ / "datasets/measurements.csv")
    parser.add_argument("--salida", type=Path, default=(RAIZ / "../../dataset").resolve())
    parser.add_argument("--semilla", type=int, default=42)
    args = parser.parse_args()

    grupos = buscar_fotos(args.fotos_1, args.fotos_2, args.csv_1, args.csv_2, args.fotos_video)
    if len(grupos) < 2:
        parser.error("Se necesitan al menos dos animales con imágenes y peso")
    entrenamiento, prueba = dividir_grupos(grupos, args.semilla)

    # Evita pisar archivos anteriores al volver a ejecutar el script.
    destinos = (args.salida / "entrenamiento", args.salida / "prueba", args.salida / "entrenamiento.csv", args.salida / "prueba.csv")
    if any(destino.exists() for destino in destinos):
        parser.error(f"La salida ya contiene archivos del dataset: {args.salida}")

    total_entrenamiento = guardar_particion(entrenamiento, destinos[0], destinos[2])
    total_prueba = guardar_particion(prueba, destinos[1], destinos[3])
    print(f"Entrenamiento: {total_entrenamiento} imágenes; prueba: {total_prueba} imágenes. Salida: {args.salida}")


if __name__ == "__main__":
    main()
