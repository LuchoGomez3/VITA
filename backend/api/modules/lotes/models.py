"""Modelo persistente del lote (potrero) y su geometría esquemática."""

from decimal import Decimal
from typing import Any
from uuid import UUID

from sqlalchemy import JSON, CheckConstraint, Index, Numeric, String, text
from sqlalchemy.dialects.postgresql import JSONB
from sqlmodel import Field

from api.shared.enums import EstadoLote, RecursoForrajero
from database.models import Base, SoftDeleteMixin

# JSONB en Postgres (indexable, comparable) y JSON en el resto: los tests corren
# sobre SQLite, que no conoce el tipo del dialecto de Postgres.
GEOMETRIA_TYPE = JSON().with_variant(JSONB, "postgresql")

MODO_GEOMETRIA_LOCAL = "local_schematic"


def _valores_sql(enum: type[EstadoLote] | type[RecursoForrajero]) -> str:
    """Lista los valores del enum para un ``CHECK ... IN`` sin duplicar literales."""
    return ", ".join(f"'{miembro.value}'" for miembro in enum)


class Lote(Base, SoftDeleteMixin, table=True):
    """División física del establecimiento donde pastorea un rodeo.

    Entidad sincronizable: la app la crea offline con su propio UUID y el backend
    resuelve conflictos por ``updated_at`` (last-write-wins).

    ``geometria_local`` NO es geografía. Es un polígono en un plano cartesiano
    común a los lotes del establecimiento, de extensión lógica 1000x1000, que
    permite dibujar el campo sin mapa, sin GPS y sin conectividad. Sus ``x``/``y``
    jamás deben interpretarse como longitud/latitud. La geometría geográfica real
    (GeoJSON WGS84 sobre PostGIS) será una columna aparte cuando exista mapa; esta
    seguirá siendo el fallback offline. Ver
    ``docs/adr/adr-0002-geometria-y-movimientos-de-lotes.md``.
    """

    __tablename__ = "lotes"
    __table_args__ = (
        # La API valida el enum, pero la base también: Supabase acepta escrituras
        # directas y esas no pasan por Pydantic.
        CheckConstraint(
            f"estado in ({_valores_sql(EstadoLote)})",
            name="ck_lotes_estado_valido",
        ),
        CheckConstraint(
            "recurso_forrajero_codigo is null"
            f" or recurso_forrajero_codigo in ({_valores_sql(RecursoForrajero)})",
            name="ck_lotes_recurso_forrajero_valido",
        ),
        CheckConstraint("superficie_ha > 0", name="ck_lotes_superficie_positiva"),
        CheckConstraint("trim(nombre) <> ''", name="ck_lotes_nombre_no_vacio"),
        # El cliente offline descarga su delta filtrando por establecimiento y
        # ``updated_at``; este es el índice que sostiene esa consulta.
        Index("ix_lotes_sync", "establecimiento_id", "updated_at"),
        # Unicidad de nombre normalizada y compatible con el borrado lógico:
        # "Potrero Bajo" y " potrero bajo " colisionan, pero borrar un lote
        # libera su nombre. El service igual lo verifica antes de escribir; esto
        # es la defensa contra dos dispositivos que sincronizan a la vez.
        Index(
            "uq_lotes_nombre_establecimiento",
            "establecimiento_id",
            text("lower(trim(nombre))"),
            unique=True,
            postgresql_where=text("deleted_at is null"),
            sqlite_where=text("deleted_at is null"),
        ),
    )

    establecimiento_id: UUID = Field(foreign_key="establecimientos.id", index=True)
    nombre: str
    # Se persiste y se devuelve verbatim: si el backend reordena claves o
    # normaliza ``extent``, el cliente no puede releer el polígono que dibujó.
    geometria_local: dict[str, Any] = Field(sa_type=GEOMETRIA_TYPE, nullable=False)
    # Discrimina qué sistema de coordenadas describe ``geometria_local``. Hoy solo
    # existe ``local_schematic``; el día que haya geometría geográfica, este campo
    # dice cuál de las dos es la vigente para el lote.
    modo_geometria: str = Field(default=MODO_GEOMETRIA_LOCAL, nullable=False)
    # Autoridad a un decimal: el cliente la guarda en décimas exactas de hectárea.
    superficie_ha: Decimal = Field(sa_type=Numeric(12, 2), nullable=False)
    # Código de catálogo, no etiqueta visible. Distinto de ``plan_alimenticio_id``:
    # uno describe qué se come en el potrero, el otro una dieta planificada.
    recurso_forrajero_codigo: RecursoForrajero | None = Field(
        default=None, sa_type=String
    )
    tiene_agua: bool = Field(default=False, nullable=False)
    estado: EstadoLote = Field(default=EstadoLote.activo, sa_type=String)
    plan_alimenticio_id: UUID | None = Field(
        default=None, foreign_key="planes_alimenticios.id"
    )
