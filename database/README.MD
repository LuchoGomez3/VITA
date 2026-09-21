# Base de datos

PostgreSQL 16 sobre Supabase. Este paquete contiene la capa de acceso compartida
(`database.py`), la base común de los modelos (`models.py`) y helpers de búsqueda
(`search.py`). Los modelos de dominio viven en `backend/api/modules/<recurso>/models.py`.

## Cómo se materializa el esquema

Hay tres caminos y conviene no confundirlos:

| Entorno | Mecanismo |
| --- | --- |
| LOCAL / TEST | `SQLModel.metadata.create_all` desde `backend/core/contextmanager.py` |
| Despliegue (staging, producción) | Migraciones Alembic — `alembic upgrade head` |
| Intervención manual en Supabase | Los scripts espejo de `backend/scripts/*.sql` |

Las migraciones viven en `backend/alembic/versions/` y se ejecutan desde `backend/`.

```bash
cd backend
alembic heads                 # lo que valida CI: debe haber un único head
alembic current               # revisión aplicada en la base apuntada por DATABASE_URL
alembic upgrade head
alembic downgrade -1
alembic check                 # los modelos y la base no deben diferir
```

La URL sale de `DATABASE_URL` (o `POSTGRES_URI`) vía `core.config.settings`; nunca se
escribe en `alembic.ini`.

### No hay revisión baseline

El esquema es anterior a Alembic, así que las revisiones son **deltas incrementales**
sobre una base que ya existe. Consecuencias prácticas:

- Un `upgrade()` tiene que poder correr sobre una base que ya tiene los objetos.
  Se comprueba con `sa.inspect(connection)` antes de crear cada tabla o índice.
- Una base nueva y vacía **no** se construye con `alembic upgrade head`: se crea con
  `create_all` y después se marca con `alembic stamp head`.
- Para incorporar una base existente al control de versiones: `alembic stamp <revisión>`
  con la última revisión que ya esté reflejada en ella.

### Scripts espejo

Cada migración que crea estructura nueva deja un `backend/scripts/*.sql` equivalente,
para ejecutar a mano desde el SQL Editor de Supabase cuando no se puede correr Alembic.
Son de respaldo: **el mecanismo normal de despliegue es Alembic**. Ambos caminos deben
producir el mismo esquema, incluidos los nombres de las restricciones.

### Row Level Security

Las políticas se apoyan en `auth.uid()`, que solo existe en Supabase. Las migraciones
detectan si la función está disponible y omiten el bloque de RLS cuando no lo está, para
que un Postgres de desarrollo pueda migrar igual. En ese caso el aislamiento por tenant
queda enteramente a cargo del service, que filtra por membresía en toda consulta —
motivo por el cual el service nunca debe delegar el aislamiento en RLS.

## Convenciones de las tablas sincronizables

Toda entidad que viaje al cliente offline hereda de `Base` y `SoftDeleteMixin`:

- PK `UUID` **generada en el cliente**, nunca autoincremental.
- `created_at` / `updated_at` en `timestamptz`; conflictos por last-write-wins sobre `updated_at`.
- Borrado lógico con `deleted_at`, para que el borrado también sincronice.
- Índice compuesto `(establecimiento_id, updated_at)` que sostiene la descarga delta.

Las tablas hijas de un agregado atómico (por ejemplo `ventas_detalles`) heredan solo de
`Base`: viajan dentro del payload de su padre y no se sincronizan por separado.

## Ventas de hacienda

`ventas` registra la operación comercial y `ventas_detalles` los animales que la componen.
Es una estructura separada de `egresos`, que modela las salidas físicas **no comerciales**
del animal (muerte, baja, traslado externo). Ver `docs/adr/adr-0001-ventas-separada-de-egresos.md`.

`ventas` — sincronizable:

| Columna | Tipo | Notas |
| --- | --- | --- |
| `id` | `uuid` PK | generada en mobile |
| `establecimiento_id` | `uuid` NOT NULL | FK `establecimientos` |
| `fecha_operacion` | `date` NOT NULL | |
| `tipo_comprador` | `varchar` NOT NULL | `frigorifico` \| `remate` \| `particular` |
| `nombre_comprador` | `varchar` NOT NULL | razón social o nombre de pila; no vacío |
| `apellido_comprador` | `varchar` | solo para persona física |
| `nro_dte` | `varchar` | **nullable**: SENASA lo emite después del trato |
| `tipo_venta` | `varchar` NOT NULL | `por_kilo` \| `al_bulto` |
| `peso_total_kg` | `numeric(10,3)` | obligatorio si `por_kilo` |
| `precio_por_kg` | `numeric(14,2)` | obligatorio si `por_kilo` |
| `monto_total` | `numeric(14,2)` NOT NULL | `> 0` |
| `observaciones` | `varchar` | |
| `registrada_por_id` | `uuid` NOT NULL | FK `usuarios`; sale del JWT |
| `created_at` / `updated_at` / `deleted_at` | `timestamptz` | |

`ventas_detalles` — no sincronizable por separado: `id`, `venta_id`, `animal_id`,
`peso_kg`, `precio`, `created_at`, `updated_at`, con `UNIQUE (venta_id, animal_id)`.

Un mismo animal puede aparecer en ventas distintas (reingresó al stock y se revendió);
lo que no puede es repetirse dentro de la misma venta.
