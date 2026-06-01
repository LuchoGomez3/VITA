import uvicorn

from core.config import EnvironmentOption, settings
from core.logger import logging

logger = logging.getLogger(__name__)

if __name__ == "__main__":
    logger.info("Running in environment: %s", settings.ENVIRONMENT)

    uvicorn.run(
        app="core.server:create_fastapi_app",
        host="0.0.0.0",
        reload=settings.ENVIRONMENT != EnvironmentOption.PRODUCTION,
        workers=1,
        factory=True,
        proxy_headers=True,
        forwarded_allow_ips="*",
    )
