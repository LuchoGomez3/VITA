from fastapi import APIRouter, Depends
from api.schemas.models import StandardResponse
from api.services.auth_service import get_current_user
from api.services.companies_service import CompaniesService
from api.dependencies import get_companies_service

router = APIRouter()

@router.get("/companies/list", response_model=StandardResponse, tags=["companies"])
async def list_companies(
    current_user: dict = Depends(get_current_user),
    companies_service: CompaniesService = Depends(get_companies_service)
):
    companies_info = companies_service.get_companies_info()
    return StandardResponse(success=True, data=companies_info.model_dump()) 