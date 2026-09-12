import logging
import os

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from starlette.middleware.httpsredirect import HTTPSRedirectMiddleware

from core.config import EnvironmentOption, settings
from core.contextmanager import lifespan
from api.shared.exceptions import DomainException
from core.middlewares import (
    cache_request_body_middleware,
    camel_case_to_snake_case_middleware,
    custom_exception_handler,
    domain_exception_handler,
    response_time_middleware,
)
from core.router import get_global_router

logger = logging.getLogger(__name__)


def create_fastapi_app() -> FastAPI:
    settings.validate_runtime_configuration()
    app = FastAPI(
        title=settings.APP_NAME,
        description=settings.APP_DESCRIPTION,
        port=8000,
        reload=settings.ENVIRONMENT != EnvironmentOption.PRODUCTION,
        workers=1,
        lifespan=lifespan,
    )

    app.add_middleware(
        CORSMiddleware,
        allow_origins=settings.CORS_ALLOW_ORIGINS,
        allow_credentials=settings.CORS_ALLOW_CREDENTIALS,
        allow_methods=settings.CORS_ALLOW_METHODS,
        allow_headers=settings.CORS_ALLOW_HEADERS,
    )

    if settings.ENVIRONMENT not in (EnvironmentOption.LOCAL, EnvironmentOption.TEST):
        app.add_middleware(HTTPSRedirectMiddleware)

    app.add_exception_handler(HTTPException, custom_exception_handler)
    app.add_exception_handler(DomainException, domain_exception_handler)

    # Add cache request body middleware
    app.middleware("http")(cache_request_body_middleware)
    # Add camelCase to snake_case middleware
    app.middleware("http")(camel_case_to_snake_case_middleware)
    # Add response time middleware
    app.middleware("http")(response_time_middleware)

    logger.info("Loading routes...")
    app.include_router(get_global_router(), prefix="/api")

    # Health check endpoint
    @app.get("/health")
    def health_check():
        return {"status": "ok", "environment": settings.ENVIRONMENT.value}

    # Show current version
    @app.get("/version")
    def version():
        return {"commit": os.getenv("GIT_SHA")}

    return app
