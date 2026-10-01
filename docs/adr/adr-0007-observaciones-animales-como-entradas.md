# ADR-0007 — Observaciones de un animal como entradas independientes

- **Estado:** aceptado
- **Fecha:** 2026-10-01
- **Contexto:** VITA-173

## Contexto

`animales.observaciones` era un único texto libre. Para agregar una nota había que
reescribir el campo entero, así que dos personas que anotaban algo sobre el mismo animal
desde dispositivos distintos se pisaban: last-write-wins se queda con una versión y
descarta la otra completa. Tampoco quedaba registrado quién escribió cada nota ni cuándo.

Además, mobile ya escribe esa columna en el alta y en la edición del animal, y puede tener
escrituras encoladas offline que van a llegar después del despliegue.

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
- Cualquier miembro activo del establecimiento puede crear, editar y borrar
  lógicamente cualquier entrada del establecimiento, no solo las propias.
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
- **Transición de la columna vieja:** `animales.observaciones` se conserva y la API la
  sigue aceptando y devolviendo, marcada como obsoleta en el esquema OpenAPI. Como puente,
  cuando el alta, la edición o el reenvío de un animal traen un texto no vacío y distinto
  del guardado, el backend crea además una entrada:
  - El id se deriva del animal y del texto (UUIDv5), así que los reintentos no duplican
    y una entrada que el usuario borró no reaparece.
  - El autor es el usuario autenticado y la fecha es el `updated_at` del cliente.
  - La entrada se crea aunque la escritura del animal pierda por last-write-wins: agregar
    una nota nunca pisa otra, y así no se pierde lo escrito offline.
  - Si la escritura del animal se rechaza por otra regla (por ejemplo, una combinación
    reproductiva inválida), se rechaza todo, también la nota.

## Consecuencias

- Mobile tiene que migrar el detalle del animal al recurso nuevo: listar, agregar,
  editar y borrar entradas, y dejar de escribir `observaciones` en el animal.
- Mientras convivan las dos vías, una nota escrita por la columna vieja aparece en las
  dos. El puente no copia ediciones en sentido inverso: editar una entrada no actualiza
  la columna.
- El puente ignora un texto idéntico a otro que ya generó una entrada para el mismo
  animal. Una nota repetida textualmente a propósito por la vía vieja se registra una
  sola vez.
- Retirar la columna, y con ella el puente, queda para otro ticket, cuando ningún
  cliente en uso la escriba. Hasta entonces el puente debe mantenerse para no perder las
  escrituras encoladas.
- El downgrade de `20261001_03` elimina la tabla. Las notas migradas siguen en la
  columna; las creadas después se pierden.
