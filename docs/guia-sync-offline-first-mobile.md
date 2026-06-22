# Guía: Sincronización offline-first en mobile (Brick ↔ Backend)

> **Para quién es esto**: desarrollo mobile (Flutter). Es la guía para conectar la app
> con el backend usando **Brick**, respetando el diferenciador del proyecto: la app debe
> **funcionar sin internet** (guardar todo en SQLite local) y **sincronizar** con la nube
> cuando recupera conexión.
>
> **Estado del backend**: ✅ ya está preparado para recibir la sincronización (módulo
> `animales`). Esta guía documenta el contrato y cómo consumirlo desde Brick.

---

## 1. El concepto en una frase

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

---

## 2. Reglas que NO se negocian (del CLAUDE.md)

1. **UUID generado en el cliente** como PK. Nunca enteros autoincrementales en tablas
   sincronizables.
2. Toda entidad sincronizable lleva `createdAt`, `updatedAt` y `deletedAt`.
3. Conflictos: **last-write-wins por `updatedAt`**.
4. Borrado = **soft delete** (set `deletedAt`), nunca DELETE físico.
5. Offline-first no se debilita "para simplificar". Si una feature no anda sin internet,
   está mal diseñada.

---

## 3. ⚠️ El modelo mobile actual está desalineado — hay que corregirlo

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

> El `syncedAt` actual no se usa para nada (ver el mapper) — Brick lleva su propia cola de
> pendientes, así que no hace falta un flag manual.

---

## 4. El contrato del backend (módulo `animales`)

Base URL: `/api/v1`. Todas las rutas requieren JWT (header `Authorization: Bearer <token>`).

### 4.1 Forma de la respuesta

**Todas** las respuestas vienen envueltas en `StandardResponse`:

```json
{ "success": true, "data": { ... }, "meta": null, "errors": null }
```

➡️ **El `RestProvider` de Brick debe leer el payload desde `data`, no del root.** En error:

```json
{ "success": false, "data": null, "errors": [{ "code": "caravana_duplicada", "message": "..." }] }
```

### 4.2 Endpoints

| Operación Brick | Método HTTP | Ruta |
| --- | --- | --- |
| crear | `POST` | `/api/v1/animales` |
| actualizar | `PUT` | `/api/v1/animales/{id}` |
| borrar (soft) | `DELETE` | `/api/v1/animales/{id}` |
| pull (descarga delta) | `GET` | `/api/v1/animales?establecimiento_id=...&updated_since=...&include_deleted=true` |

### 4.3 Campos del alta (`POST /api/v1/animales`)

Campos de **sincronización** (los genera el cliente; el backend los respeta):

| Campo | Tipo | Notas |
| --- | --- | --- |
| `id` | UUID | PK generada en el cliente |
| `createdAt` | datetime ISO-8601 | momento del alta local |
| `updatedAt` | datetime ISO-8601 | dirime el last-write-wins |
| `deletedAt` | datetime ISO-8601 \| null | normalmente null al crear |

Campos de **negocio**:

| Campo | Tipo | Requerido | Valores / notas |
| --- | --- | --- | --- |
| `nroCaravanaRfid` | string | sí | exactamente **15 dígitos** |
| `sexo` | enum | sí | `macho` \| `hembra` |
| `raza` | string | sí | no vacío |
| `fechaNacimiento` | date `YYYY-MM-DD` | sí | |
| `loteId` | UUID | sí | debe pertenecer al establecimiento |
| `establecimientoId` | UUID | sí | tenant |
| `madreId` / `padreId` | UUID | no | animal del mismo establecimiento |
| `categoriaId` | UUID | no | |
| `caravanaVisual` | string | no | |
| `pelaje` | string | no | |
| `observaciones` | string | no | |
| `pesoInicial` | decimal | sí | > 0 (alta crea el pesaje inicial) |
| `metodoPesaje` | enum | no (def. `manual`) | `manual` \| `balanza_bluetooth` \| `estimacion_ia` |
| `fechaPesaje` | datetime | no | |

> 📌 Podés mandar **camelCase** (`createdAt`, `nroCaravanaRfid`): un middleware del backend
> lo convierte a snake_case automáticamente. La respuesta vuelve en **snake_case**.

### 4.4 Ejemplo de POST

```jsonc
// POST /api/v1/animales
{
  "id": "5b1f...uuid",
  "createdAt": "2026-06-22T10:15:00Z",
  "updatedAt": "2026-06-22T10:15:00Z",
  "nroCaravanaRfid": "123456789012345",
  "sexo": "hembra",
  "raza": "Angus",
  "fechaNacimiento": "2024-01-15",
  "loteId": "9a2c...uuid",
  "establecimientoId": "7f0d...uuid",
  "pesoInicial": "120.500",
  "metodoPesaje": "manual"
}
```

### 4.5 Comportamiento clave del backend (ya implementado)

- **Idempotente**: reenviar el mismo `POST` con el mismo `id` **no duplica** ni falla por
  caravana — el replay de Brick es seguro.
- **Last-write-wins**: un `PUT`/`POST` con `updatedAt` más viejo que el guardado se ignora;
  más nuevo, se aplica.
- **Soft delete**: `DELETE` setea `deletedAt`. El pull con `include_deleted=true` devuelve
  los borrados para que la app los replique localmente; el listado normal los oculta.
- **Pull delta**: `updated_since=<timestamp>` devuelve solo lo modificado desde la última
  sync (ordenado por `updatedAt`).

---

## 5. Pasos de implementación en mobile

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

> Verificá las últimas versiones compatibles con Flutter `3.44.0` / Dart `^3.11.0` en
> pub.dev antes de fijarlas.

### Paso 2 — Anotar el modelo

Convertir `BrickAnimalModel` en un modelo Brick con la conexión REST y los campos de sync
(ver §3 y §4.3). El `id` (UUID) y los timestamps son obligatorios; las rutas REST mapean a
los endpoints de §4.2.

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
- Inyectar **una única instancia** del repositorio Brick (hoy el Cubit crea una nueva por
  vez en [`registrar_animal_cubit.dart`](../mobile/lib/features/animal_register/presentation/bloc/registrar_animal_cubit.dart),
  lo que perdería datos). Considerar `get_it` o un provider global.

### Paso 5 — Manejo de errores (no opcional)

El proyecto corre en el campo, sin posibilidad de debuggear. Ya están definidos
`DomainErrorCode.offline` y `DomainErrorCode.syncFailed` en
[`core/errors/domain_exception.dart`](../mobile/lib/core/errors/domain_exception.dart) —
usarlos para surfacear mensajes claros al productor. Nada de `try/catch` vacíos.

---

## 6. Checklist de "Done" (offline-first)

- [ ] El modelo Brick tiene `id` (UUID cliente), `createdAt`, `updatedAt`, `deletedAt`.
- [ ] Crear un animal **en modo avión** lo guarda en SQLite y la UI lo muestra.
- [ ] Al recuperar conexión, el animal aparece en el backend con **el mismo `id`** y timestamps.
- [ ] Reabrir la app **no pierde** los datos locales (persistencia real, no memoria).
- [ ] Editar offline y sincronizar respeta last-write-wins.
- [ ] Borrar marca `deletedAt` y se propaga (no reaparece tras el pull).
- [ ] Los errores de sync se muestran al usuario, no se tragan.
- [ ] Tests del flujo (incluido el escenario offline).

---

## 7. Probar contra el backend localmente

```bash
# Backend
cd backend
uv venv && source .venv/bin/activate && uv sync
python main.py            # levanta en http://localhost:8000 (/api/v1)
```

Smoke test del contrato (con un JWT válido), simulando el replay de Brick:

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

## 8. Referencias en el repo

- Contrato backend: [`backend/api/modules/animales/`](../backend/api/modules/animales/)
  (`schemas.py`, `service.py`, `router.py`).
- Campos de sync compartidos: `SyncFields` en [`backend/api/shared/schemas.py`](../backend/api/shared/schemas.py).
- Tests del comportamiento de sync (idempotencia, LWW, soft delete, delta):
  [`backend/tests/test_animales.py`](../backend/tests/test_animales.py).
- Convenciones del proyecto: [`CLAUDE.md`](../CLAUDE.md) (sección _Sync note_) y
  [`mobile/README.MD`](../mobile/README.MD).

> **Pendiente backend** (no bloquea el arranque de Brick en `animales`): replicar el patrón
> `SyncFields` + last-write-wins en `pesajes`, `eventos_sanitarios`, `movimientos` y `lotes`
> cuando esas entidades se sincronicen.
</content>
</invoke>
