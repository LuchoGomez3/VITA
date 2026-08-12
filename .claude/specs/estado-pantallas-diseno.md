# Estado de pantallas (Claude Design → Flutter)

Índice vivo de **todas** las pantallas del proyecto de referencia visual y su
estado real de implementación en `mobile/`. Se actualiza en el mismo commit
que cambia el estado de una pantalla (igual criterio que
`.claude/specs/registrar-establecimiento.md`).

**Antes de implementar una pantalla nueva, buscar acá primero**: dice si ya
existe diseño de referencia, dónde está (archivo del proyecto de Claude
Design) y qué tan avanzada está la implementación real.

## Referencia de diseño

- Proyecto: **"Trazabilidad Ganadera"** en Claude Design.
- `projectId`: `828dbc22-6b51-4365-871a-b54d21bca137`
  (`https://claude.ai/design/p/828dbc22-6b51-4365-871a-b54d21bca137`).
- Accesible vía el MCP `DesignSync` (métodos de sólo lectura: `get_project`,
  `list_files`, `get_file`, pasando el `projectId` de arriba). No usar los
  métodos de escritura (`write_files`, `finalize_plan`, etc.) sobre este
  proyecto: es una referencia de sólo lectura, no un design-system del
  equipo.
- Archivos del proyecto con pantallas (`list_files`): `screens-onboarding.jsx`,
  `screens-registro.jsx`, `screens-establecimiento.jsx`, `screens-animales.jsx`,
  `screens-campo.jsx`, `screens-pesaje.jsx`, `screens-sanidad.jsx`,
  `screens-senasa.jsx`, `screens-dashboard.jsx`, `screens-other.jsx`,
  `screens-dark.jsx` (variantes dark mode de pantallas ya cubiertas en otros
  archivos, no son pantallas nuevas). El resto (`components.jsx`,
  `design-canvas.jsx`, `tokens.css`, `spec-sheet.jsx`, `index.html`,
  `index-print.html`, `android-frame.jsx`) es infraestructura del canvas, no
  pantallas.

## Leyenda

| Símbolo | Significado |
|---|---|
| 🎨 | Sólo diseño — nada implementado en `mobile/` todavía |
| 🧱 | Mockeada — estructura/layout real, datos ficticios (equivalente a la "Etapa 1" de establecimiento) |
| ✅ | Validada — validación real de campos (equivalente a la "Etapa 2") |
| 🔌 | Conectada — flujo funcional de punta a punta contra backend o persistencia local real (equivalente a la "Etapa 3") |

**Columna "Offline"**: dado que offline-first es la restricción central del
proyecto (ver CLAUDE.md), cada flujo indica si es offline-first (usa
Brick/SQLite y cola de sincronización) u online-only (requiere conexión,
excepción explícita como `sign_up`/`establishment_register`). Útil para
saber, antes de tocar una pantalla nueva, si hace falta diseñar el camino sin
conexión o si ya está decidido que no aplica.

## Onboarding y cuenta

`screens-onboarding.jsx` + `screens-registro.jsx` (11 pantallas de diseño).

| Pantalla (diseño) | Estado | Offline | Dónde vive / notas |
|---|---|---|---|
| SplashScreen | 🎨 | — | No implementada tal cual (logo + nota SENASA 530/25). Existe `auth_check_page.dart`, pero es una pantalla técnica (spinner) para esperar la restauración de sesión, no la marca/branding del diseño. |
| LoginScreen | 🔌 | Offline-first (entra con sesión local aunque no haya internet) | `auth/presentation/login/pages/login_page.dart` |
| SelectEstabScreen | 🎨 | — | No implementada. Hoy no hay selector cuando un usuario pertenece a varios establecimientos. |
| WelcomeScreen | 🔌 | Online-only | `auth/presentation/sign_up/pages/sign_up_welcome_first_time.dart` |
| RegistroFormVacio/Completo/Validación/Duplicado | ✅ | Online-only | Un solo `sign_up_page.dart` + `sign_up_form.dart`/`sign_up_bloc.dart` cubre los 4 escenarios como estados dinámicos (no son rutas separadas). Desde Etapa 3 de establecimiento, el registro también hidrata la sesión en memoria (no persistida) para poder encadenar el alta de establecimiento sin pedir login — ver `registrar-establecimiento.md`. |
| RegistroSinConexion | 🔌 | Online-only (bloquea si no hay conexión) | `sign_up_offline_modal.dart` |
| RegistroLoading | 🧱 | Online-only | Sólo un spinner genérico (`Loading<AppUser>`); el diseño muestra pasos nombrados ("validando CUIT", "verificando correo", etc.) que no están implementados. |
| RegistroBienvenida | 🔌 | Online-only | `sign_up_success_page.dart`, ya enlaza a `establishmentRegisterEmpty`. |

## Establecimiento

`screens-establecimiento.jsx` (7 pantallas). Detalle completo de campos,
reglas y contrato de backend en
**[`registrar-establecimiento.md`](./registrar-establecimiento.md)** — acá
sólo el resumen de estado.

| Pantalla (diseño) | Estado | Offline |
|---|---|---|
| Empty state, Paso 1–4, Revisar, Éxito (7/7) | 🔌 Mockeadas, validadas y conectadas (Etapa 3 completa) | Online-only (excepción explícita, ver spec) |

## Animales

`screens-animales.jsx` (13 pantallas: lista, ficha de 5 tabs, alta de 4 pasos + éxito).

| Pantalla (diseño) | Estado | Offline | Dónde vive / notas |
|---|---|---|---|
| AnimalListScreen | 🎨 | — | No implementada. Hoy se llega a la ficha de un animal por un id hardcodeado desde el menú de desarrollo en `home_page.dart`, no hay listado real. |
| AnimalFichaGeneral/Pesajes/Genealogía/Sanidad/Movimientos (5 tabs) | 🔌 (parcial, ver nota) | Lectura vía backend real (`animal_detail_remote_data_source.dart`) | Implementada como **una sola pantalla con scroll** (`animal_detail_page.dart`: header + grilla de datos + historial de eventos + gráfico de GPD), no como 5 tabs separados del diseño. Diverge del diseño en layout, no en contenido — evaluar si conviene migrar a tabs o dejarlo así. |
| AnimalAltaLectura (Bluetooth) / AnimalAltaManual / AnimalAltaLecturaOK | ✅ (parcial, ver nota) | Offline-first (Brick) | Las variantes Bluetooth y manual están unificadas en un solo `register_animal_identification_step.dart`, no como pantallas separadas. **Falta lectura OCR de caravana visual** (CLAUDE.md la exige como método de lectura válido junto a Bluetooth/manual) — no está ni en este diseño ni en el código. |
| AnimalAltaDatos (paso 2) | ✅ | Offline-first | `register_animal_basic_data_step.dart` |
| AnimalAltaGenealogia (paso 3) | ✅ | Offline-first | `register_animal_genealogy_step.dart` |
| AnimalAltaRevisar (paso 4) | ✅ | Offline-first | `register_animal_review_step.dart` |
| AnimalAltaExito | 🔌 | Offline-first | Persiste vía `AnimalRegistrationRepositoryImpl` + `BrickAnimalStore` (guardado local, encolado para sync). El contexto de registro (establecimiento/lote/madre/padre) sigue resuelto por un mock (`AnimalRegistrationMockContext`) pendiente de sesión/catálogos reales. |

## Pendientes sin ningún código todavía

Estos flujos tienen diseño completo en Claude Design pero **ninguna carpeta
en `lib/features/` todavía** (confirmado: sólo existen `animal_detail`,
`animal_register`, `auth`, `establishment_register`, `home`, `sync`). Son los
candidatos naturales para la próxima pantalla a construir.

| Flujo | Archivo de diseño | Pantallas | Offline (a definir) |
|---|---|---|---|
| Campo / potreros (mapa, lista, detalle) | `screens-campo.jsx` | 3 | Probablemente offline-first (dato productivo de campo) |
| Dashboard (Capataz y Owner) | `screens-dashboard.jsx` | 2 | Offline-first (KPIs desde datos ya sincronizados). `home_page.dart` hoy es sólo un menú de atajos de desarrollo, marcado explícitamente por el equipo como no-definitivo (`// TODO:Agus: Esto no va, es solo un mock para la demo.`) |
| Pesaje en manga (Bluetooth/Manual/Foto) | `screens-pesaje.jsx` | 3 + 1 shell | Offline-first (captura en el campo, sin conectividad) |
| Sanidad (vacunaciones/tratamientos/alertas/aplicar) | `screens-sanidad.jsx` | 4 | Offline-first |
| Reportes SENASA (wizard de generación) | `screens-senasa.jsx` | 6 | Requiere sincronización previa; wizard en sí probablemente online-only para la exportación final |
| Gestión de archivos SENASA + Equipo + Sync + Ajustes | `screens-other.jsx` (menos `MercadoScreen`, ver abajo) | 6 | Mixto: Equipo/Ajustes probablemente online-only (afectan otros usuarios/roles); Sync es la UI que falta para el motor de sync que ya existe en `lib/features/sync` |

## Explícitamente fuera de alcance

- **`MercadoScreen`** (`screens-other.jsx`): cotizaciones Liniers/Rosgan
  ($/kg vivo). Existe en el archivo de diseño de referencia, pero choca
  directo con la restricción dura de CLAUDE.md ("no agregar, mencionar ni
  scaffoldear ningún módulo económico/de precios"). **No implementar bajo
  ningún concepto**; si el Product Owner lo pide, primero hay que resolver
  esa contradicción con el Working Agreement, no programarlo directamente.
- `screens-dark.jsx`: son las mismas 3 pantallas (`DashboardCapataz`,
  `PesajeShell`, `AplicarVacunacion`) con `dark=true`, no pantallas nuevas a
  trackear aparte.
