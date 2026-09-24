-- Espejo manual de la migración 20260924_01_crear_calibraciones_ml.
--
-- El mecanismo normal de despliegue es Alembic; este script es el respaldo para
-- ejecutar a mano desde el SQL Editor de Supabase. Ambos caminos producen el
-- mismo esquema, con los mismos nombres de restricciones e índices.
--
-- Es idempotente: se puede volver a ejecutar sobre una base que ya lo tenga.
--
-- OJO: este script NO crea el bucket de Storage. El bucket privado
-- 'calibraciones-ml' se crea a mano (Dashboard -> Storage -> New bucket, con
-- "Public bucket" DESACTIVADO) y sus credenciales viven fuera del repositorio.
-- Ver backend/api/modules/calibraciones_ml/README.md.

begin;

-- ============================================================================
-- 1. Tabla del dataset de calibración del modelo de visión
--
-- Guarda los pares (foto lateral, peso real de balanza) capturados en el "Modo
-- Calibración". Entidad sincronizable: PK UUID generada en el cliente,
-- created_at / updated_at / deleted_at, last-write-wins y borrado soft.
--
-- La foto NO vive acá: va a un bucket privado de Storage y la tabla conserva
-- solo la CLAVE del objeto (imagen_key). Una URL pública expondría la imagen y
-- una firmada vence, y el registro tiene que seguir resolviendo la foto dentro
-- de meses, cuando se reentrene el modelo.
-- ============================================================================

create table if not exists public.calibraciones_ml (
    id uuid primary key,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    deleted_at timestamptz,
    establecimiento_id uuid not null references public.establecimientos (id),
    animal_id uuid not null references public.animales (id),
    -- Peso leído en la balanza física: la etiqueta contra la que se mide el
    -- modelo. Nunca se llena con una predicción.
    peso_real_kg numeric(10, 3) not null,
    -- Lo que predijo el modelo on-device al capturar, si ya había uno cargado.
    peso_estimado_kg numeric(10, 3),
    fecha_captura timestamptz not null,
    imagen_key varchar,
    imagen_bytes integer,
    estado varchar not null,
    responsable_id uuid references public.usuarios (id),
    observaciones varchar
);

-- ============================================================================
-- 2. Restricciones
--
-- La API ya valida todo esto, pero la base también lo hace: Supabase acepta
-- escrituras directas y esas no pasan por Pydantic.
-- ============================================================================

alter table public.calibraciones_ml
    drop constraint if exists ck_calibraciones_ml_estado_valido;
alter table public.calibraciones_ml
    add constraint ck_calibraciones_ml_estado_valido
    check (estado in ('pendiente_imagen', 'completa', 'descartada'));

alter table public.calibraciones_ml
    drop constraint if exists ck_calibraciones_ml_peso_real_positivo;
alter table public.calibraciones_ml
    add constraint ck_calibraciones_ml_peso_real_positivo
    check (peso_real_kg > 0);

alter table public.calibraciones_ml
    drop constraint if exists ck_calibraciones_ml_peso_estimado_positivo;
alter table public.calibraciones_ml
    add constraint ck_calibraciones_ml_peso_estimado_positivo
    check (peso_estimado_kg is null or peso_estimado_kg > 0);

-- Una muestra completa es, por definición, la que tiene su objeto en Storage.
-- Sin esto, una escritura directa podría marcar 'completa' una fila sin imagen
-- y colarla en el dataset de entrenamiento.
alter table public.calibraciones_ml
    drop constraint if exists ck_calibraciones_ml_completa_exige_imagen;
alter table public.calibraciones_ml
    add constraint ck_calibraciones_ml_completa_exige_imagen
    check (estado <> 'completa' or imagen_key is not null);

alter table public.calibraciones_ml
    drop constraint if exists ck_calibraciones_ml_imagen_bytes_positivo;
alter table public.calibraciones_ml
    add constraint ck_calibraciones_ml_imagen_bytes_positivo
    check (imagen_bytes is null or imagen_bytes > 0);

-- ============================================================================
-- 3. Índices
-- ============================================================================

create index if not exists ix_calibraciones_ml_establecimiento_id
    on public.calibraciones_ml (establecimiento_id);

create index if not exists ix_calibraciones_ml_animal_id
    on public.calibraciones_ml (animal_id);

-- Sostiene la descarga delta del cliente offline (updated_since).
create index if not exists ix_calibraciones_ml_sync
    on public.calibraciones_ml (establecimiento_id, updated_at);

-- Dos filas no pueden apuntar al mismo objeto de Storage: la clave se deriva
-- del UUID de la muestra, así que un duplicado significaría que algo pisó el
-- dataset de otra muestra.
create unique index if not exists ix_calibraciones_ml_imagen_key
    on public.calibraciones_ml (imagen_key);

-- ============================================================================
-- 4. Row Level Security
--
-- El backend entra con un rol que no es 'authenticated', así que estas
-- políticas no gobiernan su tráfico: cubren el acceso directo vía la API de
-- Supabase, que es la vía por la que un cliente podría leer las muestras de
-- otro productor. No hay política de delete porque el borrado es soft
-- (deleted_at) y ya queda cubierto por la de update.
-- ============================================================================

alter table public.calibraciones_ml enable row level security;

drop policy if exists calibraciones_ml_select_miembros on public.calibraciones_ml;
create policy calibraciones_ml_select_miembros on public.calibraciones_ml
    for select to authenticated
    using (
        exists (
            select 1
            from public.usuarios_establecimientos ue
            where ue.establecimiento_id = calibraciones_ml.establecimiento_id
              and ue.usuario_id = auth.uid()
              and ue.activo = true
        )
    );

drop policy if exists calibraciones_ml_insert_miembros on public.calibraciones_ml;
create policy calibraciones_ml_insert_miembros on public.calibraciones_ml
    for insert to authenticated
    with check (
        responsable_id = auth.uid()
        and exists (
            select 1
            from public.usuarios_establecimientos ue
            where ue.establecimiento_id = calibraciones_ml.establecimiento_id
              and ue.usuario_id = auth.uid()
              and ue.activo = true
        )
    );

drop policy if exists calibraciones_ml_update_miembros on public.calibraciones_ml;
create policy calibraciones_ml_update_miembros on public.calibraciones_ml
    for update to authenticated
    using (
        exists (
            select 1
            from public.usuarios_establecimientos ue
            where ue.establecimiento_id = calibraciones_ml.establecimiento_id
              and ue.usuario_id = auth.uid()
              and ue.activo = true
        )
    )
    with check (
        exists (
            select 1
            from public.usuarios_establecimientos ue
            where ue.establecimiento_id = calibraciones_ml.establecimiento_id
              and ue.usuario_id = auth.uid()
              and ue.activo = true
        )
    );

commit;
