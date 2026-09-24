#!/usr/bin/env python
"""Exporta el dataset de calibración de UN establecimiento a disco local.

    uv run python scripts/exportar_dataset_calibracion.py \
        --establecimiento-id <uuid> --salida ./dataset_calibracion

Produce ``<salida>/imagenes/*.jpg`` y ``<salida>/dataset.csv`` con las columnas
``ruta_local,peso_real_kg,animal_id,split``, que es lo que consume el pipeline de
entrenamiento (lee archivos locales, no claves de Storage).

Por qué es un script y no un endpoint HTTP: el dataset son cientos de MB de
imágenes y el proyecto corre en el plan free de Supabase (5 GB de egress/mes).
Bajarlo por la API lo pagaría dos veces — Storage -> backend -> cliente — y una
sola exportación podría consumir el mes. El script corre del lado del operador,
con la service-role key, y mueve los bytes una sola vez.

``--establecimiento-id`` es obligatorio y no acepta varios valores: es lo que
hace estructuralmente imposible que un CSV mezcle datos de dos tenants.
"""

import argparse
import asyncio
import logging
import sys
from datetime import datetime
from pathlib import Path
from uuid import UUID

# El backend importa como paquete desde la raíz del monorepo.
sys.path.insert(0, str(Path(__file__).resolve().parents[2]))
sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from api.modules.calibraciones_ml.exportacion import exportar_dataset  # noqa: E402
from api.modules.calibraciones_ml.repository import (  # noqa: E402
    MuestraCalibracionRepository,
)
from core.storage import SupabaseStorage  # noqa: E402
from core.config import settings  # noqa: E402
from database.database import AsyncSessionLocal  # noqa: E402

logger = logging.getLogger("exportar_dataset_calibracion")


def _fecha(valor: str) -> datetime:
    try:
        return datetime.fromisoformat(valor)
    except ValueError as exc:
        raise argparse.ArgumentTypeError(
            f"Fecha inválida '{valor}': se espera ISO 8601 (2026-09-21 o "
            "2026-09-21T14:30:00+00:00)"
        ) from exc


def _parsear_argumentos(argv: list[str] | None = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Exporta el dataset de calibración de un establecimiento.",
    )
    parser.add_argument(
        "--establecimiento-id",
        required=True,
        type=UUID,
        help="Establecimiento a exportar. Obligatorio: un CSV nunca mezcla tenants.",
    )
    parser.add_argument(
        "--salida",
        required=True,
        type=Path,
        help="Directorio donde escribir imagenes/ y dataset.csv.",
    )
    parser.add_argument(
        "--desde",
        type=_fecha,
        default=None,
        help="Solo muestras con fecha_captura >= esta fecha (ISO 8601).",
    )
    parser.add_argument(
        "--hasta",
        type=_fecha,
        default=None,
        help="Solo muestras con fecha_captura <= esta fecha (ISO 8601).",
    )
    return parser.parse_args(argv)


async def _ejecutar(args: argparse.Namespace) -> int:
    storage = SupabaseStorage(settings.SUPABASE_STORAGE_BUCKET_CALIBRACIONES)

    async with AsyncSessionLocal() as session:
        muestras = await MuestraCalibracionRepository(session).list_exportables(
            args.establecimiento_id, desde=args.desde, hasta=args.hasta
        )

    if not muestras:
        logger.warning(
            "No hay muestras completas para el establecimiento %s en el rango pedido.",
            args.establecimiento_id,
        )
        return 1

    resumen = await exportar_dataset(muestras, storage, args.salida)

    logger.info("Dataset escrito en %s", resumen.directorio)
    logger.info("  CSV:        %s", resumen.ruta_csv)
    logger.info("  exportadas: %d de %d", resumen.exportadas, len(muestras))
    for split in ("train", "validation", "test"):
        logger.info("    %-11s %d", split, resumen.por_split.get(split, 0))
    if resumen.fallidas:
        # No es un error fatal: el dataset sirve igual. Pero hay que verlo, porque
        # una imagen que no baja suele significar un objeto borrado a mano.
        logger.warning(
            "%d muestra(s) sin imagen descargable: %s",
            len(resumen.fallidas),
            ", ".join(str(i) for i in resumen.fallidas),
        )
    return 0


def main(argv: list[str] | None = None) -> int:
    logging.basicConfig(level=logging.INFO, format="%(message)s")
    args = _parsear_argumentos(argv)
    return asyncio.run(_ejecutar(args))


if __name__ == "__main__":
    raise SystemExit(main())
