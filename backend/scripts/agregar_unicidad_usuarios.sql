-- Normaliza correos y garantiza unicidad real de los identificadores de usuario.
-- Si existen duplicados, la transaccion falla al crear el indice y no aplica
-- cambios parciales. Resolver esos registros antes de volver a ejecutar.
-- Script de respaldo para intervención manual. Los despliegues normales deben
-- aplicar la migración Alembic 20260819_01 mediante `alembic upgrade head`.
begin;

update public.usuarios
set email = lower(trim(email));

create unique index if not exists uq_usuarios_email
    on public.usuarios (email);

create unique index if not exists uq_usuarios_cuit
    on public.usuarios (cuit)
    where cuit is not null;

commit;
