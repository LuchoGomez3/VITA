-- Crea los movimientos monetarios sin alterar la tabla `egresos`, que registra
-- salidas físicas de animales. Ejecutar una vez en el SQL Editor de Supabase.
begin;

create table if not exists public.egresos_operativos (
    id uuid primary key,
    establecimiento_id uuid not null references public.establecimientos(id),
    monto numeric(14, 2) not null check (monto > 0),
    tipo varchar not null check (tipo in ('costo_produccion', 'gasto_administrativo')),
    categoria varchar not null,
    insumo varchar not null check (btrim(insumo) <> ''),
    fecha date not null check (fecha <= current_date),
    descripcion varchar,
    numero_comprobante varchar,
    cargado_por_id uuid not null references public.usuarios(id),
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    deleted_at timestamptz
);

-- Compatibilidad si se ejecutó una versión anterior del script que limitaba el
-- campo a las seis categorías iniciales.
alter table public.egresos_operativos
    drop constraint if exists ck_egresos_operativos_categoria_tipo;

-- Las categorías personalizadas pertenecen a un establecimiento y conservan un
-- valor normalizado estable, apto para persistencia local y sincronización.
create table if not exists public.categorias_egresos_operativos (
    id uuid primary key,
    establecimiento_id uuid not null references public.establecimientos(id),
    tipo varchar not null check (tipo in ('costo_produccion', 'gasto_administrativo')),
    nombre varchar not null check (btrim(nombre) <> '' and length(nombre) <= 80),
    valor varchar not null check (btrim(valor) <> ''),
    creado_por_id uuid not null references public.usuarios(id),
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    deleted_at timestamptz,
    constraint uq_categoria_egreso_operativo_establecimiento_valor
        unique (establecimiento_id, valor)
);

create index if not exists ix_egresos_operativos_establecimiento_id
    on public.egresos_operativos (establecimiento_id);
create index if not exists ix_egresos_operativos_fecha
    on public.egresos_operativos (fecha);
create index if not exists ix_egresos_operativos_cargado_por_id
    on public.egresos_operativos (cargado_por_id);
create index if not exists ix_egresos_operativos_sync
    on public.egresos_operativos (establecimiento_id, updated_at);
create index if not exists ix_categorias_egresos_operativos_establecimiento_id
    on public.categorias_egresos_operativos (establecimiento_id);
create index if not exists ix_categorias_egresos_operativos_creado_por_id
    on public.categorias_egresos_operativos (creado_por_id);

-- La API valida el catálogo y este trigger replica la garantía para escrituras
-- directas autorizadas por Supabase/RLS.
create or replace function public.validar_categoria_egreso_operativo()
returns trigger
language plpgsql
set search_path = public
as $$
begin
    if (
        new.tipo = 'costo_produccion'
        and new.categoria in ('sanidad', 'alimentacion', 'identificacion')
    ) or (
        new.tipo = 'gasto_administrativo'
        and new.categoria in ('combustible', 'estructura', 'honorarios')
    ) or exists (
        select 1
        from public.categorias_egresos_operativos c
        where c.establecimiento_id = new.establecimiento_id
          and c.tipo = new.tipo
          and c.valor = new.categoria
          and c.deleted_at is null
    ) then
        return new;
    end if;

    raise exception 'La categoría no corresponde al tipo de egreso seleccionado';
end;
$$;

drop trigger if exists validar_categoria_egreso_operativo
    on public.egresos_operativos;
create trigger validar_categoria_egreso_operativo
before insert or update on public.egresos_operativos
for each row execute function public.validar_categoria_egreso_operativo();

alter table public.egresos_operativos enable row level security;
alter table public.categorias_egresos_operativos enable row level security;

drop policy if exists categorias_egresos_operativos_select_miembros
    on public.categorias_egresos_operativos;
create policy categorias_egresos_operativos_select_miembros
on public.categorias_egresos_operativos for select to authenticated
using (
    exists (
        select 1 from public.usuarios_establecimientos ue
        where ue.establecimiento_id = categorias_egresos_operativos.establecimiento_id
          and ue.usuario_id = auth.uid() and ue.activo = true
    )
);

drop policy if exists categorias_egresos_operativos_insert_miembros
    on public.categorias_egresos_operativos;
create policy categorias_egresos_operativos_insert_miembros
on public.categorias_egresos_operativos for insert to authenticated
with check (
    creado_por_id = auth.uid()
    and exists (
        select 1 from public.usuarios_establecimientos ue
        where ue.establecimiento_id = categorias_egresos_operativos.establecimiento_id
          and ue.usuario_id = auth.uid() and ue.activo = true
    )
);

drop policy if exists egresos_operativos_select_miembros on public.egresos_operativos;
create policy egresos_operativos_select_miembros
on public.egresos_operativos for select to authenticated
using (
    exists (
        select 1 from public.usuarios_establecimientos ue
        where ue.establecimiento_id = egresos_operativos.establecimiento_id
          and ue.usuario_id = auth.uid() and ue.activo = true
    )
);

drop policy if exists egresos_operativos_insert_miembros on public.egresos_operativos;
create policy egresos_operativos_insert_miembros
on public.egresos_operativos for insert to authenticated
with check (
    cargado_por_id = auth.uid()
    and exists (
        select 1 from public.usuarios_establecimientos ue
        where ue.establecimiento_id = egresos_operativos.establecimiento_id
          and ue.usuario_id = auth.uid() and ue.activo = true
    )
);

drop policy if exists egresos_operativos_update_miembros on public.egresos_operativos;
create policy egresos_operativos_update_miembros
on public.egresos_operativos for update to authenticated
using (
    exists (
        select 1 from public.usuarios_establecimientos ue
        where ue.establecimiento_id = egresos_operativos.establecimiento_id
          and ue.usuario_id = auth.uid() and ue.activo = true
    )
)
with check (
    cargado_por_id = auth.uid()
    and exists (
        select 1 from public.usuarios_establecimientos ue
        where ue.establecimiento_id = egresos_operativos.establecimiento_id
          and ue.usuario_id = auth.uid() and ue.activo = true
    )
);

revoke all on public.egresos_operativos from anon;
grant select, insert, update on public.egresos_operativos to authenticated;
revoke all on public.categorias_egresos_operativos from anon;
grant select, insert on public.categorias_egresos_operativos to authenticated;

commit;
