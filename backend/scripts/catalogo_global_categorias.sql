-- Catálogo global de categorías: dejan de pertenecer a un establecimiento
-- (adr-0010). Espejo manual de la migración Alembic 20261014_01 para el SQL
-- Editor de Supabase. Es idempotente: si la columna ya no existe, solo
-- reemplaza la función del trigger.
--
-- Reasigna los animales de las categorías propias (datos de prueba heredados) a
-- la global del mismo nombre (las hembras del "Ternero" de prueba van a
-- "Ternera"), deja sin categoría a los que no tengan equivalente compatible,
-- borra las categorías propias y después la columna.
begin;

do $$
begin
    if exists (
        select 1 from information_schema.columns
         where table_schema = 'public'
           and table_name = 'categorias'
           and column_name = 'establecimiento_id'
    ) then
        update animales a
           set categoria_id = g.id,
               updated_at = now()
          from categorias c, categorias g
         where a.categoria_id = c.id
           and c.establecimiento_id is not null
           and g.establecimiento_id is null
           and g.deleted_at is null
           and lower(g.nombre) = case
                   when lower(c.nombre) = 'ternero' and a.sexo = 'hembra' then 'ternera'
                   else lower(c.nombre)
               end
           and (g.sexo_permitido = 'ambos' or g.sexo_permitido = a.sexo)
           and (
               a.estado_reproductivo is null
               or a.estado_reproductivo not in ('vacia', 'prenada')
               or g.permite_estado_reproductivo
           );
        update animales a
           set categoria_id = null,
               estado_reproductivo = case
                   when a.estado_reproductivo in ('vacia', 'prenada') then 'sin_determinar'
                   else a.estado_reproductivo
               end,
               updated_at = now()
          from categorias c
         where a.categoria_id = c.id
           and c.establecimiento_id is not null;
        delete from categorias where establecimiento_id is not null;
    end if;
end;
$$;

-- Deja de leer categorias.establecimiento_id. Va antes de borrar la columna:
-- plpgsql resuelve las columnas recién al ejecutar.
create or replace function public.validar_categoria_animal()
returns trigger
language plpgsql
security invoker
set search_path = public, pg_temp
as $$
declare
    v_sexo_permitido varchar;
    v_permite boolean;
    v_borrada timestamptz;
begin
    -- La compatibilidad se exige solo a animales vivos. Reenviar el borrado de un
    -- animal no puede fallar porque su categoría cambió después; restaurarlo
    -- (deleted_at vuelve a null) lo deja vivo, así que ahí sí se revalida.
    -- ``constraint`` identifica cada rechazo para que el backend lo traduzca a
    -- su error de dominio sin depender del texto del mensaje.
    if new.categoria_id is null then
        if new.deleted_at is null
           and new.estado_reproductivo in ('vacia', 'prenada') then
            raise exception 'La condición reproductiva requiere una categoría habilitada'
                using errcode = 'check_violation',
                      constraint = 'animales_estado_reproductivo_requiere_categoria';
        end if;
        return new;
    end if;

    select c.sexo_permitido, c.permite_estado_reproductivo, c.deleted_at
      into v_sexo_permitido, v_permite, v_borrada
      from public.categorias c
     where c.id = new.categoria_id
       for share;

    -- Sin categoría visible, la FK o el RLS rechazan la fila.
    if not found then
        return new;
    end if;

    -- El borrado se exige solo al asignar: una categoría que se borra después
    -- no debe trabar la edición de otros campos del animal. El catálogo es
    -- global (adr-0010), así que no hay pertenencia a un establecimiento.
    if (tg_op = 'INSERT' or new.categoria_id is distinct from old.categoria_id)
       and v_borrada is not null then
        raise exception 'No se puede asignar una categoría eliminada'
            using errcode = 'check_violation',
                  constraint = 'animales_categoria_asignable';
    end if;

    if new.deleted_at is not null then
        return new;
    end if;

    if v_sexo_permitido <> 'ambos' and v_sexo_permitido <> new.sexo then
        raise exception 'La categoría seleccionada no es compatible con el sexo del animal'
            using errcode = 'check_violation',
                  constraint = 'animales_categoria_admite_sexo';
    end if;

    if new.estado_reproductivo in ('vacia', 'prenada') and not v_permite then
        raise exception 'La categoría del animal no admite condición reproductiva'
            using errcode = 'check_violation',
                  constraint = 'animales_categoria_admite_estado_reproductivo';
    end if;

    return new;
end;
$$;

drop index if exists public.ix_categorias_establecimiento_id;
alter table public.categorias drop constraint if exists categorias_establecimiento_id_fkey;
alter table public.categorias drop column if exists establecimiento_id;

commit;
