"""Convierte el último modelo calibrado y empaqueta su intervalo para Flutter.

Ejecutar desde ``mobile`` con el entorno Python de ``../ai_models``:
``../ai_models/.venv/bin/python tool/convert_vision_weight_model.py``.
"""

import hashlib
import json
import shutil
from pathlib import Path

import tensorflow as tf


REPOSITORY_ROOT = Path(__file__).resolve().parents[2]
SOURCE_MODEL = REPOSITORY_ROOT / 'ai_models/models/modelo_pesaje_ajuste_fino.keras'
SOURCE_CALIBRATION = REPOSITORY_ROOT / 'ai_models/models/modelo_pesaje_ajuste_fino.json'
OUTPUT_MODEL = REPOSITORY_ROOT / 'mobile/assets/models/peso_bovino_mobilenet_v2.tflite'
OUTPUT_CALIBRATION = REPOSITORY_ROOT / 'mobile/assets/models/peso_bovino_intervalo.json'


def main() -> None:
    """Verifica la pareja modelo-calibración antes de copiarla a la app."""
    calibration = json.loads(SOURCE_CALIBRATION.read_text(encoding='utf-8'))
    digest = hashlib.sha256(SOURCE_MODEL.read_bytes()).hexdigest()
    if calibration['modelo'] != SOURCE_MODEL.name or calibration['sha256_modelo'] != digest:
        raise ValueError('La calibración no corresponde al modelo entrenado')
    model = tf.keras.models.load_model(SOURCE_MODEL, compile=False)
    converter = tf.lite.TFLiteConverter.from_keras_model(model)
    # La cuantización por defecto desplazó más de 11 kg una foto de control.
    # Mantener float32 conserva la predicción hasta validar una calibración.
    OUTPUT_MODEL.parent.mkdir(parents=True, exist_ok=True)
    OUTPUT_MODEL.write_bytes(converter.convert())
    shutil.copyfile(SOURCE_CALIBRATION, OUTPUT_CALIBRATION)


if __name__ == '__main__':
    main()
