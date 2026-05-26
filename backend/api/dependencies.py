from api.services.health_service import HealthService
from api.services.companies_service import CompaniesService

def get_health_service() -> HealthService:
    return HealthService()

def get_companies_service() -> CompaniesService:
    return CompaniesService() 