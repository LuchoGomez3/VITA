"""Historial del recurso forrajero de cada lote (potrero).

Cada fila dice "desde tal fecha, este potrero tiene tal recurso". El período no
necesita cerrarse a mano: termina el día anterior al siguiente período del mismo
lote (``fecha_hasta`` explícita solo hace falta para un corte, por ejemplo un
verdeo que se terminó y dejó el potrero sin recurso). Así un cambio de recurso es
una sola fila y dos dispositivos offline solo chocan si cargan el mismo lote con
la misma fecha. Ver ``docs/adr/adr-0015-alimentacion-pastoreo-derivado-y-registros.md``.
"""

from datetime import date
from uuid import UUID

from sqlalchemy import CheckConstraint, Date, Index, String, text
from sqlmodel import Field

from api.shared.enums import RecursoForrajero
from database.models import Base, SoftDeleteMixin


def _valores_sql() -> str:
    return ", ".join(f"'{miembro.value}'" for miembro in RecursoForrajero)


class PeriodoRecursoForrajero(Base, SoftDeleteMixin, table=True):
    __tablename__ = "lotes_recursos_forrajeros"
    __table_args__ = (
        CheckConstraint(
            f"recurso_forrajero_codigo in ({_valores_sql()})",
            name="ck_lotes_recursos_forrajeros_codigo_valido",
        ),
        CheckConstraint(
            "fecha_hasta is null or fecha_hasta >= fecha_desde",
            name="ck_lotes_recursos_forrajeros_fechas",
        ),
        CheckConstraint(
            "descripcion is null or trim(descripcion) <> ''",
            name="ck_lotes_recursos_forrajeros_descripcion_no_vacia",
        ),
        Index("ix_lotes_recursos_forrajeros_sync", "establecimiento_id", "updated_at"),
        Index("ix_lotes_recursos_forrajeros_lote", "lote_id", "fecha_desde"),
        # Un solo período vigente por lote y fecha de inicio. Parcial para que un
        # período borrado libere la fecha.
        Index(
            "uq_lotes_recursos_forrajeros_lote_desde",
            "lote_id",
            "fecha_desde",
            unique=True,
            postgresql_where=text("deleted_at is null"),
            sqlite_where=text("deleted_at is null"),
        ),
    )

    # Denormalizado desde el lote: lo necesitan el RLS y el pull por establecimiento.
    establecimiento_id: UUID = Field(foreign_key="establecimientos.id", index=True)
    lote_id: UUID = Field(foreign_key="lotes.id")
    recurso_forrajero_codigo: RecursoForrajero = Field(sa_type=String, nullable=False)
    # Detalle libre ("Alfalfa + festuca"); obligatorio cuando el código es ``otro``.
    descripcion: str | None = None
    fecha_desde: date = Field(sa_type=Date, nullable=False)
    fecha_hasta: date | None = Field(default=None, sa_type=Date)
    # Sale del JWT. Null en los períodos migrados desde ``lotes``.
    registrado_por_id: UUID | None = Field(default=None, foreign_key="usuarios.id")
