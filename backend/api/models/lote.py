from sqlalchemy import Column, Integer, String, Float, Date, ForeignKey
from core.database import Base

class Lote(Base):
    __tablename__ = "lotes"

    id = Column(Integer, primary_key=True, index=True)
    nombre = Column(String, index=True, unique=True)
    descripcion = Column(String)