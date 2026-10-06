# Estimación de peso bovino

Este proyecto prepara fotos laterales con peso conocido, entrena MobileNetV2 y evalúa el error sobre animales reservados para prueba. Ejecutá los comandos desde `ai_models/` con el entorno `.venv` activo o usando `.venv/bin/python`.

## Dónde está cada cosa

| Carpeta | Contenido |
| --- | --- |
| `scripts/` | Preparación del dataset, incorporación de capturas, entrenamiento, evaluación y arquitectura del modelo. |
| `tests/` | Pruebas automatizadas de los scripts actuales. |
| `datasets/` | CSV originales con los pesos de ambas fuentes. |
| `models/` | Modelos Keras actuales; `historicos/` guarda los modelos de pruebas anteriores. |
| `results/` | Predicciones y errores por foto para comparar modelos. |
| `logs/` | Eventos de TensorBoard; `hparam_tuning/` conserva las pruebas de hiperparámetros. |
| `experiments/` | Código histórico de ajuste de hiperparámetros. |

Las fotos originales están en `/home/ernesto/Documents/dataset_vita_ai` y `/home/ernesto/Downloads/yt_images/yt_images`. El dataset generado está en `../../dataset`, con `entrenamiento/`, `prueba/` y un CSV de pesos para cada carpeta. Las fotos del mismo animal permanecen en una sola partición. Se usan vistas laterales o ligeramente giradas; se excluyen las tomas traseras. De cada video se eligen los cuadros 3 y 7 para evitar copias casi iguales y vistas posteriores.

## Flujo actual

```bash
# Crear el dataset por primera vez (la salida debe estar vacía).
.venv/bin/python -m scripts.preparar_dataset

# Incorporar capturas a un dataset ya creado, sin cambiar su división.
.venv/bin/python -m scripts.agregar_capturas_video

# Entrenar el modelo actual con todas las fotos de entrenamiento.
.venv/bin/python -m scripts.entrenar_modelo_dataset

# Buscar hiperparámetros por MAE de validación y entrenar un modelo final.
.venv/bin/python -m scripts.optimizar_hiperparametros

# Entrenar otra versión con animales reservados para calibrar un intervalo.
.venv/bin/python -m scripts.entrenar_modelo_con_intervalo

# Ajustar las últimas capas visuales de esa versión y recalibrar el intervalo.
.venv/bin/python -m scripts.ajustar_modelo_con_intervalo

# Consultar peso e intervalo para una foto lateral.
.venv/bin/python -m scripts.predecir_con_intervalo /ruta/a/foto.jpg

# Evaluar sobre las fotos de prueba y escribir el CSV de resultados.
.venv/bin/python -m scripts.evaluar_modelo_dataset

# Ver métricas de entrenamiento.
.venv/bin/tensorboard --logdir logs/modelo_pesaje_lateral_video

# Ejecutar las pruebas automatizadas.
.venv/bin/python -m unittest discover -s tests
```

`scripts.preparar_dataset` no reemplaza una salida existente. Para rutas alternativas, consultá `--help` de cada módulo.

## Modelos y resultados

- `models/modelo_pesaje_lateral.keras`: entrenado antes de agregar capturas de video. MAE de 30,68 kg en las 326 fotos fijas de prueba.
- `models/modelo_pesaje_lateral_video.keras`: entrenado con las capturas incorporadas. MAE de 35,97 kg en las 538 fotos de la prueba ampliada. En las fotos fijas su MAE fue 36,30 kg y en las capturas, 35,48 kg.
- Los modelos en `models/historicos/` pertenecen a experimentos anteriores y se conservan como referencia.
- `results/modelo_lateral_prueba_ampliada.csv` contiene las predicciones del modelo anterior sobre las 538 fotos; `results/modelo_lateral_video_prueba_ampliada.csv`, las del modelo con capturas sobre esas mismas fotos. `results/modelo_lateral_fotos_fijas.csv` conserva la evaluación original sobre 326 fotos fijas.

El MAE es el error absoluto promedio entre el peso estimado y el peso real. Los CSV de `results/` permiten revisar cada caso individual.

## Búsqueda automática de hiperparámetros

`scripts.optimizar_hiperparametros` usa KerasTuner Hyperband para probar `dropout`, neuronas, tasa de aprendizaje y tamaño de lote. Separa el 20 % de las fotos de entrenamiento para validación **por animal**: las fotos fijas y capturas del mismo bovino permanecen juntas. La búsqueda minimiza `val_mae`, sin usar `prueba.csv` para elegir parámetros. Al terminar, entrena desde cero con todo `entrenamiento.csv`, guarda `models/modelo_pesaje_auto_ml.keras` y evalúa una vez sobre `prueba.csv`.

El directorio `logs/auto_ml/` guarda los ensayos y los manifiestos de la división interna; `mejores_parametros.json` registra la combinación elegida. Si una búsqueda se interrumpe, el mismo comando puede reanudarla. Las fotos de prueba ya se utilizaron en comparaciones anteriores, por lo que su resultado no equivale a una evaluación final con animales completamente nuevos.

## Intervalo de peso

`scripts.entrenar_modelo_con_intervalo` crea una red nueva con los hiperparámetros elegidos por AutoML. Separa animales completos del entrenamiento para calibración; esos animales no ajustan los pesos de la nueva red. El margen se obtiene del error máximo de cada animal reservado, para que muchas capturas del mismo bovino no cuenten como observaciones independientes. Guarda la red en `models/modelo_pesaje_con_intervalo.keras`, su margen y huella en `models/modelo_pesaje_con_intervalo.json`, y las predicciones de prueba en `results/modelo_con_intervalo_prueba.csv`.

`scripts.predecir_con_intervalo` muestra el peso estimado y un intervalo objetivo del 90 %. El margen es común a todas las fotos; no representa una probabilidad de acierto individual ni detecta por sí solo fotos traseras o de mala calidad. Como las imágenes disponibles ya influyeron en decisiones anteriores sobre el modelo, la cobertura deberá confirmarse con animales nuevos antes de usarla como garantía operativa.

### Ajuste fino y comparación

`scripts.ajustar_modelo_con_intervalo` parte del modelo calibrado anterior, ajusta las últimas capas visuales con tasa de aprendizaje baja y mantiene fijas las capas BatchNorm. Usa los mismos animales de entrenamiento y calibración, guarda un modelo separado en `models/modelo_pesaje_ajuste_fino.keras` y recalcula su margen en `models/modelo_pesaje_ajuste_fino.json`. Sus predicciones de prueba quedan en `results/modelo_ajuste_fino_prueba.csv`.

| Modelo | MAE en 538 fotos de prueba | Margen objetivo 90 % | Animales cubiertos en todas sus fotos |
| --- | ---: | ---: | ---: |
| Base con intervalo | 36,85 kg | ±111,05 kg | 105/114 |
| Ajuste fino | 29,96 kg | ±85,27 kg | 103/114 |

Para probar una foto con el ajuste fino: `.venv/bin/python -m scripts.predecir_con_intervalo /ruta/a/foto.jpg --modelo models/modelo_pesaje_ajuste_fino.keras --calibracion models/modelo_pesaje_ajuste_fino.json`. Esta comparación reutiliza animales vistos durante decisiones anteriores del proyecto; la cobertura necesita validación con animales nuevos. Las fotos alrededor de 800 kg en prueba están fuera del rango de peso observado en entrenamiento y presentan errores muy grandes. No se corrigieron etiquetas ni se incorporaron fotos sin comprobar primero sus pesos reales.
