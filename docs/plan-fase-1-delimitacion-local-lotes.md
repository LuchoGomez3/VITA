# Fase 1: delimitación local de un lote

Fecha: 2026-08-25  
Estado: PoC implementada; pendiente validación manual en emulador/dispositivo  
Instrucciones aplicables: `AGENTS.md` y `mobile/AGENTS.md`

## 1. Objetivo

Definir y probar la primera versión de la experiencia para delimitar un lote en
el móvil mediante vértices, sobre un fondo neutro georreferenciado y sin
conectividad.

Al terminar esta fase debemos saber:

- cómo interactúa el usuario con el editor;
- cómo representar puntos y polígonos sin acoplar el dominio a Flutter;
- cómo convertir toques de pantalla a coordenadas geográficas;
- cómo validar localmente un lote;
- si conviene usar Turf o una implementación Dart acotada;
- qué estructura de archivos usar para implementar posteriormente la feature.

## 2. Alcance

### Incluido

- editor visual con fondo verde/neutro;
- viewport georreferenciado;
- agregar vértices mediante toques;
- seleccionar, mover y eliminar un vértice;
- deshacer, rehacer, limpiar, cancelar y cerrar el polígono;
- nombre del lote como parte del borrador de UI;
- modelo puro de `GeoPoint` y `LotBoundary`;
- validaciones de cantidad de vértices, coordenadas, duplicados, área y
  auto-intersección;
- visualización de superficie estimada;
- evaluación técnica de `flutter_map` sin tiles;
- evaluación de Turf frente a un algoritmo Dart propio;
- tests unitarios del dominio y del estado del editor.

### Fuera de alcance

- guardar en Brick o SQLite;
- sincronización;
- FastAPI, GeoJSON REST, GeoAlchemy2 y PostGIS;
- tiles, mapas viales, satélite y descarga de regiones;
- validación contra otros lotes o reglas de solapamiento;
- asignación o movimiento de animales;
- alimentación, agua, cultivos e infraestructura;
- GPS continuo o recorrido físico del perímetro;
- CRUD productivo completo.

La Fase 1 puede usar datos sintéticos en memoria. Ninguna PoC debe escribir en
la infraestructura offline definitiva.

## 3. Hipótesis técnica principal

Usar `flutter_map` sin `TileLayer` como viewport geográfico:

```text
FlutterMap
├── fondo verde
├── cámara geográfica
├── PolylineLayer: trazo abierto
├── PolygonLayer: polígono cerrado
└── MarkerLayer: vértices
```

Esta hipótesis permite probar pan, zoom y conversión pantalla↔coordenadas sin
implementar un motor de proyección propio y sin efectuar requests de red.

La PoC no debe incorporar `TileLayer`, URL de proveedor ni API key.

Versión candidata relevada: `flutter_map: 8.3.1`. Si se incorpora durante la
PoC, debe fijarse sin `^`, de acuerdo con `mobile/AGENTS.md`.

### Alternativa a comparar

Un `CustomPainter` con gestos propios solo se elegirá si la PoC demuestra que
`flutter_map` impide una interacción necesaria. Elegirlo implica implementar y
mantener:

- proyección geográfica;
- transformación por pan y zoom;
- hit testing de vértices;
- conversión entre pantalla y latitud/longitud;
- restricciones y ajuste del viewport.

La recomendación inicial es no asumir ese costo.

## 4. Referencia geográfica de la PoC

El fondo verde no es un canvas abstracto. Cada vértice debe conservar latitud y
longitud reales aunque la cámara cambie.

Para aislar esta fase del registro real de establecimientos, la PoC recibirá un
objeto en memoria:

```text
LotEditorViewport
├── center: GeoPoint
├── visibleBounds: GeoBounds
└── establishmentBoundary: LotBoundary?  # solo referencia visual
```

Se usarán coordenadas sintéticas anonimizadas de Córdoba. El viewport debe
poder ajustarse a un contorno de establecimiento cuando exista y a
centro+bounds cuando no exista.

La exactitud sobre alambrados reales no se evalúa en esta fase porque no habrá
imagen satelital.

## 5. UX definitiva a validar

### Estado inicial

- título: `Nuevo lote`;
- fondo verde con norte y escala;
- indicación breve: `Tocá el fondo para marcar el primer vértice`;
- acciones de confirmar deshabilitadas;
- cancelar disponible.

### Construcción

1. El primer toque agrega un vértice.
2. Cada toque posterior agrega otro y dibuja un segmento.
3. Con tres o más puntos se muestra un relleno preliminar.
4. El último vértice agregado queda seleccionado.
5. La superficie estimada se actualiza sin bloquear la interacción.
6. Deshacer y rehacer afectan una acción geométrica por vez.

### Edición

- tocar un vértice lo selecciona;
- arrastrarlo actualiza su coordenada;
- eliminar actúa solo sobre el vértice seleccionado;
- limpiar solicita confirmación cuando ya hay varios puntos;
- pan/zoom debe distinguirse del arrastre de un vértice;
- el usuario puede cancelar sin modificar datos externos.

### Cierre

1. El usuario elige `Cerrar lote` o toca el primer vértice con una tolerancia
   visual definida.
2. Se ejecuta la validación completa.
3. Si es inválido, el editor conserva todos los puntos y destaca el problema.
4. Si es válido, se muestra nombre + superficie estimada + acción `Continuar`.
5. `Continuar` devuelve un `LotDraft` en memoria; no persiste todavía.

### Mensajes que deben centralizarse

- faltan vértices;
- hay un punto repetido;
- los lados del lote se cruzan;
- el lote no encierra una superficie;
- una coordenada está fuera de rango;
- el nombre es obligatorio.

Los textos vivirán en `field_strings.dart`, no en widgets o BLoCs.

## 6. Modelo de dominio propuesto

El dominio no importa Flutter, `LatLng`, `Offset`, GeoJSON ni Turf.

```text
GeoPoint
├── latitude: double
└── longitude: double

GeoBounds
├── southWest: GeoPoint
└── northEast: GeoPoint

LotBoundary
└── vertices: List<GeoPoint>

LotDraft
├── name: String
└── boundary: LotBoundary
```

Reglas:

- objetos inmutables con Freezed;
- `LotBoundary.vertices` no repite el primer punto al final;
- el orden es el orden del recorrido del perímetro;
- el modelo no almacena coordenadas de pantalla;
- la superficie se deriva y no se edita manualmente;
- `LotDraft` no incluye UUID, timestamps ni estado de sync en esta fase.

### Resultado de validación

```text
LotBoundaryValidation
├── isValid
├── issues: List<LotBoundaryValidationIssue>
└── estimatedAreaSquareMeters
```

Errores mínimos:

```text
insufficientVertices
invalidCoordinate
duplicateVertex
zeroArea
selfIntersection
```

El dominio devuelve códigos tipados, no textos de UI.

## 7. Validaciones locales

### Mínimo de vértices

- al menos tres puntos distintos;
- cerrar visualmente el anillo no agrega un punto al dominio.

### Coordenadas

- latitud finita entre -90 y 90;
- longitud finita entre -180 y 180.

### Duplicados

- no se permiten puntos consecutivos iguales;
- tampoco un mismo punto repetido en otra posición del anillo;
- la tolerancia numérica debe definirse y probarse.

### Área

- el polígono debe encerrar superficie positiva;
- la UI muestra una estimación;
- la PoC debe documentar si usa cálculo geodésico o una aproximación local y
  su margen de error;
- esta superficie no será todavía la fuente definitiva del backend.

### Auto-intersección

- al agregar un vértice se puede advertir si el nuevo segmento cruza uno
  anterior no adyacente;
- al cerrar se valida también el segmento último→primero;
- la validación final es obligatoria aunque existan advertencias incrementales.

### No incluido

No se validará solapamiento con otros lotes en esta fase. Esa regla necesita
cerrar primero su alcance funcional y pertenece a una fase posterior.

## 8. Evaluación de Turf

La PoC debe responder una pregunta concreta: ¿Turf reduce riesgo y código sin
contaminar el dominio?

### Capacidades a comprobar

- validez de un polígono simple;
- detección de auto-intersección;
- cálculo de área;
- tratamiento de puntos duplicados y colineales;
- comportamiento cerca de bordes/tolerancias;
- costo con 10, 50, 200 y 500 vértices;
- soporte y mantenimiento del paquete;
- licencia y tamaño agregado.

Versión candidata relevada: `turf: 0.0.12`, sujeta a verificación al iniciar la
PoC y fijada sin `^` si se adopta.

### Regla arquitectónica

Los tipos GeoJSON de Turf no deben aparecer en `GeoPoint`, `LotBoundary`, el
BLoC ni la UI.

Si se usa Turf:

```text
Domain
LotBoundaryValidator (contrato)
        ↑
Data / geometry
TurfLotBoundaryValidator
└── traduce LotBoundary ↔ tipos Turf internamente
```

Si se elige un algoritmo propio puro, puede implementarse detrás del mismo
contrato. La presentación y los casos de uso no cambian.

### Criterio de decisión

Adoptar Turf solo si:

1. cubre las cinco validaciones de esta fase sin depender de APIs internas;
2. los casos degenerados producen resultados consistentes;
3. su modelo no se filtra fuera del adaptador;
4. los tests propios verifican los criterios, no solo que la librería responda;
5. la dependencia y versión quedan justificadas en el relevamiento.

### Resultado de la PoC

Se adopta una solución híbrida detrás de `LotBoundaryValidator`:

- Turf `0.0.12` transforma el anillo a GeoJSON, realiza su validación general y
  calcula el área geodésica estimada en metros cuadrados;
- un algoritmo Dart acotado verifica cruces entre segmentos no adyacentes;
- la fórmula de área plana firmada intercepta anillos colineales antes del
  cálculo geodésico;
- las comprobaciones simples de cantidad, rango y duplicados permanecen en el
  adaptador.

La suite mostró que `booleanValid` de Turf Dart no rechaza por sí solo un
polígono tipo *bow-tie*. También mostró que tres coordenadas geográficas
colineales pueden producir una superficie geodésica residual mayor que cero.
Por eso no se adopta Turf como único validador topológico. Sus tipos continúan
aislados en `data/geometry`, de modo que el motor puede reemplazarse sin cambiar
dominio, BLoC ni widgets.

La complejidad del chequeo de cruces es O(n²), adecuada para la cantidad de
vértices esperada en la primera versión. La medición con 200 y 500 vértices
queda pendiente para cerrar formalmente el spike.

## 9. Estado del editor

La interacción es suficientemente compleja para usar BLoC.

Estado conceptual:

```text
LotEditorState
├── draft: LotDraft
├── selectedVertexIndex: int?
├── undoStack
├── redoStack
├── isClosed
├── validation: LotBoundaryValidation
└── canContinue
```

Eventos principales:

```text
vertexAdded
vertexSelected
vertexMoved
selectedVertexDeleted
undoRequested
redoRequested
clearRequested
boundaryCloseRequested
nameChanged
continueRequested
```

El BLoC coordina el borrador y consume casos de uso/servicios de dominio. No
conoce `flutter_map`; la página traduce `LatLng` a `GeoPoint` en el borde de
presentación.

## 10. Estructura de archivos limitada a la Fase 1

Se evoluciona `features/field`, donde ya está la UI mock de potreros.

```text
mobile/lib/features/field/
├── field_composition.dart
├── presentation/
│   ├── bloc/
│   │   ├── lot_editor_bloc.dart
│   │   ├── lot_editor_event.dart
│   │   └── lot_editor_state.dart
│   ├── pages/
│   │   └── lot_editor_page.dart
│   ├── strings/
│   │   └── field_strings.dart
│   └── widgets/
│       ├── geographic_lot_editor.dart
│       ├── lot_editor_toolbar.dart
│       ├── lot_vertex_marker.dart
│       ├── lot_validation_message.dart
│       └── lot_draft_summary.dart
├── domain/
│   ├── entities/
│   │   ├── geo_point.dart
│   │   ├── geo_bounds.dart
│   │   ├── lot_boundary.dart
│   │   └── lot_draft.dart
│   ├── services/
│   │   └── lot_boundary_validator.dart
│   └── use_cases/
│       └── validate_lot_placement_use_case.dart
└── data/                         # solo si Turf es elegido
    └── geometry/
        └── turf_lot_boundary_validator.dart
```

No se crean en esta fase:

```text
brick/models/lot.model.dart
brick/stores/lot_brick_store.dart
data/repositories/lot_repository_impl.dart
backend/api/modules/lotes/*
```

## 11. Plan de trabajo

### Paso 1: cerrar wireflow

- dibujar estados inicial, construcción, edición, error y confirmación;
- definir gestos y prioridad entre mover vértice y mover cámara;
- aprobar textos y controles con Producto/Figma.

**Salida:** wireflow aprobado.

### Paso 2: PoC del viewport

- probar `flutter_map` sin `TileLayer`;
- configurar fondo verde y bounds sintéticos;
- convertir toque a `GeoPoint`;
- comprobar estabilidad de coordenadas con pan/zoom;
- comprobar selección y arrastre de vértices.

**Salida:** decisión `flutter_map` frente a editor propio.

### Paso 3: dominio y validación

- definir entidades Freezed;
- definir contrato y resultado tipado del validador;
- implementar casos de prueba antes de elegir el motor geométrico;
- comparar Turf con implementación acotada.

**Salida:** decisión documentada sobre Turf y suite de tests del dominio.

### Paso 4: estado de presentación

- implementar eventos/transiciones del BLoC en la PoC;
- probar undo/redo, cierre, errores y `canContinue`;
- mantener toda persistencia como fake/in-memory.

**Salida:** flujo funcional de registro hasta producir un `LotDraft` válido.

### Paso 5: evaluación

- ejecutar en emulador y al menos un dispositivo real;
- probar completamente sin conectividad;
- medir fluidez con distintos números de vértices;
- registrar limitaciones de precisión y usabilidad del fondo neutro;
- decidir si la Fase 2 puede comenzar sin cambios de dominio.

**Salida:** relevamiento técnico cerrado y demo descartable/reutilizable según
calidad.

## 12. Matriz mínima de pruebas

| Caso | Resultado esperado |
| --- | --- |
| 0, 1 o 2 puntos | No permite cerrar |
| Triángulo válido | Permite cerrar y calcula área |
| Punto duplicado | Error tipado |
| Tres o más puntos colineales | Área cero |
| Polígono bow-tie | Auto-intersección |
| Cruce creado por el segmento de cierre | Auto-intersección |
| Latitud/longitud fuera de rango | Coordenada inválida |
| Pan/zoom después de dibujar | Las coordenadas no cambian |
| Mover un vértice | Recalcula forma, validación y área |
| Deshacer/rehacer | Restaura exactamente el borrador anterior |
| 200 vértices | Interacción fluida según umbral definido en PoC |
| Dispositivo sin red | Editor completo sigue funcionando |

## 13. Definition of Done de la Fase 1

La fase termina cuando:

- el wireflow de registro por vértices está aprobado;
- se eligió y justificó viewport `flutter_map` o alternativa;
- `GeoPoint`, `GeoBounds`, `LotBoundary` y `LotDraft` tienen contrato definido;
- las cinco validaciones locales tienen comportamiento y tests definidos;
- se tomó una decisión documentada sobre Turf;
- la PoC produce un `LotDraft` válido totalmente offline;
- se verificó pan/zoom y edición en dispositivo real;
- no se agregó Brick, backend ni cartografía al alcance;
- las conclusiones permiten estimar la siguiente fase.

## 14. Entregables

1. Wireflow/Figma de `Nuevo lote`.
2. Decisión técnica del viewport geográfico.
3. Decisión técnica Turf versus algoritmo propio.
4. Contratos de dominio y validación.
5. PoC local sin persistencia.
6. Tests de geometría y BLoC.
7. Informe breve de resultados, riesgos y recomendación para Fase 2.
