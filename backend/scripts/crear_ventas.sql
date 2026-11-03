-- Estructura de ventas de hacienda: la operación comercial (comprador, DTe,
-- monto) y los animales que la componen. No altera `egresos`, que registra las
-- salidas físicas no comerciales del animal (muerte, baja, traslado externo).
--
-- Script de respaldo para intervención manual desde el SQL Editor de Supabase.
-- Los despliegues normales aplican la migración Alembic 20260902_02 mediante
-- `alembic upgrade head`.
begin;

-- Las restricciones se nombran de forma explícita para que coincidan con las que
-- declara el modelo SQLModel y aplica la migración Alembic.
create table if not exists public.ventas (
    id uuid primary key,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    deleted_at timestamptz,
    establecimiento_id uuid not null references public.establecimientos(id),
    fecha_operacion date not null,
    tipo_comprador varchar not null,
    -- Razón social del frigorífico o remate, o nombre de pila de un particular.
    nombre_comprador varchar not null,
    -- Solo aplica cuando el comprador es una persona física.
    apellido_comprador varchar,
    -- Documento de Tránsito electrónico de SENASA. Nullable a propósito: se
    -- emite después de cerrar el trato y la venta puede registrarse sin señal.
    nro_dte varchar,
    tipo_venta varchar not null,
    peso_total_kg numeric(10, 3),
    precio_por_kg numeric(14, 2),
    monto_total numeric(14, 2) not null,
    observaciones varchar,
    registrada_por_id uuid not null references public.usuarios(id),
    -- La API valida el enum, pero la base también lo hace: Supabase acepta
    -- escrituras directas y esas no pasan por Pydantic.
    constraint ck_ventas_tipo_comprador_valido
        check (tipo_comprador in ('frigorifico', 'remate', 'particular')),
    constraint ck_ventas_tipo_venta_valido
        check (tipo_venta in ('por_kilo', 'al_bulto')),
    constraint ck_ventas_monto_total_positivo check (monto_total > 0),
    constraint ck_ventas_peso_total_positivo
        check (peso_total_kg is null or peso_total_kg > 0),
    constraint ck_ventas_precio_por_kg_positivo
        check (precio_por_kg is null or precio_por_kg > 0),
    constraint ck_ventas_nombre_comprador_no_vacio
        check (trim(nombre_comprador) <> ''),
    -- La venta al bulto se pacta por un monto cerrado; la venta por kilo solo
    -- existe si se conocen los dos factores con los que se calcula el monto.
    constraint ck_ventas_por_kilo_requiere_peso_y_precio check (
        tipo_venta <> 'por_kilo'
        or (peso_total_kg is not null and precio_por_kg is not null)
    )
);

-- Sin deleted_at: la venta es un agregado atómico y sus detalles viajan dentro
-- de su payload, así que no se sincronizan ni se borran por separado.
create table if not exists public.ventas_detalles (
    id uuid primary key,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    venta_id uuid not null references public.ventas(id),
    animal_id uuid not null references public.animales(id),
    peso_kg numeric(10, 3),
    precio numeric(14, 2),
    constraint ck_ventas_detalles_peso_positivo
        check (peso_kg is null or peso_kg > 0),
    constraint ck_ventas_detalles_precio_positivo
        check (precio is null or precio > 0),
    constraint uq_venta_animal unique (venta_id, animal_id)
);

create index if not exists ix_ventas_establecimiento_id
    on public.ventas (establecimiento_id);
create index if not exists ix_ventas_fecha_operacion
    on public.ventas (fecha_operacion);
create index if not exists ix_ventas_registrada_por_id
    on public.ventas (registrada_por_id);
-- Sostiene la descarga delta del cliente offline (`updated_since`).
create index if not exists ix_ventas_sync
    on public.ventas (establecimiento_id, updated_at);
create index if not exists ix_ventas_detalles_venta_id
    on public.ventas_detalles (venta_id);
-- Responde "¿este animal ya se vendió?" al armar una venta nueva.
create index if not exists ix_ventas_detalles_animal_id
    on public.ventas_detalles (animal_id);

alter table public.ventas enable row level security;
alter table public.ventas_detalles enable row level security;

drop policy if exists ventas_select_miembros on public.ventas;
create policy ventas_select_miembros
on public.ventas for select to authenticated
using (
    exists (
        select 1 from public.usuarios_establecimientos ue
        where ue.establecimiento_id = ventas.establecimiento_id
          and ue.usuario_id = auth.uid() and ue.activo = true
    )
);

drop policy if exists ventas_insert_miembros on public.ventas;
create policy ventas_insert_miembros
on public.ventas for insert to authenticated
with check (
    registrada_por_id = auth.uid()
    and exists (
        select 1 from public.usuarios_establecimientos ue
        where ue.establecimiento_id = ventas.establecimiento_id
          and ue.usuario_id = auth.uid() and ue.activo = true
    )
);

-- El borrado es soft (`deleted_at`), así que se cubre con update y no se
-- habilita ninguna política de delete.
drop policy if exists ventas_update_miembros on public.ventas;
create policy ventas_update_miembros
on public.ventas for update to authenticated
using (
    exists (
        select 1 from public.usuarios_establecimientos ue
        where ue.establecimiento_id = ventas.establecimiento_id
          and ue.usuario_id = auth.uid() and ue.activo = true
    )
)
with check (
    exists (
        select 1 from public.usuarios_establecimientos ue
        where ue.establecimiento_id = ventas.establecimiento_id
          and ue.usuario_id = auth.uid() and ue.activo = true
    )
);

drop policy if exists ventas_detalles_select_miembros on public.ventas_detalles;
create policy ventas_detalles_select_miembros
on public.ventas_detalles for select to authenticated
using (
    exists (
        select 1
        from public.ventas v
        join public.usuarios_establecimientos ue
          on ue.establecimiento_id = v.establecimiento_id
        where v.id = ventas_detalles.venta_id
          and ue.usuario_id = auth.uid() and ue.activo = true
    )
);

-- El animal debe pertenecer al mismo establecimiento que la venta: evita que un
-- miembro arme una venta con hacienda de otro tenant.
drop policy if exists ventas_detalles_insert_miembros on public.ventas_detalles;
create policy ventas_detalles_insert_miembros
on public.ventas_detalles for insert to authenticated
with check (
    exists (
        select 1
        from public.ventas v
        join public.animales a
          on a.id = ventas_detalles.animal_id
         and a.establecimiento_id = v.establecimiento_id
        join public.usuarios_establecimientos ue
          on ue.establecimiento_id = v.establecimiento_id
        where v.id = ventas_detalles.venta_id
          and ue.usuario_id = auth.uid() and ue.activo = true
    )
);

revoke all on public.ventas from anon;
revoke all on public.ventas_detalles from anon;
grant select, insert, update on public.ventas to authenticated;
-- La composición se fija al crear la venta: no se edita ni se borra.
grant select, insert on public.ventas_detalles to authenticated;

commit;
