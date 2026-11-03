-- Equipo del establecimiento: rol veterinario e invitaciones por email
-- (adr-0012). Espejo manual de la migración Alembic 20261017_02 para el SQL
-- Editor de Supabase. Es idempotente: se puede correr más de una vez.
--
-- La tabla guarda el HMAC del código de invitación, nunca el código. Tiene RLS
-- activado sin policies: ni anon ni authenticated la leen por PostgREST; el
-- backend entra como postgres y no se ve afectado.
begin;

alter table public.usuarios_establecimientos
    drop constraint if exists ck_usuarios_establecimientos_rol;

alter table public.usuarios_establecimientos
    add constraint ck_usuarios_establecimientos_rol check (rol IN ('admin', 'owner', 'employee', 'veterinarian'));

create table if not exists public.invitaciones_establecimientos (
    id uuid primary key,
    created_at timestamp with time zone not null default now(),
    updated_at timestamp with time zone not null default now(),
    establecimiento_id uuid not null references public.establecimientos (id),
    email varchar not null,
    rol varchar not null,
    codigo_hash varchar(64) not null,
    expira_en timestamp with time zone not null,
    estado varchar not null,
    invitado_por_id uuid not null references public.usuarios (id),
    aceptada_por_id uuid references public.usuarios (id),
    aceptada_en timestamp with time zone,
    email_enviado_en timestamp with time zone,
    constraint ck_invitaciones_establecimientos_rol check (rol IN ('admin', 'owner', 'employee', 'veterinarian')),
    constraint ck_invitaciones_establecimientos_estado check (estado IN ('pendiente', 'aceptada', 'cancelada'))
);

create index if not exists ix_invitaciones_establecimientos_establecimiento_id
    on public.invitaciones_establecimientos (establecimiento_id);

create index if not exists ix_invitaciones_establecimientos_codigo_hash
    on public.invitaciones_establecimientos (codigo_hash);

create unique index if not exists uq_invitaciones_establecimientos_pendiente
    on public.invitaciones_establecimientos (establecimiento_id, email)
    where estado = 'pendiente';

alter table public.invitaciones_establecimientos enable row level security;

commit;
