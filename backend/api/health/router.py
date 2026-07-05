import time
from datetime import datetime

from fastapi import APIRouter, Depends

from api.health.service import HealthService
from api.shared.schemas import StandardResponse

router = APIRouter(prefix="/health", tags=["health"])


def get_health_service() -> HealthService:
    return HealthService()


@router.get("", response_model=StandardResponse)
async def health_check(
    health_service: HealthService = Depends(get_health_service),
):
    health_info = health_service.get_health_info()
    return StandardResponse(
        success=True,
        data=health_info.model_dump(),
        meta={
            "request_id": f"req_{int(time.time())}",
            "timestamp": datetime.now().isoformat() + "Z",
        },
    )
