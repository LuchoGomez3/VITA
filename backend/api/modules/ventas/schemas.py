"""DTOs y validaciones del contrato HTTP de ventas de hacienda."""

from datetime import date, datetime, timedelta, timezone
from decimal import Decimal
from typing import Self
from uuid import UUID
from zoneinfo import ZoneInfo, ZoneInfoNotFoundError

from pydantic import BaseModel, ConfigDict, Field, field_validator, model_validator

from api.shared.enums import (
    CondicionCobro,
    EstadoCobro,
    TipoComprador,
    TipoVenta,
)
from api.shared.schemas import SyncFields

try:
    ZONA_HORARIA_NEGOCIO = ZoneInfo("America/Argentina/Cordoba")
except ZoneInfoNotFoundError:
    # Windows puede no incluir la base IANA. Argentina mantiene UTC-03 sin DST.
    ZONA_HORARIA_NEGOCIO = timezone(timedelta(hours=-3))


def _normalizar_texto(valor: str) -> str:
    """Quita espacios exteriores y compacta separaciones internas repetidas."""
    return " ".join(valor.split())


def _es_nombre_persona(valor: str) -> bool:
    """Admite letras Unicode y espacios, pero no números ni símbolos."""
    return all(caracter.isalpha() or caracter == " " for caracter in valor)


class VentaCreate(SyncFields):
    """Alta idempotente de una venta creada en mobile o desde un cliente online."""

    # La identidad nace en mobile y permite reintentar sin duplicar la operación.
    id: UUID
    establecimiento_id: UUID
    fecha_operacion: date
    tipo_comprador: TipoComprador
    nombre_comprador: str
    es_empresa: bool
    apellido_comprador: str | None = None
    nro_dte: str
    tipo_venta: TipoVenta
    peso_total_kg: Decimal | None = None
    precio_por_kg: Decimal | None = None
    monto_total: Decimal
    observaciones: str | None = None
    animal_ids: list[UUID] = Field(min_length=1)
    condicion_cobro: CondicionCobro
    monto_cobrado_inicial: Decimal | None = None

    @field_validator("fecha_operacion")
    @classmethod
    def validar_fecha_operacion(cls, fecha_operacion: date) -> date:
        """Permite carga diferida, pero nunca una venta con fecha futura."""
        hoy = datetime.now(ZONA_HORARIA_NEGOCIO).date()
        if fecha_operacion > hoy:
            raise ValueError("No se pueden registrar ventas con fecha futura")
        return fecha_operacion

    @field_validator("nombre_comprador")
    @classmethod
    def validar_nombre_comprador(cls, nombre: str) -> str:
        valor = _normalizar_texto(nombre)
        if not valor:
            raise ValueError("El nombre o razón social del comprador es obligatorio")
        return valor

    @field_validator("apellido_comprador")
    @classmethod
    def normalizar_apellido_comprador(cls, apellido: str | None) -> str | None:
        if apellido is None:
            return None
        valor = _normalizar_texto(apellido)
        if not valor:
            raise ValueError("El apellido del comprador no puede estar vacío")
        return valor

    @field_validator("nro_dte")
    @classmethod
    def validar_nro_dte(cls, nro_dte: str) -> str:
        if not nro_dte or any(digito not in "0123456789" for digito in nro_dte):
            raise ValueError("El número de DTe debe contener solamente dígitos")
        return nro_dte

    @field_validator("monto_total")
    @classmethod
    def validar_monto_total(cls, monto: Decimal) -> Decimal:
        if not monto.is_finite() or monto <= 0:
            raise ValueError("El monto total debe ser mayor a cero")
        return monto

    @field_validator("peso_total_kg", "precio_por_kg", "monto_cobrado_inicial")
    @classmethod
    def validar_decimal_opcional(cls, valor: Decimal | None) -> Decimal | None:
        if valor is not None and (not valor.is_finite() or valor <= 0):
            raise ValueError("El valor debe ser mayor a cero")
        return valor

    @field_validator("animal_ids")
    @classmethod
    def validar_animales_sin_repetidos(cls, animal_ids: list[UUID]) -> list[UUID]:
        if len(set(animal_ids)) != len(animal_ids):
            raise ValueError("La lista de animales tiene IDs repetidos")
        return animal_ids

    @field_validator("observaciones")
    @classmethod
    def normalizar_observaciones(cls, observaciones: str | None) -> str | None:
        if observaciones is None:
            return None
        return _normalizar_texto(observaciones) or None

    @model_validator(mode="after")
    def validar_comprador(self) -> Self:
        """Aplica reglas distintas a persona física y razón social."""
        if self.es_empresa:
            if self.apellido_comprador is not None:
                raise ValueError(
                    "El apellido no corresponde cuando el comprador es empresa"
                )
            return self

        if self.apellido_comprador is None:
            raise ValueError("El apellido es obligatorio para una persona física")
        if not _es_nombre_persona(self.nombre_comprador):
            raise ValueError(
                "El nombre de una persona física debe contener solamente letras"
            )
        if not _es_nombre_persona(self.apellido_comprador):
            raise ValueError(
                "El apellido de una persona física debe contener solamente letras"
            )
        return self

    @model_validator(mode="after")
    def validar_modalidad_venta(self) -> Self:
        """Evita combinar campos económicos de modalidades incompatibles."""
        if self.tipo_venta == TipoVenta.al_bulto:
            if self.peso_total_kg is not None or self.precio_por_kg is not None:
                raise ValueError(
                    "Una venta al bulto no debe incluir peso ni precio por kilo"
                )
            return self

        if self.peso_total_kg is None or self.precio_por_kg is None:
            raise ValueError("Una venta por kilo requiere peso total y precio por kilo")
        return self

    @model_validator(mode="after")
    def validar_cobro_inicial(self) -> Self:
        """El importe manual solo existe cuando el usuario selecciona parcial."""
        if self.condicion_cobro == CondicionCobro.parcial:
            if self.monto_cobrado_inicial is None:
                raise ValueError("El monto cobrado es obligatorio para un pago parcial")
            if self.monto_cobrado_inicial >= self.monto_total:
                raise ValueError(
                    "El monto parcial debe ser menor que el total de la venta"
                )
            return self

        if self.monto_cobrado_inicial is not None:
            raise ValueError(
                "El monto cobrado manual solo corresponde a un pago parcial"
            )
        return self


class VentaRead(BaseModel):
    """Representación autoritativa de la venta y su situación de cobro."""

    model_config = ConfigDict(from_attributes=True)

    id: UUID
    establecimiento_id: UUID
    fecha_operacion: date
    tipo_comprador: TipoComprador
    nombre_comprador: str
    es_empresa: bool
    apellido_comprador: str | None
    nro_dte: str
    tipo_venta: TipoVenta
    peso_total_kg: Decimal | None
    precio_por_kg: Decimal | None
    monto_total: Decimal
    observaciones: str | None
    registrada_por_id: UUID
    animal_ids: list[UUID]
    monto_cobrado: Decimal
    saldo_pendiente: Decimal
    estado_cobro: EstadoCobro
    created_at: datetime
    updated_at: datetime
    deleted_at: datetime | None
