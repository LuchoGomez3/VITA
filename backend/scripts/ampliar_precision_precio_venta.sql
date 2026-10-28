-- Conserva el precio por kilo pactado con hasta seis decimales. El importe
-- total de la venta continúa expresándose en centavos (numeric(14, 2)).
-- Espejo manual de la migración Alembic 20261003_01.
begin;

do $$
begin
    if exists (
        select 1
        from information_schema.columns
        where table_schema = 'public'
          and table_name = 'ventas'
          and column_name = 'precio_por_kg'
    ) then
        alter table public.ventas
            alter column precio_por_kg type numeric(18, 6)
            using precio_por_kg::numeric(18, 6);
    end if;
end
$$;

commit;
