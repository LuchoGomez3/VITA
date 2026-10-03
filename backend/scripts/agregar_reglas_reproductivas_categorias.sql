-- Reglas de sexo y condición reproductiva entre animales y categorías (VITA-173).
-- Espejo manual de la migración Alembic 20261001_02. Es idempotente: se puede
-- reejecutar sin pisar clasificaciones posteriores.
begin;

alter table public.categorias
    add column if not exists sexo_permitido varchar;
alter table public.categorias
    add column if not exists permite_estado_reproductivo boolean not null default false;
alter table public.animales
    add column if not exists estado_reproductivo varchar;

-- Catálogo global (establecimiento_id null): las 6 categorías del front, con
-- los mismos UUIDs que usa mobile. Decisión de Ernesto (PO) y Lucho, 2026-10-02:
-- "las categorías están en el front". Si ya existen, no se duplican.
insert into public.categorias
    (id, establecimiento_id, nombre, sexo_permitido, permite_estado_reproductivo,
     created_at, updated_at)
select v.id, null, v.nombre, v.sexo_permitido, v.permite_estado_reproductivo,
       now(), now()
  from (values
    ('d37e62fb-96db-4ff1-a26b-0e3b2c3b36d8'::uuid, 'Ternera', 'hembra', false),
    ('b9a6e57b-20ae-49b1-a7bb-17c71af546f3'::uuid, 'Ternero', 'macho', false),
    ('b6d6440c-88c6-48cc-9003-0ad2cc05f3d5'::uuid, 'Vaquillona', 'hembra', true),
    ('ef69117b-c979-4665-b13f-2b26ff0f19b3'::uuid, 'Vaca', 'hembra', true),
    ('41da4271-bd25-4ba0-ba34-24dc6586f0f2'::uuid, 'Novillo', 'macho', false),
    ('b5e8ea91-9789-4f7e-9dad-10262f1920f4'::uuid, 'Toro', 'macho', false)
  ) as v(id, nombre, sexo_permitido, permite_estado_reproductivo)
on conflict (id) do nothing;

-- Clasificación revisada a mano, por id. Nunca se infiere del nombre: se aplica
-- solo a filas todavía sin clasificar. Incluye el catálogo global (por si ya
-- existía sin reglas) y los datos de prueba heredados que hay en Supabase.
update public.categorias c
   set sexo_permitido = v.sexo_permitido,
       permite_estado_reproductivo = v.permite_estado_reproductivo
  from (values
    -- Ternera (catálogo global)
    ('d37e62fb-96db-4ff1-a26b-0e3b2c3b36d8'::uuid, 'hembra', false),
    -- Ternero (catálogo global)
    ('b9a6e57b-20ae-49b1-a7bb-17c71af546f3'::uuid, 'macho', false),
    -- Vaquillona (catálogo global)
    ('b6d6440c-88c6-48cc-9003-0ad2cc05f3d5'::uuid, 'hembra', true),
    -- Vaca (catálogo global)
    ('ef69117b-c979-4665-b13f-2b26ff0f19b3'::uuid, 'hembra', true),
    -- Novillo (catálogo global)
    ('41da4271-bd25-4ba0-ba34-24dc6586f0f2'::uuid, 'macho', false),
    -- Toro (catálogo global)
    ('b5e8ea91-9789-4f7e-9dad-10262f1920f4'::uuid, 'macho', false),
    -- Ternero (prueba): ambos, tiene 2 hembras asignadas
    ('550e8400-e29b-41d4-a716-446655440030'::uuid, 'ambos', false),
    -- Novillo (prueba)
    ('550e8400-e29b-41d4-a716-446655440031'::uuid, 'macho', false),
    -- Vaca (prueba)
    ('550e8400-e29b-41d4-a716-446655440032'::uuid, 'hembra', true),
    -- Toro (prueba)
    ('550e8400-e29b-41d4-a716-446655440033'::uuid, 'macho', false),
    -- Engorde Rápido (prueba)
    ('550e8400-e29b-41d4-a716-446655440034'::uuid, 'ambos', false)
  ) as v(id, sexo_permitido, permite_estado_reproductivo)
 where c.id = v.id
   and c.sexo_permitido is null;

-- Una categoría fuera de la clasificación detiene el script: no se asigna
-- 'ambos' por defecto.
do $$
declare
    pendientes text;
begin
    select string_agg(id::text || ' (' || nombre || ')', ', ' order by nombre, id)
      into pendientes
      from public.categorias
     where sexo_permitido is null;

    if pendientes is not null then
        raise exception
            'No se puede inferir qué sexo admite cada categoría: clasificá a mano %.',
            pendientes;
    end if;
end
$$;

-- Crear los triggers con animales inválidos los dejaría sin poder editarse.
do $$
declare
    cantidad bigint;
begin
    select count(*) into cantidad
      from public.animales a
      join public.categorias c on c.id = a.categoria_id
     where a.deleted_at is null
       and c.sexo_permitido <> 'ambos'
       and a.sexo <> c.sexo_permitido;

    if cantidad > 0 then
        raise exception
            'La clasificación de categorías deja % animal(es) con un sexo incompatible.',
            cantidad;
    end if;
end
$$;

alter table public.categorias
    alter column sexo_permitido set not null;

alter table public.categorias
    drop constraint if exists ck_categorias_sexo_permitido_valido;
alter table public.categorias
    add constraint ck_categorias_sexo_permitido_valido
    check (sexo_permitido in ('macho', 'hembra', 'ambos'));

alter table public.animales
    drop constraint if exists ck_animales_estado_reproductivo_valido;
alter table public.animales
    add constraint ck_animales_estado_reproductivo_valido
    check (estado_reproductivo is null or estado_reproductivo in ('sin_determinar', 'vacia', 'prenada'));

alter table public.animales
    drop constraint if exists ck_animales_estado_reproductivo_solo_hembras;
alter table public.animales
    add constraint ck_animales_estado_reproductivo_solo_hembras
    check (estado_reproductivo is null or sexo = 'hembra');

create or replace function public.validar_categoria_animal()
returns trigger
language plpgsql
security invoker
set search_path = public, pg_temp
as $$
declare
    v_establecimiento_id uuid;
    v_sexo_permitido varchar;
    v_permite boolean;
    v_borrada timestamptz;
begin
    if new.categoria_id is null then
        if new.estado_reproductivo in ('vacia', 'prenada') then
            raise exception 'La condición reproductiva requiere una categoría habilitada'
                using errcode = 'check_violation';
        end if;
        return new;
    end if;

    select c.establecimiento_id, c.sexo_permitido,
           c.permite_estado_reproductivo, c.deleted_at
      into v_establecimiento_id, v_sexo_permitido, v_permite, v_borrada
      from public.categorias c
     where c.id = new.categoria_id
       for share;

    -- Sin categoría visible, la FK o el RLS rechazan la fila. Con security
    -- invoker, un cliente directo no ve categorías ajenas: el trigger no
    -- distingue "ajena" de "inexistente" y no revela sus reglas.
    if not found then
        return new;
    end if;

    -- Pertenencia y borrado se exigen solo al asignar: una categoría que se
    -- borra después no debe trabar la edición de otros campos del animal.
    if tg_op = 'INSERT' or new.categoria_id is distinct from old.categoria_id then
        if v_borrada is not null then
            raise exception 'No se puede asignar una categoría eliminada'
                using errcode = 'check_violation';
        end if;
        if v_establecimiento_id is not null
           and v_establecimiento_id <> new.establecimiento_id then
            raise exception 'La categoría pertenece a otro establecimiento'
                using errcode = 'check_violation';
        end if;
    end if;

    if v_sexo_permitido <> 'ambos' and v_sexo_permitido <> new.sexo then
        raise exception 'La categoría seleccionada no es compatible con el sexo del animal'
            using errcode = 'check_violation';
    end if;

    if new.estado_reproductivo in ('vacia', 'prenada') and not v_permite then
        raise exception 'La categoría del animal no admite condición reproductiva'
            using errcode = 'check_violation';
    end if;

    return new;
end;
$$;

drop trigger if exists trg_animales_categoria_compatible on public.animales;

create trigger trg_animales_categoria_compatible
before insert or update of sexo, categoria_id, estado_reproductivo, deleted_at
on public.animales
for each row execute function public.validar_categoria_animal();

create or replace function public.validar_reglas_categoria()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
    v_incompatibles integer;
begin
    if new.sexo_permitido = old.sexo_permitido
       and new.permite_estado_reproductivo = old.permite_estado_reproductivo then
        return new;
    end if;

    select count(*)
      into v_incompatibles
      from public.animales a
     where a.categoria_id = new.id
       and a.deleted_at is null
       and (
            (new.sexo_permitido <> 'ambos' and a.sexo <> new.sexo_permitido)
            or (not new.permite_estado_reproductivo
                and a.estado_reproductivo in ('vacia', 'prenada'))
       );

    if v_incompatibles > 0 then
        -- Mensaje concatenado: DDL() de SQLAlchemy interpreta el signo de porcentaje.
        raise exception using
            errcode = 'check_violation',
            message = 'Hay ' || v_incompatibles
                || ' animal(es) que quedarían incompatibles con la categoría';
    end if;

    return new;
end;
$$;

drop trigger if exists trg_categorias_reglas_compatibles on public.categorias;

create trigger trg_categorias_reglas_compatibles
before update of sexo_permitido, permite_estado_reproductivo
on public.categorias
for each row execute function public.validar_reglas_categoria();

commit;

-- ---------------------------------------------------------------------------
-- LIMPIEZA OPCIONAL DE DATOS DE PRUEBA (manual, no la corre Alembic)
-- ---------------------------------------------------------------------------
-- Correr a mano, después de aplicar lo anterior, quitando los "-- " del bloque.
-- Es idempotente: reejecutarlo no cambia nada.
-- 1. Las hembras del "Ternero" de prueba pasan a la Ternera del catálogo.
-- 2. "Engorde Rápido" se borra lógicamente, solo si no tiene animales vivos.
-- INICIO LIMPIEZA
-- begin;
--
-- update public.animales
--    set categoria_id = 'd37e62fb-96db-4ff1-a26b-0e3b2c3b36d8',
--        updated_at = now()
--  where categoria_id = '550e8400-e29b-41d4-a716-446655440030'
--    and sexo = 'hembra'
--    and deleted_at is null;
--
-- update public.categorias
--    set deleted_at = now(),
--        updated_at = now()
--  where id = '550e8400-e29b-41d4-a716-446655440034'
--    and deleted_at is null
--    and not exists (
--        select 1 from public.animales a
--         where a.categoria_id = '550e8400-e29b-41d4-a716-446655440034'
--           and a.deleted_at is null
--    );
--
-- commit;
-- FIN LIMPIEZA
