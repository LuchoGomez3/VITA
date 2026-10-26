# Pesaje por visión — VITA-141

Entrada desde el botón central de la navbar (`/pesar-por-vision`). La cámara
trasera captura sin audio y requiere sostener el teléfono horizontalmente.
También se puede adjuntar una fotografía local. No se realizan requests de red
para capturar, revisar, calibrar o inferir.

## Flujo y límites actuales

1. `VisionCamera` coordina permisos, orientación, disparo y lifecycle mediante
   casos de uso. El repositorio serializa apertura, captura y cierre, libera
   controllers fallidos y retira el preview antes de cerrar el recurso nativo.
2. `PrepareVisionCapture` analiza resolución, exposición y nitidez en un
   isolate. Una resolución menor a 640×360 (en cualquier orientación) rechaza
   la captura; exposición y nitidez generan advertencias para revisión humana.
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

## Contrato de inferencia local

Esta rama **no incluye un modelo entrenado**, pesos ni margen experimental.
El flujo instalado permite captura, revisión y calibración de sesión, pero no
produce kilogramos IA hasta incorporar un paquete aprobado en otra revisión.

El adaptador espera estos recursos locales, que también deberán declararse en
`pubspec.yaml` cuando se apruebe su distribución:

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
en modo avión. Con un modelo aprobado: compatibilidad nativa, precisión y
latencia en equipos objetivo. La revisión humana de permisos es obligatoria
según AGENTS.md. No se guarda ni exporta un dataset de calibración.

La investigación y las exclusiones están en
[recuperación de visión](../../../docs/vision_weighing_recovery.md).
