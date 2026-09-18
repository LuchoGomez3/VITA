-- Distingue al comprador empresa del particular y vuelve obligatorio el DTe.
-- Si alguna venta tiene nro_dte vacío, o un apellido incoherente con es_empresa,
-- la transacción falla al crear los CHECK y no aplica cambios parciales.
-- Resolver esas filas antes de volver a ejecutar.
-- Script de respaldo para intervención manual. Los despliegues normales deben
-- aplicar la migración Alembic 20260910_02 mediante `alembic upgrade head`.
begin;

alter table public.ventas
    add column if not exists es_empresa boolean;

-- Hasta ahora el apellido era el único indicio del tipo de comprador: su
-- ausencia implicaba una razón social.
update public.ventas
set es_empresa = (apellido_comprador is null)
where es_empresa is null;

alter table public.ventas
    alter column es_empresa set not null,
    alter column nro_dte set not null;

alter table public.ventas
    drop constraint if exists ck_ventas_nro_dte_no_vacio;

alter table public.ventas
    add constraint ck_ventas_nro_dte_no_vacio
    check (trim(nro_dte) <> '');

alter table public.ventas
    drop constraint if exists ck_ventas_apellido_segun_comprador;

alter table public.ventas
    add constraint ck_ventas_apellido_segun_comprador
    check (
        (es_empresa and apellido_comprador is null)
        or (not es_empresa and apellido_comprador is not null
            and trim(apellido_comprador) <> '')
    );

commit;
