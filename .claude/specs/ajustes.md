---
name: ajustes
description: >-
  Secciones mock que faltan en la pantalla de Perfil/Ajustes (dispositivos
  emparejados, preferencias, sobre la app) — datos mock del diseño de
  referencia. Documento vivo, se actualiza en el mismo commit que introduce
  cada pieza descripta acá.
---

# Ajustes

`AjustesScreen` del diseño **no es una feature nueva**: la mitad superior ya
existe y está conectada a datos reales en
`lib/features/profile/presentation/pages/profile_page.dart` (tarjeta de
usuario, sección de establecimientos, cerrar sesión — ver
`ProfileCubit`/`ProfileEstablishmentsSection`). Esta iniciativa sólo agrega
las tres secciones mock que faltan, sin tocar lo que ya funciona.

Ver también **[`estado-pantallas-diseno.md`](./estado-pantallas-diseno.md)**.

## Pantallas → rutas

| Pantalla (Claude Design) | Página Flutter | Ruta |
|---|---|---|
| `AjustesScreen` (secciones nuevas) | `ProfilePage` (extendida) | `/perfil` (ya existe) |

Sin rutas nuevas: se agregan widgets a la página existente.

## Contenido — lo que ya existe (no tocar)

- Card de perfil con avatar, nombre, email, chip de rol (`ProfileUserCard`).
- Sección "Establecimientos" (`ProfileEstablishmentsSection`, datos reales
  vía `ProfileCubit`).
- Botón "Cerrar sesión".

## Contenido — secciones mock a agregar

### "Dispositivos emparejados"

| Dispositivo | Tipo | Identificador | Estado |
|---|---|---|---|
| Tru-Test GES3S | Bastón RFID | #4421 | conectado |
| Magris MC-200 | Balanza | #M9012 | conectada |
| — | — | — | fila de acción "Vincular nuevo dispositivo" |

### "Preferencias"

| Label | Valor mock |
|---|---|
| Tema | Automático (claro / oscuro) |
| Idioma | Español (Argentina) |
| Unidades | kg · ha · DD/MM/AAAA |

### "Sobre la app"

| Label | Valor mock |
|---|---|
| Manual de usuario | (fila navegable, sin destino) |
| Soporte | soporte@hacienda.app |
| Versión | real: `v<version> · build <n>` del `pubspec.yaml` instalado (sin chevron, no navegable) |

Patrón visual: cada sección es un título + card con filas separadas por
línea (label + valor/subtítulo + chevron si es navegable), replicando
`SectionList` del diseño — en Flutter, un `AppSurfaceCard` con `ListTile`s y
`Divider`s.

## Estado de la Etapa 1 (maquetado)

Implementado en `feature/pantalla-ajustes` (rama desde `develop`, sin
dependencia de otros PRs abiertos). **No es una feature ni una ruta
nueva**: se extendió `ProfilePage` existente.

- `mobile/lib/features/profile/presentation/mock/settings_mock.dart`:
  `PairedDeviceMock` + `pairedDevicesMock` (Tru-Test GES3S, Magris MC-200,
  detalle combinado tipo·id·estado igual que el diseño), `SettingsInfoMock`
  + `preferencesMock` (Tema/Idioma/Unidades, navegables) y `aboutAppMock`
  (Manual de usuario, Soporte, Versión — esta última sin chevron).
- `widgets/settings_row.dart` (`SettingsRow`) y
  `widgets/settings_section_card.dart` (`SettingsSectionCard`): widgets
  nuevos que replican `SectionList` del diseño (icono en caja + label +
  subtítulo + chevron opcional). No se reusó `ProfileInfoRow` (ya existente
  en `profile_user_card.dart`) porque su layout es distinto (label/valor
  apilados, sin chevron ni variante de "acción primaria").
- `profile_page.dart`: nuevo widget privado `_SettingsSections` insertado
  en el `ListView` entre `_EstablishmentsContent` (ya existente) y el botón
  "Cerrar sesión" — mismo orden que el diseño. No se tocó nada de lo que ya
  funcionaba (card de usuario, establecimientos, cerrar sesión).
- Todas las filas navegables y "Vincular nuevo dispositivo" muestran un
  `SnackBar` de fuera de alcance al tocarlas (mismo patrón que
  `apply_vaccination_page.dart`/`sync_status_page.dart`); "Versión" queda
  sin acción.
- Sin colores nuevos, sin rutas nuevas, sin tests (mismo criterio que las
  4 iteraciones anteriores de esta misma).

### Ajustes posteriores (2026-10-16, merge de `develop`)

Mientras el PR esperaba, `develop` rehízo Perfil (cabecera verde adaptable,
"Información personal", tarjetas de establecimiento). Se mantuvo ese diseño
y se acomodaron las secciones de ajustes:

- Títulos de sección con `AppTypography.pageTitle`, igual que
  "Información personal" y "Establecimientos".
- `SettingsRow` con las medidas del diseño: caja de icono de 32 (verde llena
  en las acciones primarias), icono 18, label 13/700, subtítulo 11/600 y
  filas a todo el ancho de la card (divisor y efecto al tocar incluidos).
- Un icono por fila (bastón/balanza, tema, idioma, unidades, manual,
  soporte, versión) en vez de uno repetido por sección.
- Fila "Sumarme a otro establecimiento" debajo de los establecimientos; por
  ahora avisa "Disponible próximamente" hasta que exista el flujo de
  sumarse con código.
- "Versión" lee la versión instalada con `package_info_plus`
  (`readInstalledAppVersion` en `profile_composition.dart`); si falla, se
  loguea y la fila muestra un guion.
- El mensaje de las filas sin destino pasó de "Fuera de alcance de esta
  iniciativa" a "Disponible próximamente".
- Queda distinto al diseño, a propósito: la cabecera (el diseño usa
  `AppHeader` con selector de establecimiento y "Ajustes") y las tarjetas de
  establecimiento, que son el rediseño reciente de Perfil en `develop`.

Con este PR, ningún flujo del índice `estado-pantallas-diseno.md` queda en
🎨: la iniciativa de maquetado queda completa (Etapa 1) en los 6 flujos que
faltaban — Campo, Pesaje, Sanidad, Sincronización, Gestión de equipo y
Ajustes.

### Establecimientos y ficha (2026-10-17)

- "Establecimientos" pasa a ser una lista como `SectionList`: cada fila
  ("Dueño · 847 ha") abre `EstablishmentDetailPage`
  (`/perfil/establecimiento`, con `EstablishmentDetails` en `extra`).
- La ficha muestra el mapa satelital con el pin y el contorno
  (`LocationMapPreview` del alta, por eso esta rama está apilada sobre
  `feature/establecimiento-delimitar-superficie`, #66), la superficie
  declarada y la delimitada (`FieldBoundaryGeometry`), y RENSPA, CUIT,
  provincia, departamento, localidad y coordenadas.
- El catálogo offline (`establishment_catalog_v1`) guarda ahora `latitude`,
  `longitude` y `boundary`, que ya devolvía el backend. Los catálogos viejos
  se leen sin ubicación hasta el próximo inicio de sesión.
- La cabecera compacta de Perfil deja de repetir el nombre del usuario.

### Foto y color de la cabecera (2026-10-17)

- Lápiz arriba a la derecha de la cabecera, visible solo con la cabecera
  expandida. Abre `ProfileAppearanceSheet` con dos pestañas de alto propio:
  - **Foto:** sacar una foto, elegir de la galería, elegir un avatar
    "Toon Head" (DiceBear, generado en el celular con `dicebear_core` +
    `dicebear_styles`, con el crédito CC BY 4.0 de Johan Melin) o quitar la
    foto.
  - **Color de fondo:** 12 colores guardados más el verde original, rueda
    (`flutter_colorpicker`) y campos R/G/B. Sobre un color claro el texto de
    la cabecera pasa a oscuro.
- Offline-first (`ProfileAppearanceRepositoryImpl`): el cambio se guarda en el
  celular (`profile_appearance_v1` + archivo en documentos) y se sube con su
  propio reintento, porque la cola de Brick no encola multipart. Lo pendiente
  no se pisa con lo que trae la cuenta; una foto que el servidor rechaza se
  descarta y se avisa.
- Backend (adr-0011): `PATCH /api/v1/usuarios/me` (color),
  `PUT|GET|DELETE /api/v1/usuarios/me/avatar`. El bucket privado `avatars`
  guarda una sola foto por usuario (`<usuario_id>.jpg`, upsert), normalizada
  a JPEG de 512 px sin metadatos; el bucket acepta solo `image/jpeg` de hasta
  1 MB. Columnas nuevas en `usuarios`: `color_cabecera` y
  `avatar_actualizado_en` (migración `20261017_01`, aplicada en Supabase por
  script el 2026-10-17).

## Explícitamente fuera de alcance de esta iniciativa

- "Vincular nuevo dispositivo" — sin flujo de emparejamiento real (ni
  siquiera mock de pantalla en el diseño).
- Fila "Manual de usuario" — sin documento destino.
- Cualquier toggle de tema/idioma funcional — son filas de sólo lectura en
  Etapa 1.

## Pendiente para Etapas 2 y 3

- Persistencia real de preferencias (tema/idioma/unidades) — hoy no existe
  ningún mecanismo de preferencias de usuario en el backend ni en
  `secure_storage_service.dart`.
- Emparejamiento real de dispositivos Bluetooth (bastón RFID, balanza) — hoy
  sólo se simula en Pesaje/Sanidad.
