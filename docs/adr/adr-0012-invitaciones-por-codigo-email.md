# ADR-0012 — Equipo del establecimiento: invitaciones por email con código

- **Estado:** propuesto (pendiente de validación del PO)
- **Fecha:** 2026-10-17
- **Contexto:** gestión del equipo (rama `feature/equipo-establecimiento`, apilada sobre PR #43)
- **Relacionado:** propuesta "Sumarse a un establecimiento con un código" (2026-10-10), PR #42 (maqueta de Equipo)

## Contexto

La única forma de tener acceso a un establecimiento era crearlo: el alta deja al
creador como `owner` en `usuarios_establecimientos` y no había otro camino para sumar
al capataz, al veterinario o a un administrador. El diseño ("9 — Equipo / Usuarios")
muestra una lista con usuarios activos e invitaciones pendientes y una pantalla
"Invitar usuario" con email y rol.

Restricciones:

- **No hay deep links** en la app (sin `app_links`, sin intent filters ni associated
  domains) y la app no usa `supabase_flutter`: la autenticación es REST contra el backend.
- **El registro no verifica el email** (`auth.admin.create_user` con `email_confirm`).
  Si alcanzara con que el email de la sesión coincida con el invitado, cualquiera
  podría registrarse con ese email y quedarse con el acceso.
- No había envío de emails, ni Celery.
- Dar acceso a un campo cambia permisos: no se puede validar un código sin el servidor.

## Decisión

1. **Email con un código.** Invitar crea una fila en `invitaciones_establecimientos` y
   manda un email con un código de 8 caracteres. La persona entra a VITA (o se
   registra) **con ese mismo email** y lo canjea en Perfil → "Sumarme a otro
   establecimiento". El canje exige las dos cosas: el código prueba que controla la
   casilla y la sesión prueba que es esa cuenta. Antes de confirmar ve a qué campo y
   con qué rol se suma (`POST /invitaciones/validaciones`, no consume el código).
2. **Código.** Tiene 8 caracteres de un alfabeto de 31 símbolos sin los que se
   confunden al dictarlos (0/O, 1/I/L): unas 8,5 × 10¹¹ combinaciones. Vence a los
   7 días, sirve una sola vez y no requiere aprobación. Reenviar genera uno nuevo e
   invalida el anterior.
3. **Se guarda un HMAC-SHA256 del código**, con una clave del servidor
   (`INVITACION_CODIGO_SECRETO`), y nunca el código. Si se filtra la tabla, sin la
   clave no se pueden probar códigos offline. No hace falta un hash lento: el código es
   aleatorio y no lo elige una persona.
4. **Límite de intentos por usuario:** 10 por hora entre validar y canjear. El
   límite sigue al usuario, no a la IP, porque en el campo la IP cambia con los datos
   móviles. Es en memoria (`core/auth_rate_limit.py`): con varios workers habría que
   pasarlo a Redis.
5. **El canje es un UPDATE condicional** (`WHERE estado = 'pendiente'`). Si llegan dos
   requests (un doble toque o un reintento), solo una crea la membresía.
6. **SMTP propio y configurable** (`core/email.py`): sirve cualquier proveedor con SMTP
   (Brevo, Resend, una casilla con contraseña de aplicación). En LOCAL/TEST se usa
   `console`, que solo loguea. Staging y producción no arrancan sin `EMAIL_PROVIDER=smtp`,
   `SMTP_HOST`, `SMTP_FROM` e `INVITACION_CODIGO_SECRETO`.
7. **El envío es sincrónico**, con un timeout de 10 s. Si falla, la invitación queda
   creada con `email_enviado=false` y se ofrece reenviar: el owner se entera en el
   momento y no pierde lo que cargó.
8. **Roles.** A los actuales `admin`, `owner` y `employee` se suma `veterinarian`, que
   por ahora opera como `employee`: no ve finanzas ni ventas y no gestiona el equipo.
   - Invitar, reenviar, cancelar y quitar: solo `owner` y `admin`.
   - Un `admin` no invita ni gestiona invitaciones de `owner`, y solo quita a
     `employee` o `veterinarian`.
   - Nadie se quita a sí mismo y el titular (`owner_id`) no se quita. Como a un `owner`
     solo lo quita otro `owner`, el campo nunca queda sin dueño.
   - Ver el equipo: cualquier miembro activo.
9. **Online-only, con la lista cacheada.** Invitar, reenviar, cancelar, quitar y canjear
   necesitan señal, igual que crear la cuenta o el establecimiento. La lista del equipo
   se guarda en el celular (`team_snapshot_v1`, se borra al cerrar sesión), se ve sin
   conexión con la fecha en que se trajo, y sin señal las acciones quedan
   deshabilitadas. Una vez adentro, la persona trabaja offline como cualquier usuario.
   Es una excepción explícita a offline-first, con el mismo criterio que el alta.
10. **Quitar es un soft delete** de la membresía (`activo = false`). Si después se la
    vuelve a invitar con el mismo rol, se reactiva esa fila.

## Alternativas descartadas

- **Deep link en el email:** exige `app_links`, intent filters, associated domains y un
  dominio con `assetlinks.json`/`apple-app-site-association`. Es mucha infraestructura
  para el MVP, y el código cubre lo mismo.
- **Solo código, sin email** (la recomendación D7 de la propuesta del 10/10): Lucho
  eligió el email porque es el flujo del diseño. El código sigue sirviendo si se dicta,
  pero el canje exige el email invitado.
- **`supabase.auth.admin.invite_user_by_email`:** crea el usuario en `auth.users` y
  choca con `/usuarios/registro`. Además, el SMTP por defecto de Supabase solo manda a
  emails del equipo del proyecto y tiene un límite de pocos por hora.
- **Envío asíncrono (BackgroundTasks o Celery):** el owner no se enteraría de que el
  email no salió.

## Consecuencias

- Hay una tabla nueva y se amplía el check de roles: migración `20261017_02` y script
  espejo `backend/scripts/equipo_establecimiento.sql`. La tabla tiene RLS activado sin
  policies: ni `anon` ni `authenticated` la leen por PostgREST.
- Antes del primer deploy hay que elegir un proveedor SMTP y cargar las variables nuevas.
- Pendiente: `/usuarios/registro` exige CUIT, y un capataz o veterinario invitado puede
  no tenerlo.
- Pendiente: acotar `veterinarian` al módulo Sanidad, en una historia aparte.
- Pendiente: el catálogo del celular se actualiza al canjear, pero los datos
  productivos del campo nuevo (animales, lotes) llegan con la próxima sincronización
  inicial.
