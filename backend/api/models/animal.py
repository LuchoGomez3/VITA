from sqlalchemy import Column, Integer, String, Float, Date, ForeignKey
from core.database import Base


class Animal(Base):
    __tablename__ = "animales"

    id = Column(Integer, primary_key=True, index=True)
    nro_caravana = Column(Integer, index=True, unique=True)
    sexo = Column(String)
    raza = Column(String)
    peso = Column(Float)
    fecha_nac = Column(Date)
    id_lote = Column(Integer, ForeignKey("lotes.id"))
    caravana_padre = Column(String)
    caravana_madre = Column(String)
    categoria = Column(String)
    pelaje = Column(String)
    observaciones = Column(String)

    