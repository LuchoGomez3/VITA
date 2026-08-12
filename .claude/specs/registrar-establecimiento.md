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

Ver también **[`estado-pantallas-diseno.md`](./estado-pantallas-diseno.md)**:
índice de todas las pantallas del proyecto de Claude Design y su estado de
implementación (éste es uno de los flujos ahí listados).

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

### Modelo extendido

`backend/api/modules/establecimientos/models.py` sumó los campos que pedía el
diseño y que el modelo original (PRO-40) no tenía: `descripcion` (`str |
None`), `tipo_produccion` (`list[str] | None`, `JSON`), `latitud`/`longitud`
(`Decimal | None`, `Numeric(9,6)`) y `poligono` (`list[dict] | None`, `JSON`
— **no PostGIS**, reservado para "Release 2: lote geolocation" por
CLAUDE.md). El mobile hoy **no envía `poligono`**: el paso 4 sigue siendo una
réplica visual estática sin coordenadas de vértices reales, sólo manda
`superficie_ha` ya calculada. La columna queda lista para cuando un mapa real
reemplace el mock.

### Endpoints

- `POST /api/v1/establecimientos` (ya existía desde PRO-40, extendido acá).
- `PUT /api/v1/establecimientos/{id}` (nuevo): actualización parcial —
  sólo valida/pisa los campos enviados; re-chequea unicidad de RENSPA
  excluyéndose a sí mismo.

### Validación de formato (Etapa 3, en el service, no en el schema)

- **RENSPA**: formato `NN.NNN.N.NNNNN/NN` (13 dígitos), regex
  `^\d{2}\.\d{3}\.\d\.\d{5}/\d{2}$` — el mismo que valida
  `RenspaInputFormatter` en mobile. Orden de chequeo: vacío → formato →
  duplicado.
- **CUIT del titular**: opcional; si viene, se normaliza (`api/shared/cuit.py
  normalizar_cuit`, quita guiones/espacios) y se valida el dígito
  verificador mod-11 (`validar_cuit`, la misma función que usa `usuarios`
  para el dueño de campo — extraída a un módulo compartido en este mismo
  esfuerzo para no duplicarla).
- **Superficie**: `superficie_ha > 0` si viene informada.

### Tabla de `error.code`

| `error.code` | HTTP | Cuándo | Qué hace el mobile |
|---|---|---|---|
| `renspa_vacio` | 422 | RENSPA vacío tras `trim` | Snackbar genérico (no debería ocurrir: la UI ya lo bloquea) |
| `renspa_formato_invalido` | 422 | RENSPA no matchea `NN.NNN.N.NNNNN/NN` | Snackbar genérico |
| `renspa_duplicado` | 409 | Ya existe un establecimiento con ese RENSPA | Vuelve al paso 2 (`stepRequested(renspa)`) + banner inline junto al campo RENSPA (`EstablishmentRegisterStrings.renspaConflictMessage`) |
| `cuit_invalido` | 422 | CUIT informado con dígito verificador incorrecto o formato inválido | Snackbar genérico |
| `superficie_invalida` | 422 | `superficie_ha <= 0` | Snackbar genérico |
| `establecimiento_no_encontrado` | 404 | `PUT`/`GET` sobre un id inexistente o sin membresía | No aplica al alta; sí a una futura pantalla de edición |
| *(sin conexión)* | — | `SocketException`/`TimeoutException` | `EstablishmentOfflineModal` (mismo patrón que `SignUpOfflineModal`, duplicado localmente a propósito) |

Todo lo que no sea `renspa_duplicado` ni un error de conectividad cae a un
snackbar genérico con el `message` que devuelve el backend — mismo criterio
que el resto de la app (`AuthRemoteDataSource`).

### Mobile: piezas nuevas

- `data/sources/establishment_registration_remote_data_source.dart` — `POST`
  con `Authorization: Bearer <token>`; a diferencia de
  `AuthRemoteDataSource` (que colapsa todo error no-offline a `validation`),
  **preserva** el `code` del backend y lo traduce 1 a 1 a
  `DomainErrorCode` (tabla arriba).
- `data/mappers/establishment_registration_json_mapper.dart` — `toJson`
  arma el body en snake_case (sin `poligono`); `registeredFromJson` combina
  el `id`/`created_at` que confirma el backend con el `EstablishmentRegistration`
  que ya se tenía localmente (no hace falta re-derivar el resto de los
  campos desde la respuesta).
- `data/repositories/establishment_registration_repository_impl.dart` —
  mismo try/catch que `AuthRepositoryImpl.register()`
  (`SocketException`/`TimeoutException` → `DomainErrorCode.offline`).
  Reemplazó a `EstablishmentRegistrationMockRepository` (borrado).
- `establishment_register_composition.dart` — cablea el repositorio real
  (`http.Client` + `SessionBackendAccessTokenProvider.instance`, mismo
  patrón manual que `auth_composition.dart`).

### Decisión: sesión entre el fin del `sign_up` y el inicio del wizard

El flujo real (`sign_up_success_page.dart` → "Configurar mi
establecimiento") pasaba **sin ningún token Bearer disponible**: el registro
de dueño nunca inició sesión por sí mismo, aunque el backend ya devolvía un
`access_token` en `/api/v1/usuarios/registro` que el mobile descartaba. Con
`establecimientos` ahora protegido por `get_current_user`, ese camino
rompía siempre con 401.

Se resolvió extendiendo — no reinventando — lo que ya existía:

- **Backend**: `/api/v1/usuarios/registro` devuelve la sesión completa
  (`access_token` + `refresh_token` + `expires_in`), igual contrato que
  `/api/auth/login` (`UsuarioService.registrar()` ahora devuelve el
  `AuthResult` completo en vez de sólo el `access_token`).
- **Mobile**: `AuthRepositoryImpl.register()` hidrata
  `SessionBackendAccessTokenProvider` en memoria con esa sesión, **sin**
  persistirla en secure storage ni correr la sync inicial de Brick — el
  registro sigue sin ser un login real (no sobrevive un reinicio de la app;
  si el usuario elige "Iniciar sesión" en vez de "Configurar mi
  establecimiento", el login real la pisa sin conflicto).
- **Límite conocido, fuera de alcance de esta iniciativa**: si el JWT vence
  a mitad del wizard (creación online-only, sesión no persistida), el
  refresco automático no funciona porque `AuthRepositoryImpl.refreshSession()`
  exige una sesión persistida en storage. Dado que el wizard es un flujo
  corto (minutos) frente a la expiración típica del access token, se acepta
  este límite por ahora; si se vuelve un problema real, la solución sería
  persistir la sesión también en el registro (lo que abriría la pregunta
  más grande de si el registro pasa a ser un login real).

Tests nuevos: `test_establecimientos.py` (CUIT inválido/válido, RENSPA con
formato inválido, superficie no positiva, lat/lng/polígono persistidos,
`PUT` exitoso/duplicado/404), `test_shared_cuit.py`,
`test_usuarios.py::test_registro_devuelve_sesion_completa`,
`establishment_registration_remote_data_source_test.dart`,
`establishment_registration_repository_impl_test.dart`,
`establishment_registration_json_mapper_test.dart`, y los tests de
`auth_remote_data_source_test.dart`/`auth_repository_impl_test.dart`
actualizados para la sesión de registro.
