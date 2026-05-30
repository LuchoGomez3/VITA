import api.dao.animal_dao as AnimalDAO
from api.models.animal import Animal
from api.schemas.animal_schema import AnimalCreate


class AnimalService:
    def __init__(self, animal_dao: AnimalDAO):
        self.dao = animal_dao

    def buscar_animal_por_caravana(self, caravana: int) -> Animal | None:
        return self.animal_dao.buscar_animal_por_caravana(caravana)

    def registrar_animal(self, data: AnimalCreate) -> Animal:
        #validamos que no existe
        existente = self.buscar_animal_por_caravana(data.nro_caravana)
        if existente:
            raise ValueError("Animal ya registrado ", data.nro_caravana)
        
        return self.dao.create_animal(data.dict())
    
    def get_all(self) -> list[Animal]:
        return self.dao.get_all()