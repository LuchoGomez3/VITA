# Plan mobile: gestión de lotes offline-first

Fecha: 2026-08-30  
Estado: aprobado para implementación por fases  
Alcance: aplicación Flutter/mobile  
Instrucciones consideradas: `AGENTS.md`, `mobile/AGENTS.md` y
`mobile/lib/brick/README.md`

## 1. Objetivo

Completar en mobile la gestión de lotes de un establecimiento para que el
productor pueda crear, consultar, editar, inactivar y eliminar lotes sin
conectividad, y pueda utilizarlos posteriormente para ubicar y mover animales.

La primera versión espacial continuará usando el lienzo verde cartesiano que ya
existe. No se presentará esa geometría como GPS ni como una ubicación real. La
arquitectura conservará explícitamente el tipo y la versión de las coordenadas
para incorporar cartografía real más adelante sin reinterpretar datos viejos.

Al finalizar este plan, mobile debe quedar funcional de manera local y tener
preparado y probado el contrato de sincronización de lotes. La ejecución de
requests remotos permanecerá deshabilitada hasta que backend implemente y valide
el contrato.

## 2. Decisiones cerradas

- El flujo de alta tendrá dos pasos:
  1. nombre y delimitación mediante vértices y superficie declarada
  2. recurso forrajero, agua, estado y confirmación.
- La geometría V1 utiliza un espacio cartesiano local compartido por los lotes
  del establecimiento: `establishment_canvas_v1`, con extensión lógica
  `1000 x 1000`.
- La superficie productiva en hectáreas es declarada por el usuario. El área
  relativa del polígono se usa solamente para validar la geometría y no es una
  conversión a hectáreas.
- La superficie se persiste como décimas exactas de hectárea: `457` representa
  `45,7 ha`. Esto evita errores de punto flotante y garantiza un decimal.
- El recurso forrajero es un catálogo identificado por un código estable, no un
  enum cerrado. El catálogo inicial podrá incluir `pasto_natural`, `alfalfa`,
  `sorgo`, `maiz`, `avena` y `otro`.
- La disponibilidad de agua es un booleano obligatorio.
- El estado es un enum local: `active`, `resting`, `maintenance`, `inactive`.
- Todos los lotes no eliminados, incluidos los inactivos, ocupan espacio y
  participan en la validación de superposición.
- Compartir un vértice, un límite completo o una porción de borde es válido.
  Se rechazan la intersección con área positiva, la contención y los polígonos
  coincidentes.
- Inactivar y eliminar son operaciones diferentes. Eliminar crea un borrado
  lógico mediante `deletedAt`; el lote deja de mostrarse y de bloquear espacio.
- No se implementará restauración en esta versión: el espacio de un lote
  eliminado puede haber sido ocupado por otro.
- No se puede inactivar ni eliminar un lote que tenga animales asignados.
- Después de crear un lote, su geometría queda bloqueada. Los datos
  alfanuméricos sí son editables. Se dejará un TODO documentado para un flujo
  futuro de corrección geométrica explícita.
- No se implementará una matriz de permisos mobile. El flujo se diseñará para
  `owner` y se dejará un TODO hasta que se definan los tres roles finales. La
  autorización definitiva seguirá siendo responsabilidad de backend.
- Los lotes locales actuales son datos de desarrollo/mock. No es requisito
  migrar su contenido funcional; sí se debe generar correctamente el nuevo
  esquema Brick. Durante desarrollo se podrá limpiar la base local.
- El estado técnico de sincronización no se mostrará en la UI de esta versión.

## 3. Alcance

### Incluido

- modelo de dominio completo del lote;
- catálogo local inicial de recursos forrajeros;
- persistencia durable con Brick/SQLite;
- alta en dos pasos;
- validación geométrica y de superposición local;
- unicidad local del nombre por establecimiento;
- edición de datos alfanuméricos;
- cambios de estado y borrado lógico;
- vista gráfica esquemática y vista de listado;
- pantalla de detalle;
- conteo y listado de animales por lote usando la caché local;
- selección de lotes reales en el registro de animales;
- movimiento local de animales entre lotes como última integración funcional;
- DTO, rutas, mappers y flujo de sync de lotes preparado y probado con dobles,
  pero deshabilitado mediante configuración;
- tests automáticos y guía de pruebas manuales offline.

### Fuera de alcance

- mapas reales, satélite, tiles, caché cartográfica y permisos de ubicación;
- latitud/longitud, GeoJSON geográfico y PostGIS;
- transformación automática del lienzo verde a coordenadas reales;
- sincronización efectiva contra un backend de lotes inexistente;
- resolución definitiva de permisos por rol;
- restauración de lotes eliminados;
- edición de geometría después del alta;
- cálculo de receptividad y alertas de sobrepastoreo;
- historial de pasturas, agua o infraestructura;
- refinamiento visual avanzado de tooltips y animaciones.

## 4. Estado actual reutilizable

La implementación existente ya aporta:

- `LocalPoint`, `LotBoundary`, `LotDraft` y una entidad `Lot` básica;
- validación de mínimo de vértices, coordenadas, duplicados, área nula y
  auto-intersección;
- editor con creación, selección y arrastre de vértices;
- serialización versionada de la geometría cartesiana local;
- `BrickLotModel`, `LotBrickStore`, repositorio y casos de uso básicos;
- guardado y lectura desde SQLite sin encolar requests remotos;
- visualización de lotes existentes al crear uno nuevo;
- un visor gráfico, un listado todavía mockeado y un detalle inicial;
- tests del validador, editor, mapper, store y guardado.

El plan debe evolucionar estas piezas; no crear una segunda implementación
paralela.

## 5. Arquitectura objetivo

Se mantiene la dependencia obligatoria:

```text
field/presentation
        ↓
field/domain (entidades, reglas, contratos y casos de uso)
        ↓
field/data (repositorios y mappers)
        ↓
brick/models + brick/stores
        ↓
SQLite local
```

Reglas de implementación:

- Presentation consume solamente casos de uso.
- Domain no conoce Flutter, Brick, SQLite, REST ni GeoJSON.
- La lógica propia de lotes no se agrega a
  `brick/core/repository.dart`; pertenece a `LotBrickStore`.
- Los archivos generados de Freezed y Brick no se editan manualmente.
- La composición e inyección seguirá siendo explícita en
  `field_composition.dart`, sin introducir otro framework.
- La integración con animales no puede importar implementaciones internas de
  otra feature. Se hará mediante contratos pequeños e inyección desde la raíz
  de composición, o consultando stores compartidos desde Data cuando
  corresponda.
- Los widgets genéricos ya existentes en `core/widgets`, los tokens de
  `core/theme` y los formatters compartidos se reutilizan. Solo se crean dentro
  de `field` los componentes específicos de lotes.
- Todo texto de producto de la feature se centraliza en `field_strings.dart`.

## 6. Modelo de dominio objetivo

```text
Lot
├── id: String                         # UUID generado en mobile
├── establishmentId: String
├── name: String
├── surfaceTenths: int                # 457 = 45,7 ha
├── forageResourceCode: String?
├── hasWater: bool
├── status: LotStatus
├── geometry: LotGeometry
├── createdAt: DateTime
├── updatedAt: DateTime
└── deletedAt: DateTime?

LotGeometry
├── mode: LotGeometryMode             # localSchematic | geographic (futuro)
├── coordinateSpace: String           # establishment_canvas_v1
├── version: int                      # 1
├── extent: LocalBounds               # 0..1000, 0..1000
└── boundary: LotBoundary

LotBoundary
└── vertices: List<LocalPoint>         # no repite el primer punto al final
```

Tipos complementarios:

- `LotStatus`: enum de estados con reglas tipadas, sin usar textos de UI como
  valores persistidos.
- `ForageResource`: entidad de catálogo con `code`, `displayName` y `active`.
- `LotSurface`: value object que valida entero positivo de décimas y expone la
  conversión de presentación a un decimal.
- `LotAnimalSummary`: proyección de lectura para detalle/listado; la entidad
  `Lot` no contiene una lista de animales.

La relación sigue siendo uno-a-muchos mediante `Animal.lotId`. El conteo y la
lista de animales son datos derivados de la caché local, no campos persistidos
dentro del lote.

## 7. Estructura de archivos prevista

Se conservarán los archivos existentes y se agregarán únicamente los que las
fases necesiten. La estructura objetivo orientativa es:

```text
lib/features/field/
├── domain/
│   ├── entities/
│   │   ├── lot.dart
│   │   ├── lot_geometry.dart
│   │   ├── lot_status.dart
│   │   ├── lot_surface.dart
│   │   ├── forage_resource.dart
│   │   └── lot_animal_summary.dart
│   ├── repositories/
│   │   ├── lot_repository.dart
│   │   ├── forage_resource_repository.dart
│   │   └── lot_animal_repository.dart
│   ├── services/
│   │   ├── local_lot_boundary_validator.dart
│   │   └── lot_overlap_validator.dart
│   └── use_cases/
│       ├── create_lot_use_case.dart
│       ├── update_lot_details_use_case.dart
│       ├── change_lot_status_use_case.dart
│       ├── delete_lot_use_case.dart
│       ├── get_lot_detail_use_case.dart
│       └── get_lot_animals_use_case.dart
├── data/
│   ├── mappers/
│   └── repositories/
└── presentation/
    ├── bloc/                    # alta en dos pasos
    ├── cubit/                   # overview y detalle
    ├── pages/
    ├── strings/
    └── widgets/

lib/brick/
├── models/lot.model.dart
└── stores/lot_brick_store.dart
```

Los nombres finales podrán ajustarse para evitar clases o carpetas artificiales,
pero no se alterarán las responsabilidades de las capas.
Si es mejor integrar cubit y bloc en un solo bloc, hacerlo, si es necesaria la division de bloc y cubit, dejarla entonces

## 8. Plan de implementación

### Fase 0 — Baseline y decisiones técnicas pequeñas

Objetivo: asegurar que la base actual sea estable antes de ampliar el modelo.

Tareas:

- ejecutar analyzer y tests actuales, registrando cualquier fallo preexistente;
- retirar del flujo productivo los mocks de `field_list_page.dart`;
- inventariar los componentes reutilizables de `core/widgets`, `core/theme`,
  formatters y validadores;
- corregir y probar el clamp entre coordenadas de pantalla y el espacio
  `0..1000`, incluyendo arrastre en bordes, zoom y tamaños distintos;
- hacer una evaluación acotada de Turf para superposición de polígonos
  cartesianos:
  - soporte real del paquete Dart mantenido;
  - semántica ante bordes/vértices compartidos;
  - contención y polígonos coincidentes;
  - tamaño, licencia y compatibilidad con las versiones del proyecto;
- adoptar Turf solamente si resuelve estos casos de manera determinista. Si no,
  implementar un servicio puro acotado y cubierto por una matriz exhaustiva de
  tests. La decisión se documentará sin mezclarla con Presentation. Es decir en general utilizar Turf, pq ya nos da todo lo encesario, si no ahi si crear funciones propias.

Criterio de salida:

- editor actual estable en el espacio local y decisión de validador de
  superposición tomada con evidencia.

### Fase 1 — Modelo completo y esquema Brick

Objetivo: establecer una única representación durable del lote.

Tareas:

- ampliar `Lot`, `LotDraft` y los mappers con superficie, forraje, agua, estado
  y metadatos geométricos;
- introducir el value object de superficie en décimas positivas;
- crear el catálogo local inicial de recursos forrajeros con códigos estables;
- persistir enum/códigos como valores explícitos y tolerar valores desconocidos
  provenientes de un backend futuro sin romper la lectura local;
- ampliar `BrickLotModel` con las nuevas columnas y campos técnicos necesarios;
- regenerar Freezed, adapters, schema y migración Brick mediante el comando de
  generación acordado;
- adaptar `LotBoundaryLocalJsonMapper` para mantener `coordinateSpace`, versión,
  extensión y vértices;
- limpiar la base de desarrollo si los mocks anteriores no son compatibles;
- ampliar repositorio/store para consultar vigentes, consultar con eliminados,
  actualizar y guardar tombstones con aislamiento por establecimiento.

Tests mínimos:

- superficie: cero, negativo, redondeo a un decimal y round-trip;
- round-trip dominio ↔ Brick de todos los campos;
- códigos de estados y forrajes conocidos/desconocidos;
- filtrado por establecimiento y exclusión de borrados;
- migración/esquema generado consistente.

Criterio de salida:

- un lote completo sobrevive al cierre y reapertura de la app sin red.

### Fase 2 — Alta en dos pasos y reglas geométricas

Objetivo: completar el flujo principal de registro local.

Tareas:

- convertir el alta en un flujo de dos pasos con un BLoC dueño del borrador
  completo, para volver del paso 2 al paso 1 sin perder datos;
- paso 1: nombre obligatorio, editor por vértices y visualización de lotes
  existentes no eliminados;
- paso 2: superficie en hectáreas, recurso forrajero opcional, disponibilidad de
  agua, estado inicial y resumen del perímetro;
- usar `AppTextFormField`, `AppDropdownFormField`, selectores, botones y tokens
  existentes antes de crear widgets nuevos;
- validar nombre normalizado y case-insensitive dentro del establecimiento;
- mostrar claramente el límite del lienzo, atenuar el exterior, impedir toques
  fuera de él y mantener cámara/vértices dentro de los bounds;
- validar superposición mientras se edita para dar feedback temprano;
- repetir toda la validación inmediatamente antes de guardar para evitar una
  condición de carrera con cambios locales;
- excluir el propio UUID en cualquier validación futura de edición;
- conservar los puntos cuando hay error y señalar el problema sin borrar el
  trabajo del usuario;
- guardar en SQLite antes de mostrar éxito, sin consultar conectividad ni
  backend;
- reemplazar la superficie relativa visible como dato productivo por la
  superficie declarada en hectáreas. El área relativa queda como diagnóstico
  interno de geometría.

Matriz obligatoria de superposición:

- separado: permitido;
- vértice compartido: permitido;
- borde parcial o completo compartido: permitido;
- cruce con área positiva: rechazado;
- lote nuevo contenido en otro: rechazado;
- lote existente contenido en el nuevo: rechazado;
- polígonos idénticos: rechazado;
- contacto con lote inactivo: aplica las mismas reglas;
- contacto con lote eliminado: ignorado.

Criterio de salida:

- crear varios lotes adyacentes funciona offline y ningún lote con área
  superpuesta puede guardarse.

### Fase 3 — Edición y ciclo de vida local

Objetivo: completar el manejo del lote una vez creado.

Tareas:

- editar nombre, superficie, recurso forrajero, agua y estado;
- mantener bloqueada la geometría y dejar el TODO de corrección futura en el
  límite de dominio/presentación correspondiente;
- conservar unicidad de nombre también al editar, excluyendo el propio lote;
- implementar las transiciones permitidas entre estados;
- antes de pasar a `inactive`, consultar el conteo local de animales y rechazar
  la operación si es mayor que cero;
- implementar eliminación con confirmación y `deletedAt`;
- rechazar eliminación si existen animales asignados;
- excluir tombstones de vistas, selección de animales y superposición;
- no ofrecer restauración.

Tests mínimos:

- edición conserva UUID y `createdAt`, y actualiza `updatedAt`;
- duplicado por cambio de mayúsculas/minúsculas;
- inactivación y borrado con/sin animales;
- un lote eliminado libera el espacio para otro;
- un lote inactivo continúa bloqueándolo.

Criterio de salida:

- CRUD local completo dentro de las reglas acordadas.

### Fase 4 — Overview gráfico, listado y detalle

Objetivo: que toda la consulta de lotes use la misma fuente SQLite.

Tareas:

- hacer que vista gráfica y listado consuman el mismo Cubit/casos de uso;
- reemplazar `paddocksMock` y cualquier contador fijo;
- ofrecer un toggle accesible entre ambas vistas sin perder el establecimiento
  seleccionado ni recargar datos innecesariamente;
- listado: nombre, hectáreas, recurso forrajero, agua, estado y cantidad de
  animales;
- vista gráfica: perímetro, nombre y color básico por estado sobre el lienzo
  esquemático; no etiquetarla como mapa georreferenciado;
- tocar una tarjeta o un polígono navega al mismo detalle;
- detalle: geometría, campos editables, fechas, estado, conteo y lista de
  animales, con acciones de editar, cambiar estado y eliminar;
- implementar una primera versión simple del resumen al seleccionar un lote si
  mejora la navegación, sin bloquear la fase por un tooltip refinado;
- incluir estados de carga, vacío, error y reintento con textos centralizados;
- no mostrar badges de sincronización ni pendientes remotos.

Criterio de salida:

- al crear o modificar un lote, volver al overview refleja inmediatamente el
  dato en ambas vistas y el detalle correcto se abre desde cualquiera de ellas.

### Fase 5 — Contrato y sincronización mobile preparados, apagados

Objetivo: dejar lista la mitad mobile de la integración sin generar tráfico ni
requests fallidas.

Tareas:

- agregar en configuración técnica una bandera de compilación, por ejemplo
  `VITA_ENABLE_LOT_REMOTE_SYNC`, cuyo valor por defecto sea `false`;
- con la bandera apagada:
  - persistir solamente en SQLite;
  - no encolar requests;
  - no iniciar pull remoto;
  - confirmar en UI `Lote guardado en el dispositivo`;
- con la bandera encendida en tests:
  - guardar local primero;
  - encolar upsert/tombstone;
  - hacer pull filtrado por establecimiento;
  - aplicar last-write-wins por `updatedAt`;
  - procesar respuesta y errores sin perder el registro local;
- centralizar rutas y transformaciones en el modelo/store de lotes;
- probar el flujo con HTTP falso, sin depender del backend real;
- documentar cómo activar la bandera cuando el contrato sea aprobado.

Contrato propuesto para validar con backend:

```text
POST /api/v1/lotes
GET  /api/v1/lotes?establecimiento_id={uuid}&updated_since={iso8601}
GET  /api/v1/lotes/{uuid}
```

Para simplificar la cola offline, `POST /api/v1/lotes` se propone como upsert
idempotente por UUID generado en el cliente. Una actualización y un borrado
lógico viajan por el mismo mecanismo con `updated_at` y `deleted_at`. Backend
deberá confirmar esta decisión antes de activar requests.

Payload mobile propuesto:

```json
{
  "id": "uuid-generado-en-mobile",
  "establecimiento_id": "uuid-establecimiento",
  "nombre": "Potrero Bajo",
  "superficie_ha": 45.7,
  "recurso_forrajero_codigo": "alfalfa",
  "tiene_agua": true,
  "estado": "active",
  "geometry_mode": "local_schematic",
  "geometria_local": {
    "coordinate_space": "establishment_canvas_v1",
    "version": 1,
    "extent": {"width": 1000.0, "height": 1000.0},
    "vertices": [
      {"x": 120.0, "y": 180.0},
      {"x": 620.0, "y": 180.0},
      {"x": 400.0, "y": 720.0}
    ]
  },
  "created_at": "2026-08-30T15:00:00Z",
  "updated_at": "2026-08-30T15:00:00Z",
  "deleted_at": null
}
```

La geometría esquemática debe almacenarse en backend como datos versionados
separados de una futura geometría PostGIS. Nunca se convierte este payload en
GeoJSON WGS84 por suposición.

Criterio de salida:

- todos los caminos remotos pasan con dobles al encender la bandera en tests y
  una ejecución normal no produce ningún request de lotes.

### Fase 6 — Lectura de animales e integración con su registro

Objetivo: conectar lotes terminados con la feature de animales sin acoplar sus
implementaciones.

Tareas:

- exponer desde Data una consulta local de animales por `lotId` y
  `establishmentId`;
- obtener conteos para listado/gráfico y los animales individuales para el
  detalle;
- reemplazar opciones mock de lote del registro de animales por lotes locales
  del establecimiento;
- inyectar la fuente de opciones desde la composición de la app, sin que
  `animal_register` dependa de clases internas de `field`;
- permitir como destino solamente lotes no eliminados y en estado `active`;
- conservar una referencia válida por UUID y actualizar el nombre derivado que
  se muestra en UI;
- definir estado vacío claro cuando todavía no hay lotes disponibles;
- mantener el registro de animal offline-first usando el store existente.

Criterio de salida:

- un animal registrado localmente puede elegir un lote real, y aparece de
  inmediato en el conteo y detalle de ese lote.

### Fase 7 — Movimiento local de animales entre lotes

Objetivo: completar el seguimiento mobile previsto una vez estable la feature
de lotes.

Se implementará como integración o subfeature de movimientos, no como lógica
embebida en widgets de `field`.

Tareas:

- seleccionar uno o varios animales desde un lote origen;
- seleccionar un lote destino `active`, del mismo establecimiento y distinto
  del origen;
- registrar fecha, motivo y responsable conforme al modelo que se acuerde;
- ejecutar en una operación local coherente:
  - crear el movimiento con UUID y timestamps;
  - actualizar `lotId` de los animales;
  - refrescar conteos de origen y destino;
- evitar mover hacia lotes inactivos, en descanso, mantenimiento o eliminados;
- preparar DTO/store/cola detrás de una bandera remota apagada;
- documentar la dependencia de sincronización: un lote creado localmente debe
  existir en backend antes de sincronizar animales o movimientos que lo
  referencian;
- ante fallo local, no dejar parcialmente actualizado el lote de los animales.

Criterio de salida:

- el movimiento funciona sin internet y se refleja de inmediato en ambos
  detalles; el envío remoto permanece deshabilitado.

### Fase 8 — Hardening, pruebas y documentación

Objetivo: cerrar el alcance con evidencia automática y una guía reproducible.

Tareas:

- ejecutar generación, formatter, analyzer y suite completa con FVM;
- unit tests de entidades, value objects, validadores, casos de uso, mappers,
  repositorios y stores;
- tests de BLoC/Cubit para alta, overview, edición, detalle y movimientos;
- widget tests de los flujos críticos:
  - alta en dos pasos;
  - error de superposición;
  - cambio entre gráfico/listado;
  - bloqueo de inactivación/eliminación con animales;
- prueba de persistencia reiniciando el repositorio/base en un entorno de test;
- prueba de que la bandera apagada genera cero requests y cero entradas de cola;
- actualizar README técnico de Brick y documentación de la feature;
- dejar los TODOs de permisos, geometría editable y mapa real con alcance y
  condición de resolución, no como comentarios vagos.

Criterio de salida:

- analyzer sin observaciones nuevas, suite verde y checklist manual entregado.

## 9. Escenarios de aceptación mobile

1. El usuario crea un lote con nombre, polígono válido y datos completos sin
   internet; aparece al volver y continúa después de reiniciar la app.
2. El usuario crea lotes adyacentes compartiendo vértices o bordes.
3. El sistema rechaza cruce, contención o coincidencia con cualquier lote no
   eliminado del mismo establecimiento.
4. El nombre duplicado se rechaza ignorando mayúsculas y espacios extremos.
5. Vista gráfica y listado muestran los mismos lotes y abren el mismo detalle.
6. El usuario modifica superficie, forraje, agua y estado sin modificar la
   geometría.
7. Un lote con animales no puede inactivarse ni eliminarse.
8. Un lote sin animales se elimina lógicamente, desaparece y libera su espacio.
9. El registro de un animal usa lotes `active` obtenidos de SQLite.
10. Un movimiento local cambia el animal de lote y actualiza ambos conteos.
11. Con sync de lotes deshabilitada no se envía ni se encola ningún request.
12. Los datos de un establecimiento nunca aparecen en otro.

## 10. Orden de entrega recomendado

Cada fase debe cerrar tests y revisión antes de avanzar. La secuencia es:

```text
baseline
  → modelo + Brick
  → alta + superposición
  → edición + borrado
  → gráfico/listado/detalle
  → sync preparado y apagado
  → animales en lotes
  → movimientos
  → hardening
```

Las fases 0 a 4 constituyen el núcleo puro de lotes. Las fases 6 y 7 no deben
comenzar hasta que ese núcleo sea estable. La fase 5 puede desarrollarse sin
backend, pero su bandera no se activa hasta una validación conjunta del contrato.

## 11. Dependencias y riesgos

- **Contrato backend pendiente:** mobile propone el payload y comportamiento,
  pero el equipo backend debe aprobarlos y puede requerir ajustes antes de
  activar la bandera.
- **Semántica geométrica:** la tolerancia numérica y los contactos de borde deben
  quedar fijados por tests para evitar resultados diferentes entre dispositivos.
- **Catálogos:** los códigos iniciales de forraje deben ser confirmados por
  Producto/backend; mobile debe conservar códigos desconocidos durante sync.
- **Movimientos:** se necesita acordar el modelo backend antes de activar su
  sincronización, aunque el flujo local pueda completarse.
- **Mapa real futuro:** requerirá una historia técnica separada para proveedor,
  permisos, tiles, costos, caché y transformación/asociación de geometrías.
- **Roles:** la UI no debe presentarse como control de seguridad mientras la
  definición de roles esté pendiente.

## 12. Definition of Done de este plan mobile

- fases 0 a 8 implementadas y revisadas;
- no quedan mocks en los caminos productivos de lotes;
- funcionamiento offline probado con cierre y reapertura;
- tests automáticos cubren las reglas críticas;
- analyzer y CI de mobile en verde;
- requests remotos de lotes y movimientos apagados por defecto;
- contrato mobile documentado y listo para revisión del equipo backend;
- prueba manual en emulador/dispositivo realizada por el responsable frontend;
- documentación y TODOs futuros actualizados;
- PR aprobado y mergeado conforme al Working Agreement.

## 13. Relación con documentos anteriores

Este documento reemplaza como plan operativo las partes de
`spike-delimitacion-espacial-lotes.md` y
`plan-fase-1-delimitacion-local-lotes.md` que describen el fondo verde mediante
latitud/longitud real. La implementación vigente usa coordenadas cartesianas
locales de referencia propia. La investigación de cartografía real, GeoJSON
WGS84 y PostGIS queda para un plan separado.
