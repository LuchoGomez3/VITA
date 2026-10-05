-- Espejo manual de la migración 20260905_03_lotes_y_movimientos_batch.
--
-- El mecanismo normal de despliegue es Alembic; este script es el respaldo para
-- ejecutar a mano desde el SQL Editor de Supabase. Ambos caminos producen el
-- mismo esquema, con los mismos nombres de restricciones.
--
-- Es idempotente: se puede volver a ejecutar sobre una base que ya lo tenga.

begin;

-- ============================================================================
-- 1. lotes: columnas nuevas
-- ============================================================================

alter table public.lotes
    add column if not exists geometria_local jsonb,
    add column if not exists modo_geometria varchar,
    add column if not exists recurso_forrajero_codigo varchar,
    add column if not exists tiene_agua boolean,
    add column if not exists estado varchar;

-- ============================================================================
-- 2. Backfill de los lotes preexistentes
--
-- La geometría es un placeholder fabricado: son filas anteriores al módulo y no
-- tienen polígono dibujado. Dejarla en null no es opción, porque el cliente la
-- castea de forma estricta y un lote sin geometría le rompe la deserialización.
-- Se asignan cuadrados de 225 sobre una grilla de paso 245 dentro del lienzo de
-- 1000x1000, que por construcción no se superponen.
-- ============================================================================

with numerados as (
    select id,
           row_number() over (order by establecimiento_id, nombre, id) - 1 as pos
      from public.lotes
     where geometria_local is null
)
update public.lotes l
   set geometria_local = jsonb_build_object(
        'type', 'LocalPolygon',
        'coordinate_space', 'establishment_canvas_v1',
        'version', 1,
        'extent', jsonb_build_object('width', 1000.0, 'height', 1000.0),
        'vertices', jsonb_build_array(
            jsonb_build_object('x', 20.0 + (n.pos % 4) * 245.0,
                               'y', 20.0 + (n.pos / 4) * 245.0),
            jsonb_build_object('x', 20.0 + (n.pos % 4) * 245.0 + 225.0,
                               'y', 20.0 + (n.pos / 4) * 245.0),
            jsonb_build_object('x', 20.0 + (n.pos % 4) * 245.0 + 225.0,
                               'y', 20.0 + (n.pos / 4) * 245.0 + 225.0),
            jsonb_build_object('x', 20.0 + (n.pos % 4) * 245.0,
                               'y', 20.0 + (n.pos / 4) * 245.0 + 225.0)
        )
   )
  from numerados n
 where l.id = n.id;

update public.lotes
   set modo_geometria = coalesce(modo_geometria, 'local_schematic'),
       tiene_agua = coalesce(tiene_agua, false),
       estado = coalesce(estado, 'activo');

-- La superficie pasa a ser obligatoria y con un decimal de precisión, que es
-- como el cliente la administra (décimas exactas de hectárea).
update public.lotes
   set superficie_ha = case
         when superficie_ha is null or superficie_ha <= 0 then 1.0
         else round(superficie_ha, 1)
       end;

-- ============================================================================
-- 3. lotes: NOT NULL y CHECKs
-- ============================================================================

alter table public.lotes
    alter column geometria_local set not null,
    alter column modo_geometria set not null,
    alter column tiene_agua set not null,
    alter column estado set not null,
    alter column superficie_ha set not null;

do $$
begin
    if not exists (
        select 1 from pg_constraint where conname = 'ck_lotes_estado_valido'
    ) then
        alter table public.lotes add constraint ck_lotes_estado_valido
            check (estado in ('activo', 'descanso', 'mantenimiento', 'inactivo'));
    end if;

    if not exists (
        select 1 from pg_constraint
         where conname = 'ck_lotes_recurso_forrajero_valido'
    ) then
        alter table public.lotes add constraint ck_lotes_recurso_forrajero_valido
            check (
                recurso_forrajero_codigo is null
                or recurso_forrajero_codigo in (
                    'pasto_natural', 'alfalfa', 'sorgo', 'maiz', 'avena', 'otro'
                )
            );
    end if;

    if not exists (
        select 1 from pg_constraint where conname = 'ck_lotes_superficie_positiva'
    ) then
        alter table public.lotes add constraint ck_lotes_superficie_positiva
            check (superficie_ha > 0);
    end if;

    if not exists (
        select 1 from pg_constraint where conname = 'ck_lotes_nombre_no_vacio'
    ) then
        alter table public.lotes add constraint ck_lotes_nombre_no_vacio
            check (trim(nombre) <> '');
    end if;
end $$;

-- ============================================================================
-- 4. Unicidad de nombre por establecimiento
--
-- Normalizada (lower + btrim) y parcial: borrar un lote libera su nombre.
-- Falla a propósito si hay duplicados preexistentes — hay que resolverlos a mano.
-- ============================================================================

create unique index if not exists uq_lotes_nombre_establecimiento
    on public.lotes (establecimiento_id, lower(btrim(nombre)))
    where deleted_at is null;

create index if not exists ix_lotes_sync
    on public.lotes (establecimiento_id, updated_at);

-- ============================================================================
-- 5. Movimientos: agregado cabecera + detalle
--
-- Reemplaza movimientos_lote (una fila por animal), que no puede sostener un
-- UUID de cliente como clave de idempotencia de una operación con N animales.
-- Se aborta si la tabla vieja tiene datos.
-- ============================================================================

do $$
declare
    filas bigint;
begin
    if exists (
        select 1 from information_schema.tables
         where table_schema = 'public' and table_name = 'movimientos_lote'
    ) then
        execute 'select count(*) from public.movimientos_lote' into filas;
        if filas > 0 then
            raise exception
                'movimientos_lote tiene % fila(s): migrarlas requiere decidir '
                'cómo agrupar las filas sueltas en operaciones.', filas;
        end if;
        drop table public.movimientos_lote;
    end if;
end $$;

create table if not exists public.movimientos_lotes (
    id uuid primary key,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    deleted_at timestamptz,
    establecimiento_id uuid not null references public.establecimientos (id),
    lote_origen_id uuid references public.lotes (id),
    lote_destino_id uuid not null references public.lotes (id),
    fecha_movimiento timestamptz not null,
    motivo varchar,
    responsable_id uuid references public.usuarios (id),
    constraint ck_movimientos_lotes_origen_distinto_destino
        check (lote_origen_id is null or lote_origen_id <> lote_destino_id)
);

create table if not exists public.movimientos_lotes_animales (
    id uuid primary key,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    movimiento_lote_id uuid not null references public.movimientos_lotes (id),
    animal_id uuid not null references public.animales (id),
    constraint uq_movimiento_lote_animal unique (movimiento_lote_id, animal_id)
);

create index if not exists ix_movimientos_lotes_establecimiento_id
    on public.movimientos_lotes (establecimiento_id);
create index if not exists ix_movimientos_lotes_lote_origen_id
    on public.movimientos_lotes (lote_origen_id);
create index if not exists ix_movimientos_lotes_lote_destino_id
    on public.movimientos_lotes (lote_destino_id);
create index if not exists ix_movimientos_lotes_sync
    on public.movimientos_lotes (establecimiento_id, updated_at);
create index if not exists ix_movimientos_lotes_animales_movimiento_lote_id
    on public.movimientos_lotes_animales (movimiento_lote_id);
create index if not exists ix_movimientos_lotes_animales_animal_id
    on public.movimientos_lotes_animales (animal_id);

-- ============================================================================
-- 6. Row Level Security
--
-- Las políticas se apoyan en auth.uid(), que solo existe en Supabase. Igual que
-- la migración de Alembic, este bloque se omite cuando la función no está
-- disponible, para que el script también corra sobre un Postgres de desarrollo.
-- En ese caso el aislamiento por tenant queda enteramente a cargo del service,
-- que filtra por membresía en toda consulta.
--
-- Sin política de delete: el borrado es lógico y se cubre con update.
-- ============================================================================

do $rls$
declare
    es_miembro_lotes constant text := $pred$
        exists (
            select 1 from public.usuarios_establecimientos ue
             where ue.establecimiento_id = lotes.establecimiento_id
               and ue.usuario_id = auth.uid()
               and ue.activo = true
        )
    $pred$;
    es_miembro_mov constant text := $pred$
        exists (
            select 1 from public.usuarios_establecimientos ue
             where ue.establecimiento_id = movimientos_lotes.establecimiento_id
               and ue.usuario_id = auth.uid()
               and ue.activo = true
        )
    $pred$;
    es_miembro_detalle constant text := $pred$
        exists (
            select 1
              from public.movimientos_lotes m
              join public.usuarios_establecimientos ue
                on ue.establecimiento_id = m.establecimiento_id
             where m.id = movimientos_lotes_animales.movimiento_lote_id
               and ue.usuario_id = auth.uid()
               and ue.activo = true
        )
    $pred$;
begin
    if to_regprocedure('auth.uid()') is null then
        raise notice 'auth.uid() no disponible: se omite el bloque de RLS.';
        return;
    end if;

    execute 'alter table public.lotes enable row level security';
    execute 'alter table public.movimientos_lotes enable row level security';
    execute 'alter table public.movimientos_lotes_animales'
            ' enable row level security';

    -- lotes
    execute 'drop policy if exists lotes_select_miembros on public.lotes';
    execute 'create policy lotes_select_miembros on public.lotes'
            ' for select to authenticated using (' || es_miembro_lotes || ')';

    execute 'drop policy if exists lotes_insert_miembros on public.lotes';
    execute 'create policy lotes_insert_miembros on public.lotes'
            ' for insert to authenticated with check (' || es_miembro_lotes || ')';

    execute 'drop policy if exists lotes_update_miembros on public.lotes';
    execute 'create policy lotes_update_miembros on public.lotes'
            ' for update to authenticated using (' || es_miembro_lotes || ')'
            ' with check (' || es_miembro_lotes || ')';

    -- movimientos_lotes
    execute 'drop policy if exists movimientos_lotes_select_miembros'
            ' on public.movimientos_lotes';
    execute 'create policy movimientos_lotes_select_miembros'
            ' on public.movimientos_lotes'
            ' for select to authenticated using (' || es_miembro_mov || ')';

    execute 'drop policy if exists movimientos_lotes_insert_miembros'
            ' on public.movimientos_lotes';
    execute 'create policy movimientos_lotes_insert_miembros'
            ' on public.movimientos_lotes'
            ' for insert to authenticated with check ('
            ' responsable_id = auth.uid() and ' || es_miembro_mov || ')';

    execute 'drop policy if exists movimientos_lotes_update_miembros'
            ' on public.movimientos_lotes';
    execute 'create policy movimientos_lotes_update_miembros'
            ' on public.movimientos_lotes'
            ' for update to authenticated using (' || es_miembro_mov || ')'
            ' with check (' || es_miembro_mov || ')';

    -- movimientos_lotes_animales
    execute 'drop policy if exists movimientos_lotes_animales_select_miembros'
            ' on public.movimientos_lotes_animales';
    execute 'create policy movimientos_lotes_animales_select_miembros'
            ' on public.movimientos_lotes_animales'
            ' for select to authenticated using (' || es_miembro_detalle || ')';

    execute 'drop policy if exists movimientos_lotes_animales_insert_miembros'
            ' on public.movimientos_lotes_animales';
    execute 'create policy movimientos_lotes_animales_insert_miembros'
            ' on public.movimientos_lotes_animales'
            ' for insert to authenticated with check ('
            || es_miembro_detalle || ')';

    execute 'revoke all on public.lotes from anon';
    execute 'revoke all on public.movimientos_lotes from anon';
    execute 'revoke all on public.movimientos_lotes_animales from anon';

    execute 'grant select, insert, update on public.lotes to authenticated';
    execute 'grant select, insert, update on public.movimientos_lotes'
            ' to authenticated';
    -- La composición se fija al crear el movimiento: no se edita ni se borra.
    execute 'grant select, insert on public.movimientos_lotes_animales'
            ' to authenticated';
end
$rls$;

commit;
