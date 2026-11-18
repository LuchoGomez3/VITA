-- Catálogo de alimentos y registros de alimentación (adr-0015).
-- Espejo manual de la migración Alembic 20261114_02. Es idempotente: se puede
-- reejecutar sin duplicar nada. Correr después de
-- crear_recursos_forrajeros_por_periodo.sql y de crear_observaciones_animales.sql
-- (de ahí sale public.animal_pertenece_a_establecimiento).
begin;

-- ------------------------------------------------------------ alimentos
-- Existe desde el esquema base sin API ni políticas: se crea solo si falta y se
-- completa con lo necesario para sincronizar.
create table if not exists public.alimentos (
    id uuid primary key,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    deleted_at timestamptz,
    -- Null = catálogo global, de solo lectura para los clientes.
    establecimiento_id uuid references public.establecimientos (id),
    nombre varchar not null,
    categoria varchar not null default 'otro',
    unidad varchar not null default 'kg',
    valor_proteico numeric(6, 2),
    valor_vitaminico numeric(6, 2),
    costo_unitario numeric(14, 2),
    creado_por_id uuid references public.usuarios (id)
);

alter table public.alimentos
    add column if not exists created_at timestamptz not null default now(),
    add column if not exists updated_at timestamptz not null default now(),
    add column if not exists deleted_at timestamptz,
    add column if not exists categoria varchar not null default 'otro',
    add column if not exists creado_por_id uuid references public.usuarios (id);

-- "not valid": valen para lo que se escriba de ahora en más sin rechazar filas
-- viejas que pudo haber cargado alguien a mano.
do $$
begin
    if not exists (select 1 from pg_constraint where conname = 'ck_alimentos_nombre_no_vacio') then
        alter table public.alimentos add constraint ck_alimentos_nombre_no_vacio
            check (trim(nombre) <> '') not valid;
    end if;
    if not exists (select 1 from pg_constraint where conname = 'ck_alimentos_categoria_valida') then
        alter table public.alimentos add constraint ck_alimentos_categoria_valida
            check (categoria in (
                'grano', 'concentrado', 'heno', 'silaje', 'subproducto', 'mineral', 'otro'
            )) not valid;
    end if;
    if not exists (select 1 from pg_constraint where conname = 'ck_alimentos_unidad_valida') then
        alter table public.alimentos add constraint ck_alimentos_unidad_valida
            check (unidad in ('kg', 'g', 'l', 'fardo', 'rollo', 'bolsa')) not valid;
    end if;
end;
$$;

create index if not exists ix_alimentos_sync
    on public.alimentos (establecimiento_id, updated_at);
create index if not exists ix_alimentos_establecimiento_id
    on public.alimentos (establecimiento_id);

-- --------------------------------------------- registros de alimentación
create table if not exists public.registros_alimentacion (
    id uuid primary key,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    deleted_at timestamptz,
    establecimiento_id uuid not null references public.establecimientos (id),
    tipo varchar not null,
    alimento_id uuid not null references public.alimentos (id),
    -- Dónde se suministró. Null = corral o manga.
    lote_id uuid references public.lotes (id),
    fecha_desde date not null,
    -- Null = en curso. Un solo día: fecha_hasta = fecha_desde.
    fecha_hasta date,
    cantidad numeric(12, 3) not null,
    unidad varchar not null,
    base_cantidad varchar not null,
    motivo varchar,
    responsable_id uuid references public.usuarios (id),
    constraint ck_registros_alimentacion_tipo_valido check (
        tipo in ('suplemento', 'dieta')
    ),
    constraint ck_registros_alimentacion_unidad_valida check (
        unidad in ('kg', 'g', 'l', 'fardo', 'rollo', 'bolsa')
    ),
    constraint ck_registros_alimentacion_base_valida check (
        base_cantidad in ('por_animal_dia', 'grupo_dia')
    ),
    constraint ck_registros_alimentacion_cantidad check (cantidad > 0),
    constraint ck_registros_alimentacion_fechas check (
        fecha_hasta is null or fecha_hasta >= fecha_desde
    )
);

create index if not exists ix_registros_alimentacion_sync
    on public.registros_alimentacion (establecimiento_id, updated_at);
create index if not exists ix_registros_alimentacion_fecha
    on public.registros_alimentacion (establecimiento_id, fecha_desde);
create index if not exists ix_registros_alimentacion_establecimiento_id
    on public.registros_alimentacion (establecimiento_id);
create index if not exists ix_registros_alimentacion_alimento_id
    on public.registros_alimentacion (alimento_id);

create table if not exists public.registros_alimentacion_animales (
    id uuid primary key,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    registro_alimentacion_id uuid not null references public.registros_alimentacion (id),
    animal_id uuid not null references public.animales (id),
    constraint uq_registro_alimentacion_animal unique (registro_alimentacion_id, animal_id)
);

create index if not exists ix_registros_alimentacion_animales_registro_alimentacion_id
    on public.registros_alimentacion_animales (registro_alimentacion_id);
create index if not exists ix_registros_alimentacion_animales_animal_id
    on public.registros_alimentacion_animales (animal_id);

-- ------------------------------------------------------------- triggers
create or replace function public.validar_registro_alimentacion()
returns trigger
language plpgsql
security invoker
set search_path = public, pg_temp
as $$
declare
    v_establecimiento_id uuid;
begin
    if tg_op = 'UPDATE' then
        if new.establecimiento_id <> old.establecimiento_id
           or new.alimento_id <> old.alimento_id
           or new.tipo <> old.tipo then
            raise exception 'Un registro de alimentación no puede cambiar de establecimiento, alimento ni tipo'
                using errcode = 'check_violation';
        end if;
    end if;

    select a.establecimiento_id
      into v_establecimiento_id
      from public.alimentos a
     where a.id = new.alimento_id;
    -- El catálogo global (establecimiento null) lo puede usar cualquiera.
    if found and v_establecimiento_id is not null
       and v_establecimiento_id <> new.establecimiento_id then
        raise exception 'El alimento pertenece a otro establecimiento'
            using errcode = 'check_violation';
    end if;

    if new.lote_id is not null then
        select l.establecimiento_id
          into v_establecimiento_id
          from public.lotes l
         where l.id = new.lote_id;
        if found and v_establecimiento_id <> new.establecimiento_id then
            raise exception 'El lote pertenece a otro establecimiento'
                using errcode = 'check_violation';
        end if;
    end if;

    return new;
end;
$$;

drop trigger if exists trg_registros_alimentacion_validar on public.registros_alimentacion;
create trigger trg_registros_alimentacion_validar
before insert or update on public.registros_alimentacion
for each row execute function public.validar_registro_alimentacion();

create or replace function public.validar_registro_alimentacion_animal()
returns trigger
language plpgsql
security invoker
set search_path = public, pg_temp
as $$
declare
    v_registro uuid;
    v_animal uuid;
begin
    select r.establecimiento_id
      into v_registro
      from public.registros_alimentacion r
     where r.id = new.registro_alimentacion_id;

    select a.establecimiento_id
      into v_animal
      from public.animales a
     where a.id = new.animal_id;

    -- Sin filas visibles deciden la FK (backend) o el RLS (cliente directo).
    if v_registro is not null and v_animal is not null and v_registro <> v_animal then
        raise exception 'El animal pertenece a otro establecimiento'
            using errcode = 'check_violation';
    end if;

    return new;
end;
$$;

drop trigger if exists trg_registros_alimentacion_animales_validar on public.registros_alimentacion_animales;
create trigger trg_registros_alimentacion_animales_validar
before insert or update on public.registros_alimentacion_animales
for each row execute function public.validar_registro_alimentacion_animal();

-- ------------------------------------------------------------------ RLS
alter table public.alimentos enable row level security;

drop policy if exists alimentos_select_miembros on public.alimentos;
create policy alimentos_select_miembros on public.alimentos
for select to authenticated
using (
    establecimiento_id is null
    or exists (
        select 1
        from public.usuarios_establecimientos ue
        where ue.establecimiento_id = alimentos.establecimiento_id
          and ue.usuario_id = auth.uid()
          and ue.activo = true
    )
);

drop policy if exists alimentos_insert_miembros on public.alimentos;
create policy alimentos_insert_miembros on public.alimentos
for insert to authenticated
with check (
    establecimiento_id is not null
    and creado_por_id = auth.uid()
    and exists (
        select 1
        from public.usuarios_establecimientos ue
        where ue.establecimiento_id = alimentos.establecimiento_id
          and ue.usuario_id = auth.uid()
          and ue.activo = true
    )
);

drop policy if exists alimentos_update_miembros on public.alimentos;
create policy alimentos_update_miembros on public.alimentos
for update to authenticated
using (
    establecimiento_id is not null
    and exists (
        select 1
        from public.usuarios_establecimientos ue
        where ue.establecimiento_id = alimentos.establecimiento_id
          and ue.usuario_id = auth.uid()
          and ue.activo = true
    )
)
with check (
    establecimiento_id is not null
    and exists (
        select 1
        from public.usuarios_establecimientos ue
        where ue.establecimiento_id = alimentos.establecimiento_id
          and ue.usuario_id = auth.uid()
          and ue.activo = true
    )
);

revoke all on public.alimentos from anon;
revoke all on public.alimentos from authenticated;
grant select, insert, update on public.alimentos to authenticated;

alter table public.registros_alimentacion enable row level security;

drop policy if exists registros_alimentacion_select_miembros on public.registros_alimentacion;
create policy registros_alimentacion_select_miembros on public.registros_alimentacion
for select to authenticated
using (
    exists (
        select 1
        from public.usuarios_establecimientos ue
        where ue.establecimiento_id = registros_alimentacion.establecimiento_id
          and ue.usuario_id = auth.uid()
          and ue.activo = true
    )
);

drop policy if exists registros_alimentacion_insert_miembros on public.registros_alimentacion;
create policy registros_alimentacion_insert_miembros on public.registros_alimentacion
for insert to authenticated
with check (
    responsable_id = auth.uid()
    and exists (
        select 1
        from public.usuarios_establecimientos ue
        where ue.establecimiento_id = registros_alimentacion.establecimiento_id
          and ue.usuario_id = auth.uid()
          and ue.activo = true
    )
);

-- Borrado soft: se cubre con update, sin política de delete.
drop policy if exists registros_alimentacion_update_miembros on public.registros_alimentacion;
create policy registros_alimentacion_update_miembros on public.registros_alimentacion
for update to authenticated
using (
    exists (
        select 1
        from public.usuarios_establecimientos ue
        where ue.establecimiento_id = registros_alimentacion.establecimiento_id
          and ue.usuario_id = auth.uid()
          and ue.activo = true
    )
)
with check (
    exists (
        select 1
        from public.usuarios_establecimientos ue
        where ue.establecimiento_id = registros_alimentacion.establecimiento_id
          and ue.usuario_id = auth.uid()
          and ue.activo = true
    )
);

revoke all on public.registros_alimentacion from anon;
revoke all on public.registros_alimentacion from authenticated;
grant select, insert, update on public.registros_alimentacion to authenticated;

alter table public.registros_alimentacion_animales enable row level security;

drop policy if exists registros_alimentacion_animales_select_miembros on public.registros_alimentacion_animales;
create policy registros_alimentacion_animales_select_miembros on public.registros_alimentacion_animales
for select to authenticated
using (
    exists (
        select 1
        from public.registros_alimentacion r
        join public.usuarios_establecimientos ue
          on ue.establecimiento_id = r.establecimiento_id
        where r.id = registros_alimentacion_animales.registro_alimentacion_id
          and ue.usuario_id = auth.uid()
          and ue.activo = true
    )
);

drop policy if exists registros_alimentacion_animales_insert_miembros on public.registros_alimentacion_animales;
create policy registros_alimentacion_animales_insert_miembros on public.registros_alimentacion_animales
for insert to authenticated
with check (
    exists (
        select 1
        from public.registros_alimentacion r
        join public.usuarios_establecimientos ue
          on ue.establecimiento_id = r.establecimiento_id
        where r.id = registros_alimentacion_animales.registro_alimentacion_id
          and ue.usuario_id = auth.uid()
          and ue.activo = true
    )
    and exists (
        select 1
        from public.registros_alimentacion r
        where r.id = registros_alimentacion_animales.registro_alimentacion_id
          and public.animal_pertenece_a_establecimiento(
              registros_alimentacion_animales.animal_id, r.establecimiento_id
          )
    )
);

-- El detalle es inmutable: corregir los animales es borrar el registro y crear
-- otro. Sin update ni delete.
revoke all on public.registros_alimentacion_animales from anon;
revoke all on public.registros_alimentacion_animales from authenticated;
grant select, insert on public.registros_alimentacion_animales to authenticated;

commit;
