---
name: sanidad
description: >-
  Flujo de sanidad (vacunaciones, tratamientos, alertas, aplicar vacunación) —
  pantallas, secciones y datos mock del diseño de referencia. Documento vivo,
  se actualiza en el mismo commit que introduce cada pieza descripta acá.
---

# Sanidad

Seguimiento de campañas de vacunación, tratamientos con período de carencia, y
una bandeja unificada de alertas sanitarias. El período de carencia
(withdrawal period) es un módulo crítico para CI (85% de cobertura exigido
por CLAUDE.md) cuando se conecte a backend, porque determina qué animales no
son comercializables. Se llega por un atajo de desarrollo desde
`livestock_page.dart`.

Ver también **[`estado-pantallas-diseno.md`](./estado-pantallas-diseno.md)**.

## Pantallas → rutas

| Pantalla (Claude Design) | Página Flutter | Ruta |
|---|---|---|
| `SanidadVacunaciones` / `SanidadTratamientos` / `SanidadAlertas` | `HealthPage` con `TabBar` de 3 tabs | `/sanidad` |
| `AplicarVacunacion` | `ApplyVaccinationPage` | `/sanidad/aplicar-vacunacion` |

Las 3 primeras pantallas son tabs de una misma página (`SanidadTabs` en el
diseño), igual criterio que las tabs Bluetooth/Manual de Pesaje. Sólo
`AplicarVacunacion` es una ruta push aparte (FAB "+ Aplicar" en la tab
Vacunaciones).

## Contenido por pantalla

### Tab Vacunaciones (`SanidadVacunaciones`)

- Header: `AppHeader` ("La Sirena" / "Sanidad" / 14 pendientes) + tabs.
- Sección "Campañas activas · 3": card por campaña con nombre, fecha
  objetivo, progreso (aplicados/objetivo), barra y link "Aplicar →".
- Sección "Programadas · próx. 30 días": 3 filas con fecha, título y
  cantidad de animales.
- FAB "+ Aplicar" → `AplicarVacunacion`.

**Datos mock — campañas activas:**

| Campaña | Objetivo | Progreso |
|---|---|---|
| Aftosa · campaña otoño | 31/05/26 | 1.248 / 2.847 (44%) |
| Brucelosis (refuerzo) | 15/06/26 | 216 / 284 (76%) |
| Clostridiales 10 vías | 30/06/26 | 88 / 612 (14%) |

**Datos mock — programadas:**

- 22 MAY · Aftosa · Potrero La Loma · 821 animales · pendiente
- 28 MAY · Aftosa · Potrero El Bajo · 518 animales · pendiente
- 03 JUN · Refuerzo brucelosis · terneras años 24 · 68 animales

### Tab Tratamientos (`SanidadTratamientos`)

- Sección "Tratamientos en curso · 2" con banner de carencia activa.
- Sección "Historial · últimos 90 días".

**Datos mock — en curso:**

- Ivermectina inyectable · lote IV-441 · iniciado 08/05/26 · **carencia
  activa**: "14 animales no comercializables hasta 22/05/26".
- Antibiótico (mastitis) · lote AB-220 · dosis 2 de 3 · vet. C. Pérez · 3
  animales · próxima dosis 17/05/26.

**Datos mock — historial:** Vermífugo oral 02/05/26 · 142 animales;
Antiparasitario 14/04/26 · 88 animales; Vitaminas + minerales 08/03/26 · 612
animales.

### Tab Alertas (`SanidadAlertas`)

Bandeja plana de 6 alertas, con tono e icono según severidad:

| Tono | Título | Subtítulo | Acción |
|---|---|---|---|
| danger | 14 animales en carencia activa | Trat. ivermectina · hasta 22/05/26 | Ver → |
| danger | 3 animales con vacuna vencida | Brucelosis · vencida hace 8 días | Aplicar → |
| warn | 23 terneras con vacunación próxima a vencer | Brucelosis · vence 18/05/26 | Programar → |
| warn | Tratamiento sin seguimiento | Antibiótico AB-220 · próxima dosis 17/05 | Marcar → |
| info | 86 animales pendientes de aftosa | Campaña otoño · cierre 31/05/26 | Programar → |
| info | Resincronizar 14 registros | Vacunaciones y pesajes locales | Reintentar → |

La última alerta ("Resincronizar 14 registros") es el hook de sync
pendiente — mismo número que el badge del header (`pending=14`), coincidencia
a no confundir con los "14 animales en carencia" de la primera alerta.

### `AplicarVacunacion` (`/sanidad/aplicar-vacunacion`)

- Header propio (no `AppHeader`): botón de cerrar + "Aplicar vacunación" +
  subtítulo "Campaña aftosa · otoño 2026".
- Bloque Animales: "6 seleccionados", link "Limpiar", grid de `Caravana`,
  botón "Leer otra caravana" (Bluetooth).
- Bloque Producto: 4 campos.
- Callout de carencia.
- CTA fijo: "Registrar aplicación".

**Campos del formulario:**

| Campo | Tipo | Valor mock |
|---|---|---|
| Producto / vacuna | selector | Vacuna antiaftosa Aftogen Oleo |
| Lote | texto mono | 2025-09-AFT |
| Dosis (ml) | numérico | 2,0 |
| Fecha de aplicación | date picker | 15/05/2026 |

**Caravanas mock:** `003 1284`, `003 1287`, `003 1290` (amarillo `#f4cf3d`);
`004 0023`, `004 0028` (crema `#e8e2d2`); `005 0772` (celeste `#5db1e3`).
Carencia: **14 días**, "Hasta el 29/05/26 estos 6 animales no podrán ser
comercializados."

## Estado de la Etapa 1 (maquetado)

_A completar en `feature/pantalla-sanidad`._ Reusa `AppStatusChip` (de
Campo) y `AppEarTagBadge` (de Pesaje) para las caravanas del grid.

## Explícitamente fuera de alcance de esta iniciativa

- Ícono "más" / opciones adicionales por card de campaña.
- Botones "Ver animales" / "Seguimiento" de la tab Tratamientos (sin pantalla
  destino todavía).
- CTA "Leer otra caravana" — lectura Bluetooth simulada, sin baton real.

## Pendiente para Etapas 2 y 3

- Backend: no existe todavía módulo `eventos_sanitarios`. CLAUDE.md marca el
  cálculo de período de carencia como módulo crítico (85% cobertura CI).
- Validaciones: dosis > 0, fecha de aplicación no futura, producto/lote no
  vacíos — mismo patrón que `RegisterEstablishmentDraftValidation`.
- Offline-first: aplicar vacunación en el campo sin conectividad es un caso
  central — cola de sync vía Brick.
- El radio-group de campañas/productos hoy es mock fijo; en Etapa 3 saldría
  de un catálogo real.
