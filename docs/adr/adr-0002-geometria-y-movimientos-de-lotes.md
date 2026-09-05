# ADR-0002 — Geometría esquemática del lote y movimiento batch de animales

- **Estado:** aceptado
- **Fecha:** 2026-09-05
- **Decide:** Lucho (Backend / ML / Infra)
- **Requiere validación del Product Owner:** no (no toca SENASA 530/2025)
- **Requiere acuerdo con Mobile:** sí (ver "Lo que mobile debe cambiar")

## Contexto

Mobile ya tiene implementada y funcionando en SQLite toda la gestión de lotes: alta en
dos pasos, dibujo del polígono, validaciones, listado, edición, inactivación, borrado
lógico y movimiento de animales entre lotes. Los contratos REST y la cola Brick están
cableados pero apagados con `VITA_ENABLE_LOT_REMOTE_SYNC` y
`VITA_ENABLE_LOT_MOVEMENT_REMOTE_SYNC`, porque el backend no tenía la contraparte:
`/api/v1/lotes` y `/api/v1/movimientos_lotes` devolvían 404.

El backend tenía dos modelos huérfanos —`Lote` y `MovimientoLote`— sin router, service,
repository, schemas, migración ni tests. Existían solo para que resolvieran las FKs de
`animales`. Entre lo que mobile serializa y lo que el backend conocía había un
desalineamiento de campos y, peor, una **incompatibilidad de cardinalidad** en el
movimiento.

El documento de contrato que preparó mobile (`docs/plan-backend-integracion-gestion-lotes.md`)
dejó doce decisiones abiertas. Este ADR las cierra.

## Decisión

### 1. La geometría del lote es esquemática y local, no geográfica

`geometria_local` es un `jsonb` que guarda un polígono en un plano cartesiano común a los
lotes del establecimiento, de extensión lógica 1000×1000. **No es lat/long ni GeoJSON
WGS84**, y no existe transformación definida entre este lienzo y el mundo real.

Esa es justamente la razón de ser: permite dibujar el campo en la manga sin mapa, sin GPS
y sin señal. Es lo que hace que el módulo cumpla offline-first en lugar de depender de un
SDK de mapas.

La geometría geográfica real llegará como una **columna aparte y nullable** cuando exista
vista aérea, conectividad y permisos de ubicación. La esquemática no se reemplaza: sigue
siendo el fallback cuando cualquiera de esas tres cosas falta. `modo_geometria` discrimina
cuál rige para el lote; hoy solo existe `local_schematic` y cualquier otro valor se
rechaza.

Consecuencia: **no se incorpora PostGIS**. Las reglas de área, auto-intersección y
superposición se calculan en CPU con `shapely`, que es una dependencia de cómputo
geométrico, no una extensión de base de datos.

### 2. El movimiento es un agregado de cabecera + detalle

Mobile crea *una* operación con N animales y le asigna *un* UUID, que es su clave de
idempotencia. El modelo anterior guardaba una fila por animal, y ese UUID no puede ser PK
de N filas: un reintento de la cola habría duplicado el historial.

Se reemplaza `movimientos_lote` (singular, una fila por animal, vacía en Supabase) por:

| Tabla | Rol | Sincronizable |
| --- | --- | --- |
| `movimientos_lotes` | cabecera: origen, destino, fecha, motivo, responsable | sí (`SoftDeleteMixin`) |
| `movimientos_lotes_animales` | detalle: qué animales la componen | no, viaja en el payload del padre |

Mismo patrón que `ventas`/`ventas_detalles` (ADR-0001) y la convención que ya fija
`database/README.MD` para las hijas de un agregado atómico.

La operación es atómica sin transacción explícita: los repositories solo hacen `flush` y
el `commit` lo emite `get_session()` al cerrar el request, con `rollback` ante cualquier
excepción. Por eso el service **nunca** debe llamar a `session.commit()`.

**Un replay no re-ejecuta el movimiento.** El movimiento es un hecho histórico, no un
estado que se recalcula: al reenviar el mismo UUID se devuelve lo persistido sin volver a
tocar a los animales. Lo único que se propaga es el tombstone, y sin revertir la ubicación
—deshacer un traslado es una operación distinta que este contrato no modela.

### 3. Los códigos de dominio van en español

Mobile proponía `active` / `resting` / `maintenance` / `inactive`. Se adoptan
`activo` / `descanso` / `mantenimiento` / `inactivo`, coherentes con los otros diez enums
de `api/shared/enums.py` y con la convención de CLAUDE.md. Por la misma razón la columna
es `modo_geometria` y no `geometry_mode`.

El costo es real —mobile tiene que cambiar su enum antes de encender el flag— pero se paga
una sola vez, mientras que la inconsistencia se paga en cada lectura del esquema. El
propio documento de mobile declaraba esos códigos como propuesta, y su `LotStatus.fromCode`
ya tiene fallback `unknown`.

### 4. Reglas de geometría: tocarse sí, pisarse no

- Mínimo tres vértices distintos, área positiva, sin auto-intersecciones.
- Ningún otro lote **no borrado** del establecimiento puede solaparse con área positiva.
- Compartir un vértice, un borde o ser adyacente **es válido**: un campo dividido en
  potreros es exactamente eso. Esas intersecciones tienen área cero.
- Los cuatro estados ocupan espacio; solo el tombstone lo libera.

### 5. Superficie con un decimal autoritativo

Mobile la administra en décimas exactas de hectárea. El backend cuantiza a un decimal al
escribir. Aceptar más precisión haría que el ida y vuelta perdiera información contra el
valor local.

### 6. Reglas menores

- **Upsert por POST**, idempotente por UUID de cliente y con last-write-wins por
  `updated_at`; el empate lo gana el servidor. Se acepta la propuesta de mobile. `PUT` y
  `DELETE` existen por paridad con animales, pero mobile no los necesita.
- **`updated_since` es inclusivo (`>=`)**, igual que animales: reenviar un registro es
  inocuo porque el upsert es idempotente, perderlo es silencioso.
- **La geometría queda bloqueada tras el alta.** Un replay que la reenvía la ve
  **ignorada, no rechazada**: Brick reenvía el registro completo y un 4xx sería un rechazo
  definitivo en la cola.
- **`responsable_id` sale del JWT.** Aceptar el del cliente permitiría imputarle un
  movimiento a otro usuario.
- **`descanso` y `mantenimiento` no expulsan hacienda.** Solo `inactivo` y el borrado
  exigen el lote vacío; los otros dos cortan el ingreso, que lo controla el movimiento.
- **Unicidad de nombre** normalizada (`lower(trim(...))`) y parcial (`where deleted_at is
  null`): borrar un lote libera su nombre.

## Consecuencias

- `lotes` existía en Supabase con 4 filas semilla sin geometría. La migración les
  **fabrica** un polígono placeholder sobre una grilla que por construcción no se
  superpone. No es un dato real: dejarlas en `null` rompía la deserialización del cliente,
  que castea la geometría de forma estricta.
- Se agrega `shapely` (y transitivamente `numpy`) a las dependencias de producción.
- Agregar un valor a `EstadoLote` o `RecursoForrajero` ahora requiere migración, porque
  las restricciones `CHECK` los replican en la base.
  `test_enums_coinciden_entre_modelo_migracion_y_script` falla si los tres artefactos se
  desalinean.
- `lotes`, `movimientos_lotes` y `movimientos_lotes_animales` pasan a tener políticas RLS.
  Hasta ahora `lotes` tenía RLS **habilitada y cero políticas** —una cerradura sin llave
  que solo no rompía porque el backend entra por `DATABASE_URL` y saltea RLS. `animales` y
  `pesajes` siguen en esa situación: queda como deuda.
- El aislamiento sigue siendo responsabilidad del service, que filtra por membresía en
  toda consulta. RLS es defensa en profundidad, nunca el mecanismo principal.
- Sigue sin haber autorización por rol, igual que en animales. Cuando Producto cierre la
  matriz, `external_buyer` no debería poder mover animales.

## Alternativas descartadas

- **PostGIS y una columna espacial ahora.** Habría atado el módulo a una extensión y a un
  SRID para representar coordenadas que no son geográficas. La geometría esquemática no
  gana nada con índices espaciales: son decenas de polígonos por establecimiento.
- **`animal_ids` como columna JSONB en una tabla única.** Evitaba la tabla hija, pero
  perdía la FK a `animales` (nada garantizaría que los UUIDs existan) y convertía "¿por
  qué lotes pasó este animal?" en un scan de JSONB.
- **Conservar una fila por animal con una columna agrupadora.** Menos cambio estructural,
  pero la idempotencia había que resolverla a mano borrando y reinsertando el grupo en
  cada replay, y no había dónde colgar el `deleted_at` de la operación.
- **Aceptar los códigos en inglés de mobile.** Cero fricción inmediata, a cambio de dejar
  el único enum en inglés del backend.
- **Validar solo la forma y dejar la no-superposición a mobile.** Más rápido de entregar,
  pero dos dispositivos offline pueden crear lotes solapados y nadie los rechazaría al
  sincronizar, que es precisamente cuando el conflicto aparece.

## Lo que mobile debe cambiar antes de encender los flags

1. `LotStatus` a los códigos en español (`activo`, `descanso`, `mantenimiento`, `inactivo`).
2. `@Rest(name: 'geometry_mode')` → `'modo_geometria'`.
3. Asumir `superficie_ha` con un decimal como autoridad del servidor.
4. Dejar de enviar `responsable_id`: se deriva del JWT y se ignora el del cliente.
5. Mapear los códigos de error de `docs/contrato-lotes-movimientos.md` en
   `lot_brick_store.dart`, recordando que **todo 4xx es un rechazo definitivo** en la cola
   (solo 500-504 se reintentan).
