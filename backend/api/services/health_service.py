import time
from api.schemas.models import HealthInfo
from core.config import Config
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

config = Config()
startup_time = time.time()

class HealthService:
    def __init__(self):
        pass

    def _check_components(self) -> dict:
        """
        Simple component checks placeholder.
        """
        return {
            "database": "healthy",
            "llm_service": "healthy"
        }
        
    def get_health_info(self) -> HealthInfo:
        """Obtiene el estado de salud de la aplicación y sus servicios."""
        uptime_seconds = int(time.time() - startup_time)

        services = self._check_components()
        overall_status = "healthy" if all(v == "healthy" for v in services.values()) else "degraded"

        return HealthInfo(
            status=overall_status,
            version=config.VERSION,
            uptime_seconds=uptime_seconds,
            services=services
        )