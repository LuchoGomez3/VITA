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

## Animales: categoría y condición reproductiva

Decisiones de fondo en `docs/adr/adr-0006-reglas-reproductivas-de-categorias.md`.

`categorias` lleva dos reglas explícitas, que nunca se infieren del nombre:

| Columna | Tipo | Notas |
| --- | --- | --- |
| `sexo_permitido` | `varchar` NOT NULL | `macho` \| `hembra` \| `ambos` |
| `permite_estado_reproductivo` | `boolean` NOT NULL, default `false` | habilita `vacia`/`prenada` en sus hembras |

`animales.estado_reproductivo` (`varchar`, nullable) vale `sin_determinar`, `vacia`,
`prenada` o `null`, y es independiente de `estado`. Los CHECK del propio animal fijan los
valores válidos y que un macho siempre tenga `null`. La compatibilidad con la categoría es
lógica entre tablas y vive en dos triggers:

- `trg_animales_categoria_compatible` (`validar_categoria_animal()`) valida el animal en
  el insert y cuando cambian `sexo`, `categoria_id`, `estado_reproductivo` o
  `deleted_at`. Comprueba que la categoría admita el sexo y, para `vacia`/`prenada`, que
  esté habilitada. Al **asignar** la categoría rechaza también una borrada o de otro
  establecimiento.
- `trg_categorias_reglas_compatibles` (`validar_reglas_categoria()`) rechaza cambiar
  `sexo_permitido` o `permite_estado_reproductivo` si deja animales vivos incompatibles.

Los triggers BEFORE corren antes que el WITH CHECK del RLS, así que no pueden leer filas
que quien escribe no ve, porque su mensaje de error las revelaría.
`validar_categoria_animal()` es `security invoker`: el backend (rol `postgres`, que no
pasa por RLS) valida todo, y un cliente directo recibe siempre el rechazo del RLS (42501),
sea la categoría ajena, inexistente o incompatible. `validar_reglas_categoria()` es
`security definer` porque tiene que contar todos los animales de la categoría. No filtra
información: solo corre en el UPDATE de filas que el RLS ya dejó actualizar.
`create_all` las instala en Postgres; en producción las
crea la migración `20261001_02` (espejo: `backend/scripts/agregar_reglas_reproductivas_categorias.sql`).
Sus tests corren contra un Postgres efímero (`VITA_TEST_POSTGRES_URL`, probados con 16;
Supabase usa 17).

El catálogo real son las seis categorías del front, globales (`establecimiento_id` null)
y con los mismos UUIDs que usa mobile:

- Ternera, `hembra`.
- Ternero, `macho`.
- Vaquillona y Vaca, `hembra`, con condición reproductiva habilitada.
- Novillo y Toro, `macho`.

La migración las siembra si faltan y las clasifica si ya existían sin reglas. Las globales
se leen y se asignan desde cualquier establecimiento, pero no se editan ni se borran:
reenviar una por `POST /categorias` responde 403.

Las cinco categorías `550e8400-…` de Supabase son **datos de prueba heredados**. Se
clasifican por id para que la migración no se corte: el Ternero de prueba queda en
`ambos` porque tiene hembras. El script espejo trae al final un paso de limpieza
**comentado**, que se corre a mano: pasa esas hembras a la Ternera global y borra
lógicamente Engorde Rápido. Ante cualquier otra categoría sin clasificar, o un animal
incompatible, la migración se detiene en vez de inventar la regla.

RLS: `categorias` y `animales` tienen RLS activo y ninguna policy, así que solo accede el
backend. Si algún día un cliente lee directo por PostgREST, va a hacer falta una policy de
lectura (globales + propias).

### Observaciones del animal

Decisiones de fondo en `docs/adr/adr-0007-observaciones-animales-como-entradas.md`.

`observaciones_animales` es sincronizable y guarda una fila por nota:

| Columna | Tipo | Notas |
| --- | --- | --- |
| `id` | `uuid` PK | generada en mobile |
| `animal_id` | `uuid` NOT NULL | FK `animales`; inmutable |
| `establecimiento_id` | `uuid` NOT NULL | FK `establecimientos`; igual al del animal; inmutable |
| `texto` | `text` NOT NULL | `trim(texto) <> ''` |
| `fecha` | `timestamptz` NOT NULL | cuándo se hizo la observación |
| `autor_id` | `uuid` | FK `usuarios`; sale del JWT; inmutable; null solo en notas migradas |
| `created_at` / `updated_at` / `deleted_at` | `timestamptz` | |

Índices: `ix_observaciones_animales_fecha (animal_id, fecha)` para el historial y
`ix_observaciones_animales_sync (establecimiento_id, updated_at)` para el pull delta. El
trigger `trg_observaciones_animales_validar` exige que el animal sea del mismo
establecimiento y rechaza cambiar animal, establecimiento o autor. Las políticas RLS dejan
leer, insertar (solo como uno mismo) y actualizar a los miembros activos; no hay política
de delete porque el borrado es lógico.

La migración `20261001_03` (espejo: `backend/scripts/crear_observaciones_animales.sql`)
convirtió cada `animales.observaciones` no vacío en una entrada:

- Autor en null.
- `fecha = animales.created_at`.
- Id determinista `md5('observacion_legacy:' || animal_id)::uuid`, para no duplicar al
  reejecutarse.

La columna vieja se conserva por compatibilidad: una nota nueva que llega por ella genera
también una entrada.

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
| `es_empresa` | `boolean` NOT NULL | distingue persona jurídica de persona física |
| `apellido_comprador` | `varchar` | obligatorio si no es empresa; debe ser `NULL` si es empresa |
| `nro_dte` | `varchar` NOT NULL | se conserva como texto; no vacío |
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

Las políticas RLS de ambas tablas permiten consultar y registrar información comercial
solo a membresías activas con rol `owner` o `admin`. El rol `employee` no puede acceder a
las ventas ni a sus montos, incluso si intenta escribir directamente mediante Supabase.

## Lotes y movimientos entre lotes

`lotes` es la división física del establecimiento donde pastorea un rodeo. Decisiones de
fondo en `docs/adr/adr-0002-geometria-y-movimientos-de-lotes.md`; contrato con mobile en
`docs/contrato-lotes-movimientos.md`.

`lotes` — sincronizable:

| Columna | Tipo | Notas |
| --- | --- | --- |
| `id` | `uuid` PK | generada en mobile |
| `establecimiento_id` | `uuid` NOT NULL | FK `establecimientos` |
| `nombre` | `varchar` NOT NULL | no vacío; único normalizado por establecimiento |
| `geometria_local` | `jsonb` NOT NULL | polígono esquemático, **no** geografía (ver abajo) |
| `modo_geometria` | `varchar` NOT NULL | hoy solo `local_schematic` |
| `superficie_ha` | `numeric(12,2)` NOT NULL | `> 0`, autoritativa a **un decimal** |
| `recurso_forrajero_codigo` | `varchar` | `pasto_natural` \| `alfalfa` \| `sorgo` \| `maiz` \| `avena` \| `otro` |
| `tiene_agua` | `boolean` NOT NULL | |
| `estado` | `varchar` NOT NULL | `activo` \| `descanso` \| `mantenimiento` \| `inactivo` |
| `plan_alimenticio_id` | `uuid` | FK `planes_alimenticios`; concepto distinto del forraje |
| `created_at` / `updated_at` / `deleted_at` | `timestamptz` | |

La unicidad de nombre es un índice de expresión **parcial**:
`unique (establecimiento_id, lower(btrim(nombre))) where deleted_at is null`. Normalizado
para que " potrero bajo " colisione con "Potrero Bajo", y parcial para que borrar un lote
libere su nombre. Está excluido de la comparación de `alembic check` (ver `alembic/env.py`):
Postgres y SQLite escriben la expresión distinto y autogenerate no puede compararla.

### La geometría no es geográfica

`geometria_local` guarda un polígono en un plano cartesiano común a los lotes del
establecimiento, de extensión lógica 1000×1000. **No es lat/long ni GeoJSON WGS84**, y no
hay transformación definida hacia el mundo real. Es lo que permite dibujar el campo sin
mapa, sin GPS y sin señal. La geometría geográfica real será una columna nullable aparte
cuando exista vista aérea; esta seguirá siendo el fallback. **No se usa PostGIS**: área,
auto-intersección y superposición se calculan con `shapely` en CPU.

Dos lotes pueden compartir vértice, borde o adyacencia —un campo dividido en potreros es
exactamente eso—; lo que no pueden es solaparse con área positiva.

### El movimiento es un agregado

`movimientos_lotes` (cabecera, sincronizable) + `movimientos_lotes_animales` (detalle,
solo `Base`, con `UNIQUE (movimiento_lote_id, animal_id)`).

Mobile crea *una* operación con N animales y le asigna *un* UUID, que es su clave de
idempotencia; ese UUID tiene que ser PK de una sola fila. La tabla anterior
`movimientos_lote` guardaba una fila por animal y no podía sostenerlo: se descartó en la
migración `20260905_03` (estaba vacía).

La cabecera lleva `lote_origen_id` (nullable en la base, obligatorio en la API V1),
`lote_destino_id`, `fecha_movimiento`, `motivo` y `responsable_id`, que **siempre** sale
del JWT.
