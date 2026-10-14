"""Modelo persistente de las observaciones de un animal."""

from datetime import datetime
from uuid import UUID

from sqlalchemy import DDL, CheckConstraint, DateTime, Index, Text, event
from sqlmodel import Field

from database.models import Base, SoftDeleteMixin


class ObservacionAnimal(Base, SoftDeleteMixin, table=True):
    """Nota sobre un animal, independiente de las demás.

    Agregar una no pisa las anteriores y editar una afecta solo a esa. Entidad
    sincronizable: la app la crea offline con su propio UUID y el backend
    resuelve conflictos por ``updated_at`` (last-write-wins). Reemplaza a la
    columna ``animales.observaciones`` (ver adr-0007).
    """

    __tablename__ = "observaciones_animales"
    __table_args__ = (
        CheckConstraint(
            "trim(texto) <> ''", name="ck_observaciones_animales_texto_no_vacio"
        ),
        # Historial de un animal, ordenado por fecha.
        Index("ix_observaciones_animales_fecha", "animal_id", "fecha"),
        # Descarga delta del cliente offline (``updated_since``).
        Index("ix_observaciones_animales_sync", "establecimiento_id", "updated_at"),
    )

    # Inmutables una vez creada: los protege el service y el trigger.
    animal_id: UUID = Field(foreign_key="animales.id")
    establecimiento_id: UUID = Field(foreign_key="establecimientos.id")
    texto: str = Field(sa_type=Text, nullable=False)
    fecha: datetime = Field(sa_type=DateTime(timezone=True), nullable=False)
    # Sale del JWT. Null solo en las notas migradas, cuyo autor no se conoce.
    autor_id: UUID | None = Field(default=None, foreign_key="usuarios.id")


# El animal tiene que ser del mismo establecimiento que la observación, y el
# animal, el establecimiento y el autor no cambian después de crearla. Supabase
# acepta escrituras directas, así que no alcanza con que lo valide el service.
#
# Es ``security invoker``: un trigger BEFORE corre antes que el WITH CHECK del
# RLS, y como definer su error revelaba si un animal ajeno existía. El backend
# (rol ``postgres``, que no pasa por RLS) valida todo. Para un cliente directo,
# la pertenencia del animal la exige la policy de INSERT, con
# ``animal_pertenece_a_establecimiento()`` (migración 20261001_03).
FUNCION_OBSERVACION_ANIMAL = """
create or replace function public.validar_observacion_animal()
returns trigger
language plpgsql
security invoker
set search_path = public, pg_temp
as $$
declare
    v_establecimiento_id uuid;
begin
    if tg_op = 'UPDATE' then
        if new.animal_id <> old.animal_id
           or new.establecimiento_id <> old.establecimiento_id
           or new.autor_id is distinct from old.autor_id then
            raise exception 'Una observación no puede cambiar de animal, establecimiento ni autor'
                using errcode = 'check_violation';
        end if;
        -- Solo el autor edita el texto o la fecha; las notas migradas no tienen
        -- autor y nadie las edita. Owner y admin pasan la policy de UPDATE para
        -- poder borrar, así que la distinción por columna se hace acá. Al backend
        -- (rol postgres) se lo exige el service.
        -- IF anidado a propósito: SQL no garantiza que el AND corte antes, y
        -- auth.uid() no existe fuera de Supabase. plpgsql prepara el IF interno
        -- recién cuando lo ejecuta.
        if current_user = 'authenticated' then
            if (new.texto is distinct from old.texto
                or new.fecha is distinct from old.fecha)
               and new.autor_id is distinct from auth.uid() then
                raise exception 'Solo el autor puede editar esta observación'
                    using errcode = 'insufficient_privilege';
            end if;
        end if;
        return new;
    end if;

    select a.establecimiento_id
      into v_establecimiento_id
      from public.animales a
     where a.id = new.animal_id;

    -- Sin animal visible, deciden la FK (backend) o el RLS (cliente directo):
    -- con security invoker, un cliente no ve animales y el trigger no
    -- distingue "ajeno" de "inexistente".
    if found and v_establecimiento_id <> new.establecimiento_id then
        raise exception 'El animal pertenece a otro establecimiento'
            using errcode = 'check_violation';
    end if;

    return new;
end;
$$
"""

TRIGGERS_OBSERVACION_ANIMAL = (
    "drop trigger if exists trg_observaciones_animales_validar"
    " on public.observaciones_animales",
    """
create trigger trg_observaciones_animales_validar
before insert or update on public.observaciones_animales
for each row execute function public.validar_observacion_animal()
""",
)

# ``create_all`` (LOCAL contra Postgres) también instala el trigger; SQLite no lo
# soporta y en producción lo crea la migración 20261001_03.
for _sentencia in (FUNCION_OBSERVACION_ANIMAL, *TRIGGERS_OBSERVACION_ANIMAL):
    event.listen(
        ObservacionAnimal.__table__,
        "after_create",
        DDL(_sentencia).execute_if(dialect="postgresql"),
    )
