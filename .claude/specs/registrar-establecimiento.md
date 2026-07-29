---
name: registrar-establecimiento
description: >-
  Lógica de negocio del wizard de registro de establecimiento (mobile) —
  pasos, campos, reglas de validación y contrato de backend. Documento vivo,
  se actualiza en el mismo commit que introduce cada pieza descripta acá.
---

# Registrar establecimiento

Wizard para que el Owner registre su primer establecimiento (o uno adicional).
Es un prerequisito duro: `establecimiento_id` es FK obligatoria de casi todo
el resto del dominio (animales, pesajes, movimientos, sanidad, etc.).

Implementación en 3 etapas — ver el plan de referencia en
`/home/lucho/.claude/plans/excelente-necesito-que-ahora-lucky-hanrahan.md`
para el detalle de ejecución. Este documento describe el resultado final de
cada etapa, no los pasos para llegar ahí.

## Pantallas → pasos

| Pantalla (Claude Design) | `RegisterEstablishmentStep` | Ruta |
|---|---|---|
| Empty state (Owner sin establecimientos) | — (pantalla previa al wizard) | `/registrar-establecimiento` |
| Paso 1 · Identificación | `identification` | `/registrar-establecimiento/paso-1` |
| Paso 2 · RENSPA y titular | `renspa` | `/registrar-establecimiento/paso-2` |
| Paso 3 · Ubicación geográfica | `location` | `/registrar-establecimiento/paso-3` |
| Paso 4 · Delimitar superficie | `surface` | `/registrar-establecimiento/paso-4` |
| Revisar y crear | `review` | `/registrar-establecimiento/revisar` |
| Éxito | — (pantalla posterior al wizard) | `/registrar-establecimiento/exito` |

Navegación: un solo BLoC (`RegisterEstablishmentBloc`) maneja los 5 pasos con
`IndexedStack` (no `PageView`, no rutas por paso en el flujo interno — las
rutas de arriba son sólo puntos de entrada/deep-link, igual que en
`animal_register`).

Puntos de entrada al flujo: botón "Configurar mi establecimiento" en
`sign_up_success_page.dart` (alta de dueño nueva) y botón de desarrollo en
`home_page.dart` (para poder revisar el diseño sin repetir el sign-up).

## Campos por paso (`RegisterEstablishmentDraft`)

- **Paso 1 — Identificación**: `nombre` (máx 60 caracteres), `descripcion`
  (opcional), `tiposProduccion` (multi-selección: Cría, Recría, Invernada,
  Ciclo completo, Tambo).
- **Paso 2 — RENSPA y titular**: `cuitTitular`, `nroRenspa` (formato
  `NN.NNN.N.NNNNN/NN`).
- **Paso 3 — Ubicación geográfica**: `provincia`, `departamento`,
  `localidad`, `latitud`/`longitud`, `ubicacionConfirmadaPorGps`.
- **Paso 4 — Delimitar superficie**: `superficieHectareas`,
  `cantidadVertices`. **Réplica visual estática en toda esta iniciativa** —
  sin SDK de mapas, sin arrastre de vértices, sin GPS real (decisión de
  producto, ver el plan de referencia). Los valores son fijos/mock hasta que
  una historia futura decida qué paquete de mapas usar.
- `cantidadUnidadesProductivas` se mantiene en 1: "agregar otra unidad
  productiva" (otro RENSPA) está deliberadamente fuera de alcance.

## Explícitamente fuera de alcance de esta iniciativa

- "Sumarme a uno existente con código" (botón en el estado vacío).
- "Agregar otra unidad productiva" (botón en el paso 2).
- Mapa/GPS real e interacción de dibujo de polígono (paso 4).
- Registro offline: la creación de establecimiento es **online-only**
  (mismo criterio que `sign_up`), no usa Brick/SQLite.

## Reglas de validación (Etapa 2)

_Pendiente — se documenta acá a medida que se implementa cada regla:_

- Paso 1: `nombre` requerido, máx 60 caracteres; al menos un tipo de
  producción seleccionado.
- Paso 2: CUIT vía `CuitInputFormatter` (dígito verificador mod-11); RENSPA
  vía un nuevo `RenspaInputFormatter` contra `^\d{2}\.\d{3}\.\d\.\d{5}/\d{2}$`.
- Paso 3: selects requeridos; avanzar exige `ubicacionConfirmadaPorGps == true`.
- Paso 4: `superficieHectareas > 0`, `cantidadVertices >= 3`.

## Contrato de backend (Etapa 3)

_Pendiente — se documenta acá una vez implementado:_ payload y respuesta de
`POST`/`PUT /api/v1/establecimientos`, tabla completa de `error.code` y qué
hace el mobile ante cada uno.
