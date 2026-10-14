---
name: campo-y-potreros
description: >-
  Flujo de campo y potreros (mapa, lista, detalle) — pantallas, secciones y
  datos mock del diseño de referencia. Documento vivo, se actualiza en el
  mismo commit que introduce cada pieza descripta acá.
---

# Campo y potreros

Vista del establecimiento por potrero: dónde está cada rodeo, cuánta carga
tiene y su historial de ocupación. Lo usa principalmente el Capataz para
decidir movimientos de hacienda entre potreros. Se llega por un atajo de
desarrollo desde `livestock_page.dart` (no hay tab propio — ver decisión de
navegación en `estado-pantallas-diseno.md`).

Ver también **[`estado-pantallas-diseno.md`](./estado-pantallas-diseno.md)**.

## Pantallas → rutas

| Pantalla (Claude Design) | Página Flutter | Ruta |
|---|---|---|
| `CampoMapa` | `FieldMapPage` | `/campo` |
| `CampoLista` | `FieldListPage` | `/campo/lista` |
| `CampoDetalle` | `FieldDetailPage` | `/campo/:potreroId` |

Navegación: `CampoMapa` y `CampoLista` son la misma vista con un toggle
segmentado (Mapa/Lista) — se resuelve con un `StatefulWidget` local, no con
dos rutas separadas en la práctica de uso (aunque ambas rutas existen como
puntos de entrada). Tocar una card en la lista empuja a `CampoDetalle`.

## Contenido por pantalla

### `CampoMapa` (`/campo`)

- Header: selector de establecimiento "La Sirena" + título "Campo" + badge de
  sync con 14 pendientes.
- Mapa a pantalla completa: SVG decorativo estático con los 8 potreros
  coloreados por densidad de carga (mismo criterio que el paso 4 de
  establecimiento — sin SDK de mapas, sin GPS real).
- Chip flotante superior izquierdo con dos KPIs: **8 potreros** / **2.847
  cabezas**.
- Botón flotante de capas (sin panel funcional todavía).
- Leyenda de densidad: 4 niveles (baja/media/alta/muy alta) con swatches de
  color.
- Toggle segmentado inferior: **Mapa** (activo) / **Lista** → navega a
  `CampoLista`.

### `CampoLista` (`/campo/lista`)

- Mismo header que `CampoMapa`.
- Barra de filtros: chip "8 potreros", chip "3.247 ha totales", ícono de
  filtro (sin panel funcional).
- Lista de 8 cards, una por potrero, con barra de color por densidad, nombre,
  cabezas, hectáreas + tipo de forraje, y último movimiento.

**Datos mock (los 8 potreros, literales del diseño):**

| Potrero | Hectáreas | Cabezas | Forraje | Último movimiento | Densidad |
|---|---|---|---|---|---|
| La Loma | 218 | 821 | Mixta · alfalfa + gramíneas | Mov. 08/05 | alta |
| El Bajo | 184 | 518 | Pastura natural | Mov. 22/04 | media |
| San José | 96 | 412 | Sorgo diferido | Mov. 02/05 | media |
| La Toma | 142 | 352 | Avena | Mov. 30/04 | alta |
| La Cumbre | 142 | 342 | Pastura natural | Mov. 14/03 | baja |
| El Tala | 88 | 274 | Mixta | Mov. 18/04 | baja |
| Los Sauces | 64 | 128 | Reserva | Mov. 10/05 | muy baja |
| Aguada Vieja | 12 | 0 | — | Libre desde 08/05 | muy baja |

`Aguada Vieja` es el caso de **potrero vacío**: 0 cabezas, forraje `—`, texto
"Libre desde 08/05". Es el único estado especial de esta pantalla — no hay
empty state global, loading ni error.

### `CampoDetalle` (`/campo/:potreroId`)

- Header propio (no `AppHeader`): botón circular de volver + nombre del
  potrero + menú de opciones (sin acciones funcionales).
- Mini-mapa recortado (mismo SVG que `CampoMapa`, 140px de alto).
- Grilla de 3 KPIs: Cabezas, Superficie (ha), Densidad (cab/ha).
- Sección "Forraje y servicios": recurso forrajero, aguada, última rotación.
- Sección "Animales en potrero" con desglose por categoría (Vacas / Terneros /
  Toros / Vaquillonas) y link "Ver lista →" (sin pantalla destino todavía).
- Sección "Historial de ocupación": 4 filas fecha/cabezas.
- CTA fijo: "Mover animales a otro potrero" — **sin pantalla destino, ver
  fuera de alcance**.

**Datos mock de ejemplo (potrero "La Loma", el que abre por defecto desde el
atajo de desarrollo):**

- Cabezas: 821 · Superficie: 218 ha · Densidad: 3,7 cab/ha.
- Recurso forrajero: Alfalfa + gramíneas. Aguada: Tanque australiano · 60 m³.
  Última rotación: hace 8 días.
- Composición: Vacas 612 · Terneros 168 · Toros 7 · Vaquillonas 34.
- Historial: `08/05 → hoy` 821 cab · `22/04 → 08/05` 604 cab · `01/03 →
  22/04` libre · descanso · `12/01 → 01/03` 780 cab.

## Estado de la Etapa 1 (maquetado)

_A completar en `feature/pantalla-campos` cuando se maqueten las 3 pantallas._

## Explícitamente fuera de alcance de esta iniciativa

- Botón de capas del mapa (sin panel).
- Ícono de filtro de la lista (sin panel).
- Link "Ver lista →" de animales en potrero (no hay pantalla destino).
- CTA "Mover animales a otro potrero" (flujo de movimiento entre potreros no
  existe todavía en ningún diseño).
- Mapa real / GPS / dibujo de polígonos — mismo criterio que el paso 4 de
  `registrar-establecimiento.md`.

## Pendiente para Etapas 2 y 3

- Backend: **el módulo `lotes` ya existe** (`/api/v1/lotes` y
  `/api/v1/movimientos_lotes`), con geometría esquemática, sync offline-first y
  movimiento batch de animales. Ver
  [`docs/contrato-lotes-movimientos.md`](../../docs/contrato-lotes-movimientos.md)
  y [`ADR-0002`](../../docs/adr/adr-0002-geometria-y-movimientos-de-lotes.md).
  Esta sección decía que no existía y que PostGIS era Release 2; ambas cosas
  quedaron desactualizadas. PostGIS **sigue** fuera de alcance, pero no bloquea
  nada: la geometría del lote es un polígono esquemático local, no geografía.
- Offline: **confirmado offline-first**. Mobile ya persiste lotes y movimientos
  en SQLite y tiene la cola Brick cableada, apagada con
  `VITA_ENABLE_LOT_REMOTE_SYNC` y `VITA_ENABLE_LOT_MOVEMENT_REMOTE_SYNC` hasta
  aplicar los cinco ajustes de contrato que lista el documento de arriba.
- Validaciones: las autoritativas ya están en el backend (nombre único
  normalizado, superficie positiva, geometría válida, no superposición con área
  positiva, no inactivar ni borrar un lote con animales). Falta el formulario
  real que las consuma en estas tres pantallas.
- El CTA "Mover animales a otro potrero" ya tiene backend
  (`POST /api/v1/movimientos_lotes`, batch y atómico); sigue faltando el diseño
  de la pantalla.
