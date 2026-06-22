import logging

from fastapi import APIRouter

from api.auth.router import router as auth_router
from api.health.router import router as health_router
from api.modules.animales.router import router as animales_router
from api.modules.establecimientos.router import router as establecimientos_router
from api.modules.usuarios.router import router as usuarios_router
from api.reportes.router import router as reportes_router

logger = logging.getLogger(__name__)


def get_global_router() -> APIRouter:
    router = APIRouter()
    router.include_router(health_router)
    router.include_router(auth_router)
    router.include_router(usuarios_router)
    router.include_router(establecimientos_router)
    router.include_router(animales_router)
    router.include_router(reportes_router)
    return router
