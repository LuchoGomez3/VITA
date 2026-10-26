# Paquete inicial de pesaje por visión

Versión de referencia: `initial-2026-09`, recuperada de `c7777a1`.
Los blobs coinciden también con `origin/jornada-poster` al recuperarlos.
Se incluye por autorización explícita del usuario el 2026-10-26 para usarlo
como punto de partida y reemplazarlo cuando exista uno mejor.

| Archivo | Bytes | SHA-256 |
| --- | ---: | --- |
| `peso_bovino_mobilenet_v2.tflite` | 19373780 | `7fc1df63216832f39731e9ba15fd91fb7a7127a5221855c3d70b71d67b876b71` |
| `peso_bovino_intervalo.json` | 466 | `357c3f49acd7fe18c0378c19d96d893fb3cd433a3b1d3ba43432411353ba3b89` |

El `sha256_modelo` dentro del JSON corresponde al archivo Keras de origen,
no al binario TFLite distribuido. La tabla anterior identifica el par exacto
incluido en la app. No se distribuyen archivos Keras, datasets ni checkpoints.

Contrato comprobado: una entrada float32 `[1,224,224,3]` RGB en `[-1,1]` y una
salida float32 `[1,1]` en kg. El JSON declara margen 85,26577758789062 kg y
cobertura objetivo 0,9. Esa cobertura no es confianza individual por foto ni
garantía de precisión en un establecimiento nuevo.

Reemplazar siempre modelo y margen como un par; cambiar este README y validar
el contrato y el paquete. Las instrucciones de reemplazo/retiro están en el
[README de la feature](../../lib/features/vision_weighing/README.md).
