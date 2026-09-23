# Pesaje por visión artificial — FRONT-01 y FRONT-02

Feature independiente en `lib/features/vision_weighing`, accesible desde el botón central «Pesaje IA» de la navbar
mediante `/pesar-por-vision`. Se aplicaron `VITA/AGENTS.md` y `mobile/AGENTS.md`.

## Flujo implementado

1. Abrir la cámara trasera y conceder permiso. No se solicita audio.
2. El visor ocupa toda la pantalla, con grilla de tercios y botón verde de
   captura abajo. «Captura sin conexión» aparece arriba y el modo calibración
   se activa desde el menú de ajustes. El visor usa `BoxFit.cover` sin deformar;
   la foto conserva el sensor completo, incluidos los márgenes fuera del visor.
   El indicador guía al operario para colocar el celular en horizontal. La toma
   se bloquea en vertical; tocar el disparador destaca el aviso en rojo con
   borde blanco y texto en negrita durante 600 ms, y luego recupera su aspecto
   normal. Girar el teléfono interrumpe el parpadeo y muestra el tick verde.
3. Capturar. `ProcessVisionCapture` coordina preparación, rechazo e inferencia;
   el repositorio local usa `compute` fuera del hilo de UI en Android/iOS.
   Para pruebas, «Configuración → Adjuntar foto» permite elegir una imagen de
   la galería y ejecutar el mismo análisis y revisión, también en modo calibración.
   La imagen adjunta conserva su orientación EXIF sin rotación por el teléfono.
4. Corregir orientación EXIF, analizar una copia de 320 píxeles de ancho y
   rechazar sólo archivos inválidos o resolución insuficiente. Exposición y
   desenfoque se presentan como advertencias para revisión manual. Las dimensiones
   del JPEG no determinan el perfil del animal ni generan advertencias de orientación.
5. Ante un rechazo técnico se muestra una alerta y se requiere una nueva captura.
6. Revisar el JPEG normalizado (máximo 1600 píxeles de ancho). La vista previa
   permanece fija dentro del formulario; al tocarla abre un visor completo que
   permite ampliar hasta 4× y recorrer la imagen dentro de sus bordes. La primera tarjeta exige confirmar nitidez, animal
   completo y que exista un solo bovino de perfil. Al confirmar se reemplaza
   por la tarjeta de selección del animal en la misma página.
7. En Modo Calibración, ingresar peso positivo con hasta dos decimales. Se
   aceptan coma y punto, sin separadores de miles. Foto y kilos quedan asociados
   **en memoria durante esta sesión**, y se descartan al salir o reintentar.
8. FRONT-02 precarga un MobileNetV2 convertido a TFLite al abrir la cámara.
   Después del control técnico, ajusta la imagen a RGB 224×224, normaliza cada
   canal a [-1, 1] y ejecuta la inferencia local en otro isolate. Muestra el
   peso estimado en verde. Mide el tiempo desde el disparador hasta la
   predicción (en galería, desde que empieza el procesamiento) y sólo muestra
   un aviso si supera los 3 segundos. Durante el análisis se muestra el mismo
   indicador circular compartido que usa la generación del reporte SENASA. Al
   terminar, aparece la revisión con la foto. El primer frame de UI no está
   incluido en el tiempo medido.
9. Tras confirmar la captura se puede seleccionar un animal local reciente (ordenado por
   actualización, no por lectura RFID) o elegir un establecimiento y abrir la
   pantalla existente de identificación con bastón. Al encontrarlo, «Usar este
   animal» vuelve a la misma captura y muestra su caravana RFID y visual. La
   selección se conserva sólo durante esa captura. El lector sigue ofreciendo
   el alta si la caravana todavía no está registrada.
10. Después de elegir el animal, «Guardar pesaje IA» registra el peso
    en SQLite con la fecha y hora actuales, el UUID de ese animal, el método
    `estimacion_ia` y `es_estimado=true`. Brick deja el registro pendiente de
    sincronización. La ficha del animal muestra la fecha y «Estimación por IA»
    en su historial de pesajes. Usar el UUID evita ambigüedad si una misma
    caravana aparece en varios establecimientos.

`VisionCaptureCubit` usa `ResultState<VisionCaptureViewData>` y sólo consume
casos de uso. `VisionCapture` conserva el resultado técnico; revisión, tiempo y
estado de guardado pertenecen al modelo de Presentation. `camera`,
`sensors_plus`, `image_picker`, TFLite y Brick quedan encapsulados en `data` y
se conectan mediante contratos de Domain. La cámara se libera al abandonar la
vista o pasar la app a segundo plano y se vuelve a abrir al regresar.

La presentación utiliza `AppSpacing`, `AppRadius`, `AppBorders`, `AppTypography`
y `AppElevation`. La revisión reutiliza `AppSurfaceCard` con sombra visible,
`AppTextFormField`, `AppFilledButton` y `AppOutlinedButton`. El visor con zoom
es `core/widgets/AppImagePreview`: recibe bytes, altura, orientación, ajuste al
alto y radio de borde, sin depender de entidades o controles del pesaje.

## Límites y continuidad

- **No hay reconocimiento automático de perfil.** Nitidez, animal completo y
  perfil único requieren confirmación del operario y no deben presentarse como
  una validación realizada por IA.
- Nitidez: varianza del Laplaciano central mínima 85 sobre imagen a 320 píxeles.
  El valor sólo genera una advertencia. Exposición: media entre 30 y 230. Son
  umbrales iniciales, no calibrados en campo; las pruebas sintéticas verifican
  funcionamiento, no precisión ni reconocimiento semántico.
- FRONT-02 usa `../ai_models/models/modelo_pesaje_ajuste_fino.keras`, convertido
  a TFLite float32 con `tool/convert_vision_weight_model.py`. El script verifica
  la huella del `.keras` contra `modelo_pesaje_ajuste_fino.json` y empaqueta
  ambos recursos de inferencia y calibración. La entrada es RGB 224×224 en
  [-1, 1] y la salida `[1,1]` contiene sólo kilogramos. Float32 coincidió con
  Keras en la foto de control; una cuantización previa alteraba 11,46 kg.
- **El intervalo no es confianza individual.** El JSON aporta un margen de
  ±85,27 kg para una cobertura objetivo del 90 %, calculado sobre el mayor
  error de cada uno de 94 animales de calibración. Ese porcentaje se conserva
  como metadato técnico, pero la interfaz muestra solamente los límites
  `max(0, peso - margen)` y `peso + margen` para no confundirlo con una
  confianza calculada para la foto actual. El modelo no detecta animales ni
  evalúa la calidad semántica de cada foto.
- **Precisión pendiente de validar en campo.** El proyecto de entrenamiento informa
  un MAE de 29,96 kg sobre 538 fotos de `../../dataset/prueba` para este ajuste
  fino. Esas fotos ya influyeron en comparaciones anteriores; falta validar
  cobertura y precisión con animales nuevos y en campo. Los registros guardados
  conservan su método de origen para distinguirlos de una balanza física.
- **El límite estricto de tres segundos no está acreditado.** La app mide y
  muestra el tiempo de preprocesamiento e inferencia; falta medir en celulares
  Android/iOS objetivo, también desde el disparo y hasta el primer frame del
  resultado. La precarga y el isolate reducen la latencia, pero el rendimiento
  depende del dispositivo.
- El dataset indicado existe en `/home/ernesto/Documents/dataset_vita_ai`.
  No se copia al repositorio ni se utiliza como fixture de pruebas.
- Quedan para próximos tickets: detector lateral con contrato y umbrales
  validados, validación independiente del intervalo, medición de latencia en dispositivos objetivo
  y exportación o sincronización del dataset de calibración. El peso real del
  formulario todavía no se guarda como dato de entrenamiento.

## Verificación

`fvm flutter test test/features/vision_weighing` cubre nitidez, exposición,
independencia del perfil respecto de la orientación del JPEG, corrupción de
archivos, peso manual, selección de animal, retorno del lector RFID, rechazo, reintentos,
doble disparo y resultados tardíos. `fvm flutter analyze` permite revisar lints.

Prueba manual pendiente en Android/iOS físico: permisos aceptados/denegados,
rotaciones, background/resume, captura sin señal, animal quieto/en movimiento,
animal cortado o frontal, luz de manga y calibración con teclado abierto.
Los tests no sustituyen esta validación ni acreditan el límite de tres segundos.
