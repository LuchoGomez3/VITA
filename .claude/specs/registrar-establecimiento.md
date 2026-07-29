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

## Estado de la Etapa 1 (maquetado)

Las 7 pantallas están maquetadas con datos ficticios y el flujo es navegable
de punta a punta (repositorio mock, siempre exitoso). Widgets compartidos que
surgieron durante el maquetado, reusables entre pasos:

- `EstablishmentReviewSection` — tarjeta numerada de revisión con filas
  label/valor (soporta `isMono`/`isMuted` por fila) y botón "Editar" que
  dispara `stepRequested`.
- `FieldBoundaryPreview` — mapa decorativo con el polígono mock superpuesto;
  con vértices numerados en el paso 4, sin ellos (miniatura) en la revisión.
- `RenspaBreakdownPanel`, `EstablishmentInfoCallout`, `StaticMapPreview` —
  reusados entre el paso 2/3/4 y la revisión.

Cambios aditivos a widgets compartidos de `core/` (no rompen usos existentes):
`AppChoiceSelector` ganó un `isSelected` opcional para soportar selección
múltiple; `AppTextFormField` ganó un `style` opcional para poder mostrar
CUIT/RENSPA/coordenadas en tipografía mono; `AppTypography` sumó
`monoValue`/`monoValueEmphasis` (placeholder `monospace` hasta agregar
Source Code Pro).

## Explícitamente fuera de alcance de esta iniciativa

- "Sumarme a uno existente con código" (botón en el estado vacío).
- "Agregar otra unidad productiva" (botón en el paso 2).
- Mapa/GPS real e interacción de dibujo de polígono (paso 4).
- Registro offline: la creación de establecimiento es **online-only**
  (mismo criterio que `sign_up`), no usa Brick/SQLite.

## Reglas de validación (Etapa 2)

Implementadas como funciones puras en
`RegisterEstablishmentDraftValidation` (extension sobre
`RegisterEstablishmentDraft`, en
`presentation/bloc/register_establishment_draft_validation.dart`). El mismo
criterio se usa en dos lugares: para habilitar/deshabilitar
"Siguiente"/"Crear establecimiento" en `establishment_register_page.dart`
(recalculado en cada cambio de `draft`, no sólo de `currentStep`), y como
revalidación defensiva en `RegisterEstablishmentBloc._buildRegistration()`
antes de armar el request — la UI nunca es la única barrera.

- **Paso 1 — Identificación**: `nombre` requerido (no vacío tras `trim`), máx
  60 caracteres (reforzado además por `maxCharacters` en el campo); al menos
  un tipo de producción seleccionado. Sin resaltado de error en rojo (mismo
  criterio que los campos de nombre/apellido en `sign_up`): sólo gatea el
  botón.
- **Paso 2 — RENSPA y titular**: CUIT vía `CuitInputFormatter.validationError`
  (dígito verificador mod-11, mismo validador que `sign_up`); RENSPA vía el
  nuevo `RenspaInputFormatter` (`core/formatters/renspa_input_formatter.dart`,
  mismo patrón de mascara+validación que `CuitInputFormatter`) contra
  `^\d{2}\.\d{3}\.\d\.\d{5}/\d{2}$` (13 dígitos, sin dígito verificador).
  Ambos campos muestran borde y mensaje de error en tiempo real.
- **Paso 3 — Ubicación geográfica**: `provincia`/`departamento`/`localidad`
  no vacíos; avanzar exige además `ubicacionConfirmadaPorGps == true` (o sea,
  tocó "Usar mi ubicación actual" al menos una vez). Mientras no está
  confirmada, las coordenadas muestran un placeholder (`—`) en vez de `0.0000°`.
- **Paso 4 — Delimitar superficie**: `superficieHectareas > 0`,
  `cantidadVertices >= 3`. Trivialmente cierto hoy (valores mock fijos, sin
  mapa real editable), pero ya con la forma correcta para cuando el mapa real
  reemplace el mock.
- **Revisar**: válido sólo si los 4 pasos anteriores lo son. `.initial()` deja
  de sembrar datos ficticios (Etapa 1) y arranca vacío en todos los campos
  excepto la superficie/vértices del paso 4 (siguen fijos, ver arriba).

Tests: `test/core/formatters/renspa_input_formatter_test.dart`,
`test/features/establishment_register/presentation/bloc/register_establishment_draft_validation_test.dart`
y los casos de gating agregados a `register_establishment_bloc_test.dart`.

## Contrato de backend (Etapa 3)

_Pendiente — se documenta acá una vez implementado:_ payload y respuesta de
`POST`/`PUT /api/v1/establecimientos`, tabla completa de `error.code` y qué
hace el mobile ante cada uno.
