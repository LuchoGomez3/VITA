from pydantic import BaseModel
from datetime import datetime, date
from typing import Optional

class AnimalCreate(BaseModel):
    nro_caravana: int
    sexo: str
    raza: str
    peso: float
    fecha_nac: Optional[date] = None
    id_lote: int
    caravana_padre: Optional[str] = None
    caravana_madre: Optional[str] = None
    categoria: Optional[str] = None
    pelaje: Optional[str] = None
    observaciones: Optional[str] = None

class AnimalResponse(BaseModel):
    nro_caravana: int
    sexo: str
    raza: str
    peso: float
    fecha_nac: Optional[date] = None
    id_lote: int
    caravana_padre: Optional[str] = None
    caravana_madre: Optional[str] = None
    categoria: Optional[str] = None
    pelaje: Optional[str] = None
    observaciones: Optional[str] = None

    class Config:
        from_attribute = True