# Plan backend de integración: gestión de lotes offline-first

Fecha: 2026-08-31  
Estado: propuesta para revisión conjunta Mobile–Backend  
Alcance: necesidades de backend para integrar la gestión de lotes ya preparada en mobile  
Instrucciones consideradas: `AGENTS.md`, `mobile/AGENTS.md` y
`mobile/lib/brick/README.md`

## 1. Propósito

Este documento entrega al equipo de backend el contexto funcional y el contrato
REST provisional que mobile preparó para lotes y movimientos de animales.

No define una implementación interna obligatoria. Backend debe validar la
viabilidad, seguridad y consistencia del contrato y puede proponer cambios. Si
una decisión cambia campos, rutas o semántica, mobile adaptará sus mappers antes
de habilitar la sincronización.

El resultado esperado de esta etapa es un contrato acordado y una API backend
capaz de sincronizar los datos creados sin conexión, sin perder el aislamiento
por establecimiento.

## 2. Alcance del trabajo backend

### Incluido

- API completa de lotes siguiendo `Router -> Service -> Repository`;
- persistencia y migraciones del modelo de lote;
- validaciones autoritativas de negocio y geometría;
- aislamiento multi-tenant y autorización;
- alta, actualización, borrado lógico y descarga incremental;
- contrato atómico para mover uno o varios animales entre lotes;
- idempotencia, resolución de conflictos y tombstones para offline-first;
- códigos de error estables consumibles por mobile;
- pruebas automatizadas de reglas, sincronización y aislamiento;
- definición de la convivencia entre geometría esquemática y geográfica futura.

### Fuera de alcance de esta entrega

- elegir el proveedor de mapas o tiles del dispositivo;
- implementar el mapa real en Flutter;
- convertir automáticamente los lotes esquemáticos existentes a coordenadas
  geográficas;
- KPIs de receptividad, sobrepastoreo o historial de pasturas;
- definir la matriz final de roles del producto.

## 3. Qué ya está implementado en mobile

Mobile funciona localmente, con SQLite como fuente de verdad, y ya permite:

- crear un lote en dos pasos;
- dibujar y mover vértices sobre un lienzo verde esquemático;
- validar mínimo de vértices, coordenadas, área, duplicados y
  auto-intersección;
- impedir superposición con área positiva entre lotes;
- permitir vértices, bordes y adyacencias compartidas;
- guardar nombre, superficie, recurso forrajero, agua y estado;
- listar, representar gráficamente, consultar, editar e inactivar lotes;
- realizar borrado lógico;
- consultar animales por lote;
- registrar animales seleccionando un lote local;
- mover localmente varios animales entre lotes;
- conservar los datos al cerrar y abrir la aplicación sin conexión.

Los contratos REST y la cola Brick están preparados, pero apagados mediante:

- `VITA_ENABLE_LOT_REMOTE_SYNC=false`;
- `VITA_ENABLE_LOT_MOVEMENT_REMOTE_SYNC=false`.

Con los flags apagados no se generan requests ni entradas fallidas en la cola.
No deben activarse hasta acordar el contrato y superar las pruebas de
integración.

## 4. Estado actual encontrado en backend

Backend cuenta con una base parcial, pero todavía no ofrece la feature:

- existe el modelo SQLModel `Lote` en la tabla `lotes`;
- actualmente almacena `establecimiento_id`, `nombre`, `superficie_ha` y
  `plan_alimenticio_id`;
- hereda UUID, timestamps y borrado lógico de las bases compartidas;
- existe `MovimientoLote`, pero representa un único `animal_id` por fila y su
  tabla actual se llama `movimientos_lote`;
- `MovimientoLote` no hereda actualmente el mixin de borrado lógico;
- `Animal` ya posee `lote_id` nullable y el API de animales permite filtrarlo y
  actualizarlo;
- el alta de animales valida que el lote pertenezca al establecimiento;
- no existen `router.py`, `service.py`, `repository.py`, `schemas.py` ni
  excepciones específicas para lotes o movimientos;
- los routers de lotes y movimientos no están registrados en
  `core/router.py`;
- no existe todavía una columna espacial PostGIS ni dependencias Python
  espaciales declaradas;
- el patrón offline-first de animales ya implementa UUID del cliente,
  `updated_since`, tombstones, replay idempotente y last-write-wins. Debe usarse
  como referencia.

Por lo tanto, `Animal.lote_id` es una base útil para la relación uno-a-muchos,
pero no reemplaza el módulo de lotes ni un movimiento batch transaccional.

## 5. Modelo funcional que mobile necesita

Cada lote sincronizable debe exponer, como mínimo:

| Campo | Tipo esperado | Observación |
|---|---|---|
| `id` | UUID | Generado por el cliente; clave idempotente |
| `establecimiento_id` | UUID | Tenant y RENSPA asociado indirectamente |
| `nombre` | string | Único de forma normalizada dentro del establecimiento |
| `geometria_local` | objeto JSON | Polígono esquemático versionado |
| `geometry_mode` | string | Actualmente `local_schematic` |
| `superficie_ha` | decimal positivo | Mobile envía un decimal, por ejemplo `45.7` |
| `recurso_forrajero_codigo` | string nullable | Código de catálogo, no etiqueta visible |
| `tiene_agua` | boolean | Disponibilidad actual |
| `estado` | string | Estado operativo acordado |
| `created_at` | datetime UTC | Generado inicialmente por el cliente |
| `updated_at` | datetime UTC | Base de resolución de conflictos |
| `deleted_at` | datetime UTC nullable | Tombstone de borrado lógico |

La relación con animales continúa siendo `Animal.lote_id`. El lote no debe
persistir una lista duplicada de animales ni un contador: ambos se derivan de
los animales vigentes asociados.

### Diferencias respecto del modelo backend actual

Backend debe revisar cómo incorporar o relacionar:

- `geometria_local` y `geometry_mode`;
- `recurso_forrajero_codigo` frente al actual `plan_alimenticio_id`;
- `tiene_agua`;
- `estado`;
- unicidad de nombre por establecimiento considerando borrado lógico;
- precisión definitiva de `superficie_ha`.

Mobile guarda la superficie internamente en décimas exactas y envía un decimal
con un dígito. Backend puede conservar `Numeric`, pero debe acordar si acepta más
precisión o normaliza a una decimal.

## 6. Geometría actual y evolución futura

### 6.1 Representación esquemática vigente

La geometría actual no es latitud/longitud ni GeoJSON geográfico. Es un sistema
cartesiano común a los lotes del establecimiento, con extensión lógica
`1000 x 1000`:

```json
{
  "type": "LocalPolygon",
  "coordinate_space": "establishment_canvas_v1",
  "version": 1,
  "extent": {
    "width": 1000.0,
    "height": 1000.0
  },
  "vertices": [
    {"x": 120.0, "y": 180.0},
    {"x": 620.0, "y": 210.0},
    {"x": 540.0, "y": 700.0}
  ]
}
```

El primer vértice no se repite al final. Backend nunca debe interpretar `x` e
`y` como longitud y latitud ni insertarlas directamente en una geometría WGS84.

Esta representación debe poder sincronizarse porque es la que permite operar
offline hoy y seguirá siendo el fallback cuando no haya mapa, conectividad o
permiso de ubicación.

### 6.2 Geometría geográfica futura

La intención de producto es incorporar más adelante una vista aérea real cuando
existan conectividad y permisos. En ese caso se espera una geometría separada,
probablemente GeoJSON WGS84 persistido en PostGIS.

La recomendación para evaluar con backend es mantener dos conceptos explícitos:

- geometría esquemática local versionada, siempre disponible como fallback;
- geometría geográfica nullable, con SRID definido, para mapa real y consultas
  espaciales.

No se ha definido una transformación automática entre ambas. Backend debe
confirmar si acepta esta convivencia, qué campo geográfico expondrá y qué
tecnología espacial utilizará. Esa decisión no debe bloquear el contrato V1
esquemático.

## 7. Contrato REST provisional preparado por mobile

Todas las respuestas se esperan envueltas en el `StandardResponse` existente.
Los cuerpos JSON pueden enviarse en `snake_case`; el middleware backend ya
tolera la conversión desde camelCase.

### 7.1 Crear, actualizar o reproducir un lote

```http
POST /api/v1/lotes
Authorization: Bearer <jwt>
Content-Type: application/json
```

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
  "geometry_mode": "local_schematic",
  "superficie_ha": 45.7,
  "recurso_forrajero_codigo": "alfalfa",
  "tiene_agua": true,
  "estado": "active",
  "created_at": "2026-08-31T14:20:00Z",
  "updated_at": "2026-08-31T14:20:00Z",
  "deleted_at": null
}
```

Mobile usa provisionalmente `POST` como upsert idempotente tanto para el alta
como para cambios posteriores y tombstones. Backend debe confirmar esta
decisión o proponer `PUT /api/v1/lotes/{id}` y un mecanismo de borrado
compatible con la cola Brick.

Respuesta esperada:

```json
{
  "success": true,
  "data": {
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
    "geometry_mode": "local_schematic",
    "superficie_ha": 45.7,
    "recurso_forrajero_codigo": "alfalfa",
    "tiene_agua": true,
    "estado": "active",
    "created_at": "2026-08-31T14:20:00Z",
    "updated_at": "2026-08-31T14:20:00Z",
    "deleted_at": null
  },
  "meta": null,
  "errors": null
}
```

### 7.2 Descargar lotes del establecimiento

Request que mobile ya tiene preparado:

```http
GET /api/v1/lotes?establecimiento_id=<uuid>&include_deleted=true
Authorization: Bearer <jwt>
```

El contrato definitivo debería admitir además:

```http
GET /api/v1/lotes?establecimiento_id=<uuid>&updated_since=<iso-8601>&include_deleted=true
```

`updated_since` permitiría descarga incremental con el mismo patrón ya usado
por animales. La respuesta debe contener una lista en `data`, ordenada de forma
estable, incluyendo tombstones cuando se soliciten.

### 7.3 Borrado lógico

El borrado no elimina físicamente la fila. Mobile actualiza:

```json
{
  "deleted_at": "2026-08-31T16:00:00Z",
  "updated_at": "2026-08-31T16:00:00Z"
}
```

El lote borrado deja de aparecer y de bloquear espacio en mobile. Backend debe
conservar el tombstone el tiempo suficiente para que otros dispositivos puedan
descargarlo. No se ofrece restauración en esta versión.

### 7.4 Movimiento batch de animales

Contrato provisional:

```http
POST /api/v1/movimientos_lotes
Authorization: Bearer <jwt>
Content-Type: application/json
```

```json
{
  "id": "f7316705-09ba-4c42-8d31-2788b54043a2",
  "establecimiento_id": "fe5f93ba-fc82-40b0-9c57-1966fe4b48a4",
  "lote_origen_id": "f255bdfc-466a-45d2-a4ea-9ba868662bbf",
  "lote_destino_id": "290df0e8-812f-44f3-9d7a-aa120c32ca1a",
  "animal_ids": [
    "a7c6d5ca-dba2-40d4-b918-75c848b69512",
    "243e9d8b-1d76-48cd-b549-bb198d5393d5"
  ],
  "fecha_movimiento": "2026-08-31T15:30:00Z",
  "motivo": "Rotación de pastoreo",
  "responsable_id": null,
  "created_at": "2026-08-31T15:30:10Z",
  "updated_at": "2026-08-31T15:30:10Z",
  "deleted_at": null
}
```

Mobile necesita una operación batch, idempotente y transaccional: o se mueven
todos los animales y se registra el movimiento, o no se modifica ninguno. El
modelo backend actual de una fila por animal puede conservarse internamente si
backend lo prefiere, pero la API debe definir cómo representa una única
operación batch y cómo evita resultados parciales durante reintentos.

Respuesta mínima esperada:

```json
{
  "success": true,
  "data": {
    "id": "f7316705-09ba-4c42-8d31-2788b54043a2",
    "animal_ids": [
      "a7c6d5ca-dba2-40d4-b918-75c848b69512",
      "243e9d8b-1d76-48cd-b549-bb198d5393d5"
    ],
    "lote_origen_id": "f255bdfc-466a-45d2-a4ea-9ba868662bbf",
    "lote_destino_id": "290df0e8-812f-44f3-9d7a-aa120c32ca1a",
    "updated_at": "2026-08-31T15:30:10Z"
  },
  "meta": null,
  "errors": null
}
```

## 8. Reglas autoritativas que backend debe aplicar

Mobile valida primero para trabajar offline y dar feedback inmediato, pero
backend debe repetir las reglas al sincronizar:

### Lotes

- el usuario debe pertenecer al establecimiento indicado;
- nombre obligatorio y único, normalizado y case-insensitive dentro del mismo
  establecimiento;
- superficie mayor que cero;
- geometría local con tipo, espacio, versión, extensión y coordenadas válidas;
- al menos tres vértices distintos;
- polígono con área positiva y sin auto-intersecciones;
- no puede existir superposición con área positiva con otro lote no eliminado;
- compartir vértice, borde o adyacencia sí es válido;
- lotes `active`, `resting`, `maintenance` e `inactive` ocupan espacio;
- un tombstone no participa de la superposición;
- no se puede inactivar ni eliminar un lote con animales vigentes;
- la geometría queda bloqueada después del alta en esta versión;
- los demás campos alfanuméricos son editables;
- todas las referencias deben pertenecer al mismo establecimiento.

### Movimientos

- origen y destino deben ser diferentes y pertenecer al establecimiento;
- el destino debe estar activo y no eliminado;
- todos los animales deben pertenecer al establecimiento y al lote de origen;
- no debe aceptarse una lista vacía ni IDs repetidos;
- el movimiento y la actualización de `Animal.lote_id` deben confirmarse en la
  misma transacción;
- repetir el mismo UUID de movimiento no debe mover dos veces ni duplicar el
  historial;
- el responsable definitivo debería derivarse del usuario autenticado; aceptar
  `responsable_id` del cliente requiere validación explícita.

## 9. Sincronización offline-first

El contrato debe mantener las convenciones ya adoptadas por animales:

- UUID generado por el dispositivo;
- alta y replay idempotentes;
- `created_at`, `updated_at` y `deleted_at` enviados por mobile;
- last-write-wins por `updated_at`, con timestamps UTC normalizados;
- pull incremental mediante `updated_since`;
- `include_deleted=true` para propagar tombstones;
- respuesta exitosa con la versión autoritativa completa;
- error estable para que Brick marque el registro como rechazado;
- aislamiento por establecimiento en cada lectura y escritura.

Backend y mobile deben definir además:

- comportamiento exacto cuando dos dispositivos crean el mismo nombre offline;
- política ante relojes de dispositivo desajustados;
- retención y purga segura de tombstones;
- orden de sincronización: lote antes que animales que lo referencian, y lotes y
  animales antes que movimientos;
- cursor inclusivo o exclusivo de `updated_since` para no perder registros con
  timestamps iguales;
- respuesta ante un replay cuyo payload sea más viejo que el persistido.

## 10. Catálogos y estados a validar

Mobile utiliza inicialmente estos códigos de recurso forrajero:

- `pasto_natural`;
- `alfalfa`;
- `sorgo`;
- `maiz`;
- `avena`;
- `otro`.

Se modelaron como catálogo, no como enum cerrado, para permitir sincronizarlos
en el futuro. Backend debe decidir si serán globales, configurables o una tabla
propia. Mobile puede adaptar el catálogo si la decisión final conserva códigos
estables y un fallback offline.

Estados actuales:

- `active`: puede recibir animales;
- `resting`: descanso;
- `maintenance`: mantenimiento;
- `inactive`: división física conservada, sin admitir animales.

Estos códigos también son una propuesta. Backend debe validar nombres,
transiciones y persistencia antes de cerrar el contrato.

## 11. Errores que mobile necesita distinguir

Backend ya dispone de `DomainException` y responde errores mediante
`StandardResponse`. Se propone acordar códigos estables como:

| Código propuesto | Uso |
|---|---|
| `nombre_lote_duplicado` | Nombre ya existente en el establecimiento |
| `geometria_lote_invalida` | Polígono o formato local inválido |
| `lotes_superpuestos` | Intersección con área positiva |
| `lote_con_animales` | Inactivación o borrado prohibido |
| `lote_no_encontrado` | UUID inexistente o no visible para el tenant |
| `lote_destino_no_disponible` | Destino inactivo, eliminado o inválido |
| `animales_no_pertenecen_lote_origen` | Estado remoto distinto del esperado |
| `conflicto_sincronizacion` | Mutación no conciliable automáticamente |
| `establecimiento_no_autorizado` | Acceso fuera del tenant |

Ejemplo:

```json
{
  "success": false,
  "data": null,
  "meta": null,
  "errors": [
    {
      "code": "nombre_lote_duplicado",
      "message": "El nombre del lote ya existe en este establecimiento.",
      "details": {"field": "nombre"}
    }
  ]
}
```

Los nombres son propuestas; lo obligatorio para mobile es que el código sea
estable, documentado y diferenciable del texto visible.

## 12. Persistencia, seguridad y módulos

Sin imponer una solución interna concreta, backend deberá contemplar:

- migraciones Alembic para todos los cambios de esquema;
- tablas y columnas en español, `snake_case` y plural según las convenciones;
- índice/constraint de unicidad normalizada por establecimiento compatible con
  soft delete;
- índices para `establecimiento_id`, `updated_at`, `deleted_at` y relaciones
  consultadas frecuentemente;
- claves foráneas coherentes entre lote, animal, catálogos y movimientos;
- RLS/políticas Supabase si la tabla se expone por esa vía;
- autorización en Service además del filtrado de repositorio;
- módulos completos separados en router, schemas, service, repository, models,
  exceptions y tests;
- registro de los routers en `core/router.py`;
- auditoría suficiente para reconstruir movimientos.

Por ahora mobile está diseñado para el flujo de `owner`, sin bloquear por rol.
Backend continúa siendo la autoridad y debe validar la membresía real. La matriz
definitiva se ajustará cuando Producto cierre los tres roles futuros.

## 13. Pruebas mínimas esperadas de backend

### Contrato y persistencia

- round-trip completo de un lote con geometría `LocalPolygon`;
- alta repetida con el mismo UUID sin duplicación;
- actualización más nueva aceptada y más vieja reconciliada según LWW;
- pull incremental incluyendo tombstones;
- superficie decimal y campos opcionales;
- rechazo de modos o versiones geométricas desconocidas según política acordada.

### Reglas de negocio

- nombre duplicado normalizado dentro del mismo establecimiento;
- mismo nombre permitido en otro establecimiento;
- geometría válida, auto-intersección, contención, coincidencia y cruce;
- borde o vértice compartido permitido;
- lote inactivo continúa bloqueando espacio;
- lote eliminado deja de bloquearlo;
- inactivar o borrar con animales es rechazado.

### Movimiento

- movimiento batch exitoso;
- rollback completo si falla un animal;
- replay del mismo UUID;
- origen, destino o animal de otro establecimiento rechazados;
- destino no activo rechazado;
- animal que ya no está en el origen rechazado;
- historial y `Animal.lote_id` quedan consistentes.

### Seguridad

- usuario sin membresía no puede leer ni mutar lotes;
- un establecimiento no puede observar IDs, geometrías, animales ni movimientos
  de otro;
- los filtros del request no permiten eludir el tenant autenticado.

## 14. Secuencia sugerida de trabajo

1. Revisar este contrato con Mobile y Producto.
2. Resolver las decisiones abiertas de geometría, catálogos, estados y
   movimientos batch.
3. Ajustar y migrar los modelos centrales.
4. Completar el módulo API de lotes.
5. Implementar validaciones, sync incremental y códigos de error.
6. Completar el movimiento transaccional de animales.
7. Incorporar aislamiento/RLS y pruebas automatizadas.
8. Ejecutar pruebas de contrato contra mobile con los flags habilitados solo en
   un ambiente de integración.
9. Corregir diferencias de contrato en ambos lados.
10. Habilitar sincronización de lotes y luego movimientos de forma controlada.

## 15. Decisiones que backend debe devolver al equipo mobile

| Tema | Propuesta mobile actual | Confirmación requerida |
|---|---|---|
| Upsert de lote | `POST /api/v1/lotes` | Aceptar o reemplazar por POST/PUT separados |
| Pull | `GET /api/v1/lotes` con tenant y tombstones | Definir cursor y paginación |
| Borrado | Upsert con `deleted_at` | Confirmar o definir DELETE sincronizable |
| Conflictos | LWW por `updated_at` | Definir empates y relojes desajustados |
| Geometría V1 | JSON `LocalPolygon` | Campo/tipo de persistencia y validación |
| Geometría futura | GeoJSON WGS84 separado | SRID, PostGIS y convivencia con fallback |
| Superficie | Un decimal positivo | Precisión y redondeo autoritativo |
| Forraje | Catálogo por código | Tabla, enum o catálogo global |
| Estado | Cuatro códigos actuales | Nombres y transiciones definitivas |
| Movimiento | POST batch con `animal_ids` | Modelo de persistencia y respuesta atómica |
| Responsable | Nullable temporalmente | Derivarlo de JWT y formato de auditoría |
| Errores | Códigos propuestos | Nombres finales y status HTTP |

## 16. Criterio de finalización de la integración

La mitad backend se considera lista para integrar cuando:

- el contrato definitivo está documentado y aceptado por ambos equipos;
- lotes y movimientos tienen API, migraciones, validaciones y autorización;
- la sincronización es idempotente y propaga altas, cambios y borrados;
- el movimiento de varios animales es transaccional;
- las pruebas de aislamiento multi-tenant y offline-first están verdes;
- mobile puede habilitar ambos flags en integración sin acumular rechazos por
  rutas inexistentes ni diferencias de payload;
- crear offline, reiniciar, recuperar conexión y sincronizar conserva el mismo
  UUID, datos, geometría y ubicación de los animales;
- los cambios de contrato necesarios quedaron reflejados en mobile antes de
  habilitar los flags en producción.
