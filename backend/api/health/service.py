import logging
import time

from api.health.schemas import HealthInfo
from core.config import settings

logger = logging.getLogger(__name__)

startup_time = time.time()


class HealthService:
    def _check_components(self) -> dict:
        return {
            "database": "healthy",
            "llm_service": "healthy",
        }

    def get_health_info(self) -> HealthInfo:
        uptime_seconds = int(time.time() - startup_time)
        services = self._check_components()
        overall_status = (
            "healthy" if all(v == "healthy" for v in services.values()) else "degraded"
        )
        return HealthInfo(
            status=overall_status,
            version=settings.VERSION,
            uptime_seconds=uptime_seconds,
            services=services,
        )
