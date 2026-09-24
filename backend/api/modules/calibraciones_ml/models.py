from datetime import datetime
from decimal import Decimal
from uuid import UUID

from sqlalchemy import CheckConstraint, DateTime, Index, Numeric, String
from sqlmodel import Field

from api.shared.enums import EstadoMuestraCalibracion
from database.models import Base, SoftDeleteMixin


def _valores_sql(enum: type[EstadoMuestraCalibracion]) -> str:
    """Lista los valores del enum para un ``CHECK ... IN`` sin duplicar literales.

    Derivarla del enum evita que la restricción de la base y la validación de
    Python queden desalineadas cuando se agrega una variante.
    """
    return ", ".join(f"'{miembro.value}'" for miembro in enum)


class MuestraCalibracion(Base, SoftDeleteMixin, table=True):
    """Par (foto lateral, peso de balanza) que alimenta el reentrenamiento del
    modelo de estimación de peso por visión.

    No es un pesaje: un ``Pesaje`` es el registro productivo del animal y entra
    en la GPD, mientras que esta muestra es dato de entrenamiento y no debe
    afectar ninguna métrica del rodeo. Por eso vive en su propia tabla en vez de
    reusar ``pesajes.foto_url``.
    """

    __tablename__ = "calibraciones_ml"
    __table_args__ = (
        # Sostiene la descarga delta del cliente offline (``updated_since``).
        Index("ix_calibraciones_ml_sync", "establecimiento_id", "updated_at"),
        # La API valida todo esto, pero la base también lo hace: Supabase acepta
        # escrituras directas y esas no pasan por Pydantic.
        CheckConstraint(
            f"estado in ({_valores_sql(EstadoMuestraCalibracion)})",
            name="ck_calibraciones_ml_estado_valido",
        ),
        CheckConstraint(
            "peso_real_kg > 0", name="ck_calibraciones_ml_peso_real_positivo"
        ),
        CheckConstraint(
            "peso_estimado_kg is null or peso_estimado_kg > 0",
            name="ck_calibraciones_ml_peso_estimado_positivo",
        ),
        # Una muestra completa es, por definición, la que tiene su objeto en
        # Storage. Sin esto, una escritura directa podría marcar ``completa`` una
        # fila sin imagen y colarla en el dataset de entrenamiento.
        CheckConstraint(
            "estado <> 'completa' or imagen_key is not null",
            name="ck_calibraciones_ml_completa_exige_imagen",
        ),
        CheckConstraint(
            "imagen_bytes is null or imagen_bytes > 0",
            name="ck_calibraciones_ml_imagen_bytes_positivo",
        ),
    )

    establecimiento_id: UUID = Field(foreign_key="establecimientos.id", index=True)
    animal_id: UUID = Field(foreign_key="animales.id", index=True)

    # Peso leído en la balanza física: es la etiqueta ("ground truth") contra la
    # que se mide el modelo. Nunca se llena con una predicción.
    peso_real_kg: Decimal = Field(sa_type=Numeric(10, 3))
    # Lo que predijo el modelo on-device en el momento de la captura, si ya había
    # un modelo cargado. Opcional y solo informativo: permite ver la deriva del
    # error sin volver a inferir sobre todo el dataset.
    peso_estimado_kg: Decimal | None = Field(default=None, sa_type=Numeric(10, 3))

    fecha_captura: datetime = Field(sa_type=DateTime(timezone=True), nullable=False)

    # Clave del objeto en el bucket privado, NO una URL: una URL pública
    # expondría la foto y una firmada vence, y este registro tiene que seguir
    # resolviendo la imagen dentro de meses, cuando se reentrene.
    imagen_key: str | None = Field(default=None, unique=True)
    # Tamaño del JPEG ya recomprimido. Permite ver cuánto del bucket consume el
    # dataset sin listar Storage.
    imagen_bytes: int | None = None

    estado: EstadoMuestraCalibracion = Field(
        default=EstadoMuestraCalibracion.pendiente_imagen,
        sa_type=String,
        nullable=False,
    )

    responsable_id: UUID | None = Field(default=None, foreign_key="usuarios.id")
    observaciones: str | None = None
