"""DTOs y validaciones del contrato HTTP de ventas de hacienda."""

from datetime import date, datetime, timedelta, timezone
from decimal import ROUND_DOWN, Decimal
from typing import Self
from uuid import UUID
from zoneinfo import ZoneInfo, ZoneInfoNotFoundError

from pydantic import BaseModel, ConfigDict, Field, field_validator, model_validator

from api.shared.enums import (
    CondicionCobro,
    EstadoCobro,
    MedioCobro,
    TipoComprador,
    TipoVenta,
)
from api.shared.schemas import SyncFields

try:
    ZONA_HORARIA_NEGOCIO = ZoneInfo("America/Argentina/Cordoba")
except ZoneInfoNotFoundError:
    # Windows puede no incluir la base IANA. Argentina mantiene UTC-03 sin DST.
    ZONA_HORARIA_NEGOCIO = timezone(timedelta(hours=-3))

PRECISION_MONETARIA = Decimal("0.01")
PRECISION_PESO_KG = Decimal("0.001")
PRECISION_PRECIO_UNITARIO = Decimal("0.000001")


def _normalizar_texto(valor: str) -> str:
    """Quita espacios exteriores y compacta separaciones internas repetidas."""
    return " ".join(valor.split())


def _es_nombre_persona(valor: str) -> bool:
    """Admite letras Unicode y espacios, pero no números ni símbolos."""
    return all(caracter.isalpha() or caracter == " " for caracter in valor)


def _normalizar_decimal_positivo(
    valor: Decimal,
    precision: Decimal,
    nombre: str,
) -> Decimal:
    """Valida la escala antes de representarla con la precisión de la base."""
    if not valor.is_finite():
        raise ValueError(f"{nombre} debe ser un número finito")
    if valor <= 0:
        raise ValueError(f"{nombre} debe ser mayor a cero")
    decimales = max(0, -valor.normalize().as_tuple().exponent)
    decimales_admitidos = max(0, -precision.as_tuple().exponent)
    if decimales > decimales_admitidos:
        raise ValueError(
            f"{nombre} admite hasta {decimales_admitidos} decimales; "
            "el valor no se redondeó"
        )
    return valor.quantize(precision)


class VentaCobroInicialCreate(SyncFields):
    """Cobro efectivo que nace junto con una venta total o parcial."""

    # Mobile genera esta identidad aun sin conexión para reintentar sin duplicar.
    id: UUID
    fecha_cobro: date
    monto: Decimal
    medio_cobro: MedioCobro
    observaciones: str | None = None

    @field_validator("fecha_cobro")
    @classmethod
    def validar_fecha_cobro(cls, fecha_cobro: date) -> date:
        hoy = datetime.now(ZONA_HORARIA_NEGOCIO).date()
        if fecha_cobro > hoy:
            raise ValueError("La fecha de cobro no puede ser futura")
        return fecha_cobro

    @field_validator("monto")
    @classmethod
    def validar_monto(cls, monto: Decimal) -> Decimal:
        return _normalizar_decimal_positivo(
            monto,
            PRECISION_MONETARIA,
            "El monto cobrado",
        )

    @field_validator("observaciones")
    @classmethod
    def normalizar_observaciones(cls, observaciones: str | None) -> str | None:
        if observaciones is None:
            return None
        return _normalizar_texto(observaciones) or None

    @model_validator(mode="after")
    def validar_cobro_activo(self) -> Self:
        if self.deleted_at is not None:
            raise ValueError("El cobro inicial no puede registrarse anulado")
        return self


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
    cobro_inicial: VentaCobroInicialCreate | None = None

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
        return _normalizar_decimal_positivo(
            monto,
            PRECISION_MONETARIA,
            "El monto total",
        )

    @field_validator("peso_total_kg")
    @classmethod
    def validar_peso_total(cls, valor: Decimal | None) -> Decimal | None:
        if valor is None:
            return None
        return _normalizar_decimal_positivo(
            valor,
            PRECISION_PESO_KG,
            "El peso total",
        )

    @field_validator("precio_por_kg")
    @classmethod
    def validar_precio_por_kg(cls, valor: Decimal | None) -> Decimal | None:
        if valor is None:
            return None
        return _normalizar_decimal_positivo(
            valor,
            PRECISION_PRECIO_UNITARIO,
            "El precio por kilo",
        )

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
        monto_calculado = (self.peso_total_kg * self.precio_por_kg).quantize(
            PRECISION_MONETARIA,
            rounding=ROUND_DOWN,
        )
        if self.monto_total != monto_calculado:
            raise ValueError(
                "El monto total debe coincidir con el peso de venta multiplicado "
                "por el precio por kilo"
            )
        return self

    @model_validator(mode="after")
    def validar_cobro_inicial(self) -> Self:
        """Relaciona la condición elegida con el dinero realmente recibido."""
        if self.condicion_cobro == CondicionCobro.total:
            if self.cobro_inicial is None:
                raise ValueError("El cobro inicial es obligatorio para un pago total")
            if self.cobro_inicial.monto != self.monto_total:
                raise ValueError(
                    "El monto cobrado debe coincidir con el total de la venta"
                )
            return self

        if self.condicion_cobro == CondicionCobro.parcial:
            if self.cobro_inicial is None:
                raise ValueError("El cobro inicial es obligatorio para un pago parcial")
            if self.cobro_inicial.monto >= self.monto_total:
                raise ValueError(
                    "El monto parcial debe ser menor que el total de la venta"
                )
            return self

        if self.cobro_inicial is not None:
            raise ValueError("Una venta pendiente no debe incluir un cobro inicial")
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
