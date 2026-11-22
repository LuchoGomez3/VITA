-- Recurso forrajero del potrero con historial por período (adr-0016).
-- Espejo manual de la migración Alembic 20261114_01. Es idempotente: se puede
-- reejecutar sin duplicar los períodos migrados.
begin;

-- Catálogo ampliado del recurso vigente del lote.
alter table public.lotes drop constraint if exists ck_lotes_recurso_forrajero_valido;
alter table public.lotes add constraint ck_lotes_recurso_forrajero_valido check (
    recurso_forrajero_codigo is null
    or recurso_forrajero_codigo in (
        'pasto_natural', 'alfalfa', 'sorgo', 'maiz', 'avena', 'otro',
        'pastura_consociada', 'festuca', 'agropiro', 'raigras', 'cebada',
        'centeno', 'triticale', 'moha', 'gatton_panic', 'grama_rhodes',
        'rastrojo_maiz', 'rastrojo_sorgo', 'rastrojo_soja', 'verdeo_verano'
    )
);

create table if not exists public.lotes_recursos_forrajeros (
    id uuid primary key,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    deleted_at timestamptz,
    establecimiento_id uuid not null references public.establecimientos (id),
    lote_id uuid not null references public.lotes (id),
    recurso_forrajero_codigo varchar not null,
    -- Detalle libre ("Alfalfa + festuca"); el backend lo exige para 'otro'.
    descripcion varchar,
    fecha_desde date not null,
    -- Null = vigente hasta el próximo período del lote.
    fecha_hasta date,
    -- Null solo en los períodos migrados, cuyo autor no se conoce.
    registrado_por_id uuid references public.usuarios (id),
    constraint ck_lotes_recursos_forrajeros_codigo_valido check (
        recurso_forrajero_codigo in (
            'pasto_natural', 'alfalfa', 'sorgo', 'maiz', 'avena', 'otro',
            'pastura_consociada', 'festuca', 'agropiro', 'raigras', 'cebada',
            'centeno', 'triticale', 'moha', 'gatton_panic', 'grama_rhodes',
            'rastrojo_maiz', 'rastrojo_sorgo', 'rastrojo_soja', 'verdeo_verano'
        )
    ),
    constraint ck_lotes_recursos_forrajeros_fechas check (
        fecha_hasta is null or fecha_hasta >= fecha_desde
    ),
    constraint ck_lotes_recursos_forrajeros_descripcion_no_vacia check (
        descripcion is null or trim(descripcion) <> ''
    )
);

-- Descarga delta del cliente offline (updated_since).
create index if not exists ix_lotes_recursos_forrajeros_sync
    on public.lotes_recursos_forrajeros (establecimiento_id, updated_at);
-- Historial de un lote, ordenado por fecha.
create index if not exists ix_lotes_recursos_forrajeros_lote
    on public.lotes_recursos_forrajeros (lote_id, fecha_desde);
create index if not exists ix_lotes_recursos_forrajeros_establecimiento_id
    on public.lotes_recursos_forrajeros (establecimiento_id);
-- Un solo período vigente por lote y fecha de inicio; borrar uno libera la fecha.
create unique index if not exists uq_lotes_recursos_forrajeros_lote_desde
    on public.lotes_recursos_forrajeros (lote_id, fecha_desde)
    where deleted_at is null;

create or replace function public.validar_lote_recurso_forrajero()
returns trigger
language plpgsql
security invoker
set search_path = public, pg_temp
as $$
declare
    v_establecimiento_id uuid;
begin
    if tg_op = 'UPDATE' then
        if new.lote_id <> old.lote_id
           or new.establecimiento_id <> old.establecimiento_id then
            raise exception 'Un período de recurso no puede cambiar de lote ni de establecimiento'
                using errcode = 'check_violation';
        end if;
        return new;
    end if;

    select l.establecimiento_id
      into v_establecimiento_id
      from public.lotes l
     where l.id = new.lote_id;

    -- Sin lote visible deciden la FK (backend) o el RLS (cliente directo).
    if found and v_establecimiento_id <> new.establecimiento_id then
        raise exception 'El lote pertenece a otro establecimiento'
            using errcode = 'check_violation';
    end if;

    return new;
end;
$$;

drop trigger if exists trg_lotes_recursos_forrajeros_validar on public.lotes_recursos_forrajeros;

create trigger trg_lotes_recursos_forrajeros_validar
before insert or update on public.lotes_recursos_forrajeros
for each row execute function public.validar_lote_recurso_forrajero();

-- Un período por cada lote con recurso:
-- - fecha_desde = lotes.created_at: es el único dato disponible.
-- - created_at/updated_at = now(), para que el pull delta de los clientes lo baje.
-- El id determinista evita duplicados al reejecutar el script.
insert into public.lotes_recursos_forrajeros
    (id, establecimiento_id, lote_id, recurso_forrajero_codigo, descripcion,
     fecha_desde, fecha_hasta, registrado_por_id, created_at, updated_at, deleted_at)
select md5('recurso_legacy:' || l.id::text)::uuid,
       l.establecimiento_id,
       l.id,
       l.recurso_forrajero_codigo,
       null,
       l.created_at::date,
       null,
       null,
       now(),
       now(),
       l.deleted_at
  from public.lotes l
 where l.recurso_forrajero_codigo is not null
on conflict (id) do nothing;

alter table public.lotes_recursos_forrajeros enable row level security;

drop policy if exists lotes_recursos_forrajeros_select_miembros on public.lotes_recursos_forrajeros;
create policy lotes_recursos_forrajeros_select_miembros on public.lotes_recursos_forrajeros
for select to authenticated
using (
    exists (
        select 1
        from public.usuarios_establecimientos ue
        where ue.establecimiento_id = lotes_recursos_forrajeros.establecimiento_id
          and ue.usuario_id = auth.uid()
          and ue.activo = true
    )
);

drop policy if exists lotes_recursos_forrajeros_insert_miembros on public.lotes_recursos_forrajeros;
create policy lotes_recursos_forrajeros_insert_miembros on public.lotes_recursos_forrajeros
for insert to authenticated
with check (
    registrado_por_id = auth.uid()
    and exists (
        select 1
        from public.usuarios_establecimientos ue
        where ue.establecimiento_id = lotes_recursos_forrajeros.establecimiento_id
          and ue.usuario_id = auth.uid()
          and ue.activo = true
    )
);

-- El borrado es soft (deleted_at): se cubre con update, sin política de delete.
drop policy if exists lotes_recursos_forrajeros_update_miembros on public.lotes_recursos_forrajeros;
create policy lotes_recursos_forrajeros_update_miembros on public.lotes_recursos_forrajeros
for update to authenticated
using (
    exists (
        select 1
        from public.usuarios_establecimientos ue
        where ue.establecimiento_id = lotes_recursos_forrajeros.establecimiento_id
          and ue.usuario_id = auth.uid()
          and ue.activo = true
    )
)
with check (
    exists (
        select 1
        from public.usuarios_establecimientos ue
        where ue.establecimiento_id = lotes_recursos_forrajeros.establecimiento_id
          and ue.usuario_id = auth.uid()
          and ue.activo = true
    )
);

revoke all on public.lotes_recursos_forrajeros from anon;
revoke all on public.lotes_recursos_forrajeros from authenticated;
grant select, insert, update on public.lotes_recursos_forrajeros to authenticated;

commit;
