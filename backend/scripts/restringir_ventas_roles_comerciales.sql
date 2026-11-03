-- Restringe ventas y sus importes a los roles comerciales del establecimiento.
-- Espejo manual de la migración Alembic 20260910_01.
begin;

drop policy if exists ventas_select_miembros on public.ventas;
create policy ventas_select_miembros
on public.ventas for select to authenticated
using (
    exists (
        select 1 from public.usuarios_establecimientos ue
        where ue.establecimiento_id = ventas.establecimiento_id
          and ue.usuario_id = auth.uid() and ue.activo = true
          and ue.rol in ('admin', 'owner')
    )
);

drop policy if exists ventas_insert_miembros on public.ventas;
create policy ventas_insert_miembros
on public.ventas for insert to authenticated
with check (
    registrada_por_id = auth.uid()
    and exists (
        select 1 from public.usuarios_establecimientos ue
        where ue.establecimiento_id = ventas.establecimiento_id
          and ue.usuario_id = auth.uid() and ue.activo = true
          and ue.rol in ('admin', 'owner')
    )
);

drop policy if exists ventas_update_miembros on public.ventas;
create policy ventas_update_miembros
on public.ventas for update to authenticated
using (
    exists (
        select 1 from public.usuarios_establecimientos ue
        where ue.establecimiento_id = ventas.establecimiento_id
          and ue.usuario_id = auth.uid() and ue.activo = true
          and ue.rol in ('admin', 'owner')
    )
)
with check (
    exists (
        select 1 from public.usuarios_establecimientos ue
        where ue.establecimiento_id = ventas.establecimiento_id
          and ue.usuario_id = auth.uid() and ue.activo = true
          and ue.rol in ('admin', 'owner')
    )
);

drop policy if exists ventas_detalles_select_miembros on public.ventas_detalles;
create policy ventas_detalles_select_miembros
on public.ventas_detalles for select to authenticated
using (
    exists (
        select 1
        from public.ventas v
        join public.usuarios_establecimientos ue
          on ue.establecimiento_id = v.establecimiento_id
        where v.id = ventas_detalles.venta_id
          and ue.usuario_id = auth.uid() and ue.activo = true
          and ue.rol in ('admin', 'owner')
    )
);

drop policy if exists ventas_detalles_insert_miembros on public.ventas_detalles;
create policy ventas_detalles_insert_miembros
on public.ventas_detalles for insert to authenticated
with check (
    exists (
        select 1
        from public.ventas v
        join public.animales a
          on a.id = ventas_detalles.animal_id
         and a.establecimiento_id = v.establecimiento_id
        join public.usuarios_establecimientos ue
          on ue.establecimiento_id = v.establecimiento_id
        where v.id = ventas_detalles.venta_id
          and ue.usuario_id = auth.uid() and ue.activo = true
          and ue.rol in ('admin', 'owner')
    )
);

commit;
