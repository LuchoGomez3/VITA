-- Espejo manual de la migracion Alembic 20261015_01.
alter table public.animales
    add column if not exists estado_actualizado_en timestamptz null;

update public.animales
set estado_actualizado_en = updated_at
where estado in ('vendido', 'muerto', 'baja')
  and estado_actualizado_en is null;
