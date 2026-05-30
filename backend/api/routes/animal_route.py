from fastapi import APIRouter, Depends
from api.schemas.animal_schema import AnimalResponse, AnimalCreate
from api.services.animal_service import AnimalService
from api.dependencies import get_animal_service # Importamos el inyector

router = APIRouter(prefix="/animales", tags=["Animales"])

@router.get("/", response_model=list[AnimalResponse])
def listar_animales(servicio: AnimalService = Depends(get_animal_service)):
    return servicio.get_all()


@router.post("/", response_model=AnimalResponse)
def create_animal(animal_nuevo: AnimalCreate, servicio: AnimalService = Depends(get_animal_service)):
    return servicio.registrar_animal(animal_nuevo)
