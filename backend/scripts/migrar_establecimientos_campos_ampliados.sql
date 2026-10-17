-- Completa establecimientos creados antes de incorporar descripción, tipos de
-- producción y georreferencia. Todos los cambios son aditivos y conservan los
-- establecimientos y membresías existentes.
begin;

alter table public.establecimientos
    add column if not exists descripcion varchar,
    add column if not exists tipo_produccion json,
    add column if not exists latitud numeric(9, 6),
    add column if not exists longitud numeric(9, 6),
    add column if not exists poligono json;

commit;
