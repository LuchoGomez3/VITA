# Contrato de lotes y movimientos — respuesta de backend a mobile

Fecha: 2026-09-05
Estado: implementado en backend, pendiente de ajuste en mobile
Responde a: [`plan-backend-integracion-gestion-lotes.md`](./plan-backend-integracion-gestion-lotes.md)
Decisiones de fondo: [`adr/adr-0002-geometria-y-movimientos-de-lotes.md`](./adr/adr-0002-geometria-y-movimientos-de-lotes.md)

Backend implementó los dos módulos. Este documento cierra las doce decisiones abiertas de
la sección 15 del plan y lista lo que mobile tiene que ajustar antes de encender los flags.

## 1. Respuesta a las decisiones abiertas

| Tema | Propuesta de mobile | Resolución |
|---|---|---|
| Upsert de lote | `POST /api/v1/lotes` | **Aceptada.** Idempotente por UUID de cliente, LWW por `updated_at`. Devuelve **201 también en el replay**. Existen `PUT` y `DELETE` por paridad con animales, pero no hacen falta. |
| Pull | `GET /api/v1/lotes` con tenant y tombstones | **Aceptado**, más `updated_since` y filtro opcional `estado`. Cursor **inclusivo (`>=`)** y `ORDER BY updated_at`. **Sin paginación**, igual que animales. |
| Borrado | Upsert con `deleted_at` | **Aceptado.** También sirve `DELETE /api/v1/lotes/{id}?deleted_at=&updated_at=`. Los tombstones no se purgan. |
| Conflictos | LWW por `updated_at` | **Aceptado.** **El empate lo gana el servidor**: con timestamps iguales no hay forma de saber cuál es posterior, y conservar lo persistido hace que el resultado no dependa del orden de los reintentos. No hay corrección de relojes desajustados. |
| Geometría V1 | JSON `LocalPolygon` | **Aceptada** como `jsonb`, persistida y devuelta **verbatim**. Validación estricta espejo de la de mobile: `type`, `coordinate_space`, `version`, `extent` 1000×1000, ≥3 vértices distintos, coordenadas en `[0, 1000]`. |
| Geometría futura | GeoJSON WGS84 separado | **Confirmada la convivencia**, sin implementar. Será una columna nullable aparte; la esquemática **no** se reemplaza, queda como fallback. **No se incorpora PostGIS**: las reglas se calculan con `shapely` en CPU. |
| Superficie | Un decimal positivo | **Aceptado y autoritativo**: el backend cuantiza a un decimal al escribir. `> 0` obligatorio. |
| Forraje | Catálogo por código | **Columna con `CHECK`**, no tabla propia todavía. Los seis códigos de mobile se conservan tal cual. |
| Estado | Cuatro códigos actuales | **Cambian a español** (ver §2). |
| Movimiento | POST batch con `animal_ids` | **Aceptado** el contrato externo. Internamente es cabecera + detalle; la API sigue recibiendo y devolviendo `animal_ids` como lista. |
| Responsable | Nullable temporalmente | **Sale del JWT.** El `responsable_id` del cliente se ignora. |
| Errores | Códigos propuestos | **Aceptados casi todos**, con dos agregados y un renombre (ver §4). |

## 2. Cambios que mobile debe hacer

Cinco, todos en el modelo Brick y su store. Hasta que estén, **no encender los flags**.

**a) `LotStatus` a códigos en español.** El backend rechaza cualquier otro valor con
`CHECK`:

| Antes | Ahora |
|---|---|
| `active` | `activo` |
| `resting` | `descanso` |
| `maintenance` | `mantenimiento` |
| `inactive` | `inactivo` |

**b) `geometry_mode` → `modo_geometria`.** El valor sigue siendo `local_schematic`; cambia
solo el nombre del campo:

```dart
@Rest(name: 'modo_geometria') final String geometryMode;
```

**c) `superficie_ha` la redondea el servidor.** Un `52.25` vuelve como `52.3`. El cliente
debe tomar el valor de la respuesta como autoridad, no conservar el local.

**d) Dejar de enviar `responsable_id`.** Se puede seguir mandando `null`; el backend lo
ignora y usa el usuario del JWT.

**e) Mapear los códigos de error de §4** en `lot_brick_store.dart`. Ojo con esto: el
cliente solo reintenta 500-504, así que **todo 4xx es un rechazo definitivo**. Es la
semántica buscada para las reglas de negocio, pero significa que un lote rechazado por
nombre duplicado o superposición necesita intervención del usuario, no un reintento.

## 3. Endpoints

### Lotes — `/api/v1/lotes`

| Método | Ruta | Notas |
|---|---|---|
| `POST` | `/api/v1/lotes` | Upsert idempotente. 201 también en replay |
| `GET` | `/api/v1/lotes` | `establecimiento_id` (req.), `estado`, `updated_since`, `include_deleted` |
| `GET` | `/api/v1/lotes/{id}` | 404 si es de otro tenant (no revela existencia) |
| `PUT` | `/api/v1/lotes/{id}` | LWW. La geometría no es editable |
| `DELETE` | `/api/v1/lotes/{id}` | Soft delete; `deleted_at`/`updated_at` por query param |

Cuerpo del `POST` (el del plan, con los dos renombres aplicados):

```json
{
  "id": "1c1b12e1-243b-44ea-9cf8-57d15fefca02",
  "establecimiento_id": "fe5f93ba-fc82-40b0-9c57-1966fe4b48a4",
  "nombre": "Potrero Bajo",
  "geometria_local": {
    "type": "LocalPolygon",
    "coordinate_space": "establishment_canvas_v1",
    "version": 1,
    "extent": {"width": 1000.0, "height": 1000.0},
    "vertices": [
      {"x": 120.0, "y": 180.0},
      {"x": 620.0, "y": 210.0},
      {"x": 540.0, "y": 700.0}
    ]
  },
  "modo_geometria": "local_schematic",
  "superficie_ha": 45.7,
  "recurso_forrajero_codigo": "alfalfa",
  "tiene_agua": true,
  "estado": "activo",
  "created_at": "2026-08-31T14:20:00Z",
  "updated_at": "2026-08-31T14:20:00Z",
  "deleted_at": null
}
```

La respuesta devuelve **todos** esos campos, `deleted_at` incluido, envueltos en
`StandardResponse`. El listado devuelve `{"data": [...]}` ordenado por `updated_at`.

### Movimientos — `/api/v1/movimientos_lotes`

| Método | Ruta | Notas |
|---|---|---|
| `POST` | `/api/v1/movimientos_lotes` | Batch atómico e idempotente |
| `GET` | `/api/v1/movimientos_lotes` | `establecimiento_id` (req.), `updated_since`, `include_deleted` |

El cuerpo es el del plan §7.4 sin cambios. `lote_origen_id` y `motivo` son **obligatorios**
al escribir y nunca vuelven `null` en la respuesta.

**Qué garantiza el batch:** o se mueven todos los animales y queda registrado el
movimiento, o no se modifica ninguno. Un fallo en cualquier animal revierte todo.

**Qué hace un replay:** devuelve el movimiento persistido **sin volver a mover a nadie**.
El movimiento es un hecho histórico, no un estado que se recalcula. Si el payload trae
`deleted_at`, se propaga el tombstone de la cabecera pero **no** se revierte la ubicación
de los animales: deshacer un traslado es otra operación, que este contrato no modela.

**Efecto colateral buscado:** mover animales actualiza su `updated_at`, así que bajan en el
pull delta de `/api/v1/animales`. Es como los otros dispositivos ven el `lote_id` nuevo.

## 4. Códigos de error

| `code` | HTTP | Cuándo |
|---|---|---|
| `nombre_lote_duplicado` | 409 | Nombre ya usado en el establecimiento (normalizado) |
| `geometria_lote_invalida` | 422 | Formato, versión, área nula o auto-intersección |
| `lotes_superpuestos` | 409 | Intersección con área positiva. `details.lote_id` dice con cuál |
| `lote_con_animales` | 409 | Inactivar o borrar con animales vigentes |
| `lote_no_encontrado` | 404 | UUID inexistente o de otro tenant |
| `lote_destino_no_disponible` | 422 | Destino inexistente, borrado, de otro tenant o no `activo` |
| `lote_origen_no_disponible` | 422 | **Nuevo.** Origen inexistente, borrado o de otro tenant |
| `movimiento_lote_invalido` | 422 | **Nuevo.** Origen igual a destino, lista vacía o IDs repetidos |
| `animales_no_pertenecen_lote_origen` | 422 | `details.animal_ids` lista los que fallaron |
| `establecimiento_no_autorizado` | 403 | Sin membresía activa en el establecimiento |

`conflicto_sincronizacion` **no se implementó**: no hay ningún caso que lo produzca. Los
conflictos se resuelven solos por LWW y los demás rechazos tienen un código específico.

## 5. Orden de sincronización

El backend valida referencias, así que el orden importa:

1. **Lotes** antes que los animales que los referencian.
2. **Lotes y animales** antes que los movimientos.

Un movimiento cuyo lote destino todavía no subió recibe `lote_destino_no_disponible`, que
es un 4xx y por lo tanto un rechazo definitivo en la cola.

## 6. Reglas que el backend aplica al sincronizar

Mobile valida primero para dar feedback inmediato en la manga; estas son las autoritativas.

**Lotes**

- Membresía activa en el establecimiento, verificada en toda lectura y escritura.
- Nombre obligatorio, único por `lower(trim(nombre))` dentro del establecimiento,
  ignorando tombstones. Borrar un lote **libera** su nombre.
- Superficie `> 0`, cuantizada a un decimal.
- Geometría válida y sin superposición de área positiva con otro lote no borrado.
  **Compartir vértice, borde o adyacencia es válido.**
- Los cuatro estados ocupan espacio; solo el tombstone lo libera.
- No se puede pasar a `inactivo` ni borrar un lote con animales vigentes.
  **`descanso` y `mantenimiento` sí se permiten con hacienda dentro**: cortan el ingreso,
  no expulsan.
- La geometría queda bloqueada tras el alta. Un payload que la reenvía la ve **ignorada,
  no rechazada** — un 4xx convertiría un replay legítimo de Brick en un rechazo definitivo.

**Movimientos**

- Origen y destino distintos, existentes, no borrados y del establecimiento.
- Destino en estado `activo`.
- Lista no vacía y sin repetidos.
- Todos los animales vigentes, del establecimiento y **hoy en el lote de origen**.
- Movimiento y actualización de `Animal.lote_id` en la misma transacción.

## 7. Lo que queda pendiente

- **Autorización por rol.** Hoy solo se valida pertenencia al establecimiento, igual que en
  animales. `RolUsuario` quedó en `admin`/`owner`/`employee` tras el PR #45; falta definir
  cuáles de esos pueden mover hacienda.
- **Paginación del pull.** No existe en ningún listado delta. Con decenas de lotes por
  establecimiento no molesta; el historial de movimientos puede crecer.
- **Purga de tombstones.** No hay política todavía.
- **Catálogo de forraje sincronizable.** Hoy es un `CHECK` en la base, no una tabla.
- **Geometría geográfica.** Columna nullable aparte, cuando haya mapa real.
