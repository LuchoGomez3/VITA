-- Crea los cobros de ventas, su tope concurrente y sus políticas de acceso.
-- Espejo manual de la migración Alembic 20261001_01 para el SQL Editor de Supabase.
-- Es reejecutable: cada objeto se crea solo si falta o se reemplaza.
begin;

create table if not exists public.ventas_cobros (
    id uuid primary key,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    deleted_at timestamptz,
    venta_id uuid not null references public.ventas(id),
    fecha_cobro date not null,
    monto numeric(14, 2) not null,
    medio_cobro varchar not null,
    registrado_por_id uuid not null references public.usuarios(id),
    observaciones varchar,
    constraint ck_ventas_cobros_monto_positivo check (monto > 0),
    constraint ck_ventas_cobros_medio_cobro_valido
        check (medio_cobro in ('efectivo', 'transferencia', 'cheque', 'tarjeta'))
);

-- Lleva venta_id adelante: sostiene la FK, el saldo y el pull delta.
create index if not exists ix_ventas_cobros_sync
    on public.ventas_cobros (venta_id, updated_at);
create index if not exists ix_ventas_cobros_fecha_cobro
    on public.ventas_cobros (fecha_cobro);
create index if not exists ix_ventas_cobros_registrado_por_id
    on public.ventas_cobros (registrado_por_id);
create index if not exists ix_ventas_cobros_updated_at
    on public.ventas_cobros (updated_at);

-- No se aceptan cobros con fecha futura. Es trigger y no check porque el "hoy"
-- cambia y Postgres exige que un check sea inmutable.
create or replace function public.validar_fecha_cobro()
returns trigger
language plpgsql
security invoker
set search_path = public, pg_temp
as $$
begin
    -- Un cobro es dinero ya recibido. Se compara contra el día de Córdoba, no
    -- el de UTC: entre las 21 y las 24 hora local ya es mañana en UTC.
    if (tg_op = 'INSERT' or new.fecha_cobro is distinct from old.fecha_cobro)
       and new.fecha_cobro
           > cast(now() at time zone 'America/Argentina/Cordoba' as date) then
        raise exception 'La fecha de cobro no puede ser futura'
            using errcode = 'check_violation';
    end if;

    return new;
end;
$$;

-- El for update sobre la venta serializa los cobros concurrentes de una misma
-- venta. Es security invoker: una venta de otro tenant es invisible para la
-- función, así que no se bloquea ni se revela su saldo; el rechazo es el del RLS.
create or replace function public.validar_tope_cobros_venta()
returns trigger
language plpgsql
security invoker
set search_path = public, pg_temp
as $$
declare
    v_monto_total numeric(14, 2);
    v_venta_borrada timestamptz;
    v_cobrado numeric(14, 2);
begin
    if tg_op = 'UPDATE' and (
        new.id <> old.id
        or new.venta_id <> old.venta_id
        or new.registrado_por_id <> old.registrado_por_id
    ) then
        raise exception 'Un cobro no puede cambiar de id, de venta ni de autor'
            using errcode = 'check_violation';
    end if;

    -- Anular un cobro solo puede bajar lo cobrado.
    if new.deleted_at is not null then
        return new;
    end if;

    select v.monto_total, v.deleted_at
      into v_monto_total, v_venta_borrada
      from public.ventas v
     where v.id = new.venta_id
       for update;

    -- Sin venta, la FK rechaza la fila.
    if not found then
        return new;
    end if;

    if v_venta_borrada is not null
       and (tg_op = 'INSERT' or old.deleted_at is not null) then
        raise exception 'No se pueden registrar cobros de una venta eliminada'
            using errcode = 'check_violation';
    end if;

    select coalesce(sum(c.monto), 0)
      into v_cobrado
      from public.ventas_cobros c
     where c.venta_id = new.venta_id
       and c.deleted_at is null
       and c.id <> new.id;

    if v_cobrado + new.monto > v_monto_total then
        raise exception 'Los cobros superan el monto total de la venta'
            using errcode = 'check_violation';
    end if;

    return new;
end;
$$;

create or replace function public.validar_monto_venta_cubre_cobros()
returns trigger
language plpgsql
security invoker
set search_path = public, pg_temp
as $$
declare
    v_cobrado numeric(14, 2);
begin
    if new.monto_total >= old.monto_total then
        return new;
    end if;

    select coalesce(sum(c.monto), 0)
      into v_cobrado
      from public.ventas_cobros c
     where c.venta_id = new.id
       and c.deleted_at is null;

    if v_cobrado > new.monto_total then
        raise exception 'El monto total no puede quedar por debajo de lo cobrado'
            using errcode = 'check_violation';
    end if;

    return new;
end;
$$;

drop trigger if exists ventas_cobros_validar_fecha on public.ventas_cobros;
create trigger ventas_cobros_validar_fecha
before insert or update on public.ventas_cobros
for each row execute function public.validar_fecha_cobro();

drop trigger if exists ventas_cobros_validar_tope on public.ventas_cobros;
create trigger ventas_cobros_validar_tope
before insert or update on public.ventas_cobros
for each row execute function public.validar_tope_cobros_venta();

drop trigger if exists ventas_validar_monto_cubre_cobros on public.ventas;
create trigger ventas_validar_monto_cubre_cobros
before update of monto_total on public.ventas
for each row execute function public.validar_monto_venta_cubre_cobros();

alter table public.ventas_cobros enable row level security;

drop policy if exists ventas_cobros_select_miembros on public.ventas_cobros;
create policy ventas_cobros_select_miembros
on public.ventas_cobros for select to authenticated
using (
    exists (
        select 1
        from public.ventas v
        join public.usuarios_establecimientos ue
          on ue.establecimiento_id = v.establecimiento_id
        where v.id = ventas_cobros.venta_id
          and ue.usuario_id = auth.uid() and ue.activo = true
          and ue.rol in ('admin', 'owner')
    )
);

drop policy if exists ventas_cobros_insert_miembros on public.ventas_cobros;
create policy ventas_cobros_insert_miembros
on public.ventas_cobros for insert to authenticated
with check (
    registrado_por_id = auth.uid()
    and exists (
        select 1
        from public.ventas v
        join public.usuarios_establecimientos ue
          on ue.establecimiento_id = v.establecimiento_id
        where v.id = ventas_cobros.venta_id
          and ue.usuario_id = auth.uid() and ue.activo = true
          and ue.rol in ('admin', 'owner')
    )
);

-- El borrado es soft (deleted_at): se cubre con update y no existe política ni
-- permiso de delete.
drop policy if exists ventas_cobros_update_miembros on public.ventas_cobros;
create policy ventas_cobros_update_miembros
on public.ventas_cobros for update to authenticated
using (
    exists (
        select 1
        from public.ventas v
        join public.usuarios_establecimientos ue
          on ue.establecimiento_id = v.establecimiento_id
        where v.id = ventas_cobros.venta_id
          and ue.usuario_id = auth.uid() and ue.activo = true
          and ue.rol in ('admin', 'owner')
    )
)
with check (
    exists (
        select 1
        from public.ventas v
        join public.usuarios_establecimientos ue
          on ue.establecimiento_id = v.establecimiento_id
        where v.id = ventas_cobros.venta_id
          and ue.usuario_id = auth.uid() and ue.activo = true
          and ue.rol in ('admin', 'owner')
    )
);

-- Supabase otorga todo por defecto a anon y authenticated en public.
revoke all on public.ventas_cobros from anon, authenticated;
grant select, insert, update on public.ventas_cobros to authenticated;

commit;
