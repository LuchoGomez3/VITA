-- Crea el historial inmutable de archivos SENASA.
-- Ejecutar una sola vez desde el SQL Editor de Supabase.
begin;

create table if not exists public.exportaciones_senasa (
    id uuid primary key default gen_random_uuid(),
    establecimiento_id uuid not null
        references public.establecimientos(id),
    usuario_generador_id uuid not null
        references public.usuarios(id),
    nombre_archivo varchar(255) not null,
    formato varchar(10) not null
        check (formato in ('txt', 'pdf')),
    tipo_exportacion varchar(40) not null
        check (tipo_exportacion = 'declaracion_identificacion'),
    media_type varchar(100) not null,
    contenido bytea not null,
    hash_sha256 varchar(64) not null
        check (hash_sha256 ~ '^[0-9a-f]{64}$'),
    cantidad_animales integer not null
        check (cantidad_animales >= 0),
    desde timestamptz,
    hasta timestamptz,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    check (hasta is null or desde is null or hasta >= desde)
);

create index if not exists ix_exportaciones_senasa_establecimiento_id
    on public.exportaciones_senasa (establecimiento_id);

create index if not exists ix_exportaciones_senasa_historial
    on public.exportaciones_senasa (establecimiento_id, created_at desc);

create table if not exists public.exportaciones_senasa_animales (
    id uuid primary key default gen_random_uuid(),
    exportacion_senasa_id uuid not null
        references public.exportaciones_senasa(id),
    animal_id uuid not null
        references public.animales(id),
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    constraint uq_exportacion_senasa_animal
        unique (exportacion_senasa_id, animal_id)
);

create index if not exists ix_exportaciones_senasa_animales_exportacion_id
    on public.exportaciones_senasa_animales (exportacion_senasa_id);

create index if not exists ix_exportaciones_senasa_animales_animal_id
    on public.exportaciones_senasa_animales (animal_id);

-- Las exportaciones son evidencia histórica: una corrección genera un archivo
-- nuevo y nunca modifica o elimina el contenido que ya se descargó.
create or replace function public.impedir_modificacion_exportacion_senasa()
returns trigger
language plpgsql
set search_path = public
as $$
begin
    raise exception 'Las exportaciones SENASA son inmutables';
end;
$$;

drop trigger if exists exportaciones_senasa_inmutables
    on public.exportaciones_senasa;
create trigger exportaciones_senasa_inmutables
before update or delete on public.exportaciones_senasa
for each row execute function public.impedir_modificacion_exportacion_senasa();

drop trigger if exists exportaciones_senasa_animales_inmutables
    on public.exportaciones_senasa_animales;
create trigger exportaciones_senasa_animales_inmutables
before update or delete on public.exportaciones_senasa_animales
for each row execute function public.impedir_modificacion_exportacion_senasa();

alter table public.exportaciones_senasa enable row level security;
alter table public.exportaciones_senasa_animales enable row level security;

-- Un miembro activo solo puede consultar archivos de sus establecimientos.
drop policy if exists exportaciones_senasa_select_miembros
    on public.exportaciones_senasa;
create policy exportaciones_senasa_select_miembros
on public.exportaciones_senasa
for select
to authenticated
using (
    exists (
        select 1
        from public.usuarios_establecimientos ue
        where ue.establecimiento_id = exportaciones_senasa.establecimiento_id
          and ue.usuario_id = auth.uid()
          and ue.activo = true
    )
);

-- La identidad del generador se toma del JWT y debe pertenecer al tenant.
drop policy if exists exportaciones_senasa_insert_miembros
    on public.exportaciones_senasa;
create policy exportaciones_senasa_insert_miembros
on public.exportaciones_senasa
for insert
to authenticated
with check (
    usuario_generador_id = auth.uid()
    and exists (
        select 1
        from public.usuarios_establecimientos ue
        where ue.establecimiento_id = exportaciones_senasa.establecimiento_id
          and ue.usuario_id = auth.uid()
          and ue.activo = true
    )
);

-- La composición hereda el establecimiento de la exportación y valida que el
-- animal pertenezca al mismo establecimiento, evitando cruces entre tenants.
drop policy if exists exportaciones_senasa_animales_select_miembros
    on public.exportaciones_senasa_animales;
create policy exportaciones_senasa_animales_select_miembros
on public.exportaciones_senasa_animales
for select
to authenticated
using (
    exists (
        select 1
        from public.exportaciones_senasa es
        join public.usuarios_establecimientos ue
          on ue.establecimiento_id = es.establecimiento_id
        where es.id = exportaciones_senasa_animales.exportacion_senasa_id
          and ue.usuario_id = auth.uid()
          and ue.activo = true
    )
);

drop policy if exists exportaciones_senasa_animales_insert_miembros
    on public.exportaciones_senasa_animales;
create policy exportaciones_senasa_animales_insert_miembros
on public.exportaciones_senasa_animales
for insert
to authenticated
with check (
    exists (
        select 1
        from public.exportaciones_senasa es
        join public.animales a
          on a.id = exportaciones_senasa_animales.animal_id
         and a.establecimiento_id = es.establecimiento_id
        join public.usuarios_establecimientos ue
          on ue.establecimiento_id = es.establecimiento_id
        where es.id = exportaciones_senasa_animales.exportacion_senasa_id
          and es.usuario_generador_id = auth.uid()
          and ue.usuario_id = auth.uid()
          and ue.activo = true
    )
);

revoke all on public.exportaciones_senasa from anon;
revoke all on public.exportaciones_senasa_animales from anon;
grant select, insert on public.exportaciones_senasa to authenticated;
grant select, insert on public.exportaciones_senasa_animales to authenticated;

commit;
