import sys
from pathlib import Path

import uvicorn

# Agregar la raíz del monorepo a PYTHONPATH para imports desde database/
_monorepo_root = Path(__file__).parent.parent
sys.path.insert(0, str(_monorepo_root))

from core.config import EnvironmentOption, settings  # noqa: E402
from core.logger import logging  # noqa: E402

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
        forwarded_allow_ips=settings.FORWARDED_ALLOW_IPS,
    )
