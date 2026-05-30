from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base
from core.config import settings

# engine gestiona la conexion con la db
engine = create_engine(
    settings.DATABASE_URL, 
    connect_args={"check_same_thread": False} # Esto es exclusivo para SQLite
)
# cada instancia de SessionLocal es una nueva sesión de base de datos
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
# clase base para los modelos de la db
Base = declarative_base()