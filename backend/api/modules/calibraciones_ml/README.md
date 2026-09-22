# Módulo `calibraciones_ml`

Recepción del **dataset de calibración** del modelo de estimación de peso por
visión (VITA-141 / VITA-156): pares *foto lateral + peso real de balanza* que se
capturan en campo y se usan para entrenar y reentrenar el `.tflite` que corre
on-device.

Una muestra **no es un pesaje**. `pesajes` es el registro productivo del animal y
alimenta la GPD; una muestra de calibración es dato de entrenamiento y no debe
afectar ninguna métrica del rodeo. De ahí la tabla propia en vez de reusar
`pesajes.foto_url`.

## Por qué el alta va en dos requests

El ticket pedía un único `POST multipart/form-data`. No se puede: la cola offline
del cliente (Brick, `brick_offline_first_with_rest`) solo persiste y reproduce
requests de **texto** — la columna del body de su SQLite es `TEXT` y
`RestOfflineQueueClient` hace

```dart
if (request is! http.Request) { return await _inner.send(request); }
```

o sea que un `MultipartRequest` **esquiva la cola**: sin señal no se encola ni se
reintenta, se pierde. Eso rompe el criterio de aceptación *"la muestra sigue
disponible en el móvil durante una interrupción de red"*.

La solución es partir el alta:

| Paso | Endpoint | Quién reintenta |
|---|---|---|
| 1. Metadata | `POST /api/v1/calibraciones_ml` (JSON) | la cola de Brick, gratis, idempotente por UUID |
| 2. Imagen | `POST /api/v1/calibraciones_ml/{id}/imagen` (multipart) | uploader propio del cliente |

Entre los dos pasos la muestra existe en `estado = pendiente_imagen`: está
registrada pero todavía no entrena, y la exportación la saltea. Ese hueco es
visible a propósito, para que el móvil sepa qué le falta subir.

> **Nota para el front (VITA-154/155):** el paso 2 **no** puede ir por la cola de
> Brick. Necesita su propio mecanismo de reintento sobre la foto guardada en
> disco. Además, `AuthenticatedBackendClient._syncRequestFrom` solo emite
> `BackendSyncResult` para un `POST` con `id` en un body JSON, así que el estado
> local de la imagen se maneja aparte del de la metadata.

## Endpoints

| Método | Ruta | Notas |
|---|---|---|
| `POST` | `/api/v1/calibraciones_ml` | Alta idempotente (UUID de cliente + LWW por `updated_at`). |
| `POST` | `/api/v1/calibraciones_ml/{id}/imagen` | `multipart/form-data`, campo `imagen`. |
| `GET` | `/api/v1/calibraciones_ml` | `establecimiento_id` (obligatorio), `animal_id`, `updated_since`, `include_deleted`. |
| `GET` | `/api/v1/calibraciones_ml/{id}` | Detalle. Cross-tenant devuelve **404**, no 403. |
| `PUT` | `/api/v1/calibraciones_ml/{id}` | Corrección con LWW. El cliente solo puede llevar `estado` a `descartada`. |
| `DELETE` | `/api/v1/calibraciones_ml/{id}` | Soft delete (`deleted_at`), para que el borrado sincronice. |

Todo responde `StandardResponse`. Toda operación exige membresía activa en el
establecimiento (`UsuarioEstablecimientoRepository.get_membership`) **antes** de
tocar la base o Storage.

## La imagen

- Bucket **privado** `calibraciones-ml`; clave `{establecimiento_id}/{muestra_id}.jpg`.
- Se persiste la **clave**, nunca una URL: una pública expondría la foto y una
  firmada vence, y el registro tiene que seguir resolviendo la imagen dentro de
  meses, cuando se reentrene.
- La clave se deriva del UUID de la muestra, así que **reenviar la foto pisa el
  mismo objeto**: es lo que vuelve idempotente el reintento.
- El backend valida magic bytes + decodificabilidad real (Pillow) y
  **recomprime** a `CALIBRACION_IMAGEN_LADO_MAX` px de lado mayor. Sin eso, el
  plan free de Supabase (1 GB) se llena con ~230 fotos de celular sin tocar; con
  recompresión entran ~3000. El modelo entrena a 224-380 px, así que no se pierde
  nada útil.
- El re-encode **descarta el EXIF**, y es deseable: la foto de campo trae el GPS
  del establecimiento, que es dato identificable del productor.

### Fallos parciales

Storage y Postgres no comparten transacción. El orden del paso 2 es:

1. Validar y recomprimir en memoria → nada inválido llega a Storage.
2. Subir. Si falla, **la base no se toca**: la muestra sigue `pendiente_imagen` y
   la API devuelve `502 subida_de_imagen_fallida` (un 5xx, que la cola del cliente
   sí reintenta, a diferencia de un 4xx).
3. Persistir la clave **y cerrar la transacción con un `commit` explícito**. Este
   módulo es el único que commitea dentro del service: el commit de
   `get_session` ocurre *después* de que el método retorne, y si fallara ahí ya no
   habría forma de borrar el objeto. Si la persistencia falla, se compensa
   borrando el objeto recién subido.

Si la compensación también falla, queda un objeto huérfano: se loguea con su
clave (`[CALIBRACION] Objeto huerfano en Storage`) para poder limpiarlo a mano y
se propaga el error original. Los logs nunca incluyen bytes, tokens ni el body.

## Exportación para entrenamiento

```bash
uv run python scripts/exportar_dataset_calibracion.py \
    --establecimiento-id <uuid> --salida ./dataset_calibracion
```

Produce `imagenes/*.jpg` + `dataset.csv` con
`ruta_local,peso_real_kg,animal_id,split`. El pipeline de visión lee archivos
locales, no claves de Storage.

Es un script y no un endpoint porque el dataset son cientos de MB y el plan free
tiene 5 GB de egress/mes: por HTTP se pagarían dos veces (Storage → backend →
cliente) y una sola exportación podría consumir el mes.

- `--establecimiento-id` es **obligatorio y único**: hace estructuralmente
  imposible que un CSV mezcle tenants.
- La columna `split` se asigna con SHA-256 **del `animal_id`** (70/15/15), así
  todas las fotos de un mismo animal caen siempre en el mismo conjunto. Si se
  partieran, el modelo vería en validación un animal que ya memorizó en
  entrenamiento y la métrica saldría optimista. Se usa SHA-256 y no `hash()`
  porque el de strings está aleatorizado por proceso y el corte cambiaría entre
  corridas.
- Elegir *qué* fotos laterales son útiles sigue fuera de alcance: es preparación
  del dataset, no recepción.

## Dependencia externa: crear el bucket

No se crea por migración (decisión del ticket: el bucket y sus credenciales viven
fuera del repo). A mano, una vez por entorno:

1. Supabase Dashboard → **Storage** → **New bucket**
2. Nombre: `calibraciones-ml`
3. **"Public bucket" DESACTIVADO.**

Verificar:

```sql
select id, public from storage.buckets where id = 'calibraciones-ml';
-- public debe ser false
```

**No agregar policies de Storage.** El backend entra con la `service_role` key,
que las bypassea, y no hay ningún otro cliente que deba leer el bucket: una
policy permisiva solo abriría las fotos de todos los establecimientos.

## Variables de entorno

Documentadas en `backend/.env.example`:
`SUPABASE_STORAGE_BUCKET_CALIBRACIONES`, `CALIBRACION_IMAGEN_MAX_BYTES`,
`CALIBRACION_IMAGEN_LADO_MAX`, `CALIBRACION_IMAGEN_CALIDAD`.

## Tests

`backend/tests/test_calibraciones_ml.py` — 98% del módulo (el umbral de módulo
crítico es 85%). Ninguno toca la red: `get_storage_calibraciones` se sobreescribe
por un `FakeStorage` en memoria que registra subidas/borrados y puede fallar a
pedido, que es lo que hace verificables la idempotencia y la compensación.
