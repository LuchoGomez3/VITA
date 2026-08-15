---
name: sincronizacion
description: >-
  Pantalla de estado de sincronización offline-first (cola de operaciones y
  resolución de conflictos) — secciones y datos mock del diseño de
  referencia. Documento vivo, se actualiza en el mismo commit que introduce
  cada pieza descripta acá.
---

# Sincronización

Es la UI que le falta al motor de sincronización que **ya existe en
código** en `mobile/lib/features/sync/` (`data/`, `domain/`,
`sync_composition.dart`). Esta pantalla es sólo la vista de estado — no
implementa lógica de sync nueva. Muestra progreso, la cola de operaciones
pendientes/en curso/con error, y la resolución de un conflicto
last-write-wins. Se llega por un atajo de desarrollo desde
`livestock_page.dart`.

Ver también **[`estado-pantallas-diseno.md`](./estado-pantallas-diseno.md)**.

## Pantallas → rutas

| Pantalla (Claude Design) | Página Flutter | Ruta |
|---|---|---|
| `SyncScreen` | `SyncStatusPage` | `/sincronizacion` |

Pantalla única, sin bottom nav (push).

## Contenido

- Header propio: back + "Sincronización" + subtítulo "Última: hace 2 min · 14
  pendientes" + botón de refresh manual.
- Banner de progreso: "Sincronizando 14 registros…", "Conexión 3G · velocidad
  lenta", contador "6 / 14".
- Sección "Cola de operaciones": 7 filas con ícono de estado
  (`syncing`/`pending`/`error`/`ok`), tipo de operación, timestamp mono, y
  línea de error si aplica.
- Sección "Conflictos · 1": card con borde de error, chip "Last-write-wins",
  bloque "Tu cambio (local)" vs "En servidor", y 2 botones de resolución.

**Datos mock — cola de operaciones (en orden):**

| Estado | Operación | Detalle | Hora |
|---|---|---|---|
| syncing | Pesaje | 003 1284 | 11:42:18 |
| pending | Vacunación | aftosa · 6 animales | 11:41:30 |
| pending | Alta de animal | 003 1295 | 11:39:02 |
| error | Movimiento | La Loma → El Bajo · 24 cab · "Conflicto con servidor" | 11:32:55 |
| ok | Tratamiento | ivermectina · 14 animales | 11:28:11 |
| ok | Pesaje | 003 1287 | 11:27:48 |
| ok | Pesaje | 003 1290 | 11:27:24 |

**Datos mock — conflicto:** "Movimiento de potrero · animal 003 1284"; local
(15/05 11:32) "La Loma → El Bajo"; servidor (Cecilia · 14/05 18:12) "La Loma →
San José". Botones: "Mantener servidor" / "Aplicar el mío".

## Estado de la Etapa 1 (maquetado)

Implementado en `feature/pantalla-sync` (rama desde `develop`, sin
dependencia de otros PRs — no usa `AppEarTagBadge` ni `AppSyncBadge`).

- `mobile/lib/features/sync/presentation/` — se agregó la capa
  `presentation/` al feature `sync` ya existente (que sólo tenía
  `data/`/`domain/` de la sincronización inicial post-login):
  - `mock/sync_status_mock.dart`: banner (14 pendientes, 6/14, "Conexión 3G ·
    velocidad lenta"), `enum SyncQueueState { syncing, pending, error, ok }` +
    `SyncQueueEntryMock` (7 filas) y `SyncConflictMock` (1 conflicto), todo
    con los mismos valores que la tabla de arriba.
  - `strings/sync_status_strings.dart`.
  - `widgets/sync_progress_banner.dart`, `widgets/sync_queue_row.dart`
    (ícono/color por estado con pattern matching de records, igual que
    `health_alert_tile.dart`), `widgets/sync_conflict_card.dart` (borde de
    error, chip `AppStatusChipTone.danger`, bloques local/servidor y los 2
    botones).
  - `pages/sync_status_page.dart`: header propio (back + título/subtítulo +
    botón de refresh), sin bottom nav, pushed desde `livestock_page.dart`.
- **`AppStatusChip` ganó un tercer tono**, `AppStatusChipTone.danger`
  (`errorContainer`/`error`), para la chip "Last-write-wins". Cambio
  aditivo en `core/widgets/app_status_chip.dart`, no afecta a los
  consumidores existentes (`neutral`/`success`).
- Sin colores nuevos: toda la paleta necesaria ya existía en `AppColors`.
- Ruta `/sincronizacion` (`AppRoutes.syncStatus`) + atajo de desarrollo en
  `livestock_page.dart`.
- Refresh manual, "Mantener servidor" y "Aplicar el mío" muestran un
  `SnackBar` de fuera de alcance — no hay lógica real detrás (ver más abajo
  por qué).
- Sin tests, mismo criterio que `weighing`/`field`: ninguna maqueta de
  Etapa 1 en este repo tiene `mobile/test/features/`.

### Aclaración importante sobre "ya existe en código"

La primera versión de este spec decía que Sincronización "es la pieza que sí
conecta con código real existente". Es sólo parcialmente cierto:
`mobile/lib/features/sync/` (`PrepareInitialDataSyncUseCase` +
`InitialDataSyncRepositoryImpl`) es la **hidratación inicial de datos
posterior al login** (trae animales/categorías/pesajes una sola vez), no una
cola de operaciones pendientes ni una entidad de conflicto. No hay nada de
eso implementado todavía. Conectar esta pantalla de verdad (Etapa 2/3)
requiere primero diseñar y construir ese dominio — no es sólo cablear la UI
a algo que ya existe.

## Explícitamente fuera de alcance de esta iniciativa

- Resolución real de conflictos — los botones son mock, no invocan al motor
  de sync real todavía.
- Refresh manual real — no dispara una sincronización de verdad en Etapa 1.

## Pendiente para Etapas 2 y 3

Esta es la pieza que sí conecta con código real existente, a diferencia de
los otros flujos de esta iniciativa:

- La cola de operaciones debería leer de `lib/features/sync/domain/` /
  `data/` en vez de datos mock.
- La resolución "Mantener servidor" / "Aplicar el mío" debería invocar la
  estrategia last-write-wins ya documentada como decisión de arquitectura en
  CLAUDE.md (conflict resolution por `updated_at`).
- El contador de pendientes del `AppHeader` en las demás pantallas (badge
  `pending=14`) debería salir de la misma fuente que esta pantalla, no ser un
  mock independiente por feature.
