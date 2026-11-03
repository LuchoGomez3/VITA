# ADR-0014: paquete inicial de pesaje reemplazable

- Fecha: 2026-10-26
- Estado: propuesto para revisión humana
- Historia: VITA-141
- Complementa ADR-0013; reemplaza únicamente su decisión de excluir el paquete inicial.

## Contexto

La primera recuperación excluyó los assets experimentales por el alcance
original. El usuario aclaró que se debe usar el modelo probado en jornada-poster
y reemplazarlo cuando haya uno mejor. La autorización se limita al TFLite y su
JSON de margen; entrenamiento, checkpoints, datasets y demos siguen excluidos.

## Decisión

Distribuir el par exacto de `c7777a1`, también presente en jornada-poster, con
procedencia y hashes documentados en `mobile/assets/models/README.md`.
Declarar solo esos dos assets en pubspec. Mantener la inferencia detrás de
`VisionWeightEstimatorRepository`; hacer configurables las rutas del modelo y
del margen en el constructor del adaptador de Data.

Un modelo con el mismo contrato reemplaza los dos archivos sin cambiar cámara,
revisión, Cubit, dominio o persistencia. Un contrato distinto requiere adaptar
el preprocesamiento y los tensores de Data. Retirar el paquete conserva el
manejo de modelo ausente establecido por ADR-0013.

## Consecuencias

La app vuelve a incluir un modelo real para inferencia offline y aumenta su
paquete en aproximadamente 19 MB antes de compresión. El reemplazo requiere
compilar/distribuir una nueva versión; no se introduce descarga remota.
El margen de ±85,27 kg permanece experimental. Faltan validación independiente
de precisión y medición de latencia en los dispositivos objetivo.
