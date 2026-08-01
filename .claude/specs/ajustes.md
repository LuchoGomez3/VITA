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

_A completar en `feature/pantalla-ajustes`._

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
