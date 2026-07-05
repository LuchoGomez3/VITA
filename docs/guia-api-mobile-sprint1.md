# VITA — Guía de API Backend para Mobile (Sprint 1 + Sync offline-first)

Documentación de los endpoints implementados en el **Sprint 1** para consumir desde el
front (Flutter), **más** la guía de cómo conectar la app con **Brick** respetando el
diferenciador del proyecto: la app debe **funcionar sin internet** (todo en SQLite local) y
**sincronizar** con la nube cuando recupera conexión.

| Historia                                                                                     | Módulo              | Endpoints                                                                                  |
| -------------------------------------------------------------------------------------------- | ------------------- | ------------------------------------------------------------------------------------------ |
| [PRO-15](https://linear.app/utn-frc-proyecto-final/issue/PRO-15) — Registrar dueño de campo  | `usuarios` / `auth` | `POST /api/v1/usuarios/registro`, `GET /api/auth/me`                                       |
| [PRO-40](https://linear.app/utn-frc-proyecto-final/issue/PRO-40) — Registrar establecimiento | `establecimientos`  | `POST/GET /api/v1/establecimientos`, `GET /api/v1/establecimientos/{id}`                   |
| [PRO-22](https://linear.app/utn-frc-proyecto-final/issue/PRO-22) — Registrar animal          | `animales`          | `POST/GET /api/v1/animales`, `GET /api/v1/animales/{id}`, `PUT/DELETE /api/v1/animales/{id}` |
| [PRO-14](https://linear.app/utn-frc-proyecto-final/issue/PRO-14) — Documentación SENASA      | `reportes`          | `GET /api/v1/reportes/senasa`                                                              |

> El módulo `animales` ya está preparado para la **sincronización offline-first** (acepta
> UUID/timestamps del cliente, idempotente, last-write-wins, soft delete y pull delta).
> Ver [§ Animales](#pro-22--registrar-animal) y [§ Implementación con Brick](#implementación-en-mobile-con-brick).

---

## Offline-first: el concepto (leer antes que nada)

En offline-first, **el registro nace en el celular sin conexión**. Por eso el **cliente**
(la app) genera el `id` (UUID), el `createdAt` y el `updatedAt`; los guarda en SQLite; y
cuando hay internet, Brick los **reproduce** contra el backend. La nube **toma** esos
valores tal cual — **no los recrea**. Si dos cambios chocan, gana el de `updatedAt` más
nuevo (**last-write-wins**). Los borrados son lógicos (`deletedAt`) para que también
sincronicen.

```
Sin internet:                          Con internet (Brick replay):
┌─────────────┐                         ┌─────────────┐      ┌──────────────┐
│  UI Flutter │                         │ Brick queue │ ───▶ │ Backend API  │
└──────┬──────┘                         │  (SQLite)   │      │ (FastAPI)    │
       ▼                                └─────────────┘      └──────┬───────┘
┌─────────────┐   genera id+timestamps                              ▼
│ Brick local │   guarda local                              ┌──────────────┐
│  (SQLite)   │                                             │  Postgres    │
└─────────────┘                                             │ (Supabase)   │
                                                            └──────────────┘
```

**Reglas que NO se negocian (del [CLAUDE.md](../CLAUDE.md), sección _Sync note_):**

1. **UUID generado en el cliente** como PK. Nunca enteros autoincrementales en tablas sincronizables.
2. Toda entidad sincronizable lleva `createdAt`, `updatedAt` y `deletedAt`.
3. Conflictos: **last-write-wins por `updatedAt`**.
4. Borrado = **soft delete** (set `deletedAt`), nunca DELETE físico.
5. Offline-first no se debilita "para simplificar". Si una feature no anda sin internet, está mal diseñada.

> La excepción es el **registro de usuario** (`POST /api/v1/usuarios/registro`), que sí
> requiere conexión obligatoria.

---

## Convenciones generales

**Base URL:** `http://localhost:8000` en desarrollo (configurable). Todas las rutas cuelgan
de `/api` (los recursos versionados, de `/api/v1`; auth, de `/api/auth`).

### Formato de respuesta — `StandardResponse`

Todas las respuestas de éxito (y los errores de dominio) usan esta envoltura:

```json
{ "success": true, "data": {}, "meta": null, "errors": null }
```

➡️ **Para Brick: el `RestProvider` debe leer el payload desde `data`, no del root.**

### Convención de nombres ⚠️ IMPORTANTE

- **Body JSON (request):** podés enviar las claves en **camelCase**; un middleware las
  convierte a snake_case automáticamente. Ej.: `nroRenspa` → `nro_renspa`,
  `createdAt` → `created_at`. (También se acepta snake_case directo.)
- **Query params (request):** **NO se convierten.** Hay que mandarlos en **snake_case** tal
  cual los define el endpoint (ej.: `establecimiento_id`, `lote_id`, `updated_since`).
- **Respuestas (response):** las claves siempre vienen en **snake_case** (ej.:
  `nro_caravana_rfid`, `created_at`, `deleted_at`).

### Autenticación

- Casi todos los endpoints requieren un **JWT** en el header: `Authorization: Bearer <access_token>`.
- El token se obtiene al registrarse (`POST /api/v1/usuarios/registro`) — ver PRO-15.
- Excepción: `POST /api/v1/usuarios/registro` es **público**.

### Formato de errores (3 formas posibles)

El front debe contemplar las tres:

1. **Error de dominio** (reglas de negocio: duplicados, datos incompletos, sin acceso).
   Status correcto (`409`, `422`, `403`, `404`) + `StandardResponse`:

   ```json
   {
     "success": false,
     "data": null,
     "meta": null,
     "errors": [{ "code": "renspa_duplicado", "message": "El RENSPA '...' ya está registrado" }]
   }
   ```

   Algunos incluyen `details` (ej. reporte SENASA con la lista de animales incompletos).

2. **Error de validación de formato** (campo faltante, email mal escrito, tipo inválido) →
   status `422` con el formato nativo de FastAPI:

   ```json
   { "detail": [{ "loc": ["body", "email"], "msg": "value is not a valid email address", "type": "value_error" }] }
   ```

3. **Error de autenticación** → status `401`:
   ```json
   { "error": "Could not validate credentials", "status": 401 }
   ```

> Regla práctica: si la respuesta trae `errors[]`, leé `errors[0].code` y `errors[0].message`.
> Si trae `detail[]`, es un error de validación de formulario. Si trae `error`, es de auth.

### Campos de sincronización (`SyncFields`)

Las entidades sincronizables aceptan, **además** de sus campos de negocio, estos campos que
**genera el cliente** y el backend respeta. Hoy están implementados en `animales`:

| Campo | Tipo | Notas |
| --- | --- | --- |
| `id` | UUID | PK generada en el cliente |
| `createdAt` | datetime ISO-8601 | momento de creación local |
| `updatedAt` | datetime ISO-8601 | dirime el last-write-wins |
| `deletedAt` | datetime ISO-8601 \| null | soft delete (normalmente null al crear) |

---

## PRO-15 — Registrar dueño de campo

### `POST /api/v1/usuarios/registro` (público)

Crea las credenciales (en el proveedor de identidad) y el perfil del productor. Devuelve el
perfil + token de sesión. **Es la única acción que requiere conexión obligatoria** (excepción
al offline-first).

**Request body:**
| Campo (camelCase) | Tipo | Requerido | Reglas |
| --- | --- | --- | --- |
| `nombre` | string | sí | no vacío |
| `apellido` | string | sí | no vacío |
| `cuit` | string | sí | 11 dígitos + dígito verificador válido (se aceptan guiones, se normalizan) |
| `email` | string | sí | formato email válido, único |
| `password` | string | sí | ≥8 caracteres, al menos un número o una mayúscula |

```bash
curl -X POST http://localhost:8000/api/v1/usuarios/registro \
  -H "Content-Type: application/json" \
  -d '{"nombre":"Juan","apellido":"Pérez","cuit":"20-11111111-2","email":"juan@campo.com","password":"Segura123"}'
```

**Respuesta `201`:**

```json
{
  "success": true,
  "data": {
    "usuario": {
      "id": "3e2ed885-4d82-4b22-94fc-a10b095288e6",
      "nombre": "Juan",
      "apellido": "Pérez",
      "email": "juan@campo.com",
      "cuit": "20111111112",
      "telefono": null
    },
    "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6...",
    "token_type": "bearer"
  }
}
```

Guardá `access_token` y mandalo como `Authorization: Bearer <token>` en el resto de las llamadas.

**Errores:**
| Status | `code` | Cuándo |
| --- | --- | --- |
| `422` | `cuit_invalido` | CUIT con 11 dígitos pero dígito verificador incorrecto |
| `409` | `email_ya_registrado` | El email ya existe |
| `409` | `cuit_ya_registrado` | El CUIT ya existe |
| `422` | _(detail)_ | Falta un campo, email mal formado o password débil |

### `GET /api/auth/me` (Bearer)

Devuelve el perfil del usuario autenticado.

```bash
curl http://localhost:8000/api/auth/me -H "Authorization: Bearer <token>"
```

```json
{
  "success": true,
  "data": { "id": "3e2ed885-...", "nombre": "Juan", "apellido": "Pérez", "email": "juan@campo.com" }
}
```

---

## PRO-40 — Registrar Establecimiento Ganadero

Todos requieren `Authorization: Bearer <token>`.

### `POST /api/v1/establecimientos`

Crea el establecimiento y vincula automáticamente al usuario como `owner` (queda con acceso).

**Request body:**
| Campo | Tipo | Requerido |
| --- | --- | --- |
| `nombre` | string | sí (no vacío) |
| `nroRenspa` | string | sí (no vacío, **único en todo el sistema**) |
| `cuit` | string | no |
| `superficieHa` | number (decimal) | no |
| `provincia` | string | no |
| `departamento` | string | no |
| `localidad` | string | no |

```bash
curl -X POST http://localhost:8000/api/v1/establecimientos \
  -H "Authorization: Bearer <token>" -H "Content-Type: application/json" \
  -d '{"nombre":"Estancia La Vita","nroRenspa":"12.345.6.78901","superficieHa":150.5,"provincia":"Córdoba","departamento":"Río Cuarto","localidad":"Sampacho"}'
```

**Respuesta `201`:**

```json
{
  "success": true,
  "data": {
    "id": "a1b2...",
    "owner_id": "3e2ed885-...",
    "nombre": "Estancia La Vita",
    "nro_renspa": "12.345.6.78901",
    "cuit": null,
    "superficie_ha": "150.50",
    "provincia": "Córdoba",
    "departamento": "Río Cuarto",
    "localidad": "Sampacho",
    "created_at": "2026-06-04T12:00:00Z",
    "updated_at": "2026-06-04T12:00:00Z"
  }
}
```

**Errores:** `422 renspa_vacio` · `409 renspa_duplicado` · `422 (detail)` si falta `nombre`/`nroRenspa`.

### `GET /api/v1/establecimientos`

Lista **solo** los establecimientos a los que el usuario tiene acceso. `data` es un array de
establecimientos (mismo shape que arriba).

### `GET /api/v1/establecimientos/{id}`

Detalle de un establecimiento (incluye auditoría: `owner_id`, `created_at`). Si el `id` no
existe o el usuario no tiene acceso → `404 establecimiento_no_encontrado`.

---

## PRO-22 — Registrar animal

Todos requieren `Authorization: Bearer <token>`. El número de caravana llega como **string ya
resuelto** (Bluetooth/manual/OCR son del lado móvil; el backend es agnóstico al método de
captura).

> Este módulo está **listo para sync offline-first**: acepta los [`SyncFields`](#campos-de-sincronización-syncfields)
> en `POST`/`PUT`, y expone `PUT`/`DELETE`/pull-delta para el replay de Brick. Ver
> [comportamiento de sync](#comportamiento-de-sync-ya-implementado).

### `POST /api/v1/animales`

Da de alta el animal **y registra su pesaje inicial** en la misma operación.

**Request body** — campos de **sincronización** (opcionales; ver [`SyncFields`](#campos-de-sincronización-syncfields))
**+** campos de **negocio**:

| Campo | Tipo | Requerido | Reglas |
| --- | --- | --- | --- |
| `id`, `createdAt`, `updatedAt`, `deletedAt` | ver `SyncFields` | no | el cliente los genera; el backend los respeta |
| `nroCaravanaRfid` | string | sí | exactamente **15 dígitos** (ISO 11784/85), **único global** (SENASA 530/2025) |
| `sexo` | string | sí | `macho` \| `hembra` |
| `raza` | string | sí | no vacío |
| `fechaNacimiento` | string `YYYY-MM-DD` | sí | real o estimada |
| `loteId` | UUID | sí | debe pertenecer al establecimiento |
| `establecimientoId` | UUID | sí | el usuario debe tener acceso |
| `pesoInicial` | number (decimal) | sí | > 0 |
| `metodoPesaje` | string | no (default `manual`) | `manual` \| `balanza_bluetooth` \| `estimacion_ia` |
| `fechaPesaje` | string ISO datetime | no | default: ahora |
| `madreId` / `padreId` | UUID | no | deben ser animales del mismo establecimiento |
| `categoriaId` | UUID | no | categoría global o del propio establecimiento |
| `caravanaVisual`, `pelaje`, `observaciones` | string | no | |

```bash
curl -X POST http://localhost:8000/api/v1/animales \
  -H "Authorization: Bearer <token>" -H "Content-Type: application/json" \
  -d '{"id":"5b1f...uuid","createdAt":"2026-06-22T10:15:00Z","updatedAt":"2026-06-22T10:15:00Z","nroCaravanaRfid":"123456789012345","sexo":"hembra","raza":"Angus","fechaNacimiento":"2024-01-15","loteId":"<lote_uuid>","establecimientoId":"<est_uuid>","pesoInicial":120.5,"metodoPesaje":"manual"}'
```

**Respuesta `201`:** `data` = el animal creado. Incluye `id`, `estado: "activo"`, `created_at`,
`updated_at`, `deleted_at` (null), etc. **Si mandaste `id`/timestamps, vuelven los mismos.**

**Errores:**
| Status | `code` | Cuándo |
| --- | --- | --- |
| `403` | `establecimiento_no_autorizado` | El usuario no tiene acceso al `establecimientoId` |
| `409` | `caravana_duplicada` | Ya existe **otro** animal (distinto `id`) con esa caravana RFID |
| `422` | `lote_no_pertenece_establecimiento` | El `loteId` no es del establecimiento |
| `422` | `referencia_invalida` | `madreId`/`padreId`/`categoriaId` inválido o de otro establecimiento |
| `422` | _(detail)_ | Caravana ≠ 15 dígitos, falta `sexo`, etc. |

### `PUT /api/v1/animales/{id}`

Edita un animal (edición de usuario o replay de `update` de Brick) con **last-write-wins**.
Aplica solo los campos provistos, **solo si** el `updatedAt` entrante es más nuevo que el
guardado (si es más viejo, gana el servidor y no cambia nada).

**Request body** (todos opcionales): `raza`, `fechaNacimiento`, `categoriaId`, `loteId`,
`pelaje`, `observaciones`, `estado` (`activo`|`vendido`|`muerto`|`baja`), más `updatedAt` y
`deletedAt` de [`SyncFields`](#campos-de-sincronización-syncfields).

```bash
curl -X PUT http://localhost:8000/api/v1/animales/<id> \
  -H "Authorization: Bearer <token>" -H "Content-Type: application/json" \
  -d '{"raza":"Hereford","updatedAt":"2026-06-22T11:00:00Z"}'
```

**Errores:** `404 animal_no_encontrado` · `403 establecimiento_no_autorizado` ·
`422 lote_no_pertenece_establecimiento` · `422 referencia_invalida`.

### `DELETE /api/v1/animales/{id}`

**Soft delete**: marca `deletedAt` para que el borrado se propague en el sync (no borra
físicamente). Acepta opcionalmente el timestamp local del cliente por query param
(`deleted_at`, `updated_at`); si no, usa el del servidor.

```bash
curl -X DELETE http://localhost:8000/api/v1/animales/<id> -H "Authorization: Bearer <token>"
```

**Respuesta `200`:** `data` = el animal con `deleted_at` ya seteado. **Errores:** `404 animal_no_encontrado`.

### `GET /api/v1/animales`

Lista los animales de un establecimiento. Sirve para la UI **y** para la **descarga delta**
del sync. **Query params (snake_case):**

| Param | Tipo | Requerido | Notas |
| --- | --- | --- | --- |
| `establecimiento_id` | UUID | sí | |
| `lote_id` | UUID | no | |
| `sexo` | `macho`\|`hembra` | no | |
| `estado` | `activo`\|`vendido`\|`muerto`\|`baja` | no | |
| `updated_since` | ISO datetime | no | **pull delta**: solo lo modificado desde ese instante |
| `include_deleted` | bool | no (def. `false`) | incluye soft-deleted para propagar borrados al cliente |

```bash
# Listado normal de UI
curl "http://localhost:8000/api/v1/animales?establecimiento_id=<est_uuid>&sexo=hembra" \
  -H "Authorization: Bearer <token>"

# Pull delta para sincronizar (incluye borrados, ordenado por updated_at)
curl "http://localhost:8000/api/v1/animales?establecimiento_id=<est_uuid>&updated_since=2026-06-22T00:00:00Z&include_deleted=true" \
  -H "Authorization: Bearer <token>"
```

`data` = array de animales.

### `GET /api/v1/animales/{id}`

Detalle de un animal del establecimiento del usuario. Si no existe o sin acceso →
`404 animal_no_encontrado`. (`madre_id`/`padre_id` permiten navegar la genealogía.)

### Comportamiento de sync (ya implementado)

- **Idempotente**: reenviar el mismo `POST` con el mismo `id` **no duplica** ni falla por
  caravana — el replay de Brick es seguro (no recrea el pesaje inicial).
- **Last-write-wins**: un `PUT`/`POST` con `updatedAt` más viejo que el guardado se ignora;
  más nuevo, se aplica.
- **Soft delete**: `DELETE` setea `deletedAt`. El pull con `include_deleted=true` devuelve los
  borrados para que la app los replique localmente; el listado normal los oculta.
- **Pull delta**: `updated_since=<timestamp>` devuelve solo lo modificado desde la última sync.

---

## PRO-14 — Generar documentación de SENASA

### `GET /api/v1/reportes/senasa` (Bearer)

Genera un reporte exportable en **CSV** o **PDF**. **Devuelve el archivo binario directamente**
(no `StandardResponse`), con header `Content-Disposition: attachment; filename="reporte_senasa.csv|pdf"`.

**Query params (snake_case):**
| Param | Tipo | Requerido | Notas |
| --- | --- | --- | --- |
| `establecimiento_id` | UUID | sí | el usuario debe tener acceso |
| `formato` | `csv` \| `pdf` | no (default `csv`) | |
| `desde` / `hasta` | ISO datetime | no | rango de fechas |
| `lote_id` | UUID | no | filtra por lote |
| `tipo_evento` | string | no | `vacunacion`, `egreso`, `ingreso`, `movimiento` |
| `incluir_responsable` | bool | no | solo PDF: incluye pie con responsable |
| `responsable_nombre` | string | no | |
| `responsable_dni` | string | no | |

```bash
curl "http://localhost:8000/api/v1/reportes/senasa?establecimiento_id=<est_uuid>&formato=pdf&incluir_responsable=true&responsable_nombre=Juan%20Perez&responsable_dni=30111222" \
  -H "Authorization: Bearer <token>" -o reporte_senasa.pdf
```

**Columnas del reporte:** RENSPA del establecimiento · Identificador del animal (caravana RFID
15 dígitos) · Fecha/Hora · Tipo de evento.

**Validación previa (importante para el front):** si hay animales sin RFID de 15 dígitos o sin
categoría, **no se genera el archivo** y se responde `422`:

```json
{
  "success": false,
  "errors": [
    {
      "code": "datos_incompletos_para_reporte",
      "message": "Hay animales con datos incompletos ...",
      "details": {
        "animales_incompletos": [
          { "animal_id": "...", "caravana": "123", "faltante": ["nro_caravana_rfid", "categoria_id"] }
        ]
      }
    }
  ]
}
```

El front debería mostrar esa lista para que el usuario complete los datos antes de reintentar.

**Otros errores:** `403 establecimiento_no_autorizado`.

> **Notas / pendientes (confirmar con PO):**
>
> - **CUIG:** la historia menciona el "CUIG de cada animal", distinto del RFID. El modelo
>   todavía no lo tiene; por ahora el identificador del reporte usa el **RFID**.
> - **"Cambio de categoría":** aún no se modela el historial de categorías, por lo que ese tipo
>   de evento no aparece todavía en el reporte. Los eventos disponibles son vacunación, egreso e
>   ingreso/movimiento de lote.

---

## Implementación en mobile con Brick

### ⚠️ El modelo mobile actual está desalineado — hay que corregirlo

El scaffolding actual en [`mobile/lib/brick/models/animal.model.dart`](../mobile/lib/brick/models/animal.model.dart)
y la entidad [`Animal`](../mobile/lib/features/animal_register/domain/entities/animal.dart)
**no coinciden con el contrato del backend**. Antes de conectar Brick hay que ajustarlos:

| Campo actual (mobile) | Problema | Debe ser |
| --- | --- | --- |
| _(no existe)_ | falta la identidad de sync | **`id`** `String` (UUID generado en cliente) |
| _(no existe)_ | faltan timestamps de sync | **`createdAt`**, **`updatedAt`**, **`deletedAt`** (`DateTime?`) |
| `int nroCaravana` | el RFID es un **string de 15 dígitos** (ISO 11784/85), no un int | `String nroCaravanaRfid` |
| `int? idLote` | el backend usa UUID | `String loteId` (UUID, **requerido**) |
| `int? caravanaPadre/Madre` | el backend referencia por **UUID del animal**, no por caravana | `String? madreId`, `String? padreId` (UUID) |
| _(no existe)_ | falta el tenant | **`establecimientoId`** `String` (UUID, requerido) |
| `DateTime? syncedAt` | Brick maneja el estado de sync solo | eliminar (lo gestiona Brick) |

Faltan además, para el alta: `pesoInicial`, `metodoPesaje`, `categoriaId?`, `caravanaVisual?`.

### Paso 1 — Dependencias

Brick **no está instalado todavía**. Agregar a [`mobile/pubspec.yaml`](../mobile/pubspec.yaml):

```yaml
dependencies:
  brick_offline_first_with_rest: ^<latest>
  brick_rest: ^<latest>
  brick_sqlite: ^<latest>
  sqflite: ^<latest>
  connectivity_plus: ^<latest>   # detectar online/offline

dev_dependencies:
  brick_offline_first_with_rest_build: ^<latest>
  brick_sqlite_generators: ^<latest>
  build_runner: ^2.5.4           # ya está
```

> Verificá las últimas versiones compatibles con Flutter `3.44.0` / Dart `^3.11.0` en pub.dev
> antes de fijarlas.

### Paso 2 — Anotar el modelo

Convertir `BrickAnimalModel` en un modelo Brick con la conexión REST y los campos de sync. El
`id` (UUID) y los timestamps son obligatorios; las rutas REST mapean a los endpoints de
`animales`:

| Operación Brick | Método HTTP | Ruta |
| --- | --- | --- |
| crear | `POST` | `/api/v1/animales` |
| actualizar | `PUT` | `/api/v1/animales/{id}` |
| borrar (soft) | `DELETE` | `/api/v1/animales/{id}` |
| pull (descarga delta) | `GET` | `/api/v1/animales?establecimiento_id=...&updated_since=...&include_deleted=true` |

### Paso 3 — Repositorio offline-first

Reemplazar el stub en memoria de [`mobile/lib/brick/repository.dart`](../mobile/lib/brick/repository.dart)
(hoy guarda en una `List` que se pierde al cerrar la app) por uno que extienda
`OfflineFirstWithRestRepository`, configurando:

- `RestProvider` → base URL del backend + extracción del campo `data`.
- `SqliteProvider` → base local.
- La cola offline (la maneja Brick) + reintentos al volver la conexión.

### Paso 4 — Conectar la feature

Ya existe el flujo de UI completo de "registrar animal"
([`features/animal_register/`](../mobile/lib/features/animal_register/)). Hay que:

- Ajustar la entidad `Animal` y el `AnimalBrickMapper` a los nuevos campos.
- Inyectar **una única instancia** del repositorio Brick (hoy el Cubit crea una nueva por vez
  en [`registrar_animal_cubit.dart`](../mobile/lib/features/animal_register/presentation/bloc/registrar_animal_cubit.dart),
  lo que perdería datos). Considerar `get_it` o un provider global.

### Paso 5 — Manejo de errores (no opcional)

El proyecto corre en el campo, sin posibilidad de debuggear. Ya están definidos
`DomainErrorCode.offline` y `DomainErrorCode.syncFailed` en
[`core/errors/domain_exception.dart`](../mobile/lib/core/errors/domain_exception.dart) —
usarlos para surfacear mensajes claros al productor. Nada de `try/catch` vacíos.

### Checklist de "Done" (offline-first)

- [ ] El modelo Brick tiene `id` (UUID cliente), `createdAt`, `updatedAt`, `deletedAt`.
- [ ] Crear un animal **en modo avión** lo guarda en SQLite y la UI lo muestra.
- [ ] Al recuperar conexión, el animal aparece en el backend con **el mismo `id`** y timestamps.
- [ ] Reabrir la app **no pierde** los datos locales (persistencia real, no memoria).
- [ ] Editar offline y sincronizar respeta last-write-wins.
- [ ] Borrar marca `deletedAt` y se propaga (no reaparece tras el pull).
- [ ] Los errores de sync se muestran al usuario, no se tragan.
- [ ] Tests del flujo (incluido el escenario offline).

---

## Cómo levantar el backend en local

```bash
cd backend
uv venv && source .venv/bin/activate
uv sync
cp env.example .env   # AUTH_PROVIDER=local por defecto en dev (no requiere Supabase)
python main.py        # http://localhost:8000
```

Docs interactivas (Swagger): `http://localhost:8000/docs`.

> En desarrollo, `AUTH_PROVIDER=local` emite y valida tokens localmente (sin Supabase), así el
> front puede registrarse y probar sin infraestructura externa.

### Smoke test del contrato de sync

Con un JWT válido, simulando el replay de Brick:

```bash
# Alta con id/timestamps propios → la respuesta debe devolver EL MISMO id
curl -X POST http://localhost:8000/api/v1/animales \
  -H "Authorization: Bearer <jwt>" -H "Content-Type: application/json" \
  -d '{"id":"<uuid>","createdAt":"2026-06-22T10:00:00Z","updatedAt":"2026-06-22T10:00:00Z","nroCaravanaRfid":"123456789012345","sexo":"hembra","raza":"Angus","fechaNacimiento":"2024-01-15","loteId":"<uuid-lote>","establecimientoId":"<uuid-est>","pesoInicial":"120.5"}'

# Reenviar el MISMO POST → idempotente (no duplica, no error)
# Pull delta (incluye borrados)
curl "http://localhost:8000/api/v1/animales?establecimiento_id=<uuid-est>&updated_since=2026-06-22T00:00:00Z&include_deleted=true" \
  -H "Authorization: Bearer <jwt>"
```

---

## Referencias en el repo

- Contrato backend: [`backend/api/modules/animales/`](../backend/api/modules/animales/) (`schemas.py`, `service.py`, `router.py`).
- Campos de sync compartidos: `SyncFields` en [`backend/api/shared/schemas.py`](../backend/api/shared/schemas.py).
- Tests del comportamiento de sync (idempotencia, LWW, soft delete, delta): [`backend/tests/test_animales.py`](../backend/tests/test_animales.py).
- Convenciones del proyecto: [`CLAUDE.md`](../CLAUDE.md) (sección _Sync note_) y [`mobile/README.MD`](../mobile/README.MD).

> **Pendiente backend** (no bloquea el arranque de Brick en `animales`): replicar el patrón
> `SyncFields` + last-write-wins en `pesajes`, `eventos_sanitarios`, `movimientos` y `lotes`
> cuando esas entidades se sincronicen.
</content>
