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

- La invitación llega **por email con un código de 6 caracteres** (`XXX-XXX`), que el
  dueño también ve una vez para compartirlo por WhatsApp. Se canjea con
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
| `InvCodigoGenerado` | `InvitationCreatedPage` | `/perfil/establecimiento/:establishmentId/equipo/invitacion` (código en `extra`) |
| `InvIngresarCodigo`, `InvError`, `InvConfirmar`, `InvExito` | `JoinEstablishmentPage` | `/perfil/sumarme` |

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

### `InvitationCreatedPage`

Se abre al invitar y al reenviar. Muestra:

- el invitado, con el rol y el chip "Pendiente";
- el código grande, con su vencimiento y "uso único";
- "Copiar", y "Compartir" (el menú de compartir del celular, con un mensaje que
  incluye el email invitado);
- "Listo", y "Cancelar invitación" con confirmación.

### `JoinEstablishmentPage`

Se abre desde la fila "Sumarme a otro establecimiento" de Perfil.

1. **Ingresar:** 6 cajitas `XXX-XXX`. No distingue mayúsculas; se puede pegar el
   código copiado. Hay un aviso de que hace falta conexión y el botón "Validar código".
2. **Error:** las cajitas quedan en rojo y aparece un banner con el motivo (inválido,
   vencido, usado, cancelado, de otra cuenta, sin conexión) y "Te quedan N intentos".
   - "Volver a intentar": si el error fue de conexión, reintenta; si no, vuelve a la
     edición con lo escrito.
   - "Borrar y escribir de nuevo".
3. **Confirmar:** "Código válido" y la tarjeta del campo (RENSPA, localidad, quién
   invitó y con qué rol, el rol propio y el correo). Debajo, "Como X vas a poder…".
   Botones "Unirme a {campo}" y "No es mi invitación".
4. **Éxito:** "Ya sos parte de {campo}. Le avisamos a {quien invitó}". La descarga de
   los datos del campo (la sincronización inicial) se muestra con una barra
   indeterminada. "Ir al inicio".

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
