---
name: sincronizacion
description: >-
  Pantalla de estado de sincronización offline-first: muestra en vivo la cola
  de operaciones que el teléfono todavía no envió al backend, los registros que
  el backend rechazó y lo enviado en la sesión. Documento vivo, se actualiza en
  el mismo commit que introduce cada pieza descripta acá.
---

# Sincronización

Es la vista de estado de la cola offline de Brick. No implementa lógica de
sync nueva: lee la cola que Brick ya mantiene en
`vita_brick_offline_queue.sqlite` y la traduce a operaciones que el productor
entiende ("Pesaje", "Alta de animal", ...).

Ver también **[`estado-pantallas-diseno.md`](./estado-pantallas-diseno.md)**.

## Pantallas → rutas

| Pantalla (Claude Design) | Página Flutter | Ruta |
|---|---|---|
| `SyncScreen` | `SyncStatusPage` | `/sincronizacion` |

Pantalla única, sin bottom nav (push). Se entra desde el ícono de nube del
encabezado de Inicio y de Sanidad (`SyncQueueIndicator`), que muestra la
cantidad de pendientes en vivo. Cada pantalla recibe el indicador ya armado
desde el router, así no depende de la feature de sincronización.

## Contenido

- Header: back + "Sincronización" + "N registros pendientes" / "Todo
  sincronizado" + botón "Sincronizar ahora".
- Banner según el estado de la cola y la conectividad (`connectivity_plus`):
  - vacía → "Todo sincronizado";
  - sin señal → "N registros guardados en el teléfono · se envían solos cuando
    vuelva la señal";
  - con señal y una request tomada por Brick → "Enviando N registros…";
  - con señal, nada en curso → "N registros esperando su turno".
- "No se pudieron guardar" (solo si hay): registros que el backend rechazó
  con un 4xx, con tipo, hora del último cambio y código de error. Van primero
  porque son los únicos que piden una acción del productor.
- "Cola de operaciones": una fila por request, en el orden en que Brick las va
  a enviar, con tipo, hora en que se registró y estado (`En espera`,
  `Enviando…`, `Reintentando · N fallos`).
- "Enviados recientemente" (solo si hay): los últimos 20 registros que el
  backend aceptó desde que se abrió la app. Al recuperar la señal, cada fila
  pasa de la cola a esta sección.

## Cómo funciona

```txt
SyncStatusPage / SyncQueueIndicator
  -> SyncQueueCubit (cola + conectividad + sincronizar ahora)
  -> SyncQueueRepository.watch()
  -> SyncQueueRepositoryImpl
  -> AppBrickRepository.queuedRequests()   (solo método, path, intentos, fechas)
  -> RestRequestSqliteCacheManager.unprocessedRequests()
```

- **En vivo**: Brick no avisa cuando toma, reintenta o borra una fila (lo hace
  con su timer de 5 s), así que mientras haya una pantalla suscripta se relee
  la cola cada 2 s, y además ante cada `localChanges` (escritura local) y
  `syncResults` (respuesta del backend). Solo se emite si la cola cambió. Sin
  suscriptores no se consulta nada.
- **Estado de cada fila**: `locked = 1` → enviando; `attempts > 1` →
  reintentando (los 5xx y la falta de red quedan en cola); si no, en espera.
  Brick marca `locked` recién desde el segundo intento: el primer envío de una
  request nueva se ve como "En espera" hasta que responde.
- **Tipo de operación**: sale del path y del método, usando las constantes
  `*RequestTransformer.*Path` de los modelos Brick. Un path desconocido se
  muestra como "Otro registro" en vez de ocultarse.
- **Privacidad**: `BrickQueuedRequest` no expone headers ni body de la fila,
  que contienen el payload del productor.
- **Errores**: si falla la lectura de SQLite se muestra un aviso ("tus registros
  siguen guardados en el teléfono") y el stream sigue vivo; la próxima lectura
  lo limpia. Si falla "Sincronizar ahora" se muestra un SnackBar.
- "Sincronizar ahora" dispara `OfflineSyncCoordinator.synchronize()`, el mismo
  ciclo que usan la reconexión y el resume. La cola se sigue vaciando sola.
- **Rechazados**: Brick borra de la cola una request rechazada y cada store
  marca el modelo como `rejected` en SQLite (con `syncErrorCode`). Ese estado
  es la única huella del rechazo y sobrevive a reiniciar la app.
  `BrickRejectedRecordsReader` lo lee de los seis modelos sync-ables y
  `SyncRejectionsRepositoryImpl` relee ante `localChanges` y `syncResults` (sin
  consulta periódica: un registro solo cambia de estado por esos dos caminos).
  Un error leyendo rechazados se registra y no tapa la cola.
- **Enviados**: Brick no guarda historial, porque borra la request al recibir
  un 2xx. `SyncHistoryRecorder` escucha `syncResults` desde `main.dart`
  (`startSyncHistoryRecorder()`), así también registra lo que se envió con la
  pantalla cerrada. Vive en memoria y se pierde al cerrar la app, que es lo
  esperable para "enviados recientemente". Guarda una fila por registro: si el
  backend confirma dos veces el mismo `localId` (el ciclo de sincronización
  reencola los movimientos pendientes mientras la cola ya los está enviando),
  se actualiza la hora en vez de duplicar la fila.
- **Conectividad**: `onConnectivityChanged` solo avisa cambios, así que una
  pantalla abierta ya sin señal nunca se enteraba y mostraba el banner "con
  señal". `connectivityStatus()` consulta `checkConnectivity()` al suscribirse
  y después sigue los cambios.
- **Tipo de operación**: `syncOperationKindFor(path, method:)` lo comparten la
  cola, los rechazados y el historial. Sin método (respuestas del backend,
  rechazos leídos de SQLite) un animal se muestra como "Animal".
- El indicador de la nube usa `createSyncQueueCubit()` (solo la cola); la
  pantalla usa `createSyncStatusCubit()` (cola, rechazados e historial).

## Fuera de alcance (y por qué)

- **Resolución de conflictos** ("Mantener servidor" / "Aplicar el mío" del
  diseño): el backend resuelve last-write-wins por `updated_at`, así que el
  cliente nunca recibe un conflicto para resolver. Se quitaron la tarjeta y el
  mock.
- **Corregir un rechazo desde acá**: la pantalla lo informa, pero la
  corrección se hace en la pantalla de cada registro, que es la que conoce sus
  reglas.
- **Archivos**: la cola de Brick descarta los `MultipartRequest`, así que una
  subida de archivo nunca aparece como pendiente.

## Tests

- `test/brick/core/queued_requests_test.dart`: una request con el backend
  caído (503) queda en la cola real (SQLite ffi) y la vista de la fila no
  arrastra headers ni body.
- `test/features/sync/data/sync_queue_repository_impl_test.dart`: traducción
  de path/método a tipo y de `locked`/`attempts` a estado, emisión inicial,
  relectura ante cambios y por consulta periódica, sin reemisión si nada
  cambió, recuperación tras un error, y que deja de consultar al cancelar.
- `test/features/sync/data/brick_rejected_records_reader_test.dart`: sobre
  SQLite real (ffi), devuelve solo los `rejected` de cada modelo, con su
  código, el más reciente primero.
- `test/features/sync/data/sync_rejections_repository_impl_test.dart`: emisión
  inicial, relectura ante cambios, sin reemisión si nada cambió, recuperación
  tras un error y que deja de leer al cancelar.
- `test/features/sync/data/sync_history_recorder_test.dart`: solo guarda los
  aceptados, el más reciente primero, respeta la capacidad, no duplica un
  registro confirmado dos veces y entrega lo enviado antes de que se abra la
  pantalla.
- `test/features/sync/data/sync_operation_kind_mapper_test.dart`: traducción
  de path y método a tipo.
- `test/features/sync/data/connectivity_status_test.dart`: al abrir sin señal
  informa offline aunque no haya cambios, no repite valores y sigue si falla la
  consulta inicial.
- `test/features/health/presentation/health_page_test.dart`: Sanidad muestra
  el indicador que recibe del router en vez del badge mock.
- `test/features/sync/presentation/`: cubit (cola, conectividad, errores,
  sincronizar ahora sin superponerse, rechazados e historial sin tapar la cola)
  y página (sin señal, lista en vivo hasta vaciarse, al reconectar lo pendiente
  pasa a enviados y los rechazados se destacan, SnackBar si falla la
  sincronización manual).
