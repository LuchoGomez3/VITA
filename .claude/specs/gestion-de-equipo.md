---
name: gestion-de-equipo
description: >-
  Flujo de gestión de equipo (listado de usuarios del establecimiento e
  invitación con rol) — pantallas, secciones y datos mock del diseño de
  referencia. Documento vivo, se actualiza en el mismo commit que introduce
  cada pieza descripta acá.
---

# Gestión de equipo

Administración de los usuarios que tienen acceso a un establecimiento y su
rol. Es una acción sensible (afecta permisos de otros usuarios), por lo que
probablemente sea **online-only** cuando se conecte a backend (mismo criterio
que `sign_up`/`establishment_register`, a confirmar en Etapa 3). Se llega por
un atajo de desarrollo desde `livestock_page.dart`; en el diseño original vive
detrás del tab "Más", que no existe en el shell actual de 4 tabs.

Ver también **[`estado-pantallas-diseno.md`](./estado-pantallas-diseno.md)**.

## Pantallas → rutas

| Pantalla (Claude Design) | Página Flutter | Ruta |
|---|---|---|
| `EquipoScreen` | `TeamPage` | `/equipo` |
| `EquipoInvitar` | `InviteTeamMemberPage` | `/equipo/invitar` |

## Contenido por pantalla

### `TeamPage` (`/equipo`)

- Header: `AppHeader` ("La Sirena" / "Equipo" / 14 pendientes).
- Sección "Usuarios · 4": una card por usuario con avatar de iniciales
  coloreado, nombre, chip de estado (activo/invitación pendiente), email,
  chip de rol y subtítulo opcional de alcance.
- FAB "Invitar usuario" → `InviteTeamMemberPage`.

**Datos mock (los 4 usuarios):**

| Nombre | Email | Rol (diseño) | Estado | Iniciales/color | Alcance |
|---|---|---|---|---|---|
| Mariano Suárez | mariano@lasirena.com.ar | Capataz | activo | MS · primario | — |
| Cecilia Lazarte | ceci@lasirena.com.ar | Owner | activo | CL · chart-4 | — |
| Diego Romero | dr.vet@gmail.com | Veterinario | activo | DR · chart-2 | Acceso solo lectura · módulo Sanidad |
| Augusto Páez | augusto.consign@gmail.com | Consignatario externo | invitación pendiente | AP · muted | Acceso solo lectura · módulo Animales |

### `InviteTeamMemberPage` (`/equipo/invitar`)

- Header propio: botón de cerrar + "Invitar usuario".
- Campo de email (mock: `hernan.peon@lasirena.com.ar`).
- Selector de rol: radio-cards con descripción, uno seleccionado por defecto.
- CTA fijo: "Enviar invitación".

**Roles del diseño** (radio-cards, `capataz` preseleccionado):

| Rol (diseño) | Descripción |
|---|---|
| Owner | Control total · facturación · eliminar el establecimiento. |
| Administrator | Configuración + datos + usuarios. No factura. |
| Capataz (preseleccionado) | Operación diaria: animales, pesajes, sanidad, movimientos. |
| Veterinario | Acceso parcial al módulo Sanidad. Puede aplicar tratamientos. |
| Consignatario externo | Solo lectura del rodeo. Pensado para escritorios. |

**Divergencia con el dominio real a documentar, no a copiar ciegamente**:
CLAUDE.md define **seis** roles (`administrator`, `owner`, `veterinarian`,
`capataz`, `asset_manager`, `external_buyer`); el diseño sólo tiene 5 y omite
`asset_manager`. El mock de Etapa 1 debe listar los 6 roles reales (agregando
una descripción razonable para `asset_manager`), no limitarse a los 5 del
diseño.

## Estado de la Etapa 1 (maquetado)

_A completar en `feature/pantalla-equipo`._

## Explícitamente fuera de alcance de esta iniciativa

- Acción sobre una card de usuario existente (editar rol, revocar acceso) —
  el diseño no la define, sólo el alta.
- Reenvío de invitación pendiente.

## Pendiente para Etapas 2 y 3

- Backend: no existe todavía endpoint de invitación/gestión de miembros de
  `usuario` por establecimiento.
- Validación de email (formato) y de que el rol seleccionado sea uno de los
  6 válidos.
- Confirmar si el alta de miembro es online-only (afecta permisos de otro
  usuario, similar a por qué `sign_up` lo es) — a decidir con el Product
  Owner antes de Etapa 3.
