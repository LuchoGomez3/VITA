import logging

from fastapi import APIRouter

from api.auth.router import router as auth_router
from api.health.router import router as health_router
from api.modules.animales.router import router as animales_router
from api.modules.categorias.router import router as categorias_router
from api.modules.establecimientos.router import router as establecimientos_router
from api.modules.egresos_operativos.router import router as egresos_operativos_router
from api.modules.lotes.router import router as lotes_router
from api.modules.movimientos.router import router as movimientos_lotes_router
from api.modules.pesajes.router import router as pesajes_router
from api.modules.usuarios.router import router as usuarios_router
from api.reportes.router import router as reportes_router

logger = logging.getLogger(__name__)


def get_global_router() -> APIRouter:
    router = APIRouter()
    router.include_router(health_router)
    router.include_router(auth_router)
    router.include_router(usuarios_router)
    router.include_router(establecimientos_router)
    router.include_router(egresos_operativos_router)
    router.include_router(animales_router)
    router.include_router(lotes_router)
    router.include_router(movimientos_lotes_router)
    router.include_router(categorias_router)
    router.include_router(pesajes_router)
    router.include_router(reportes_router)
    return router
