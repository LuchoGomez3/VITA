# Brick

Esta carpeta concentra la infraestructura offline-first del mobile.

La [auditoría de sincronización de toda la app](sync/README.md) registra el estado
de cada módulo, hallazgos priorizados, archivos involucrados y pruebas pendientes
para la rama de integración general. Es un análisis del código, no una declaración
de que esos problemas ya estén corregidos.

Pendiente para la integración general: [sesión y cola offline](auth/README.md).
Documenta la conservación de envíos al vencer o cerrar sesión y su reanudación
al iniciar sesión, incluyendo el aislamiento entre cuentas. Todavía no está
implementado.

Brick es la capa que conecta tres mundos:

- SQLite local, para que la app funcione sin internet.
- Cola de requests REST, para reintentar sync cuando vuelva la conexion.
- Backend FastAPI/Supabase, para sincronizar datos reales.

Las features no deberian acceder a Brick desde `presentation` ni desde
`domain`. La integracion normal es:

```txt
feature/presentation -> feature/domain -> feature/data -> brick
```

## Estructura

```txt
lib/brick/
  brick.g.dart
  brick_bootstrap.dart
  README.md

  auth/
    authenticated_backend_client.dart
    backend_access_token_provider.dart

  core/
    repository.dart

  sync/
    backend_sync_result.dart

  models/
    animal.model.dart

  stores/
    animal_brick_store.dart

  adapters/
    brick_animal_model_adapter.g.dart

  db/
    schema.g.dart
    *.migration.dart
```

## Que va en cada carpeta

### `core/`

Contiene la infraestructura central de Brick.

`repository.dart` configura:

- `SqliteProvider`, para leer/escribir modelos en SQLite.
- `RestProvider`, para hablar con el backend.
- `RestRequestSqliteCacheManager`, para la cola offline.
- migraciones locales.
- helpers genericos como `upsertLocal`, `enqueueRemoteUpsert` y `getLocal`.

Este archivo no debe tener logica de animales, lotes, pesajes ni movimientos.
Si una regla pertenece a una entidad concreta, va en `stores/`.

### `auth/`

Contiene lo necesario para que Brick haga requests autenticadas.

`backend_access_token_provider.dart` define de donde sale el JWT. Hoy existe
una implementacion de sesion en memoria
(`SessionBackendAccessTokenProvider`) que conoce access token, refresh token y
expiracion.

Con login real, auth persiste la sesion en secure storage y, al iniciar sesion o
restaurar la app offline, hidrata `SessionBackendAccessTokenProvider`. Brick no
lee secure storage ni guarda JWT en SQLite: solo pide un token vigente a este
contrato antes de enviar requests REST. Si el access token vencio, el provider
intenta renovarlo mediante un callback configurado por auth; si no puede,
informa una falla transitoria de red o de autenticación según el caso. Sin
sesión devuelve `null`. El tratamiento de esos resultados por la cola tiene
pendientes documentados en [auth/README.md](auth/README.md).

`authenticated_backend_client.dart` envuelve el cliente HTTP usado por Brick:

- agrega `Authorization: Bearer <jwt>`;
- loguea request/response en debug;
- detecta resultados de sync;
- publica eventos genericos para que los stores actualicen SQLite.

No debe tener `if animal`, `if lote` o reglas por feature.

### `sync/`

Contiene tipos genericos del mecanismo de sincronizacion.

Su [README de auditoría](sync/README.md) reúne los pendientes de sincronización
de toda la app y el orden propuesto para implementarlos.

`backend_sync_result.dart` representa el resultado de una request sync-able. No
pertenece a una feature concreta: incluye `resourcePath`, `localId`,
`synchronized` y `errorCode`.

Cada store decide si un evento le corresponde. Por ejemplo, `AnimalBrickStore`
escucha todos los eventos y procesa solo los de `/api/v1/animales`.

### `models/`

Contiene modelos Brick escritos por nosotros.

Un modelo Brick describe como se guarda una entidad en SQLite y como se
serializa contra REST. Por ejemplo, `animal.model.dart` define los campos del
animal local, los nombres esperados por el backend y que datos son solo mobile.

Estos modelos no son entidades de dominio. Son modelos tecnicos de
persistencia/sync.

### `stores/`

Contiene operaciones por entidad Brick.

Un store es el puente entre una feature y la infraestructura Brick. Por ejemplo,
`animal_brick_store.dart` sabe como:

- guardar un animal primero en SQLite;
- encolar el POST remoto;
- escuchar el resultado del backend;
- pasar el estado local de `pending` a `synchronized` o `rejected`.

Cuando se agreguen mas entidades sincronizables, deberian aparecer stores como
`lot_brick_store.dart`, `weighing_brick_store.dart` o
`movement_brick_store.dart`.

### `adapters/`

Contiene codigo generado por Brick.

No se edita a mano. Se regenera con build runner cuando cambian los modelos
Brick.

### `db/`

Contiene schema y migraciones locales generadas por Brick.

No representan la base PostgreSQL/Supabase. Representan la base SQLite del
dispositivo.

## Archivos en la raiz

### `brick_bootstrap.dart`

Inicializa Brick antes de arrancar la app.

Define las rutas de:

- `vita_brick.sqlite`, base principal local;
- `vita_brick_offline_queue.sqlite`, cola offline de requests REST.

Tambien configura `AppBrickRepository` y registra los stores por entidad.

### `brick.g.dart`

Archivo central generado por Brick.

Agrupa adapters, model dictionaries y migraciones. No se edita a mano y no va
dentro de `models/` porque no es un modelo: es el indice generado de Brick.

## Flujo actual de registrar animal

```txt
RegisterAnimalPage
  -> RegisterAnimalBloc
  -> RegisterAnimalUseCase
  -> AnimalRegistrationRepositoryImpl
  -> AnimalRegistrationBrickMapper
  -> AnimalBrickStore
  -> AppBrickRepository
  -> SQLite + offline REST queue
  -> Backend FastAPI
```

El alta es offline-first:

1. La feature crea un `AnimalRegistration` de dominio.
2. El mapper lo transforma a `BrickAnimalModel`.
3. El store guarda el animal en SQLite con `syncStatus = pending`.
4. El store encola el POST remoto sin bloquear la UI.
5. El backend responde.
6. `AuthenticatedBackendClient` publica un `BackendSyncResult`.
7. `AnimalBrickStore` actualiza el registro local:
   `pending -> synchronized` o `pending -> rejected`.

## Flujo local de lotes y movimientos

La gestión de lotes utiliza SQLite como fuente de verdad y los movimientos
reutilizan el contrato batch validado del backend:

```txt
Field UI
  -> casos de uso de field
  -> repositorios de field
  -> BrickLotStore / BrickAnimalLotMovementStore / AnimalBrickStore
  -> SQLite
```

`BrickLotModel` conserva la delimitación cartesiana local versionada. Sus
coordenadas pertenecen al lienzo `0..1000`; no son latitud/longitud ni GeoJSON.
Además persiste superficie en décimas de hectárea, forraje, agua, estado y los
timestamps necesarios para el futuro esquema LWW.

El movimiento entre lotes actualiza la ubicación de los animales y guarda un
`BrickAnimalLotMovementModel` con origen, destino, animales, fecha y motivo.
Ambas escrituras se ejecutan dentro de una única transacción SQLite para no
dejar un traslado parcial si alguna operación falla.

Los movimientos ya usan el contrato batch confirmado de
`/api/v1/movimientos_lotes` y se sincronizan por defecto. Admiten origen `null`,
separan el sync de ubicación del resto de ediciones del animal y conservan
rechazos en SQLite. El movimiento pendiente funciona como outbox para recuperar
jobs ausentes en la cola separada tras un cierre de la app.

El flujo y sus límites se documentan en
[asignación y traslado entre lotes](../features/lot_movement/README.md).
La lectura de destinos activos funciona sin flags. El alta/edición remota de
lotes mantiene `VITA_ENABLE_LOT_REMOTE_SYNC=true`; ya no existe el flag de
movimientos. El historial de la ficha del animal incluye los movimientos
locales y remotos, con su resultado de sincronización.

## Codigo generado

Si cambia un modelo Brick, se debe regenerar:

```powershell
cd mobile
fvm dart run build_runner build --delete-conflicting-outputs
```

Archivos generados habituales:

- `brick.g.dart`
- `adapters/*.g.dart`
- `db/schema.g.dart`
- `db/*.migration.dart`

## Reglas importantes

- No editar archivos `.g.dart` a mano.
- No meter logica de feature en `core/repository.dart`.
- No usar Brick desde `presentation` ni desde `domain`.
- No guardar secretos en esta carpeta.
- No guardar JWT en SQLite/Brick. Auth lo guarda en secure storage y alimenta
  `SessionBackendAccessTokenProvider` en memoria.
- Cada entidad sync-able debe usar UUID generado por el cliente y timestamps
  `created_at`, `updated_at`, `deleted_at` cuando aplique.

## Edición de animales y notas

`BrickAnimalStore.updateAnimal` persiste la ficha y encola un
`BrickAnimalUpdateModel` para PUT. Este modelo es un sobre del comando HTTP:
no se inserta en su tabla SQLite; el estado local pertenece a BrickAnimalModel
y la persistencia del envío a la cola de Brick. Su payload acotado evita
sobrescribir datos ausentes en una caché anterior. El cliente HTTP observa
POST y PUT, e informa updated_at para que el store ignore respuestas de versiones
anteriores (por ejemplo, una baja seguida de Deshacer).

`BrickAnimalObservationStore` maneja entradas independientes y su POST, GET
filtrado y estado local de sincronización. El pull conserva notas pendientes o
rechazadas y respeta las bajas lógicas recibidas. El autor se lee del backend,
pero nunca se envía desde mobile. Las columnas nuevas del animal y categoría
usan deserialización tolerante a null para instalaciones con filas anteriores
a la migración.

## Compatibilidad de categorías después del merge

La migración 20261005193219 restaura columnas que una rama había retirado.
Las instalaciones de la otra rama ya las conservan. Antes de inicializar Brick,
`resolveCompatibleMigrations` consulta el esquema local y adapta únicamente esa
migración para agregar las columnas faltantes. Se mantiene su versión y los
registros existentes; no se borran bases ni se modifica el código generado.
