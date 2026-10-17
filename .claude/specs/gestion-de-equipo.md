---
name: gestion-de-equipo
description: >-
  Equipo del establecimiento: lista de usuarios activos e invitaciones
  pendientes, invitar por email con un código y sumarse a otro campo con ese
  código. Documento vivo, se actualiza en el mismo commit que introduce cada
  pieza descripta acá.
---

# Gestión de equipo

Quién tiene acceso a cada establecimiento y con qué rol. Las decisiones están en
**[`adr-0012`](../../docs/adr/adr-0012-invitaciones-por-codigo-email.md)**:

- La invitación llega **por email con un código de 8 caracteres**, que se canjea con
  una sesión iniciada con ese mismo email.
- Hay 4 roles: `owner`, `admin`, `employee` y `veterinarian`. `veterinarian` opera
  como `employee`.
- Solo dueños y administradores gestionan el equipo.
- Es **online-only**, con la lista cacheada para verla sin conexión.

Se entra desde **Perfil → Establecimientos → ficha del establecimiento → Equipo**,
no desde Hacienda: cada establecimiento tiene su equipo. La maqueta original
(PR #42, `feature/pantalla-equipo`) entraba por un atajo en `livestock_page.dart`;
se reemplaza por esta implementación.

Ver también **[`estado-pantallas-diseno.md`](./estado-pantallas-diseno.md)**.

## Pantallas → rutas

| Pantalla (Claude Design) | Página Flutter | Ruta |
|---|---|---|
| `EquipoScreen` | `TeamPage` | `/perfil/establecimiento/:establishmentId/equipo` |
| `EquipoInvitar` | `InviteTeamMemberPage` | `/perfil/establecimiento/:establishmentId/equipo/invitar` |
| (no está en el diseño) | `JoinEstablishmentPage` | `/perfil/sumarme` |

Las rutas llevan el id en el path y no en `extra`, para sobrevivir a que el sistema
restaure la app. El establecimiento y el rol propio salen de `EstablishmentCatalog`.

## Contenido por pantalla

### Ficha del establecimiento

- Después de "Datos del establecimiento" hay una sección "Equipo" con la fila
  "Usuarios del establecimiento".
- La ven todos los miembros. El subtítulo cambia según si la persona puede
  gestionar el equipo.

### `TeamPage`

- Header: `AppHeader` con el nombre del campo y "Equipo".
- "Usuarios · N" lista los miembros activos. Cada card tiene:
  - avatar de iniciales con el color de cabecera del perfil;
  - nombre, chip "Activo", email y chip de rol;
  - para el titular, la nota "Titular del establecimiento".
- "Invitaciones pendientes · N" lista las invitaciones:
  - el chip es "Invit. pend." (warn), o "Vencida" si pasó la fecha;
  - una nota muestra el vencimiento o avisa que el email no salió.
- Menú ⋮, solo con las acciones que permite el rol propio:
  - en un miembro: quitar, que pide confirmación;
  - en una invitación: reenviar, y cancelar con confirmación.
- FAB "Invitar usuario": solo para owner y admin.
- Sin conexión aparece un banner con la fecha de lo guardado; las acciones y el FAB
  quedan deshabilitados.
- Se actualiza tirando hacia abajo (pull to refresh).

### `InviteTeamMemberPage`

- Campo de email, validado en la app y en el backend.
- Radio-cards con los roles que quien invita puede asignar: un admin no ve "Dueño".
  Empleado viene preseleccionado.
- "Enviar invitación" vuelve a Equipo con un aviso. Si el email no salió, la
  invitación queda creada y se reenvía desde la lista.

### `JoinEstablishmentPage`

Se abre desde la fila "Sumarme a otro establecimiento" de Perfil, que antes decía
"Disponible próximamente".

1. Se escribe el código. Se acepta con o sin guion y en minúsculas.
2. "Continuar" previsualiza: "Te vas a sumar a La Sirena como Veterinario. Te invitó…".
3. "Sumarme" canjea el código, agrega el campo al catálogo del celular y vuelve a
   Perfil, que recarga la lista.

Cada error tiene su mensaje: código inválido, vencido, usado, revocado, de otro email,
demasiados intentos o sin conexión.

## Backend

Son 8 endpoints en `backend/api/modules/equipo/` (ver el ADR):

- `GET` y `DELETE` sobre `/establecimientos/{id}/usuarios[/{usuario_id}]`;
- `GET` y `POST` sobre `/establecimientos/{id}/invitaciones`, más `POST .../{inv}/reenvios`
  y `DELETE .../{inv}`;
- `POST /invitaciones/validaciones` y `POST /invitaciones/aceptaciones`.

## Fuera de alcance

- Cambiar el rol de un miembro existente.
- Transferir la titularidad del establecimiento.
- Permisos finos por módulo para `veterinarian`; los otros roles de CLAUDE.md
  (`capataz`, `asset_manager`, `external_buyer`) tampoco se implementan.
- Deep links.

## Pendiente

- Validar con Ernesto (PO) la tabla de permisos y que `veterinarian` funcione como
  `employee`.
- Elegir el proveedor SMTP y cargar las variables antes del primer deploy.
- `/usuarios/registro` exige CUIT, y un invitado puede no tenerlo.
- Los datos productivos del campo al que alguien se suma llegan con la próxima
  sincronización inicial.
