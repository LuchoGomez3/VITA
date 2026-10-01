# ADR-0005 — Cobros de ventas y tope de cobro garantizado por la base

- **Estado:** propuesto (pendiente de validación del PO en los puntos marcados)
- **Fecha:** 2026-10-01
- **Contexto:** VITA-43 / VITA-172

## Contexto

Una venta de hacienda conserva su importe comercial (`ventas.monto_total`), pero el
dinero puede llegar en varias partes o no llegar todavía. El flujo de caja necesita los
cobros efectivos y los indicadores comerciales necesitan el monto vendido, así que son
dos datos distintos.

Los cobros se registran offline y pueden llegar a sincronizarse en simultáneo desde dos
dispositivos del mismo establecimiento. Además, Supabase acepta escrituras directas
que no pasan por el backend. Una validación del tipo "sumar y comparar" en el service no
alcanza: dos transacciones concurrentes leen la misma suma, cada una entra por separado y
la venta queda sobrepagada.

## Decisión

- `ventas_cobros` registra cada cobro efectivo como una fila sincronizable: UUID
  generado en el cliente, `created_at`/`updated_at`/`deleted_at`, `monto numeric(14,2)
  > 0`. Anular un cobro es un soft delete.
- El estado de cobro (pendiente, parcial, cobrada) y el saldo **no se almacenan**: se
  calculan desde la suma de los cobros activos.
- La tabla no tiene `establecimiento_id`: el tenant se resuelve por la venta. Duplicarlo
  permitiría atar un cobro de un campo a la venta de otro.
- El tope "cobros activos ≤ `monto_total`" lo garantiza un trigger `BEFORE INSERT OR
  UPDATE` que toma `select ... from ventas where id = new.venta_id for update` antes de
  sumar. Ese lock de fila serializa las escrituras de cobros de una misma venta. En READ
  COMMITTED, la suma posterior al lock ve los cobros que la otra transacción ya commiteó.
  En REPEATABLE READ o SERIALIZABLE, el lock sobre una fila modificada en paralelo falla
  con un error de serialización. En los dos casos no puede haber sobrepago.
- Se prefirió el lock de fila sobre un advisory lock: vive en la transacción, no requiere
  una convención de claves y serializa también contra el segundo trigger.
- Un segundo trigger `BEFORE UPDATE OF monto_total` en `ventas` impide bajar el monto de
  la venta por debajo de lo cobrado. Sin él, el invariante se rompe por la otra punta.
- Las funciones son `security definer` con `search_path` fijo, para que la suma no
  dependa de qué filas le deja ver el RLS a quien escribe.
- Defaults de producto, **pendientes de validación del PO**:
  - Un cobro no cambia de venta ni de autor. Para corregir uno, se anula y se registra
    otro.
  - Una venta eliminada lógicamente no recibe cobros nuevos ni reactivados. Sus cobros
    existentes siguen siendo editables y anulables.
  - Eliminar una venta no anula sus cobros en la base. Si corresponde, lo hará el service.
- RLS: `select`, `insert` y `update` solo para membresías activas `owner`/`admin` del
  establecimiento de la venta (misma allowlist que ADR-0001/20260910_01). Sin política ni
  permiso de `delete`.

## Consecuencias

- El backend puede traducir el `check_violation` (SQLSTATE 23514) del trigger a un error
  de negocio. La regla vale también para escrituras que no pasan por la API.
- Un cobro que se sincroniza tarde puede rebotar si mientras tanto se cobró el total
  desde otro dispositivo. Mobile tiene que mostrar el rechazo y no reintentar en loop.
- SQLite (tests y cliente) no ejecuta el trigger. Su comportamiento se prueba contra un
  Postgres descartable (`VITA_TEST_POSTGRES_URL`, ver `backend/tests/postgres_helpers.py`).
  Esos tests se saltean en CI mientras el workflow no levante un Postgres.
- La función vive en tres artefactos: el modelo (para `create_all`), la migración y el
  script espejo. Un test de contrato exige que los tres textos sean idénticos.
