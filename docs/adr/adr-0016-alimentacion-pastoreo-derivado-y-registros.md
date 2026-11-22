# ADR-0016 — Alimentación: pastoreo derivado y registros de suplementos y dietas

- **Estado:** aceptado
- **Fecha:** 2026-11-14

## Contexto

Hasta ahora no había forma de saber qué comió un animal. El potrero (`lotes`) guardaba un
único `recurso_forrajero_codigo` con 6 opciones y sin fechas: al cambiarlo se perdía lo
que había antes, así que no se podía responder "¿qué había en el potrero cuando este
animal estuvo ahí?". Tampoco existía un registro de suplementos ni de dietas.

En Supabase ya existían las tablas `alimentos`, `planes_alimenticios` y
`planes_alimenticios_items`, sin migración, sin API, con RLS activo sin políticas y con
todos los permisos para `anon`.

El dueño y el empleado necesitan ver, en la ficha del animal, qué comió, dónde y si tuvo
alimentación específica. Como todo en VITA, tiene que funcionar sin señal.

## Decisión

### Recurso del potrero con historial

- Nueva tabla `lotes_recursos_forrajeros`: "desde tal fecha, este potrero tiene tal
  recurso". Es sincronizable (UUID del cliente, LWW por `updated_at`, `deleted_at`).
- **Fin efectivo derivado.** Un período termina el día anterior al siguiente período del
  mismo lote; `fecha_hasta` solo se carga para un corte (el potrero quedó sin recurso).
  - Cambiar el recurso es cargar una sola fila; no hay que cerrar la anterior.
  - No hace falta un `EXCLUDE` para evitar solapamientos.
  - Dos dispositivos offline solo chocan si cargan el mismo lote con la misma fecha de
    inicio: índice único parcial `(lote_id, fecha_desde) where deleted_at is null` y 409
    `periodo_recurso_duplicado`.
- El catálogo se amplía con pasturas, verdeos y rastrojos de la zona (20 códigos).
- La migración convierte el recurso actual de cada lote en un período inicial con id
  determinista `md5('recurso_legacy:' || lote_id)` y `fecha_desde = lotes.created_at`.

### `lotes.recurso_forrajero_codigo` lo mantiene el servidor

- Es el recurso del período más reciente del lote, o null si ese período está cerrado.
  Lo recalcula el service del historial en la misma transacción y toca `updated_at` del
  lote para que baje en el pull delta.
- **Compatibilidad.** La app publicada todavía edita el recurso desde el lote
  (`POST`/`PUT /lotes`). Un recurso distinto del vigente se registra como un período que
  empieza ese día (si ya hay uno ese día, se corrige). Un null no borra nada. Las
  versiones nuevas de la app dejan de mandar el campo, así que nunca pasan por ese camino.

### Pastoreo derivado en el cliente

- El pastoreo no se registra: la app lo calcula cruzando los movimientos del animal
  (`movimientos_lotes`) con el historial de recursos de cada potrero. Funciona offline
  porque todo está en SQLite.
- El historial de movimientos tiene huecos conocidos (`PUT /animales` cambia `lote_id`
  sin generar un movimiento, y el alta tampoco lo genera). Los tramos que se infieren se
  muestran como **Estimado**; los tramos sin período cargado, como "Recurso sin
  registrar". Arreglar los huecos de fondo queda para otro cambio.

### Registros de suplementos y dietas

- Agregado cabecera + detalle, igual que los movimientos: `registros_alimentacion` (tipo,
  alimento, potrero, fechas, cantidad, unidad, base de la cantidad, motivo) y
  `registros_alimentacion_animales`. El UUID de la cabecera es la clave de idempotencia
  de la cola offline aunque el registro abarque N animales.
- El potrero se guarda como hecho, no se deriva del historial de movimientos.
  `fecha_hasta` null significa "en curso".
- **LWW con identidad inmutable.** Un reenvío con el mismo UUID aplica last-write-wins
  sobre lo editable (cerrar una dieta en curso, corregir cantidad, potrero o motivo). Si
  cambia lo que lo identifica (establecimiento, alimento, tipo o el conjunto de animales)
  es un 409 `registro_alimentacion_id_en_conflicto`. Se eligió LWW y no inmutabilidad
  total porque una dieta en curso tiene que poder cerrarse después, también sin señal.
- Se acepta un animal que hoy no está activo: se puede registrar retroactivamente lo que
  comió un animal que después se vendió.

### Catálogo de alimentos

- Se adopta `alimentos`: la migración le suma `created_at`/`updated_at`, `deleted_at`,
  `categoria` y `creado_por_id`. Sus CHECK se agregan `not valid` para no trabar el
  deploy con filas viejas que no se conocen.
- Las filas con `establecimiento_id` null son un catálogo global de solo lectura.
- **Los nombres repetidos se toleran.** Dos dispositivos sin señal pueden dar de alta
  "Maíz partido" a la vez; un 409 por nombre dejaría rechazados también todos los
  registros que lo usan. La app evita el duplicado mostrando coincidencias mientras se
  escribe.
- `costo_unitario` y los valores nutricionales se conservan pero no se exponen.

### Permisos

Cualquier miembro activo del establecimiento crea, corrige y borra (lógicamente), igual
que con lotes y movimientos. El autor o responsable sale siempre del JWT. RLS con el
patrón `_ES_MIEMBRO`; `anon` pierde todos los permisos; sin políticas de delete. El
detalle de un registro es inmutable (solo select e insert).

## Consecuencias

- La pestaña Alimentación de la ficha se arma sin conexión y sin que nadie cargue el
  pastoreo a mano.
- El recurso del potrero deja de editarse desde el lote en la app; pasa a una sección de
  historial en el detalle del potrero.
- Queda fuera de alcance: `planes_alimenticios` y `lotes.plan_alimenticio_id`, costos y
  su vínculo con egresos, KPIs (consumo, conversión, relación con la GPD), cabezas por
  fecha en el potrero, fusionar alimentos duplicados y editar la lista de animales de un
  registro (se borra y se vuelve a crear).
