# ADR-0013 — Recuperación de la respuesta de un canje confirmado

- **Estado:** propuesto, pendiente de revisión humana de permisos y validación del PO.
- **Fecha:** 2026-10-20.
- **Relacionado:** [ADR-0012](adr-0012-invitaciones-por-codigo-email.md).

## Contexto

Un canje puede quedar confirmado en backend y perder su respuesta. Rechazar todos
los reintentos como `codigo_usado` impide distinguir ese resultado de un rechazo.
La caché local no demuestra que la cuenta autenticada recibió acceso.

## Decisión

El código sigue produciendo una sola mutación. `POST /invitaciones/aceptaciones`
puede repetir su respuesta (201, mismo esquema) únicamente si el código ya fue
aceptado por el ID autenticado, el email actual coincide con el invitado y existe
una membresía activa en ese establecimiento. Se devuelve el rol efectivo actual,
no el rol histórico de la invitación. No se escribe, reactiva ni avisa por email
en esa rama. Si el acceso fue revocado, otra cuenta consumió el código o cambió
el email, se conserva `codigo_usado`; mobile nunca convierte un 409 en éxito.
`POST /invitaciones/validaciones` aplica las mismas comprobaciones, permitiendo
retomar el flujo tras reiniciar la app. El vencimiento limita el primer canje;
un resultado ya confirmado se consulta contra el acceso vigente.

Mobile conserva en memoria el código y el alcance validado mientras el resultado
es incierto. Recuperar repite el comando autorizado: el servidor demuestra el
resultado o acepta el código si el primer envío no llegó. Solo una respuesta
válida permite guardar la membresía y mostrar éxito. El código desaparece del
estado después de confirmar; no se persiste en la caché de equipo.

El coordinador existente ordena la persistencia del catálogo después de cualquier
sincronización anterior y publica ese cambio antes de descargar datos. El ciclo
posterior consulta otra vez los establecimientos. Inicio relee el catálogo sin
recrear el shell, incluso si la descarga falla o la ruta de canje ya se cerró.
Las operaciones de Team se serializan mediante una cola explícita por sesión;
los Cubits poseen sus emisiones y el repositorio/coordinador su persistencia.
Los resultados de una sesión reemplazada no se publican ni escriben el catálogo.

## Consecuencias

No hay cambios de esquema, dependencias ni migraciones. Se requiere desplegar el
ajuste backend para recuperar mediante reintento; clientes previos siguen siendo
compatibles. Las políticas online-only y roles del ADR-0012 siguen pendientes del
PO. Las modificaciones de autorización y sesión requieren revisión humana.
Las pruebas usan datos sintéticos, HTTP simulado y SQLite de test; resta validar
el recorrido contra backend real y dispositivos con pérdida de conectividad.
