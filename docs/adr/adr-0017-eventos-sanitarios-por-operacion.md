# ADR-0017: Eventos sanitarios por operación, con catálogo fijo e historial por versión

- **Estado:** Aceptado
- **Fecha:** 2026-11-21
- **Contexto de la decisión:** VITA-20 (y VITA-142, VITA-143, VITA-146, VITA-206, VITA-207)
- **Contrato con Mobile:** `docs/plan-backend-integracion-sanidad.md` (rama `feature/vita-20-eventos-sanitarios`)

## Contexto

Un operario registra una práctica sanitaria sobre uno o varios animales desde la ficha, el lote o la manga, sin señal. El celular guarda la operación con su UUID y la reenvía cuando vuelve la conexión, posiblemente más de una vez. El mismo estudio puede recibir su primer resultado desde dos celulares. Mobile descarga el historial por establecimiento de forma incremental.

`eventos_sanitarios` y `productos_sanitarios` existían en Supabase sin API y sin políticas (RLS activo, `anon` con todos los permisos), y estaban vacías.

## Decisiones

1. **Una operación, un evento por animal.** El alta (`POST /api/v1/eventos_sanitarios`) es atómica: si un integrante es inválido, no se guarda nada y el error indica `campo` (por ejemplo `animales.1.animal_id` o `datos.dosis`) y `animal_id`. Cada evento guarda una foto de la práctica (`practica_id`, `practica_nombre`, `practica_modelo`) y de sus `datos` en `jsonb`, incluido el nombre del producto que decide el servidor. Así el historial se sigue leyendo aunque el catálogo cambie.

2. **Idempotencia con `operaciones_sanitarias`.** Cada envío aceptado (alta o resultado) deja una fila con el UUID de operación y la `huella` (SHA-256 del cuerpo).
   - **Reenvío con la misma huella:** devuelve el estado vigente de sus eventos, incluidos los cambios posteriores, sin revalidar el producto ni el animal.
   - **Mismo UUID con otro cuerpo:** devuelve 409 `operacion_sanitaria_conflicto`.
   - **Corrección de un rechazo:** usa un UUID de operación nuevo y puede conservar los UUID de los eventos, porque el rechazo no persistió nada.

3. **Catálogo fijo en código, productos por establecimiento.** Las prácticas (`vacunacion`, `desparasitacion`, `tratamiento`, `sangrado`, `raspaje_prepucial`, `materia_fecal` y `lesion`) tienen ids estables que el celular guarda para trabajar offline. Cada práctica de aplicación acepta ciertos tipos de producto. Los productos son globales (`establecimiento_id` nulo) o propios del campo. Un producto retirado (`deleted_at`) deja de ofrecerse.

4. **Primer resultado, gana el primero.** `PUT /{evento_id}/resultado` aplica solo a muestreos.
   - **Reenvío de la misma operación:** se responde con éxito.
   - **Otra operación cuando el resultado ya existe:** devuelve 409 `resultado_ya_completado` con el evento vigente en `details.evento`.
   - **Sin acceso o evento inexistente:** devuelve 404, sin revelar que el evento existe en otro campo.

5. **Historial ordenado por `version`, no por fecha.** Cada cambio confirmado recibe la siguiente `version` del establecimiento. El cursor es esa versión, y la última página también devuelve un `next_cursor` válido.
   - **Las escrituras sanitarias de un campo se serializan con `pg_advisory_xact_lock`.** Con el lock, las versiones se confirman en orden y un lector que ya vio la N no puede encontrarse después con una N-1 nueva.
   - **`updated_at` nunca retrocede.** En el alta toma el mayor entre el reloj del servidor y el del celular. En el resultado avanza al menos 1 µs.

6. **RLS de solo lectura.** Los miembros activos leen eventos y operaciones de su campo, y cualquier autenticado lee los productos globales. Nadie escribe directo, porque la versión la asigna el backend. `anon` pierde todos los permisos.

7. **Filas anteriores sin completar.** No tienen práctica ni versión, así que quedan fuera del historial. Al migrar, la tabla de Supabase estaba vacía.

## Consecuencias

- **Toda escritura sanitaria tiene que pasar por el servicio,** incluidas las futuras bajas lógicas. Un `UPDATE` directo en SQL no avanzaría la `version` y el celular no se enteraría.
- **La carencia (`periodo_carencia_dias` y `fecha_fin_carencia`)** se calcula al aplicar, a partir del producto vigente.
- **Una operación admite hasta 500 animales.**
- **La migración `20261121_01` encadena sobre `20261114_02` (Alimentación).**
- **Queda para otra entrega:** la agenda sanitaria, las jornadas con varias prácticas, la administración de productos y los recordatorios.
