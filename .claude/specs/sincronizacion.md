---
name: sincronizacion
description: >-
  Pantalla de estado de sincronización offline-first: muestra en vivo la cola
  de operaciones que el teléfono todavía no envió al backend. Documento vivo,
  se actualiza en el mismo commit que introduce cada pieza descripta acá.
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
encabezado de Inicio (`SyncQueueIndicator`), que muestra la cantidad de
pendientes en vivo.

## Contenido

- Header: back + "Sincronización" + "N registros pendientes" / "Todo
  sincronizado" + botón "Sincronizar ahora".
- Banner según el estado de la cola y la conectividad (`connectivity_plus`):
  - vacía → "Todo sincronizado";
  - sin señal → "N registros guardados en el teléfono · se envían solos cuando
    vuelva la señal";
  - con señal y una request tomada por Brick → "Enviando N registros…";
  - con señal, nada en curso → "N registros esperando su turno".
- "Cola de operaciones": una fila por request, en el orden en que Brick las va
  a enviar, con tipo, hora en que se registró y estado (`En espera`,
  `Enviando…`, `Reintentando · N fallos`).

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

## Fuera de alcance (y por qué)

- **Resolución de conflictos** ("Mantener servidor" / "Aplicar el mío" del
  diseño): el backend resuelve last-write-wins por `updated_at`, así que el
  cliente nunca recibe un conflicto para resolver. Se quitaron la tarjeta y el
  mock.
- **Rechazos (4xx)**: Brick borra de la cola una request rechazada y el store
  marca el registro como `rejected` en SQLite. No aparecen en esta pantalla; se
  ven en cada feature (por ejemplo, el historial de movimientos). Sumarlos acá
  requiere leer el `syncStatus` de cada modelo Brick.
- **Archivos**: la cola de Brick descarta los `MultipartRequest`, así que una
  subida de archivo nunca aparece como pendiente.
- **Badge de Sanidad** (`AppSyncBadge` en `health_page.dart`): sigue con el
  valor mock de su maqueta; debería pasar a `SyncQueueIndicator` cuando Sanidad
  deje de ser mock.

## Tests

- `test/brick/core/queued_requests_test.dart`: una request con el backend
  caído (503) queda en la cola real (SQLite ffi) y la vista de la fila no
  arrastra headers ni body.
- `test/features/sync/data/sync_queue_repository_impl_test.dart`: traducción
  de path/método a tipo y de `locked`/`attempts` a estado, emisión inicial,
  relectura ante cambios y por consulta periódica, sin reemisión si nada
  cambió, recuperación tras un error, y que deja de consultar al cancelar.
- `test/features/sync/presentation/`: cubit (cola, conectividad, errores,
  sincronizar ahora sin superponerse) y página (sin señal, lista en vivo hasta
  vaciarse, SnackBar si falla la sincronización manual).
