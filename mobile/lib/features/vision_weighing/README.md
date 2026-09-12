# Pesaje por visión artificial — FRONT-01

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
3. Capturar. `PrepareVisionCapture` delega al repositorio local y `compute`
   ejecuta el procesamiento fuera del hilo de UI en Android/iOS.
   Para pruebas, «Configuración → Adjuntar foto» permite elegir una imagen de
   la galería y ejecutar el mismo análisis y revisión, también en modo calibración.
   La imagen adjunta conserva su orientación EXIF sin rotación por el teléfono.
4. Corregir orientación EXIF, analizar una copia de 320 píxeles de ancho y
   rechazar sólo archivos inválidos o resolución insuficiente. Exposición y
   desenfoque se presentan como advertencias para revisión manual. Las dimensiones
   del JPEG no determinan el perfil del animal ni generan advertencias de orientación.
5. Ante un rechazo técnico se muestra una alerta y se requiere una nueva captura.
6. Revisar el JPEG normalizado (máximo 1600 píxeles de ancho, sin recortar y
   ampliable hasta 4×). Confirmar explícitamente nitidez, animal completo y que
   exista un solo bovino de perfil.
7. En Modo Calibración, ingresar peso positivo con hasta dos decimales. Se
   aceptan coma y punto, sin separadores de miles. Foto y kilos quedan asociados
   **en memoria durante esta sesión**, y se descartan al salir o reintentar.

`VisionCaptureCubit` usa `ResultState<VisionCapture>`, pertenece a la página y
sólo consume un caso de uso. Cámara y permisos son recursos visuales del plugin;
la infraestructura de análisis vive en `data`. La cámara se libera al abandonar
la vista o pasar la app a segundo plano y se vuelve a abrir al regresar.

La presentación utiliza `AppSpacing`, `AppRadius`, `AppBorders`, `AppTypography`
y `AppElevation`. La revisión reutiliza `AppSurfaceCard` con sombra visible,
`AppTextFormField`, `AppFilledButton` y `AppOutlinedButton`. El visor con zoom
es `core/widgets/AppImagePreview`: recibe bytes, altura y orientación, sin
depender de entidades o controles del pesaje.
La revisión suspende el scroll desde el primer contacto sobre el visor para
permitir el zoom con dos dedos; al soltar todos los dedos se recupera el scroll.

## Límites y continuidad

- **No hay reconocimiento automático de perfil.** Nitidez, animal completo y
  perfil único requieren confirmación del operario y no deben presentarse como
  una validación realizada por IA.
- Nitidez: varianza del Laplaciano central mínima 85 sobre imagen a 320 píxeles.
  El valor sólo genera una advertencia. Exposición: media entre 30 y 230. Son
  umbrales iniciales, no calibrados en campo; las pruebas sintéticas verifican
  funcionamiento, no precisión ni reconocimiento semántico.
- Se inspeccionó `AI-research` (8747e6b), ya antecesora de esta rama, y la
  referencia local `origin/AI-research` (896249b). Hay modelos `.keras` de
  regresión MobileNetV2: entrada RGB 224×224, normalización [-1, 1], salida
  escalar de peso. No incluyen detector, bounding boxes ni confianza.
  El commit remoto agrega reentrenamiento, no el detector faltante; no se hizo
  merge. No se convirtió ni integró el estimador, fuera de FRONT-01.
- El dataset indicado existe en `/home/ernesto/Documents/dataset_vita_ai`.
  No se copia al repositorio ni se utiliza como fixture de pruebas.
- Quedan para próximos tickets: detector lateral con contrato y umbrales
  validados, inferencia `.tflite`, medición de latencia menor a 3 segundos en
  dispositivos objetivo, confianza del modelo, SQLite/Brick y exportación o
  sincronización del dataset. El formulario **no afirma haber guardado datos**.
- El JPEG de revisión no es todavía un tensor de entrada del modelo. La
  normalización específica se debe aplicar al integrar TFLite.

## Verificación

`fvm flutter test test/features/vision_weighing` cubre nitidez, exposición,
independencia del perfil respecto de la orientación del JPEG, corrupción de
archivos, peso manual, rechazo, reintentos,
doble disparo y resultados tardíos. `fvm flutter analyze` permite revisar lints.

Prueba manual pendiente en Android/iOS físico: permisos aceptados/denegados,
rotaciones, background/resume, captura sin señal, animal quieto/en movimiento,
animal cortado o frontal, luz de manga y calibración con teclado abierto.
Los tests no sustituyen esta validación ni acreditan el límite de tres segundos.
