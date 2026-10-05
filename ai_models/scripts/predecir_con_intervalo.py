"""Predice el peso de una foto y muestra su intervalo calibrado."""

import argparse
import hashlib
import json
from pathlib import Path

import tensorflow as tf

from .entrenar_modelo_dataset import RAIZ
from .evaluar_modelo_dataset import crear_dataset_prueba
from .intervalo_peso import aplicar_intervalo


def main():
    """Carga la red y su margen asociado; ambos archivos deben ir juntos."""
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("imagen", type=Path)
    parser.add_argument("--modelo", type=Path, default=RAIZ / "models/modelo_pesaje_con_intervalo.keras")
    parser.add_argument("--calibracion", type=Path, default=RAIZ / "models/modelo_pesaje_con_intervalo.json")
    args = parser.parse_args()
    if not args.imagen.is_file():
        parser.error(f"No existe la imagen: {args.imagen}")
    datos = json.loads(args.calibracion.read_text(encoding="utf-8"))
    if datos["modelo"] != args.modelo.name or datos["sha256_modelo"] != hashlib.sha256(args.modelo.read_bytes()).hexdigest():
        parser.error("La calibración no corresponde al modelo indicado")

    modelo = tf.keras.models.load_model(args.modelo)
    foto = crear_dataset_prueba([str(args.imagen)], 1)
    estimado = float(modelo.predict(foto, verbose=0).reshape(-1)[0])
    inferior, superior = aplicar_intervalo(estimado, datos["margen_kg"])
    print(f"Peso estimado: {estimado:.1f} kg")
    print(f"Intervalo objetivo {datos['cobertura_objetivo']:.0%}: {inferior:.1f}–{superior:.1f} kg")
    print("El intervalo supone fotos laterales similares a las de calibración; no es una probabilidad individual.")


if __name__ == "__main__":
    main()
