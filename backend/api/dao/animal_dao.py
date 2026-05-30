from sqlalchemy.orm import Session
from api.models.animal import Animal


class AnimalDAO:
    def __init__(self, db: Session):
        self.db = db

    def buscar_animal_por_caravana(self, caravana: int) -> Animal | None:
        return self.db.query(Animal).filter(Animal.caravana == caravana).first()

    def create_animal(self, animal_data) -> Animal:
        nuevo_animal = Animal(**animal_data)
        self.db.add(nuevo_animal)
        self.db.commit()
        self.db.refresh(nuevo_animal)
        return nuevo_animal
    
    def get_all(self) -> list[Animal]:
        return self.db.query(Animal).all()