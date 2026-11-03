-- Personalización del perfil: color de la cabecera y fecha de la foto
-- (adr-0011). Espejo manual de la migración Alembic 20261017_01 para el SQL
-- Editor de Supabase. Es idempotente: se puede correr más de una vez.
--
-- La foto vive en el bucket privado "avatars" con clave "<usuario_id>.jpg";
-- acá solo se guarda cuándo se subió.
begin;

alter table public.usuarios
    add column if not exists color_cabecera varchar(7);

alter table public.usuarios
    add column if not exists avatar_actualizado_en timestamp with time zone;

alter table public.usuarios
    drop constraint if exists ck_usuarios_color_cabecera;

alter table public.usuarios
    add constraint ck_usuarios_color_cabecera check (color_cabecera IS NULL OR (length(color_cabecera) = 7 AND substr(color_cabecera, 1, 1) = '#' AND ltrim(substr(color_cabecera, 2), '0123456789ABCDEF') = ''));

commit;
