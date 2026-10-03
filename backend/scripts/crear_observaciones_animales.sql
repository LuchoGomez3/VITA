-- Observaciones de un animal como entradas independientes (VITA-173).
-- Espejo manual de la migración Alembic 20261001_03. Es idempotente: se puede
-- reejecutar sin duplicar las notas migradas.
begin;

create table if not exists public.observaciones_animales (
    id uuid primary key,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    deleted_at timestamptz,
    animal_id uuid not null references public.animales (id),
    establecimiento_id uuid not null references public.establecimientos (id),
    texto text not null,
    fecha timestamptz not null,
    -- Null solo en las notas migradas, cuyo autor no se conoce.
    autor_id uuid references public.usuarios (id),
    constraint ck_observaciones_animales_texto_no_vacio check (trim(texto) <> '')
);

-- Historial de un animal, ordenado por fecha.
create index if not exists ix_observaciones_animales_fecha
    on public.observaciones_animales (animal_id, fecha);
-- Descarga delta del cliente offline (updated_since).
create index if not exists ix_observaciones_animales_sync
    on public.observaciones_animales (establecimiento_id, updated_at);

create or replace function public.validar_observacion_animal()
returns trigger
language plpgsql
security invoker
set search_path = public, pg_temp
as $$
declare
    v_establecimiento_id uuid;
begin
    if tg_op = 'UPDATE' then
        if new.animal_id <> old.animal_id
           or new.establecimiento_id <> old.establecimiento_id
           or new.autor_id is distinct from old.autor_id then
            raise exception 'Una observación no puede cambiar de animal, establecimiento ni autor'
                using errcode = 'check_violation';
        end if;
        return new;
    end if;

    select a.establecimiento_id
      into v_establecimiento_id
      from public.animales a
     where a.id = new.animal_id;

    -- Sin animal visible, deciden la FK (backend) o el RLS (cliente directo):
    -- con security invoker, un cliente no ve animales y el trigger no
    -- distingue "ajeno" de "inexistente".
    if found and v_establecimiento_id <> new.establecimiento_id then
        raise exception 'El animal pertenece a otro establecimiento'
            using errcode = 'check_violation';
    end if;

    return new;
end;
$$;

drop trigger if exists trg_observaciones_animales_validar on public.observaciones_animales;

create trigger trg_observaciones_animales_validar
before insert or update on public.observaciones_animales
for each row execute function public.validar_observacion_animal();

-- Una entrada por cada animales.observaciones no vacío:
-- - El texto se copia íntegro.
-- - El autor queda en null: no se conoce.
-- - fecha = animales.created_at: es el único timestamp disponible y solo dice
--   cuándo se dio de alta el animal, no cuándo se escribió la nota.
-- - created_at/updated_at = now(), para que el pull delta de los clientes las baje.
-- El id determinista evita duplicados al reejecutar el script.
insert into public.observaciones_animales
    (id, animal_id, establecimiento_id, texto, fecha, autor_id,
     created_at, updated_at, deleted_at)
select md5('observacion_legacy:' || a.id::text)::uuid,
       a.id,
       a.establecimiento_id,
       a.observaciones,
       a.created_at,
       null,
       now(),
       now(),
       a.deleted_at
  from public.animales a
 where a.observaciones is not null
   and trim(a.observaciones) <> ''
on conflict (id) do nothing;

-- Pertenencia del animal para la policy de INSERT. Es security definer porque
-- un cliente directo no ve animales (RLS activo sin policies), pero solo
-- responde por establecimientos donde quien pregunta es miembro activo:
-- llamada por RPC no sirve para sondear animales ajenos.
create or replace function public.animal_pertenece_a_establecimiento(
    p_animal_id uuid,
    p_establecimiento_id uuid
)
returns boolean
language sql
stable
security definer
set search_path = public, pg_temp
as $$
    select exists (
        select 1
          from public.animales a
          join public.usuarios_establecimientos ue
            on ue.establecimiento_id = a.establecimiento_id
         where a.id = p_animal_id
           and a.establecimiento_id = p_establecimiento_id
           and ue.usuario_id = auth.uid()
           and ue.activo = true
    )
$$;

revoke all on function public.animal_pertenece_a_establecimiento(uuid, uuid) from public, anon;
grant execute on function public.animal_pertenece_a_establecimiento(uuid, uuid) to authenticated;

alter table public.observaciones_animales enable row level security;

drop policy if exists observaciones_animales_select_miembros on public.observaciones_animales;
create policy observaciones_animales_select_miembros on public.observaciones_animales
for select to authenticated
using (
    exists (
        select 1
        from public.usuarios_establecimientos ue
        where ue.establecimiento_id = observaciones_animales.establecimiento_id
          and ue.usuario_id = auth.uid()
          and ue.activo = true
    )
);

drop policy if exists observaciones_animales_insert_miembros on public.observaciones_animales;
create policy observaciones_animales_insert_miembros on public.observaciones_animales
for insert to authenticated
with check (
    autor_id = auth.uid()
    and exists (
        select 1
        from public.usuarios_establecimientos ue
        where ue.establecimiento_id = observaciones_animales.establecimiento_id
          and ue.usuario_id = auth.uid()
          and ue.activo = true
    )
    and public.animal_pertenece_a_establecimiento(animal_id, establecimiento_id)
);

-- El borrado es soft (deleted_at): se cubre con update, sin política de delete.
drop policy if exists observaciones_animales_update_miembros on public.observaciones_animales;
create policy observaciones_animales_update_miembros on public.observaciones_animales
for update to authenticated
using (
    exists (
        select 1
        from public.usuarios_establecimientos ue
        where ue.establecimiento_id = observaciones_animales.establecimiento_id
          and ue.usuario_id = auth.uid()
          and ue.activo = true
    )
)
with check (
    exists (
        select 1
        from public.usuarios_establecimientos ue
        where ue.establecimiento_id = observaciones_animales.establecimiento_id
          and ue.usuario_id = auth.uid()
          and ue.activo = true
    )
);

revoke all on public.observaciones_animales from anon;
revoke all on public.observaciones_animales from authenticated;
grant select, insert, update on public.observaciones_animales to authenticated;

commit;
