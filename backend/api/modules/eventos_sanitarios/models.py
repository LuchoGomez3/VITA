"""Eventos sanitarios y las operaciones con las que se registraron (VITA-20).

Un operario registra una práctica sobre uno o varios animales: la operación de
alta crea un evento por animal. Cada fila guarda una foto de la práctica y del
producto aplicado (nombre y datos), así el historial se sigue leyendo aunque el
catálogo cambie. Las decisiones están en
``docs/adr/adr-0017-eventos-sanitarios-por-operacion.md``.
"""

from datetime import date, datetime
from typing import Any
from uuid import UUID

from sqlalchemy import (
    JSON,
    BigInteger,
    CheckConstraint,
    DateTime,
    Index,
    String,
    UniqueConstraint,
)
from sqlalchemy.dialects.postgresql import JSONB
from sqlmodel import Field

from api.shared.enums import TipoEventoSanitario
from database.models import Base, SoftDeleteMixin


class EventoSanitario(Base, SoftDeleteMixin, table=True):
    __tablename__ = "eventos_sanitarios"
    __table_args__ = (
        # Feed incremental por establecimiento: el cursor es ``version``.
        UniqueConstraint(
            "establecimiento_id", "version", name="uq_eventos_sanitarios_version"
        ),
        Index("ix_eventos_sanitarios_historial", "animal_id", "fecha_aplicacion"),
        Index("ix_eventos_sanitarios_operacion", "operacion_id"),
        CheckConstraint(
            "practica_modelo is null"
            " or practica_modelo in ('aplicacion', 'muestreo', 'lesion')",
            name="ck_eventos_sanitarios_practica_modelo",
        ),
    )

    establecimiento_id: UUID = Field(foreign_key="establecimientos.id", index=True)
    animal_id: UUID = Field(foreign_key="animales.id", index=True)
    tipo: TipoEventoSanitario = Field(sa_type=String, nullable=False)
    producto_id: UUID | None = Field(
        default=None, foreign_key="productos_sanitarios.id"
    )
    fecha_aplicacion: datetime = Field(sa_type=DateTime(timezone=True), nullable=False)
    dosis: str | None = None
    periodo_carencia_dias: int | None = None
    fecha_fin_carencia: date | None = None
    resultado: str | None = None
    # Legado: autor del esquema anterior. Las altas nuevas usan
    # ``registrado_por_id`` (del JWT) y ``responsable`` (texto del operario).
    responsable_id: UUID | None = Field(default=None, foreign_key="usuarios.id")
    observaciones: str | None = None

    # --- Operación de alta (null solo en filas anteriores a VITA-20) ---
    operacion_id: UUID | None = Field(default=None)
    practica_id: str | None = Field(default=None, max_length=60)
    practica_nombre: str | None = Field(default=None, max_length=120)
    practica_modelo: str | None = Field(default=None, max_length=20)
    datos: dict[str, Any] | None = Field(
        default=None, sa_type=JSON().with_variant(JSONB(), "postgresql")
    )
    caravana: str | None = Field(default=None, max_length=60)
    lote_id: UUID | None = Field(default=None, foreign_key="lotes.id")
    referencia_muestra: str | None = Field(default=None, max_length=60)
    responsable: str | None = Field(default=None, max_length=120)
    registrado_por_id: UUID | None = Field(default=None, foreign_key="usuarios.id")

    # --- Primer resultado de un estudio ---
    resultado_fecha: datetime | None = Field(
        default=None, sa_type=DateTime(timezone=True)
    )
    resultado_registrado_por_id: UUID | None = Field(
        default=None, foreign_key="usuarios.id"
    )
    resultado_operacion_id: UUID | None = Field(default=None)

    # Orden del feed, asignado por el servidor en cada cambio confirmado.
    version: int | None = Field(default=None, sa_type=BigInteger)


class OperacionSanitaria(Base, table=True):
    """Envío aceptado (alta o resultado), para responder reenvíos sin duplicar.

    El ``id`` es el UUID de operación que genera el celular. ``huella`` es el
    hash del cuerpo: el mismo UUID con otro cuerpo es un conflicto.
    """

    __tablename__ = "operaciones_sanitarias"
    __table_args__ = (
        CheckConstraint(
            "tipo in ('alta', 'resultado')", name="ck_operaciones_sanitarias_tipo"
        ),
    )

    establecimiento_id: UUID = Field(foreign_key="establecimientos.id", index=True)
    tipo: str = Field(max_length=20)
    evento_id: UUID | None = Field(default=None, foreign_key="eventos_sanitarios.id")
    huella: str = Field(max_length=64)
    usuario_id: UUID = Field(foreign_key="usuarios.id")
