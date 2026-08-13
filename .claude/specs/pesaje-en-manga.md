---
name: pesaje-en-manga
description: >-
  Flujo de captura de peso en la manga (Bluetooth/Manual/Foto) — pantallas,
  secciones y datos mock del diseño de referencia. Documento vivo, se
  actualiza en el mismo commit que introduce cada pieza descripta acá.
---

# Pesaje en manga

Captura del peso de cada animal durante el paso por la manga, para poder
calcular GPD (ganancia diaria de peso). Es el caso de uso central de
"offline-first en el campo, sin conectividad" que menciona CLAUDE.md. Se llega
por un atajo de desarrollo desde `livestock_page.dart`.

Ver también **[`estado-pantallas-diseno.md`](./estado-pantallas-diseno.md)**.

## Pantallas → rutas

| Pantalla (Claude Design) | Página Flutter | Ruta |
|---|---|---|
| `PesajeBluetooth` | `WeighingPage` (tab Bluetooth) | `/pesaje` |
| `PesajeManual` | `WeighingPage` (tab Manual) | `/pesaje` (mismo estado, tab distinta) |
| `PesajeGuardado` | Toast sobre `WeighingPage`, no una ruta aparte | — |

**No son 3 pantallas separadas**: el diseño (`PesajeShell`) es una sola base
parametrizable con 3 tabs (Bluetooth / Manual / Por foto) más un toast de
confirmación. En Flutter es **una sola página** (`WeighingPage`,
`StatefulWidget`) con `TabBar`/`TabBarView` de 2 tabs habilitadas y una
tercera deshabilitada, más un `SnackBar`/overlay para el estado "guardado".

## Contenido por pantalla

### Header común (ambas tabs)

- Botón circular de cerrar (X) → sale del flujo.
- `Caravana` del animal actual: **003 1284**, color amarillo (`#f4cf3d`).
- RFID mono: **982 000 412 884 712**.
- Raza/categoría: **Aberdeen Angus · Vaca**.
- Chip de progreso del lote: **8 / 142**.

### Tab Bluetooth (`PesajeBluetooth`)

- Lectura de peso gigante y centrada: **442 kg**.
- Chip verde: "GPD vs. anterior: **+0,85** kg/día".
- Pill de estado de conexión: "Balanza Magris MC-200 · estable".
- Tabs inferiores: Bluetooth (activa) / Manual / Por foto (deshabilitada,
  rótulo "Próximamente").
- CTA fijo: "Guardar pesaje".

### Tab Manual (`PesajeManual`)

- Mismo header de animal.
- Peso ingresado mostrado en grande: **442 kg** (color primario).
- Numpad propio (no teclado del sistema): grid 3 columnas — `1 2 3 / 4 5 6 /
  7 8 9 / , 0 ⌫`. Decimal con coma (formato es-AR).
- Mismas tabs inferiores, "Manual" activa.
- CTA fijo: "Guardar pesaje".

### Confirmación (`PesajeGuardado`)

- Toast flotante sobre la tab Bluetooth: círculo verde con check, título
  "Pesaje guardado", subtítulo "GPD vs. anterior: +0,85 kg/día · Avanzando al
  siguiente animal…".
- Efecto: vuelve a la tab Bluetooth con el siguiente animal del lote (9/142),
  repitiendo el ciclo hasta agotar el lote mock.

## Estado de la Etapa 1 (maquetado)

_A completar en `feature/pantalla-pesaje` cuando se maquete la página._
Introduce el widget compartido `AppEarTagBadge` en `core/widgets/` (caravana
con color de plástico + número mono), reusado luego por Sanidad.

## Explícitamente fuera de alcance de esta iniciativa

- Tab "Por foto": se muestra deshabilitada con "Próximamente", no se
  implementa estimación de peso por imagen (eso es todo `ai_models/`, fuera
  del MVP según CLAUDE.md).
- Conexión real a balanza Bluetooth — el estado "conectada/estable" es mock
  fijo.
- Cálculo real de GPD — el valor `+0,85` es mock fijo, no se deriva de
  pesajes anteriores.

## Pendiente para Etapas 2 y 3

- Backend: ya existe el módulo `pesajes` (agregado en un PR en curso,
  `feature/epetrich9/vita-116-...` — `backend/api/modules/pesajes/`) — la
  Etapa 3 de este flujo debería conectar contra ese módulo, no crear uno
  nuevo.
- Offline-first real: cola de sincronización vía Brick (mismo patrón que
  `animal_register`), dado que la captura ocurre sin conectividad.
- Validación del campo numérico manual (rango razonable de kg, no vacío).
- Selección real del lote/animal actual en vez de mock fijo — depende de que
  exista una lista de animales por lote.
