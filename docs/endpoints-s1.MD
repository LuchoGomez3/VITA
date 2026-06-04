# VITA — API Backend (Guía para Frontend)

Documentación de los endpoints implementados en el **Sprint 1** para consumir desde el front (Flutter).

| Historia                                                                                     | Módulo              | Endpoints                                                                |
| -------------------------------------------------------------------------------------------- | ------------------- | ------------------------------------------------------------------------ |
| [PRO-15](https://linear.app/utn-frc-proyecto-final/issue/PRO-15) — Registrar dueño de campo  | `usuarios` / `auth` | `POST /api/v1/usuarios/registro`, `GET /api/auth/me`                     |
| [PRO-40](https://linear.app/utn-frc-proyecto-final/issue/PRO-40) — Registrar establecimiento | `establecimientos`  | `POST/GET /api/v1/establecimientos`, `GET /api/v1/establecimientos/{id}` |
| [PRO-22](https://linear.app/utn-frc-proyecto-final/issue/PRO-22) — Registrar animal          | `animales`          | `POST/GET /api/v1/animales`, `GET /api/v1/animales/{id}`                 |
| [PRO-14](https://linear.app/utn-frc-proyecto-final/issue/PRO-14) — Documentación SENASA      | `reportes`          | `GET /api/v1/reportes/senasa`                                            |

---

## Convenciones generales (leer primero)

**Base URL:** `http://localhost:8000` en desarrollo (configurable). Todas las rutas cuelgan de `/api`.

### Formato de respuesta — `StandardResponse`

Todas las respuestas de éxito (y los errores de dominio) usan esta envoltura:

```json
{
  "success": true,
  "data": {},
  "meta": null,
  "errors": null
}
```

### Convención de nombres ⚠️ IMPORTANTE

- **Body JSON (request):** podés enviar las claves en **camelCase**; un middleware las convierte a snake_case automáticamente. Ej.: `nroRenspa` → `nro_renspa`. (También se acepta snake_case directo.)
- **Query params (request):** **NO se convierten.** Hay que mandarlos en **snake_case** tal cual los define el endpoint (ej.: `establecimiento_id`, `lote_id`, `tipo_evento`).
- **Respuestas (response):** las claves siempre vienen en **snake_case** (ej.: `nro_caravana_rfid`, `created_at`).

### Autenticación

- Casi todos los endpoints requieren un **JWT** en el header: `Authorization: Bearer <access_token>`.
- El token se obtiene al registrarse (`POST /api/v1/usuarios/registro`) — ver PRO-15.
- Excepción: `POST /api/v1/usuarios/registro` es **público**.

### Formato de errores (3 formas posibles)

El front debe contemplar las tres:

1. **Error de dominio** (reglas de negocio: duplicados, datos incompletos, sin acceso). Status correcto (`409`, `422`, `403`, `404`) + `StandardResponse`:

   ```json
   {
     "success": false,
     "data": null,
     "meta": null,
     "errors": [
       {
         "code": "renspa_duplicado",
         "message": "El RENSPA '...' ya está registrado"
       }
     ]
   }
   ```

   Algunos incluyen `details` (ej. reporte SENASA con la lista de animales incompletos).

2. **Error de validación de formato** (campo faltante, email mal escrito, tipo inválido) → status `422` con el formato nativo de FastAPI:

   ```json
   {
     "detail": [
       {
         "loc": ["body", "email"],
         "msg": "value is not a valid email address",
         "type": "value_error"
       }
     ]
   }
   ```

3. **Error de autenticación** → status `401`:
   ```json
   { "error": "Could not validate credentials", "status": 401 }
   ```

> Regla práctica para el front: si la respuesta trae `errors[]`, leé `errors[0].code` y `errors[0].message`. Si trae `detail[]`, es un error de validación de formulario. Si trae `error`, es de auth.

---

## PRO-15 — Registrar dueño de campo

### `POST /api/v1/usuarios/registro` (público)

Crea las credenciales (en el proveedor de identidad) y el perfil del productor. Devuelve el perfil + token de sesión. **Es la única acción que requiere conexión obligatoria** (excepción al offline-first).

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
  "data": {
    "id": "3e2ed885-...",
    "nombre": "Juan",
    "apellido": "Pérez",
    "email": "juan@campo.com"
  }
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

Lista **solo** los establecimientos a los que el usuario tiene acceso. `data` es un array de establecimientos (mismo shape que arriba).

### `GET /api/v1/establecimientos/{id}`

Detalle de un establecimiento (incluye auditoría: `owner_id`, `created_at`). Si el `id` no existe o el usuario no tiene acceso → `404 establecimiento_no_encontrado`.

---

## PRO-22 — Registrar animal

Todos requieren `Authorization: Bearer <token>`. El número de caravana llega como **string ya resuelto** (Bluetooth/manual/OCR son del lado móvil; el backend es agnóstico al método de captura).

### `POST /api/v1/animales`

Da de alta el animal **y registra su pesaje inicial** en la misma operación.

**Request body:**
| Campo | Tipo | Requerido | Reglas |
| --- | --- | --- | --- |
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
  -d '{"nroCaravanaRfid":"123456789012345","sexo":"hembra","raza":"Angus","fechaNacimiento":"2024-01-15","loteId":"<lote_uuid>","establecimientoId":"<est_uuid>","pesoInicial":120.5,"metodoPesaje":"manual"}'
```

**Respuesta `201`:** `data` = el animal creado (incluye `estado: "activo"`, `created_at`, etc.).

**Errores:**
| Status | `code` | Cuándo |
| --- | --- | --- |
| `403` | `establecimiento_no_autorizado` | El usuario no tiene acceso al `establecimientoId` |
| `409` | `caravana_duplicada` | Ya existe un animal con esa caravana RFID |
| `422` | `lote_no_pertenece_establecimiento` | El `loteId` no es del establecimiento |
| `422` | `referencia_invalida` | `madreId`/`padreId`/`categoriaId` inválido o de otro establecimiento |
| `422` | _(detail)_ | Caravana ≠ 15 dígitos, falta `sexo`, etc. |

### `GET /api/v1/animales`

Lista los animales de un establecimiento. **Query params (snake_case):**

- `establecimiento_id` (UUID, **requerido**)
- `lote_id` (UUID, opcional)
- `sexo` (`macho`|`hembra`, opcional)
- `estado` (`activo`|`vendido`|`muerto`|`baja`, opcional)

```bash
curl "http://localhost:8000/api/v1/animales?establecimiento_id=<est_uuid>&sexo=hembra" \
  -H "Authorization: Bearer <token>"
```

`data` = array de animales.

### `GET /api/v1/animales/{id}`

Detalle de un animal del establecimiento del usuario. Si no existe o sin acceso → `404 animal_no_encontrado`. (`madre_id`/`padre_id` permiten navegar la genealogía.)

---

## PRO-14 — Generar documentación de SENASA

### `GET /api/v1/reportes/senasa` (Bearer)

Genera un reporte exportable en **CSV** o **PDF**. **Devuelve el archivo binario directamente** (no `StandardResponse`), con header `Content-Disposition: attachment; filename="reporte_senasa.csv|pdf"`.

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

**Columnas del reporte:** RENSPA del establecimiento · Identificador del animal (caravana RFID 15 dígitos) · Fecha/Hora · Tipo de evento.

**Validación previa (importante para el front):** si hay animales sin RFID de 15 dígitos o sin categoría, **no se genera el archivo** y se responde `422`:

```json
{
  "success": false,
  "errors": [
    {
      "code": "datos_incompletos_para_reporte",
      "message": "Hay animales con datos incompletos ...",
      "details": {
        "animales_incompletos": [
          {
            "animal_id": "...",
            "caravana": "123",
            "faltante": ["nro_caravana_rfid", "categoria_id"]
          }
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
> - **CUIG:** la historia menciona el "CUIG de cada animal", distinto del RFID. El modelo todavía no lo tiene; por ahora el identificador del reporte usa el **RFID**.
> - **"Cambio de categoría":** aún no se modela el historial de categorías, por lo que ese tipo de evento no aparece todavía en el reporte. Los eventos disponibles son vacunación, egreso e ingreso/movimiento de lote.

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

> En desarrollo, `AUTH_PROVIDER=local` emite y valida tokens localmente (sin Supabase), así el front puede registrarse y probar sin infraestructura externa.
