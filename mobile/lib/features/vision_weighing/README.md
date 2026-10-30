# Pesaje por visión — VITA-141

Entrada desde el botón central de la navbar (`/pesar-por-vision`). La cámara
trasera captura sin audio y requiere sostener el teléfono horizontalmente.
También se puede adjuntar una fotografía local. No se realizan requests de red
para capturar, revisar, calibrar o inferir.

## Flujo y límites actuales

1. `VisionCamera` coordina permisos, orientación, disparo y lifecycle mediante
   casos de uso. El repositorio serializa apertura, captura y cierre, libera
   controllers fallidos y retira el preview antes de cerrar el recurso nativo.
   La orientación física se toma al disparar y se bloquea explícitamente en el
   plugin durante la captura; el bloqueo se libera incluso si la toma falla.
2. `PrepareVisionCapture` analiza resolución, exposición y nitidez en un
   isolate. Una resolución menor a 640×360 (en cualquier orientación) rechaza
   la captura; exposición y nitidez generan advertencias para revisión humana.
   El EXIF se normaliza una sola vez: inferencia, revisión, ampliación y foto
   privada utilizan el mismo JPEG, sin rotaciones visuales adicionales.
3. `ProcessVisionCapture` intenta inferencia local. Si falta el modelo o su
   contrato no es compatible, conserva la foto para revisión y explica que
   no es posible guardar un pesaje IA. No inventa resultados ni descarga assets.
4. El operario confirma nitidez, animal completo y un único animal de perfil.
   Estos controles son humanos: no hay detector de animales ni reconocimiento
   automático del perfil. Calibración exige un peso real positivo y admite
   coma decimal; foto y peso de calibración permanecen solo en la sesión.
5. Con una estimación válida, se elige un animal local por caravana manual,
   lista reciente o lector RFID existente. El catálogo se limita a membresías
   offline. Se resuelve el establecimiento a partir del UUID del animal.
   Si hay varios establecimientos, se exige elegir uno antes de buscar/listar
   animales o abrir RFID. Cambiarlo limpia el animal seleccionado anteriormente.
   Solo se ofrecen membresías con un rol operativo conocido. El guardado vuelve
   a leer el catálogo local y deniega la operación si la membresía fue retirada
   o su rol es desconocido, antes de escribir la foto o el pesaje.
6. Al guardar, el JPEG se copia mediante `AnimalPhotoStore`, ya presente en
   `develop`: una foto privada por establecimiento/animal, visible en su ficha.
   Después se guarda el pesaje en SQLite con UUID cliente, método
   `artificialIntelligence`, `isEstimated = true` y estado pendiente. El store
   Brick existente encola el envío sin esperar conectividad. No se sincroniza
   el JPEG. Si falla la foto, no se confirma el pesaje. Si falla SQLite tras
   guardar la foto, puede quedar la foto actualizada; el pesaje permite reintento.

El Cubit usa `ResultState`, invalida resultados tardíos y bloquea operaciones
duplicadas durante el guardado. La página conserva la misma sesión de cámara
ante reconstrucciones del router. Al salir o pasar a background se cierran
cámara y suscripciones. El stream de orientación se pausa una sola vez aunque
el sistema emita `inactive → hidden → paused`.

El guardado tiene un `ResultState<void>` propio dentro del estado de revisión.
La pantalla renderiza progreso, éxito y error desde ese estado; un fallo conserva
la captura y la selección para reintentar sin excepciones entre Cubit y widget.
`DeviceVisionCameraRepository` conserva el único controlador nativo y notifica
su disponibilidad a `VisionCameraPreviewAdapter`, que construye el preview en
presentación. El adaptador retira su referencia antes de cerrar el controlador
y no se encarga de abrirlo ni liberarlo.

## Contrato de inferencia local

Esta rama incluye como punto de partida el modelo probado en `jornada-poster`
y su margen experimental de **±85,27 kg**. Los dos archivos se recuperaron sin
modificaciones desde `c7777a1`; no se incorporan entrenamiento ni checkpoints.
Su procedencia y hashes están en [assets/models](../../../assets/models/README.md).

El adaptador carga estos recursos, declarados explícitamente en `pubspec.yaml`:

- `assets/models/peso_bovino_mobilenet_v2.tflite`: una entrada float32
  `[1,224,224,3]`, RGB normalizado a `[-1,1]`, y una salida float32 `[1,1]` en kg.
- `assets/models/peso_bovino_intervalo.json`: `margen_kg` finito, no negativo, y
  `cobertura_objetivo` estrictamente entre 0 y 1. No hay valores por defecto.

El isolate realiza decode/resize, crea el intérprete, comprueba tensores y
ejecuta inferencia; `finally` libera el intérprete. No hay worker global ni
handles nativos que sobrevivan a la operación. Puede terminar un trabajo ya
iniciado al salir; el Cubit descarta su resultado. Ver
[ADR-0013](../../../../docs/adr/adr-0013-inferencia-local-por-captura.md).

El intervalo muestra `max(0, peso - margen)` y `peso + margen`. La cobertura
declarada es metadato del modelo, no confianza individual para una fotografía.
No se acredita precisión de campo ni una latencia menor a tres segundos.

## Reemplazar o retirar el modelo

- Para un modelo compatible, reemplazar **juntos** el `.tflite` y el JSON del
  margen conservando sus nombres. No cambian cámara, Cubit, dominio ni Brick.
  Actualizar procedencia/hashes y las expectativas del test del paquete.
- Para conservar archivos versionados con otros nombres, declarar las nuevas
  rutas en `pubspec.yaml` y pasarlas mediante `modelAsset`/`calibrationAsset` al
  construir `TfliteWeightEstimator` en la composición de la feature.
- Si cambia resolución, normalización o salida, adaptar el preprocesamiento y
  contrato de tensores en `data/services/tflite_weight_estimator.dart`. No basta
  con cambiar la extensión: se comprueban forma y tipo de los tensores.
- Para retirar el paquete, quitar ambos archivos y sus declaraciones de assets.
  La ausencia mantiene captura/revisión/calibración y deshabilita el pesaje IA
  con un aviso, sin pesos de reemplazo inventados.

Estos cambios requieren **una nueva compilación de la app**. No hay descarga
remota ni selector de modelos en la interfaz. Ver
[ADR-0014](../../../../docs/adr/adr-0014-modelo-inicial-de-pesaje-intercambiable.md).

## Arquitectura y generación

`presentation → domain/use_cases → domain/repositories ← data → Brick/plugins`.
La composición explícita vive en `vision_weighing_composition.dart`.
No cambian modelos, schema, adapters ni migraciones Brick. Los Freezed se
regeneran con `fvm dart run melos run build`; descartar salidas incidentales de
módulos ajenos cuyos sources no cambiaron.

## Validación y revisión pendiente

Tests en `test/features/vision_weighing` cubren calidad, inferencia mediante
puertos de prueba, modelo ausente, revisión, calibración, guardado, permisos y
carreras de lifecycle. Los dobles y las imágenes sintéticas están solo en tests.
La selección RFID y el contrato existente de pesajes tienen tests de regresión.

Pendiente en Android/iOS físico: permiso inicial/denegado/restringido, volver
de Ajustes, background/resume, orientación JPEG/EXIF, galería, captura y guardado
en modo avión. Con el modelo inicial: compatibilidad nativa, precisión y
latencia en equipos objetivo. La revisión humana de permisos es obligatoria
según AGENTS.md. No se guarda ni exporta un dataset de calibración.

La investigación y las exclusiones están en
[recuperación de visión](../../../docs/vision_weighing_recovery.md).
