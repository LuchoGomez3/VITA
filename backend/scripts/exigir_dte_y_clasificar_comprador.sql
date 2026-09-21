-- Exige el DTe y distingue empresas de personas físicas en las ventas.
-- Espejo manual de la migración Alembic 20260910_02.
begin;

alter table public.ventas
    add column if not exists es_empresa boolean;

-- En el esquema anterior, apellido NULL identificaba una razón social.
update public.ventas
set es_empresa = (apellido_comprador is null)
where es_empresa is null;

do $$
declare
    cantidad bigint;
begin
    select count(*) into cantidad
    from public.ventas
    where nro_dte is null or trim(nro_dte) = '';

    if cantidad > 0 then
        raise exception
            'No se puede exigir el DTe: hay % venta(s) sin un número válido.',
            cantidad;
    end if;

    select count(*) into cantidad
    from public.ventas
    where (es_empresa and apellido_comprador is not null)
       or (
            not es_empresa
            and (apellido_comprador is null or trim(apellido_comprador) = '')
       );

    if cantidad > 0 then
        raise exception
            'No se puede clasificar el comprador: hay % venta(s) con un apellido incompatible.',
            cantidad;
    end if;
end
$$;

alter table public.ventas
    alter column es_empresa set not null,
    alter column nro_dte set not null;

do $$
begin
    if not exists (
        select 1 from pg_constraint
        where conname = 'ck_ventas_nro_dte_no_vacio'
          and conrelid = 'public.ventas'::regclass
    ) then
        alter table public.ventas
            add constraint ck_ventas_nro_dte_no_vacio
            check (trim(nro_dte) <> '');
    end if;

    if not exists (
        select 1 from pg_constraint
        where conname = 'ck_ventas_apellido_segun_comprador'
          and conrelid = 'public.ventas'::regclass
    ) then
        alter table public.ventas
            add constraint ck_ventas_apellido_segun_comprador
            check (
                (es_empresa and apellido_comprador is null)
                or (
                    not es_empresa
                    and apellido_comprador is not null
                    and trim(apellido_comprador) <> ''
                )
            );
    end if;
end
$$;

commit;
