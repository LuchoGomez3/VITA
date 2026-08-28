# Plan V1: gestión y delimitación offline de lotes

> Este documento conserva la visión completa del módulo. El plan operativo
> vigente para comenzar el relevamiento es
> [`plan-fase-1-delimitacion-local-lotes.md`](plan-fase-1-delimitacion-local-lotes.md).
> Backend, Brick, sincronización y cartografía se abordarán en fases posteriores.

Fecha: 2026-08-25  
Estado: propuesta para revisión, sin implementación iniciada  
Instrucciones consideradas: `AGENTS.md` y `mobile/AGENTS.md`

## 1. Decisión de alcance

La primera versión debe resolver la gestión espacial de lotes sin depender de
cartografía, tiles, imágenes satelitales ni conectividad.

La V1 tendrá:

- un fondo verde/neutro;
- un viewport geográfico con norte y escala;
- delimitación mediante vértices;
- coordenadas reales de latitud/longitud;
- edición, validación y cálculo de superficie;
- persistencia local con Brick + SQLite;
- sincronización diferida con FastAPI y PostgreSQL/PostGIS.

La V1 no tendrá:

- mapa vial o satelital;
- descarga o administración de regiones cartográficas;
- MBTiles/PMTiles;
- movimientos masivos de animales;
- historial de alimentación, agua, cultivos o infraestructura;
- seguimiento GPS continuo;
- reconocimiento automático de alambrados.

La cartografía queda como una mejora posterior y reemplazable:

```text
V1       fondo verde georreferenciado
futuro   mapa/satélite online
futuro   mapa/satélite descargado para uso offline
```

Agregar una capa cartográfica no debe modificar `Lot`, `LotBoundary`, Brick,
GeoJSON ni el contrato backend.

## 2. Aclaración esencial: fondo verde no es un canvas en píxeles

Los vértices no deben persistirse como posiciones de pantalla:

```text
Incorrecto: Offset(120 px, 340 px)
Correcto:   GeoPoint(latitude: -31.412, longitude: -64.201)
```

El editor necesita una cámara geográfica que convierta cada toque de pantalla
a WGS84 y que vuelva a proyectar esas coordenadas al hacer pan o zoom.

Esto exige una referencia inicial:

1. opción preferida: límite georreferenciado del establecimiento;
2. alternativa mínima: centro real del establecimiento y un radio/escala
   inicial definidos;
3. si solo existe una ubicación aproximada, la interfaz debe comunicar que la
   delimitación también es aproximada.

Un fondo sin accidentes visuales hace difícil identificar alambrados reales.
La V1 valida el flujo y conserva geometría compatible con mapas futuros, pero
no debe prometer precisión catastral o productiva si no existe una referencia
visual/geodésica suficiente.

## 3. User story V1

**Como** usuario con acceso a un establecimiento,  
**quiero** crear y editar un lote delimitando espacialmente sus límites mediante
vértices,  
**para** identificarlo y continuar trabajando aunque no tenga conectividad.

### Criterios de aceptación

1. El usuario puede abrir el editor con fondo verde sin conectividad.
2. Cada toque agrega un vértice geográfico real, no una coordenada de pantalla.
3. Puede mover/eliminar vértices, deshacer, rehacer, cancelar y cerrar el
   polígono.
4. La app no permite guardar menos de tres vértices distintos, coordenadas
   inválidas, puntos repetidos, superficie nula ni auto-intersecciones.
5. La app contrasta el lote con las geometrías disponibles localmente y advierte
   o rechaza los solapamientos según la regla funcional acordada.
6. El usuario ingresa un nombre y confirma la superficie derivada de la
   geometría.
7. El lote se guarda localmente con UUID y queda visible inmediatamente.
8. Después de cerrar por completo y reabrir la app sin conexión, el lote sigue
   disponible y editable.
9. Al recuperar conectividad, el lote se sincroniza o queda en un estado de
   conflicto/rechazo comprensible y corregible.
10. El backend valida nuevamente geometría, permisos y solapamientos antes de
    persistir en PostGIS.

## 4. Decisiones funcionales que faltan

Estas decisiones deben cerrarse con Producto antes de implementar reglas
irreversibles:

### Alcance del no-solapamiento

- **Por establecimiento:** se comparan lotes del mismo establecimiento.
- **Global:** se comparan lotes de cualquier establecimiento de VITA.

Si la regla es global, un dispositivo offline no puede conocer todos los lotes.
La validación local será provisional y el backend podrá rechazar al sincronizar.

En ambos casos hay que confirmar si compartir un borde o vértice está permitido
y solo se rechaza una intersección con área positiva.

### Otras definiciones

- si `lote` y `potrero` son el mismo concepto para el usuario;
- si la V1 incluye crear, listar, ver, editar y eliminar, o un subconjunto;
- si un nombre debe ser único entre lotes activos del establecimiento;
- qué referencia geográfica real tendrá el editor verde;
- qué ocurre ante ediciones concurrentes del mismo polígono;
- si un animal puede quedar temporalmente sin lote.

## 5. Tecnología mobile recomendada para la V1

### `flutter_map` sin tiles

Se recomienda evaluar e incorporar `flutter_map` como motor del editor
geográfico, aun cuando la V1 no muestre un mapa base.

Configuración conceptual:

```text
FlutterMap
├── MapOptions(backgroundColor: verde, CRS geográfico, cámara inicial)
├── PolygonLayer(lotes existentes + lote en edición)
├── PolylineLayer(trazo todavía abierto)
└── MarkerLayer(vértices editables)
```

Motivos:

- funciona sin `TileLayer` ni requests de red;
- ya resuelve cámara, pan, zoom, proyección y transformaciones
  pantalla↔latitud/longitud;
- `MapOptions.onTap` entrega directamente la coordenada geográfica;
- soporta `PolygonLayer`, `MarkerLayer`, ajuste de cámara y restricciones;
- es Flutter puro, más simple para superponer controles y testear esta V1;
- en el futuro se puede agregar un `TileLayer` sin reemplazar el editor.

Versión candidata al 2026-08-25: `flutter_map: 8.3.1`, fijada sin `^` si la
PoC la aprueba. La versión final debe verificarse nuevamente al implementarla.

Documentación:

- [MapOptions y fondo/cámara](https://pub.dev/documentation/flutter_map/latest/flutter_map/MapOptions-class.html)
- [Conversión entre pantalla y LatLng](https://pub.dev/documentation/flutter_map/latest/flutter_map/MapCamera-class.html)
- [API general y capas](https://pub.dev/documentation/flutter_map/latest/flutter_map/)

### Por qué no MapLibre en esta V1

MapLibre sigue siendo un candidato válido para cartografía vectorial y regiones
offline, pero agrega una vista nativa, styles y configuración de plataforma que
la primera versión no necesita. Se reconsiderará en la story de cartografía si
`flutter_map` no cubre los requisitos de tiles/satélite elegidos.

### Validación geométrica

La decisión entre algoritmo Dart propio y `turf` queda para una PoC corta.

Un algoritmo propio es razonable para:

- mínimo de puntos;
- rangos de coordenadas;
- duplicados;
- área nula;
- intersección entre segmentos.

El solapamiento robusto entre polígonos agrega casos de contención, bordes
compartidos y tolerancias numéricas. Antes de incorporar una dependencia hay
que comparar complejidad, cobertura de tests, licencia y mantenimiento.

La validación local solo usa geometrías disponibles en el dispositivo. El
backend es siempre autoritativo.

## 6. Modelo de dominio

El dominio no conoce Flutter, `LatLng`, GeoJSON, Brick, SQLite ni HTTP.

```text
Lot
├── id
├── establishmentId
├── name
├── boundary: LotBoundary
├── createdAt
├── updatedAt
└── deletedAt

LotBoundary
└── vertices: List<GeoPoint>

GeoPoint
├── latitude
└── longitude
```

`Lot`, `LotBoundary` y los estados de BLoC/Cubit deben ser inmutables y usar
Freezed según las reglas del proyecto.

La superficie es derivada de `LotBoundary`; no se aceptan geometría y hectáreas
escritas manualmente como dos fuentes de verdad independientes.

`LotBoundaryValidator` puede vivir en Domain porque es lógica pura y no necesita
infraestructura.

## 7. GeoJSON como detalle de infraestructura

El mapper de Data convierte:

```text
Domain                         Infrastructure
LotBoundary                   GeoJSON Polygon
GeoPoint(lat, lon)     →      [longitude, latitude]
```

El primer vértice se repite al serializar el anillo GeoJSON, no dentro de la
colección de edición del dominio.

En SQLite, `BrickLotModel` puede almacenar el Geometry GeoJSON como texto. En
PostgreSQL, la dirección candidata es `geometry(Polygon, 4326)` con PostGIS.

Fuentes:

- [RFC 7946, formato GeoJSON](https://www.rfc-editor.org/rfc/rfc7946.html)
- [ST_GeomFromGeoJSON](https://postgis.net/docs/ST_GeomFromGeoJSON.html)

## 8. Estructura de archivos mobile propuesta

Se recomienda evolucionar `features/field`, que ya contiene lista, mapa y
detalle visual de potreros, en lugar de crear una segunda feature paralela con
las mismas pantallas.

Los identificadores y nombres de archivos ejecutables permanecen en inglés.

```text
mobile/lib/features/field/
├── field_composition.dart
├── presentation/
│   ├── bloc/
│   │   ├── lot_editor_bloc.dart
│   │   ├── lot_editor_event.dart
│   │   └── lot_editor_state.dart
│   ├── pages/
│   │   ├── field_list_page.dart          # existente, reemplazar mock
│   │   ├── field_detail_page.dart        # existente, reemplazar mock
│   │   ├── field_map_page.dart           # visor de lotes
│   │   └── lot_editor_page.dart          # alta/edición
│   ├── strings/
│   │   └── field_strings.dart
│   └── widgets/
│       ├── geographic_lot_editor.dart
│       ├── lot_polygon_layer.dart
│       ├── lot_vertex_marker.dart
│       ├── lot_editor_toolbar.dart
│       └── lot_sync_badge.dart
├── domain/
│   ├── entities/
│   │   ├── geo_point.dart
│   │   ├── lot_boundary.dart
│   │   └── lot.dart
│   ├── services/
│   │   └── lot_boundary_validator.dart
│   ├── repositories/
│   │   └── lot_repository.dart
│   └── use_cases/
│       ├── get_lots_use_case.dart
│       ├── save_lot_use_case.dart
│       └── delete_lot_use_case.dart
└── data/
    ├── mappers/
    │   ├── lot_brick_mapper.dart
    │   └── lot_geo_json_mapper.dart
    └── repositories/
        └── lot_repository_impl.dart

mobile/lib/brick/
├── models/
│   └── lot.model.dart
├── stores/
│   └── lot_brick_store.dart
├── adapters/
│   └── brick_lot_model_adapter.g.dart       # generado
└── db/
    ├── schema.g.dart                           # generado
    └── <timestamp>.migration.dart              # generado
```

Flujo obligatorio:

```text
Page/Widget
    ↓
LotEditorBloc
    ↓
Use Case
    ↓
LotRepository (Domain)
    ↓
LotRepositoryImpl (Data)
    ↓
LotBrickStore
    ↓
AppBrickRepository genérico
    ↓
SQLite + cola REST
```

Presentation no accede a repositories ni a Brick. `AppBrickRepository` no
recibe reglas específicas de lotes. Los archivos generados no se editan a mano.

### Estructura de tests mobile

```text
mobile/test/features/field/
├── domain/
│   ├── services/lot_boundary_validator_test.dart
│   └── use_cases/save_lot_use_case_test.dart
├── data/
│   ├── mappers/lot_geo_json_mapper_test.dart
│   └── repositories/lot_repository_impl_test.dart
└── presentation/
    └── bloc/lot_editor_bloc_test.dart

mobile/test/brick/
└── stores/lot_brick_store_test.dart
```

## 9. Estructura backend propuesta

El contrato y la tecnología espacial siguen siendo candidatos de la PoC, no
una implementación aprobada.

```text
backend/api/modules/lotes/
├── __init__.py
├── models.py
├── schemas.py
├── repository.py
├── service.py
├── router.py
└── exceptions.py

backend/tests/
└── test_lotes.py

backend/alembic/versions/
└── <revision>_geometria_lotes_postgis.py
```

Responsabilidades:

- Router: HTTP, dependencias de auth y `StandardResponse`.
- Service: permisos, reglas de solapamiento, idempotencia y conflictos.
- Repository: consultas y funciones PostGIS.
- Schemas: contrato GeoJSON de entrada/salida.
- Models: `lotes`, UUID/timestamps/soft delete y Geometry PostGIS.

Candidato backend:

- PostgreSQL + PostGIS;
- GeoAlchemy2 con versión fija;
- `geometry(Polygon, 4326)`;
- `ST_IsValid` como validación autoritativa;
- `ST_Area(geometria::geography)` para superficie;
- índice GiST;
- tests de integración contra PostgreSQL/PostGIS real, no SQLite.

El contrato candidato mantiene endpoints españoles y plurales bajo
`/api/v1/lotes`, pero POST/PUT, códigos 409/422, delta y política de versiones
se cierran durante la PoC.

## 10. Persistencia y conflictos: decisiones abiertas

El repositorio actual usa una SQLite para los modelos Brick y otra para la cola
REST. Debe probarse un cierre de la app entre el guardado local y el encolado.

Estrategias candidatas:

- aprovechar el comportamiento existente de Brick si ya garantiza recuperación;
- registro `pending` + reconciliador de pendientes;
- outbox en la misma base transaccional.

No se elige una hasta verificar la infraestructura existente con una prueba de
falla reproducible.

Tampoco se fija todavía LWW. La regla segura es no mezclar listas de vértices
editadas concurrentemente. Producto debe elegir entre último cambio, conflicto
manual, servidor o conservación de ambas versiones.

## 11. Orden de las PoC

### PoC A: editor geográfico verde

- `flutter_map` sin `TileLayer` y sin requests;
- referencia inicial del establecimiento;
- agregar, mover y eliminar vértices;
- pan/zoom, deshacer/rehacer y cierre;
- comprobar que las coordenadas no cambian al mover la cámara;
- validar geometría y mostrar superficie.

**Salida:** editor demostrable y decisión sobre algoritmo propio o librería.

### PoC B: persistencia local

- modelo Brick y mapper GeoJSON;
- guardar sin conectividad;
- cerrar completamente la app;
- reabrir offline y recuperar geometría/nombre/estado;
- editar y eliminar con soft delete.

**Salida:** evidencia de persistencia offline y estrategia de reencolado.

### PoC C: backend espacial

- PostGIS + GeoAlchemy2;
- endpoint candidato;
- geometría válida/inválida;
- cálculo de superficie;
- permisos multi-tenant;
- solapamiento según el alcance funcional acordado.

**Salida:** inserción y lectura demostradas contra PostGIS real.

### PoC D: sincronización extremo a extremo

- crear offline;
- reiniciar offline;
- recuperar conectividad;
- sincronizar;
- probar conflicto geométrico y edición concurrente;
- verificar soft delete y descarga delta.

**Salida:** criterio principal del spike satisfecho.

### PoC E: cartografía futura, fuera de la V1

- determinar si se necesita satélite, mapa vial o ambos;
- comparar proveedores/licencias;
- evaluar tiles online, regiones offline y PMTiles/MBTiles;
- reconsiderar `flutter_map` frente a MapLibre con requisitos cartográficos
  reales.

Esta PoC no bloquea la implementación del editor verde.

## 12. Reglas técnicas obligatorias

- Dependencias Flutter con versión fija, sin `^`.
- Entidades y estados inmutables con Freezed.
- Presentation consume solo Use Cases.
- Domain no importa Flutter, Brick, GeoJSON ni Data.
- Brick específico en `lib/brick/models` y `lib/brick/stores`.
- `lib/brick/core/repository.dart` permanece genérico.
- Strings de UI y errores centralizados en `field_strings.dart`.
- Archivos generados no se editan manualmente.
- Generación con `melos run build`.
- Comandos Flutter/Dart mediante FVM.
- Tests con `fvm flutter test` y analyzer sin warnings.
- UUID generado por cliente, timestamps y soft delete para entidades
  sincronizables.
- Validación multi-tenant tanto en Service como mediante RLS.

## 13. Relación futura con animales y alimentación

El lote debe quedar preparado para relacionarse con el modelo existente:

- `Animal.lote_id` representa el lote actual;
- `MovimientoLote` conserva el historial de traslados;
- alimentos/planes pertenecen al contexto del lote y no se copian en cada
  animal;
- cultivos, agua y alimentación necesitan vigencia temporal para reconstruir
  qué contexto tuvo un animal en una fecha.

Este dominio no forma parte del spike espacial V1.

## 14. Criterio de cierre del spike V1

El spike se considera exitoso cuando, con datos sintéticos:

1. el usuario crea un lote sobre el fondo verde usando coordenadas geográficas;
2. la app valida y guarda el lote sin conectividad;
3. el lote sobrevive al cierre y reapertura offline;
4. al recuperar Internet se sincroniza con FastAPI;
5. PostGIS persiste un `Polygon` SRID 4326 válido;
6. los conflictos de permisos, geometría o solapamiento quedan visibles y son
   recuperables;
7. el flujo no depende de tiles ni de ningún servicio cartográfico.
