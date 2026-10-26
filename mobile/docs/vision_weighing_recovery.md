# Recuperación selectiva del pesaje por visión — VITA-141

Fecha: 2026-10-26. Base consultada después de `git fetch origin --prune`:
`origin/develop = e5aa980`. Rama: `feature/pesaje-vision-inicial`.
No se hace push, PR ni merge a develop.

Commit de implementación y tests: `5e67842`
(`feat(pesaje-vision): recuperar captura y pesaje offline VITA-141`).

## Grafo investigado

El merge-base de develop tanto con jornada-poster como con la rama original
es `8206871`. Los tres candidatos tienen patch-id nuevo frente a develop
(`git cherry` los marca `+`); ninguno puede aplicarse completo con seguridad.
Se observan merges explícitos; no se encontró evidencia de un rebase que
permita considerar limpia la rama original.

Secuencia principal de `origin/epetrich9/vita-141-pesar-por-vision-artificial`:

```text
3e82d19
  → 97e5698 → 18ae08e → 8747e6b   experimentos ML excluidos
  → da2ea62                        cámara/revisión/calibración y screenshots
  → 6155b34                       merge de develop (5730cfb)
  → c7777a1                        inferencia/offline y experimentos mezclados
  → 54179b2                       merge de develop (fc2d7bd)
  → d1cac3a                       merge de jornada-poster (847d58e)
  → a2e28ba                       merge de 3c5488c; incluye enlace de foto local
  → 9989705                       merge de jornada-poster (91668d5)
  → 01695d2                       merge con 4ca4b66
  → 55aa7b2                       fix cámara y compatibilidad Brick mezclados

54179b2 → 4ca4b66                  merge alternativo de jornada-poster (58f5626)
```

`58f5626` y `9bc9a65` incorporan modo demo y datos sintéticos. Jornada-poster
integra la rama de visión mediante `afebe46` y `a25d9db`; después incorpora
otras funcionalidades de UX/ventas. No se toma ningún merge como commit fuente
de la rama nueva, ni se incorpora su ascendencia.

Antes de los merges de presentación, los cambios propios de visión son
`da2ea62` y `c7777a1`; los tres commits anteriores son investigación ML.
Después de esos merges, los únicos cambios adicionales dentro de la feature
son el enlace de foto privada de `a2e28ba` y el fix de cámara de `55aa7b2`.
Se comprobó con diff del subárbol entre `c7777a1` y el tip original.

## Fuentes y selección

| Fuente | Recuperación | Descartado |
| --- | --- | --- |
| `da2ea62` | `cherry-pick --no-commit`, resolución selectiva: cámara, revisión, calibración, ruta/navbar, permisos, estilos y preview reutilizables, tests de la feature | `test/screenshots/**` completo; hunk de Home; reemplazos de router y dependencias que pisaban develop. Lockfile regenerado |
| `c7777a1` | Diff limitado a feature, preview y tests; integración adaptada del router y selección RFID; dependencias fijas; ajuste Gradle específico de TFLite | Todo `ai_models/**`, `assets/models/**`, `tool/convert_vision_weight_model.py`, hunk de historial animal y su test; reorganizaciones ajenas del router. Sin paquete experimental de inferencia |
| `55aa7b2` | Hunks de cámara y tests de lifecycle, adaptados y ampliados sobre el código recuperado | `brick/core/migration_compatibility.dart`, cambios de `brick/core/repository.dart`, su test y documentación: pertenecen a esquemas contaminados, no al fix del controller |
| `a2e28ba` (árbol del merge, sin cherry-pick) | Solo enlace del JPEG desde `SaveVisionWeight` a `AnimalPhotoStore` existente, mediante contrato de dominio; tests adaptados | Todo el resto del merge. Infraestructura de fotos, ficha, lotes, backend, datos y assets ya tienen resoluciones independientes en develop |

No se incorporan `97e5698`, `18ae08e`, `8747e6b`, checkpoints, modelos Keras,
TFLite experimental de 19 MB, logs de entrenamiento, fotos demo ni mapas de
presentación. Los dobles e imágenes sintéticas se limitan a pruebas automatizadas.
Los mocks preexistentes de otras pantallas de develop quedan fuera del diff.

## Ya resuelto en develop

- Stores de animales y pesajes, SQLite, cola REST, enums del método IA y estado
  estimado: se reutilizan sin modificar modelos ni código generado Brick.
- Pesaje manual desde ficha: `e574126`; no se reemplaza por la versión antigua.
- Fotos privadas y ficha actual: `ce2bef7`, `537a8a1`, `2c3f35f`, `34edecf`.
  Falta solo el enlace del JPEG de visión al store compartido, recuperado aquí.
- `git cherry` confirma equivalencia de `889d9eb → dc6914d`,
  `5e8db1c → 8affb97`, `774f8a9 → 03050c6`, `ac51210 → dfda1c9`,
  `b275c81 → 9010091`, `b679fb7 → de597cc`, `5804158 → 105f535`,
  `d8314a7 → 17ad345`. No se vuelven a integrar esas historias.
- Catálogo global: `8eca3c7` no tiene patch-id equivalente exacto, pero está
  resuelto mediante `5fc2edc` y `4b474cb`. Se conserva el contrato actual.
- Permisos/membresías, estados productivos y navegación actual de develop se
  conservan; no se copia la infraestructura de auth/demo de jornada-poster.

## Correcciones sobre la recuperación

- Cola de apertura/captura/cierre; controller fallido liberado; preview sin
  referencia a controller descartado; resultados viejos no cierran cámara nueva.
- Error diferenciado por permiso denegado, restringido o cámara ausente;
  reintento visible y galería local disponible.
- Sensor pausado una sola vez; cancelación de listeners al salir; callbacks
  tardíos de captura/apertura descartados; animaciones con cancelación explícita.
- Cámara con dueño estable durante la sesión aunque el router se reconstruya.
- Codec e inferencia fuera de la UI; intérprete local por operación liberado
  con `finally`, sin worker global. Ver ADR-0013.
- Modelo ausente conserva revisión/calibración y bloquea guardar pesos ficticios.
- Guardado duplicado bloqueado, errores reintentables, sin emitir tras cerrar.
- Búsqueda manual local por caravana además de los cinco recientes y RFID.

## Validación

SDK: FVM Flutter 3.44.0 / Dart 3.12.0.

- `fvm flutter pub get`: correcto; lockfile conserva las dependencias de base
  salvo cámara/sensores/TFLite e `image` fijada a 4.9.2.
- `fvm dart run melos run build`: correcto. No cambia el esquema Brick ni crea
  migraciones. Se descartaron regeneraciones incidentales de otros módulos.
  El generador informa advertencias preexistentes de versión analyzer/SDK y
  constraint de json_annotation; no se actualizan dependencias ajenas.
- `fvm dart format`: aplicado a archivos recuperados y tests; verificar también
  los Freezed recuperados mediante el formatter, sin edición manual.
- `fvm dart analyze --fatal-infos lib/features/vision_weighing` y el mismo comando
  sobre `test/features/vision_weighing`: sin diagnósticos nuevos.
- `fvm flutter analyze --no-pub --fatal-infos`: 247 avisos preexistentes, sin
  errores ni warnings. Se ejecutó el mismo proceso sobre un worktree temporal
  de `origin/develop`: 247 avisos. Comparación de mensaje/ruta/regla normalizando
  números de línea: sin diagnósticos agregados. El check estricto global sigue
  fallando por esa deuda previa; no se afirma CI verde.
- Suite focalizada: **94 tests aprobados**, sin modelos experimentales:

  ```powershell
  fvm flutter test --no-pub test/features/vision_weighing test/core/navigation/camera_reveal_page_test.dart test/core/widgets/app_image_preview_test.dart test/core/storage/animal_photo_store_test.dart test/features/rfid_scan test/features/weighing test/brick/models/pesaje_model_test.dart
  ```

- `git diff --check` sin hallazgos en archivos escritos por el equipo. Freezed
  emite 12 líneas vacías con espacios y desactiva su formatter; se conserva esa
  salida oficial sin editarla a mano.

## Revisión humana y límites

No se ejecutó cámara física ni compilación nativa Android/iOS en este entorno.
Validar permisos y Ajustes, background/resume, JPEG/EXIF, rotación, captura,
galería y guardado en modo avión. El código de permisos requiere revisión humana
por AGENTS.md; toda la rama debe pasar revisión antes de abrir/integrar la PR.

Sin modelo aprobado, la app no estima kg reales: esta limitación es deliberada
para excluir artefactos experimentales. Aprobar modelo/margen, declarar sus
assets y medir precisión y latencia es un paso posterior. La calibración actual
solo conserva peso/foto durante la sesión, sin dataset ni entrenamiento.

Foto privada y SQLite no forman una transacción: un fallo de SQLite posterior
a la copia puede dejar la foto actualizada sin nuevo pesaje. El error se muestra
y el operario puede reintentar. El aislamiento final remoto sigue dependiendo
de los contratos/RLS existentes, sin modificaciones en esta recuperación.
