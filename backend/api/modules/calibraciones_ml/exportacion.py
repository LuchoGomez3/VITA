"""Armado del dataset local de calibración para el pipeline de entrenamiento.

El pipeline de visión lee archivos del disco, no claves de Storage, así que la
exportación baja las imágenes y emite un CSV que las referencia por ruta
**relativa** al directorio de salida (así el dataset se puede mover o copiar a
otra máquina sin reescribir el CSV).

Vive acá y no en el script para poder testearse: recibe las muestras ya
filtradas y el almacén por parámetro, y no sabe nada de ``argparse`` ni de red.
"""

import csv
import hashlib
import logging
from dataclasses import dataclass, field
from pathlib import Path
from uuid import UUID

from api.modules.calibraciones_ml.models import MuestraCalibracion
from core.storage import ObjectStorage, StorageError

logger = logging.getLogger(__name__)

NOMBRE_CSV = "dataset.csv"
SUBDIRECTORIO_IMAGENES = "imagenes"
COLUMNAS = ("ruta_local", "peso_real_kg", "animal_id", "split")

# Proporciones del corte. El resto hasta 100 es "test".
_CORTE_TRAIN = 70
_CORTE_VALIDATION = 85


def asignar_split(animal_id: UUID) -> str:
    """Asigna train/validation/test de forma determinística **por animal**.

    La clave es que el corte dependa del animal y no de la muestra: si dos fotos
    del mismo bovino cayeran en conjuntos distintos, el modelo vería en
    validación un animal que ya memorizó en entrenamiento y la métrica saldría
    optimista (fuga de datos).

    Se usa SHA-256 y no ``hash()`` porque el hash de strings de Python está
    aleatorizado por proceso (``PYTHONHASHSEED``): el mismo animal cambiaría de
    conjunto entre corridas y dos entrenamientos dejarían de ser comparables.
    """
    digest = hashlib.sha256(str(animal_id).encode()).digest()
    cubeta = int.from_bytes(digest[:8], "big") % 100
    if cubeta < _CORTE_TRAIN:
        return "train"
    if cubeta < _CORTE_VALIDATION:
        return "validation"
    return "test"


@dataclass
class ResumenExportacion:
    """Qué produjo la exportación, para reportarlo por consola y testearlo."""

    directorio: Path
    ruta_csv: Path
    exportadas: int = 0
    # Muestras cuyo objeto no se pudo bajar. No abortan la corrida: una imagen
    # perdida no debería impedir entrenar con las otras 2999.
    fallidas: list[UUID] = field(default_factory=list)
    por_split: dict[str, int] = field(default_factory=dict)


async def exportar_dataset(
    muestras: list[MuestraCalibracion],
    storage: ObjectStorage,
    directorio: Path,
) -> ResumenExportacion:
    """Baja las imágenes de ``muestras`` a ``directorio`` y escribe el CSV.

    Quien llama es responsable de que ``muestras`` pertenezca a **un solo**
    establecimiento (lo garantiza ``list_exportables``, que exige el
    ``establecimiento_id``). Acá no se mezcla nada porque no se consulta nada.
    """
    directorio_imagenes = directorio / SUBDIRECTORIO_IMAGENES
    directorio_imagenes.mkdir(parents=True, exist_ok=True)

    resumen = ResumenExportacion(
        directorio=directorio, ruta_csv=directorio / NOMBRE_CSV
    )
    filas: list[dict[str, object]] = []

    for muestra in muestras:
        if muestra.imagen_key is None:
            # Defensa: ``list_exportables`` ya las excluye.
            continue
        try:
            datos = await storage.descargar(muestra.imagen_key)
        except StorageError:
            logger.warning(
                "[EXPORT] No se pudo descargar la imagen de la muestra %s; se omite",
                muestra.id,
            )
            resumen.fallidas.append(muestra.id)
            continue

        nombre = f"{muestra.id}.jpg"
        (directorio_imagenes / nombre).write_bytes(datos)

        split = asignar_split(muestra.animal_id)
        filas.append(
            {
                # Relativa a propósito: el CSV sigue siendo válido si se copia el
                # directorio a la máquina que entrena.
                "ruta_local": f"{SUBDIRECTORIO_IMAGENES}/{nombre}",
                "peso_real_kg": f"{muestra.peso_real_kg:.3f}",
                "animal_id": str(muestra.animal_id),
                "split": split,
            }
        )
        resumen.por_split[split] = resumen.por_split.get(split, 0) + 1
        resumen.exportadas += 1

    with resumen.ruta_csv.open("w", newline="", encoding="utf-8") as archivo:
        writer = csv.DictWriter(archivo, fieldnames=COLUMNAS)
        writer.writeheader()
        writer.writerows(filas)

    return resumen
