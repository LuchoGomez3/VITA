# api/dependencies.py
from fastapi import Depends
from sqlalchemy.orm import Session
from core.database import SessionLocal
from api.dao.animal_dao import AnimalDAO
from api.services.animal_service import AnimalService

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# --- NUEVA DEPENDENCIA PARA EL SERVICIO ---
def get_animal_service(db: Session = Depends(get_db)) -> AnimalService:
    dao = AnimalDAO(db)
    return AnimalService(dao)