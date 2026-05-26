from fastapi import APIRouter, HTTPException, Depends
from datetime import datetime
import time
from api.schemas.models import StandardResponse
from api.services.health_service import HealthService
from api.dependencies import get_health_service

router = APIRouter()

@router.get("/health", response_model=StandardResponse)
async def health_check(health_service: HealthService = Depends(get_health_service)):
    health_info = health_service.get_health_info()
    return StandardResponse(
        success=True,
        data=health_info.model_dump(),
        meta={
            "request_id": f"req_{int(time.time())}",
            "timestamp": datetime.now().isoformat() + "Z"
        }
    )