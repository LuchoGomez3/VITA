# ADR-0007 — Observaciones de un animal como entradas independientes

- **Estado:** aceptado
- **Fecha:** 2026-10-01, revisado el 2026-10-04 con las decisiones de Ernesto (PO) en #56
- **Contexto:** VITA-173

## Contexto

`animales.observaciones` era un único texto libre. Para agregar una nota había que
reescribir el campo entero, así que dos personas que anotaban algo sobre el mismo animal
desde dispositivos distintos se pisaban: last-write-wins se queda con una versión y
descarta la otra completa. Tampoco quedaba registrado quién escribió cada nota ni cuándo.

Mobile escribe esa columna en el alta y en la edición del animal. La app todavía no está
desplegada en un entorno de trabajo real, así que backend y mobile pueden cambiar juntos.

## Decisión

- Las notas pasan a `observaciones_animales`: una fila por entrada, con texto, fecha y
  autor. Expone el recurso `/api/v1/observaciones_animales` (alta, listado, edición y
  borrado lógico).
  - La tabla es sincronizable como cualquier otra: UUID del cliente, last-write-wins por
    `updated_at`, `deleted_at`, `updated_since` e `include_deleted`.
  - Agregar una entrada no toca las demás y editar una afecta solo a esa.
  - El autor sale del JWT.
  - El animal, el establecimiento y el autor no cambian después de crear la entrada.
    Lo exigen el service y un trigger.
  - El listado ordena por `fecha` descendente y desempata por `created_at` e `id`.
- **Permisos** (decisión de Ernesto, PO, en #56). El backend es la autoridad: el rol sale
  de `usuarios_establecimientos`, y un usuario puede tener más de uno en el mismo campo.
  - Crear: cualquier miembro activo.
  - Editar texto o fecha: solo el autor. Las notas migradas no tienen autor, así que
    nadie las edita.
  - Borrar lógicamente: el autor, las suyas; `owner` y `admin`, cualquiera del
    establecimiento, incluidas las migradas. Un `employee` no borra notas ajenas.
  - Las reglas valen para PUT, DELETE y el reenvío del alta, y se exigen antes del LWW:
    un cambio no autorizado se rechaza aunque además sea rancio. Un reintento idéntico
    no cuenta como cambio.
  - Errores 403: `observacion_solo_autor` y `observacion_borrado_no_permitido`.
  - En la base, la policy de UPDATE (que también cubre el borrado lógico) deja pasar al
    autor y a `owner`/`admin`. Una policy no distingue columnas, así que el trigger
    completa la regla: un cliente directo que no es el autor no puede cambiar texto ni
    fecha (42501).
- **Sin fuga entre establecimientos en escrituras directas.** El trigger
  `validar_observacion_animal()` corre antes que el WITH CHECK del RLS. Como
  `security definer`, su mensaje revelaba si un animal ajeno existía ("pertenece a otro
  establecimiento" frente al error de FK). El mismo hallazgo se marcó en la revisión de
  VITA-172. Por eso:
  - El trigger es `security invoker`. El backend (rol `postgres`, que no pasa por RLS)
    sigue validando la pertenencia y la inmutabilidad.
  - Un cliente directo no ve `animales` (RLS activo sin policies), así que la
    pertenencia del animal la exige la policy de INSERT con
    `animal_pertenece_a_establecimiento(animal_id, establecimiento_id)`.
  - Esa función es `security definer`, pero solo responde por establecimientos donde
    quien pregunta es miembro activo. Llamada por RPC, no sirve para sondear animales
    ajenos, y `anon` no puede ejecutarla.
  - Animal ajeno, inexistente o declarado en otro establecimiento: el cliente recibe
    siempre el mismo rechazo del RLS (42501). Un test lo fija.
- **Migración de datos** (`20261001_03` y su script espejo): cada `animales.observaciones`
  no vacío se convierte en una entrada.
  - El texto se copia íntegro.
  - `autor_id` queda en null: el autor no se conoce y no se inventa.
  - `fecha` toma `animales.created_at`, el único timestamp disponible. Solo indica
    cuándo se dio de alta el animal, no cuándo se escribió la nota; `updated_at` no
    sirve porque cambia con cualquier edición del animal.
  - `created_at` y `updated_at` toman el momento de la migración, para que los
    clientes bajen las entradas en su próximo pull delta.
  - El id es determinista, `md5('observacion_legacy:' || animal_id)::uuid`: reejecutar
    la migración o el script no duplica nada.
  - Las notas de animales borrados se migran con el mismo `deleted_at`.
- **Sin puente de transición.** `animales.observaciones` queda como columna legacy: el
  alta y la edición del animal ya no la aceptan. Pydantic ignora las claves
  desconocidas, así que un cliente viejo que la manda no falla, pero la nota se pierde.
  `AnimalRead` la sigue devolviendo, marcada como obsoleta, hasta que se retire.
- **Borrar un animal borra sus observaciones** (decisión de Ernesto en #56):
  - Al borrar el animal, por DELETE, por PUT con `deleted_at` o por reenvío del alta,
    sus observaciones vivas se borran lógicamente en la misma transacción. Toman el
    mismo `deleted_at` y un `updated_at` del servidor, así el pull delta lo propaga
    aunque el emisor haya estado offline con el reloj atrasado.
  - Al restaurar el animal (reenvío del alta con `deleted_at` en null) se restauran solo
    las que se borraron en esa cascada, es decir, las que tienen exactamente ese
    `deleted_at`. Las que alguien borró a mano antes siguen borradas.
  - Si un animal ya borrado se vuelve a borrar con otra marca, las de la cascada la
    acompañan, para que una restauración posterior las encuentre.
  - Un borrado que pierde por last-write-wins no dispara la cascada.
  - La API no deja agregar observaciones a un animal borrado (422
    `animal_no_pertenece_establecimiento`).
  - La cascada vive en el service. Un borrado directo en la base no la dispara.

## Consecuencias

- Mobile tiene que migrar el detalle del animal al recurso nuevo: listar, agregar,
  editar y borrar entradas, y dejar de escribir `observaciones` en el animal.
- Retirar la columna `animales.observaciones` queda para otro ticket.
- Las notas migradas no muestran ninguna aclaración: se ven como cualquier otra, sin
  autor.
- El downgrade de `20261001_03` elimina la tabla. Las notas migradas siguen en la
  columna; las creadas después se pierden.
