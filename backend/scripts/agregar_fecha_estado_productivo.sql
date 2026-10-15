-- Espejo manual de la migracion Alembic 20261015_01.
alter table public.animales
    add column if not exists estado_actualizado_en timestamptz null;
