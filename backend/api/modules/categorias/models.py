from uuid import UUID

from sqlalchemy import DDL, CheckConstraint, String, event, false
from sqlmodel import Field

from api.shared.enums import SexoPermitido
from database.models import Base, SoftDeleteMixin


def _valores_sql(enum: type[SexoPermitido]) -> str:
    """Lista los valores del enum para un ``CHECK ... IN`` sin duplicar literales."""
    return ", ".join(f"'{miembro.value}'" for miembro in enum)


class Categoria(Base, SoftDeleteMixin, table=True):
    __tablename__ = "categorias"
    __table_args__ = (
        # La API valida el enum, pero la base también: Supabase acepta escrituras
        # directas y esas no pasan por Pydantic.
        CheckConstraint(
            f"sexo_permitido in ({_valores_sql(SexoPermitido)})",
            name="ck_categorias_sexo_permitido_valido",
        ),
    )

    # null = catálogo global; con valor = categoría propia del establecimiento.
    establecimiento_id: UUID | None = Field(
        default=None, foreign_key="establecimientos.id", index=True
    )
    nombre: str
    descripcion: str | None = None
    # Reglas explícitas de la categoría: nunca se infieren de su nombre. Que un
    # macho no pueda ser "Vaca" lo decide este atributo, no la palabra.
    sexo_permitido: SexoPermitido = Field(sa_type=String, nullable=False)
    # Solo las categorías habilitadas admiten ``vacia``/``prenada`` en sus hembras.
    permite_estado_reproductivo: bool = Field(
        default=False,
        nullable=False,
        sa_column_kwargs={"server_default": false()},
    )


# Cierra el invariante por la otra punta: cambiar las reglas de una categoría no
# puede dejar animales vivos incompatibles. Misma condición que
# ``CategoriaRepository.contar_animales_incompatibles``.
FUNCION_REGLAS_CATEGORIA = """
create or replace function public.validar_reglas_categoria()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
    v_incompatibles integer;
begin
    if new.sexo_permitido = old.sexo_permitido
       and new.permite_estado_reproductivo = old.permite_estado_reproductivo then
        return new;
    end if;

    select count(*)
      into v_incompatibles
      from public.animales a
     where a.categoria_id = new.id
       and a.deleted_at is null
       and (
            (new.sexo_permitido <> 'ambos' and a.sexo <> new.sexo_permitido)
            or (not new.permite_estado_reproductivo
                and a.estado_reproductivo in ('vacia', 'prenada'))
       );

    if v_incompatibles > 0 then
        raise exception 'Hay % animal(es) que quedarían incompatibles con la categoría',
            v_incompatibles
            using errcode = 'check_violation';
    end if;

    return new;
end;
$$
"""

TRIGGERS_REGLAS_CATEGORIA = (
    "drop trigger if exists trg_categorias_reglas_compatibles on public.categorias",
    """
create trigger trg_categorias_reglas_compatibles
before update of sexo_permitido, permite_estado_reproductivo
on public.categorias
for each row execute function public.validar_reglas_categoria()
""",
)

for _sentencia in (FUNCION_REGLAS_CATEGORIA, *TRIGGERS_REGLAS_CATEGORIA):
    event.listen(
        Categoria.__table__,
        "after_create",
        DDL(_sentencia).execute_if(dialect="postgresql"),
    )
