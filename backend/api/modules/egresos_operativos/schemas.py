"""DTOs y validaciones del contrato HTTP de egresos operativos."""

from datetime import date, datetime
from decimal import Decimal
from uuid import UUID
from zoneinfo import ZoneInfo

from pydantic import BaseModel, ConfigDict, field_validator

from api.shared.enums import CategoriaEgresoOperativo, TipoEgresoOperativo
from api.shared.schemas import SyncFields

# La fecha contable se valida según el día civil donde opera el producto.
ZONA_HORARIA_NEGOCIO = ZoneInfo("America/Argentina/Cordoba")

# Esta matriz define el catálogo base que usa la API. Debe mantenerse sincronizada
# con `validar_categoria_egreso_operativo()` en scripts/crear_egresos_operativos.sql;
# `test_catalogo_base_coincide_con_trigger_postgresql` protege ese contrato en CI.
CATEGORIAS_POR_TIPO = {
    TipoEgresoOperativo.costo_produccion: {
        CategoriaEgresoOperativo.sanidad,
        CategoriaEgresoOperativo.alimentacion,
        CategoriaEgresoOperativo.identificacion,
    },
    TipoEgresoOperativo.gasto_administrativo: {
        CategoriaEgresoOperativo.combustible,
        CategoriaEgresoOperativo.estructura,
        CategoriaEgresoOperativo.honorarios,
    },
}


class EgresoOperativoCreate(SyncFields):
    """Alta local o en línea; acepta UUID y marcas temporales generadas offline."""

    establecimiento_id: UUID
    monto: Decimal
    tipo: TipoEgresoOperativo
    categoria: str
    insumo: str
    fecha: date
    descripcion: str | None = None
    numero_comprobante: str | None = None

    @field_validator("monto")
    @classmethod
    def validar_monto(cls, monto: Decimal) -> Decimal:
        """Rechaza importes nulos o negativos antes de persistirlos."""
        if monto <= 0:
            raise ValueError("El monto ingresado debe ser un valor mayor a cero")
        return monto

    @field_validator("insumo")
    @classmethod
    def validar_insumo(cls, insumo: str) -> str:
        """Normaliza el insumo y evita textos vacíos usados como dato obligatorio."""
        valor = insumo.strip()
        if not valor:
            raise ValueError("El insumo es obligatorio")
        return valor

    @field_validator("fecha")
    @classmethod
    def validar_fecha(cls, fecha_egreso: date) -> date:
        """Permite carga diferida pero nunca movimientos con fecha futura."""
        hoy = datetime.now(ZONA_HORARIA_NEGOCIO).date()
        if fecha_egreso > hoy:
            raise ValueError("No se pueden registrar egresos con fecha futura")
        return fecha_egreso

    @field_validator("categoria")
    @classmethod
    def validar_categoria(cls, categoria: str) -> str:
        """Normaliza el identificador que luego se valida contra el catálogo tenant."""
        valor = categoria.strip().lower()
        if not valor:
            raise ValueError("La categoría es obligatoria")
        return valor


class UsuarioAuditoriaRead(BaseModel):
    """Identidad visible de quien registró el movimiento, sin datos sensibles."""

    id: UUID
    nombre: str
    apellido: str
    email: str


class EgresoOperativoRead(BaseModel):
    """Representación completa para historial, auditoría y descarga delta."""

    model_config = ConfigDict(from_attributes=True)

    id: UUID
    establecimiento_id: UUID
    monto: Decimal
    tipo: TipoEgresoOperativo
    categoria: str
    insumo: str
    fecha: date
    descripcion: str | None
    numero_comprobante: str | None
    cargado_por_id: UUID
    cargado_por: UsuarioAuditoriaRead
    created_at: datetime
    updated_at: datetime
    deleted_at: datetime | None


class CategoriaEgresoRead(BaseModel):
    """Opción de catálogo con valor estable y etiqueta para presentar en la UI."""

    valor: str
    etiqueta: str
    personalizada: bool = False


class CategoriaEgresoCreate(SyncFields):
    """Alta sincronizable de una categoría propia de un establecimiento."""

    establecimiento_id: UUID
    tipo: TipoEgresoOperativo
    nombre: str

    @field_validator("nombre")
    @classmethod
    def validar_nombre(cls, nombre: str) -> str:
        """Evita categorías vacías y limita etiquetas excesivamente largas."""
        valor = " ".join(nombre.split())
        if not valor:
            raise ValueError("El nombre de la categoría es obligatorio")
        if len(valor) > 80:
            raise ValueError("El nombre de la categoría no puede superar 80 caracteres")
        return valor


class CategoriaEgresoPersonalizadaRead(BaseModel):
    """Categoría custom con campos de sincronización y auditoría."""

    model_config = ConfigDict(from_attributes=True)

    id: UUID
    establecimiento_id: UUID
    tipo: TipoEgresoOperativo
    nombre: str
    valor: str
    creado_por_id: UUID
    created_at: datetime
    updated_at: datetime
    deleted_at: datetime | None


class TipoEgresoRead(BaseModel):
    """Tipo contable acompañado por sus categorías válidas."""

    valor: TipoEgresoOperativo
    etiqueta: str
    categorias: list[CategoriaEgresoRead]
