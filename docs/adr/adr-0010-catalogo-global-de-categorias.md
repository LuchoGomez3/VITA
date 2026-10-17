# ADR-0010 — Catálogo global de categorías

- **Estado:** propuesto
- **Fecha:** 2026-10-14
- **Contexto:** pedido de mobile en el commit `5fc2edc` (VITA-22, alta de animal)
- **Reemplaza en parte a:** ADR-0006 (deja de haber categorías propias de un establecimiento)

> Numerada 0010 porque la 0008 (GPS) y la 0009 (delimitación del establecimiento) están en
> PRs abiertos (#64 y #66).

## Contexto

Las categorías podían ser globales (`establecimiento_id` null) o propias de un
establecimiento, y la API permitía crearlas, editarlas y borrarlas. Mobile pasó a
tratarlas como un catálogo global administrado por el equipo: lo descarga una vez en la
sincronización inicial con `GET /api/v1/categorias?include_deleted=true`, **sin**
establecimiento, y solo envía el UUID elegido al dar de alta un animal.

El backend todavía exigía `establecimiento_id`, así que **la sincronización inicial de
develop fallaba en su primer paso (422)** para cualquier usuario: no se descargaban
potreros, animales ni pesajes.

En Supabase quedaban 5 categorías propias de prueba (ids `550e8400-…`) con 14 animales
vivos, además de las 6 globales del front.

## Decisión

1. **Catálogo global, igual para todos los establecimientos.** `categorias` pierde
   `establecimiento_id` (con su FK e índice).
2. **La API solo lo lee.** `GET /api/v1/categorias` devuelve el catálogo completo
   ordenado por nombre, con `updated_since` e `include_deleted`, y exige autenticación.
   Se retiran `POST`, `PUT` y `DELETE`: el catálogo se administra desde la base.
3. **Campos:** `id`, `nombre`, `descripcion`, `created_at`, `updated_at`, `deleted_at`.
   Se mantienen también `sexo_permitido` y `permite_estado_reproductivo` (ADR-0006):
   mobile no los necesita, pero son las reglas que valida el backend.
4. **Alta y edición de animales:** la categoría solo tiene que existir y no estar
   borrada. Desaparece el rechazo por "categoría de otro establecimiento", también en el
   trigger `validar_categoria_animal()`.
5. **Datos de prueba** (decisión de Lucho, 2026-10-14): cada animal pasa a la categoría
   global del mismo nombre y compatible con su sexo; las hembras del "Ternero" de prueba
   (que admitía ambos sexos) van a "Ternera". Si alguno no tuviera equivalente, queda sin
   categoría. Después se borran las categorías propias. A los animales reasignados se les
   actualiza `updated_at` para que la descarga delta propague el cambio.

Lo aplica la migración `20261014_01` (espejo: `backend/scripts/catalogo_global_categorias.sql`),
que reemplaza la función del trigger **antes** de borrar la columna: plpgsql resuelve las
columnas recién al ejecutar.

## Consecuencias

- La sincronización inicial de mobile vuelve a completarse.
- Agregar o cambiar una categoría es una tarea del equipo en la base, no de la app. El
  trigger `trg_categorias_reglas_compatibles` sigue impidiendo cambiar las reglas de una
  categoría si deja animales vivos incompatibles.
- Se pierden los tests de alta, edición y borrado de categorías por API; la protección de
  las reglas queda cubierta por los tests del trigger contra Postgres.
- **Encadenamiento:** la migración cuelga de `20261001_03` (head de develop). Supabase
  está sellado en `20261003_01`, de la rama de ventas que todavía no entró a develop.
  Cuando entren las dos, la que mergee segunda re-encadena su `down_revision`. Aplicarla
  en Supabase antes de eso se hace con el script espejo.
