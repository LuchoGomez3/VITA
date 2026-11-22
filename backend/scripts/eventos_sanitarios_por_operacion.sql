-- Espejo manual de la migración 20261121_01 (VITA-20): eventos sanitarios por
-- operación, productos retirables, operaciones aceptadas y RLS de solo lectura.
-- Idempotente: se puede correr más de una vez en el SQL Editor de Supabase.
-- Decisiones en docs/adr/adr-0017-eventos-sanitarios-por-operacion.md.

begin;

-- 1. eventos_sanitarios: operación, foto de la práctica, contexto y resultado.
alter table public.eventos_sanitarios
    add column if not exists operacion_id uuid,
    add column if not exists practica_id varchar(60),
    add column if not exists practica_nombre varchar(120),
    add column if not exists practica_modelo varchar(20),
    add column if not exists datos jsonb,
    add column if not exists caravana varchar(60),
    add column if not exists lote_id uuid references public.lotes (id),
    add column if not exists referencia_muestra varchar(60),
    add column if not exists responsable varchar(120),
    add column if not exists registrado_por_id uuid references public.usuarios (id),
    add column if not exists resultado_fecha timestamptz,
    add column if not exists resultado_registrado_por_id uuid references public.usuarios (id),
    add column if not exists resultado_operacion_id uuid,
    add column if not exists version bigint;

do $$
begin
    if not exists (
        select 1 from pg_constraint
         where conname = 'ck_eventos_sanitarios_practica_modelo'
    ) then
        alter table public.eventos_sanitarios
            add constraint ck_eventos_sanitarios_practica_modelo
            check (practica_modelo is null
                   or practica_modelo in ('aplicacion', 'muestreo', 'lesion'));
    end if;
    if not exists (
        select 1 from pg_constraint where conname = 'uq_eventos_sanitarios_version'
    ) then
        alter table public.eventos_sanitarios
            add constraint uq_eventos_sanitarios_version
            unique (establecimiento_id, version);
    end if;
end
$$;

create index if not exists ix_eventos_sanitarios_historial
    on public.eventos_sanitarios (animal_id, fecha_aplicacion);
create index if not exists ix_eventos_sanitarios_operacion
    on public.eventos_sanitarios (operacion_id);

-- 2. productos_sanitarios: retiro lógico.
alter table public.productos_sanitarios
    add column if not exists deleted_at timestamptz;

-- 3. operaciones_sanitarias: envíos aceptados, para reenvíos idempotentes.
create table if not exists public.operaciones_sanitarias (
    id uuid primary key,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    establecimiento_id uuid not null references public.establecimientos (id),
    tipo varchar(20) not null,
    evento_id uuid references public.eventos_sanitarios (id),
    huella varchar(64) not null,
    usuario_id uuid not null references public.usuarios (id),
    constraint ck_operaciones_sanitarias_tipo check (tipo in ('alta', 'resultado'))
);
create index if not exists ix_operaciones_sanitarias_establecimiento_id
    on public.operaciones_sanitarias (establecimiento_id);

-- 4. RLS: los miembros activos leen; las escrituras pasan por el backend.
alter table public.eventos_sanitarios enable row level security;
drop policy if exists eventos_sanitarios_select_miembros on public.eventos_sanitarios;
create policy eventos_sanitarios_select_miembros on public.eventos_sanitarios
for select to authenticated
using (
    exists (
        select 1
        from public.usuarios_establecimientos ue
        where ue.establecimiento_id = eventos_sanitarios.establecimiento_id
          and ue.usuario_id = auth.uid()
          and ue.activo = true
    )
);

alter table public.operaciones_sanitarias enable row level security;
drop policy if exists operaciones_sanitarias_select_miembros on public.operaciones_sanitarias;
create policy operaciones_sanitarias_select_miembros on public.operaciones_sanitarias
for select to authenticated
using (
    exists (
        select 1
        from public.usuarios_establecimientos ue
        where ue.establecimiento_id = operaciones_sanitarias.establecimiento_id
          and ue.usuario_id = auth.uid()
          and ue.activo = true
    )
);

alter table public.productos_sanitarios enable row level security;
drop policy if exists productos_sanitarios_select_catalogo on public.productos_sanitarios;
-- Globales para cualquier usuario autenticado; propios, para miembros.
create policy productos_sanitarios_select_catalogo on public.productos_sanitarios
for select to authenticated
using (
    establecimiento_id is null
    or exists (
        select 1
        from public.usuarios_establecimientos ue
        where ue.establecimiento_id = productos_sanitarios.establecimiento_id
          and ue.usuario_id = auth.uid()
          and ue.activo = true
    )
);

revoke all on public.eventos_sanitarios from anon;
revoke all on public.eventos_sanitarios from authenticated;
grant select on public.eventos_sanitarios to authenticated;
revoke all on public.operaciones_sanitarias from anon;
revoke all on public.operaciones_sanitarias from authenticated;
grant select on public.operaciones_sanitarias to authenticated;
revoke all on public.productos_sanitarios from anon;
revoke all on public.productos_sanitarios from authenticated;
grant select on public.productos_sanitarios to authenticated;

commit;
