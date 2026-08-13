-- Ejecutar SOLO si ya se aplicó una versión anterior de
-- crear_exportaciones_senasa.sql que contenía la columna tipo_evento.
begin;

do $$
begin
    if exists (
        select 1
        from information_schema.columns
        where table_schema = 'public'
          and table_name = 'exportaciones_senasa'
          and column_name = 'tipo_evento'
    ) and not exists (
        select 1
        from information_schema.columns
        where table_schema = 'public'
          and table_name = 'exportaciones_senasa'
          and column_name = 'tipo_exportacion'
    ) then
        alter table public.exportaciones_senasa
            rename column tipo_evento to tipo_exportacion;
    end if;
end;
$$;

-- Se retira el CHECK anterior sin modificar registros históricos. Los valores
-- viejos permanecen como evidencia; las nuevas filas usan únicamente
-- declaracion_identificacion desde el backend.
do $$
declare
    restriccion record;
begin
    for restriccion in
        select conname
        from pg_constraint
        where conrelid = 'public.exportaciones_senasa'::regclass
          and contype = 'c'
          and pg_get_constraintdef(oid) like '%tipo_exportacion%'
    loop
        execute format(
            'alter table public.exportaciones_senasa drop constraint %I',
            restriccion.conname
        );
    end loop;
end;
$$;

alter table public.exportaciones_senasa
    add constraint ck_exportaciones_senasa_tipo_exportacion
    check (
        tipo_exportacion in (
            'declaracion_identificacion',
            'novedad_nacimientos',
            'acta_vacunacion'
        )
    );

comment on constraint ck_exportaciones_senasa_tipo_exportacion
on public.exportaciones_senasa is
'Los valores anteriores se conservan solo como historial; las nuevas exportaciones son declaraciones de identificación.';

commit;
