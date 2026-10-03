from datetime import date
from uuid import UUID

from sqlalchemy import DDL, CheckConstraint, String, event
from sqlmodel import Field

from api.shared.enums import EstadoAnimal, EstadoReproductivo, SexoAnimal
from database.models import Base, SoftDeleteMixin


def _valores_sql(enum: type[EstadoReproductivo]) -> str:
    """Lista los valores del enum para un ``CHECK ... IN`` sin duplicar literales."""
    return ", ".join(f"'{miembro.value}'" for miembro in enum)


class Animal(Base, SoftDeleteMixin, table=True):
    __tablename__ = "animales"
    __table_args__ = (
        CheckConstraint(
            "estado_reproductivo is null"
            f" or estado_reproductivo in ({_valores_sql(EstadoReproductivo)})",
            name="ck_animales_estado_reproductivo_valido",
        ),
        # Un macho nunca tiene condición reproductiva. La compatibilidad con la
        # categoría necesita consultar otra tabla y por eso vive en un trigger
        # (migración 20261001_02), no en un CHECK.
        CheckConstraint(
            "estado_reproductivo is null or sexo = 'hembra'",
            name="ck_animales_estado_reproductivo_solo_hembras",
        ),
    )

    establecimiento_id: UUID = Field(foreign_key="establecimientos.id", index=True)
    # Identificación electrónica RFID: única a nivel nacional (SENASA 530/2025).
    nro_caravana_rfid: str | None = Field(default=None, unique=True, index=True)
    caravana_visual: str | None = None
    sexo: SexoAnimal = Field(sa_type=String, nullable=False)
    raza: str | None = None
    fecha_nacimiento: date | None = None
    categoria_id: UUID | None = Field(default=None, foreign_key="categorias.id")
    lote_id: UUID | None = Field(default=None, foreign_key="lotes.id", index=True)
    padre_id: UUID | None = Field(default=None, foreign_key="animales.id")
    madre_id: UUID | None = Field(default=None, foreign_key="animales.id")
    pelaje: str | None = None
    estado: EstadoAnimal = Field(
        default=EstadoAnimal.activo, sa_type=String, nullable=False
    )
    # Separado de ``estado``: un animal puede estar ``activo`` y ``prenada``.
    estado_reproductivo: EstadoReproductivo | None = Field(
        default=None, sa_type=String, nullable=True
    )
    # Obsoleta: las notas viven en ``observaciones_animales``. Se conserva
    # mientras haya clientes que la escriben (ver adr-0007).
    observaciones: str | None = None


# Compatibilidad del animal con su categoría. Es lógica entre tablas, así que no
# puede ser un CHECK: vive en un trigger porque Supabase acepta escrituras
# directas que no pasan por el service. ``for share`` bloquea la categoría hasta
# el commit, de modo que un cambio concurrente de sus reglas espera y luego ve
# este animal.
#
# Es ``security invoker`` a propósito. El trigger corre ANTES que el WITH CHECK
# del RLS: con ``security definer`` leería categorías que quien escribe no puede
# ver, y su mensaje de error revelaría que existen y cuáles son sus reglas. Como
# invoker, el backend (rol ``postgres``, que no pasa por RLS) valida todo, y un
# cliente directo solo valida contra lo que ya ve; el rechazo es el del RLS.
FUNCION_CATEGORIA_COMPATIBLE = """
create or replace function public.validar_categoria_animal()
returns trigger
language plpgsql
security invoker
set search_path = public, pg_temp
as $$
declare
    v_establecimiento_id uuid;
    v_sexo_permitido varchar;
    v_permite boolean;
    v_borrada timestamptz;
begin
    if new.categoria_id is null then
        if new.estado_reproductivo in ('vacia', 'prenada') then
            raise exception 'La condición reproductiva requiere una categoría habilitada'
                using errcode = 'check_violation';
        end if;
        return new;
    end if;

    select c.establecimiento_id, c.sexo_permitido,
           c.permite_estado_reproductivo, c.deleted_at
      into v_establecimiento_id, v_sexo_permitido, v_permite, v_borrada
      from public.categorias c
     where c.id = new.categoria_id
       for share;

    -- Sin categoría visible, la FK o el RLS rechazan la fila. Con security
    -- invoker, un cliente directo no ve categorías ajenas: el trigger no
    -- distingue "ajena" de "inexistente" y no revela sus reglas.
    if not found then
        return new;
    end if;

    -- Pertenencia y borrado se exigen solo al asignar: una categoría que se
    -- borra después no debe trabar la edición de otros campos del animal.
    if tg_op = 'INSERT' or new.categoria_id is distinct from old.categoria_id then
        if v_borrada is not null then
            raise exception 'No se puede asignar una categoría eliminada'
                using errcode = 'check_violation';
        end if;
        if v_establecimiento_id is not null
           and v_establecimiento_id <> new.establecimiento_id then
            raise exception 'La categoría pertenece a otro establecimiento'
                using errcode = 'check_violation';
        end if;
    end if;

    if v_sexo_permitido <> 'ambos' and v_sexo_permitido <> new.sexo then
        raise exception 'La categoría seleccionada no es compatible con el sexo del animal'
            using errcode = 'check_violation';
    end if;

    if new.estado_reproductivo in ('vacia', 'prenada') and not v_permite then
        raise exception 'La categoría del animal no admite condición reproductiva'
            using errcode = 'check_violation';
    end if;

    return new;
end;
$$
"""

TRIGGERS_CATEGORIA_COMPATIBLE = (
    "drop trigger if exists trg_animales_categoria_compatible on public.animales",
    """
create trigger trg_animales_categoria_compatible
before insert or update of sexo, categoria_id, estado_reproductivo, deleted_at
on public.animales
for each row execute function public.validar_categoria_animal()
""",
)

# ``create_all`` (LOCAL contra Postgres) también instala el trigger; SQLite no lo
# soporta y en producción lo crea la migración 20261001_02.
for _sentencia in (FUNCION_CATEGORIA_COMPATIBLE, *TRIGGERS_CATEGORIA_COMPATIBLE):
    event.listen(
        Animal.__table__,
        "after_create",
        DDL(_sentencia).execute_if(dialect="postgresql"),
    )
