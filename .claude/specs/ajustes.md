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
| Versión | v0.9.3 · build 412 (sin chevron, no navegable) |

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

Con este PR, ningún flujo del índice `estado-pantallas-diseno.md` queda en
🎨: la iniciativa de maquetado queda completa (Etapa 1) en los 6 flujos que
faltaban — Campo, Pesaje, Sanidad, Sincronización, Gestión de equipo y
Ajustes.

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
