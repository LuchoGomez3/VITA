# Asignación y traslado entre lotes

El flujo usa los endpoints existentes del backend. No cambia `lote_id` mediante
PUT de animales y no envía `responsable_id`: el servidor identifica al responsable
con el JWT.

## Uso

- En **Visualizar animal**, **Cambiar de lote** aparece junto a **Baja por muerte**.
  La ficha sigue mostrando **Muerto** como estado productivo. El animal queda
  preseleccionado si no tiene otro traslado pendiente o rechazado.
- En **Campo**, **Mover animales** abre la selección múltiple. El grupo inicial es
  **Sin lote asignado**; el selector de origen permite elegir un lote.
- Desde la ficha de un lote se abre el mismo flujo con ese origen.
- Elegir uno o varios animales del grupo, un destino activo, fecha/hora y un
  motivo obligatorio. **Revisar movimiento** muestra cantidad, origen y destino.
  Cancelar no escribe datos; confirmar guarda la operación local.
- El historial del flujo distingue pendiente, confirmado y rechazado. Los
  movimientos que incluyen al animal también aparecen en su **Historial de
  Eventos**, junto con nacimiento y pesajes, ordenados por fecha efectiva.
- Al volver a una ficha se recarga su ubicación. Tirar hacia abajo refresca los
  datos remotos sin perder el historial local si no hay conectividad.

## Arquitectura y contrato

```text
Página -> Cubit -> casos de uso -> repositorio de lot_movement
                                     -> stores compartidos de Brick
                                     -> SQLite + cola REST existente
```

Las features se conectan por `go_router`; no importan el dominio, repositorios
ni pantallas internas de otra feature. `animal_detail` proyecta movimientos del
store compartido en sus propios eventos de dominio.

Requests:

- `GET /api/v1/lotes?establecimiento_id=<UUID>&estado=activo`.
- `GET /api/v1/animales?establecimiento_id=<UUID>`. Se reutiliza el pull de
  animales. Omitir `lote_id` trae todo el establecimiento; la UI agrupa por origen.
  Un `lote_id: null` remoto se representa como string vacío en el modelo Brick
  anterior y vuelve a `null` en el dominio del movimiento.
- `POST /api/v1/movimientos_lotes` con exactamente `id`, `establecimiento_id`,
  `lote_origen_id`, `lote_destino_id`, `animal_ids`, `fecha_movimiento` y `motivo`.
  La fecha local se convierte a UTC ISO 8601 con `Z`, preservando el instante y
  cumpliendo el contrato de fecha con zona horaria.
- `GET /api/v1/movimientos_lotes?establecimiento_id=<UUID>&include_deleted=true`
  hidrata el historial y respeta los tombstones disponibles en el backend actual.

El sync inicial posterior al login descarga destinos e historial. Abrir este
flujo muestra primero SQLite y luego actualiza esos recursos. La recepción de
ubicaciones de otros dispositivos usa el GET habitual de animales, nunca aplica
otra vez un movimiento histórico.

## Guardado offline y reintentos

1. El caso de uso rechaza selección vacía, UUID inválidos, IDs repetidos, motivo
   vacío, orígenes distintos y destinos no disponibles o iguales al origen.
2. El store vuelve a leer animales y destino **dentro de una transacción SQLite**.
   Valida establecimiento, origen, estado activo y que no haya otra operación
   de ubicación abierta. Guarda el movimiento y cambia todos los lotes locales,
   o revierte todo si falla alguna escritura.
3. `lotMovementId`, `lotSyncStatus` y `lotSyncErrorCode` en el animal mantienen
   separado el sync de ubicación del sync de categoría, muerte y otras ediciones.
   No se cambia `updatedAt` del animal al moverlo offline: el servidor asigna la
   versión autoritativa y la próxima lectura la recibe.
4. El movimiento pendiente funciona como **outbox durable** en la base principal.
   Se persiste su request en la cola existente de Brick, sin esperar red. Como
   ambas bases son distintas, se reconstruyen jobs faltantes al arrancar y cada
   30 segundos mientras la app sigue ejecutándose. El body estable permite
   deduplicar jobs, incluyendo requests bloqueados por el procesador.
5. Brick transmite el POST autenticado y reintenta fallos de red/5xx. Los resultados
   HTTP actualizan en una transacción el movimiento y su estado de ubicación.
   Un rechazo queda guardado con su código y conserva la ubicación optimista,
   excepto el caso de destino local no disponible explicado abajo;
   no se elimina el historial ni se presenta como un movimiento confirmado.
6. **Reintentar** conserva ID, animales, origen, destino, fecha y motivo. Un UUID
   ya confirmado no vuelve a mover los animales. El GET de historial también
   confirma una operación cuyo servidor la recibió pero cuya respuesta se perdió.

Se impide crear otro traslado sobre un animal cuya ubicación está pendiente o
rechazada. Esto evita cadenas de operaciones que dependan de un origen aún no
confirmado. Se pueden registrar operaciones de animales distintos sin conexión.

### Destinos creados solamente en el celular

El selector ofrece únicamente lotes activos con `syncStatus = synchronized`.
El store revalida esta condición dentro de la transacción. Un lote guardado
localmente debe sincronizarse antes de recibir animales; los lotes ya confirmados
y guardados en la caché siguen disponibles sin conexión.

Para reparar intentos de versiones anteriores, un rechazo con código backend
`lote_destino_no_disponible` hacia un destino no sincronizado restaura el origen
de los animales que aún tienen ese movimiento como ubicación pendiente. El job
se retira únicamente si no está en vuelo. La reparación se ejecuta al arrancar,
al recibir resultados y cada 30 segundos. El historial conserva el intento
rechazado con el prefijo técnico `released_local_destination:` y su código
original; no ofrece reintentar un intento liberado. Se puede crear otro traslado.
La ficha no cuenta ese rechazo histórico como sincronización aún pendiente.

Un movimiento pendiente de respuesta **no se revierte automáticamente**: el
servidor podría haberlo aplicado. Necesita recuperar conexión y recibir rechazo
o confirmación. Tampoco se revierten por esta vía errores de sesión u origen.
La reparación conserva las otras ediciones locales del animal.

La sincronización de movimientos está habilitada por defecto. Se retiró
`VITA_ENABLE_LOT_MOVEMENT_REMOTE_SYNC`. La edición/alta de lotes conserva su flag
`VITA_ENABLE_LOT_REMOTE_SYNC`, habilitado por defecto. Un define explícito en
`false` permite desactivarlo en builds locales; la lectura de destinos activos
funciona sin él. Este cambio no recupera automáticamente altas locales previas.

## Límites pendientes y decisiones necesarias

- La cola compartida aún tiene los pendientes de [sesión y aislamiento entre
  cuentas](../../brick/auth/README.md). Un 401 se muestra como rechazo durable y
  permite reintentar el mismo movimiento tras recuperar sesión; todavía no hay
  una pausa/reanudación global automática segura por propietario de cola.
- No se inventó un endpoint para anular o rebasar un movimiento rechazado. Si
  cambió el origen en otro dispositivo, el payload original se conserva y el
  rechazo se muestra. Hace falta acordar la política de reconciliación: aceptar
  ubicación remota, descartar explícitamente la propuesta local o crear una
  operación nueva tras revisión. Reintentar no cambia silenciosamente su origen.
- El backend actual asigna `animal.updated_at = fecha_movimiento`. Con fechas
  retroactivas ese timestamp puede retroceder; no hay garantía de un cursor
  monotónico para sincronización incremental de ubicación. Se usa el pull completo
  existente y se deja esta discrepancia del contrato señalada para backend.
- Las altas de animales pendientes
  necesitan existir en el servidor antes del traslado. La cola conserva su orden
  de inserción, pero no se agregó un grafo general de dependencias. Un destino o
  animal inexistente se informa como rechazo; no se envían altas de lotes fuera
  del contrato autorizado ni se ocultan errores.
- Los reintentos funcionan con la app ejecutándose. No se incorporó ejecución en
  segundo plano con la app cerrada ni se probó contra un backend real o dispositivo
  físico en esta tarea. Las pruebas usan SQLite real y HTTP simulado.

## Verificación

- Casos de uso: asignación inicial, traslado, selección con distintos orígenes,
  vacíos, duplicados, UUID inválidos y animal con otro movimiento abierto.
- Cubit: cambio de grupo limpia selección, doble pulsación y reintento sin nuevo ID.
- Formulario: selección vacía, confirmación previa, cancelar sin guardar y ausencia
  de destinos activos.
- SQLite/cola: origen null, contrato POST sin responsable, rechazo durable,
  confirmación 201, mismo payload en reintentos, recuperación de jobs faltantes,
  deduplicación y recepción de ubicaciones desde otro dispositivo.
- Historial de eventos: asignación inicial, traslado, estado técnico y cronología.
- Generación mediante `fvm dart run melos run build`, análisis y tests del proyecto.

Resultado de esta corrección: la suite completa pasó con **353 tests** y el
análisis del código funcional afectado no reportó observaciones. El análisis
general todavía informa lints de código previo y migraciones generadas, sin
errores ni warnings. `git diff --check` señala espacios finales emitidos por
Freezed en `animal_detail.freezed.dart`; se conserva la salida del generador sin
editar archivos generados a mano.
