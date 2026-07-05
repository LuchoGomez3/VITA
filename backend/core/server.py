import logging
import os

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from starlette.middleware.sessions import SessionMiddleware

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
    app = FastAPI(
        title=settings.APP_NAME,
        description=settings.APP_DESCRIPTION,
        port=8000,
        reload=settings.ENVIRONMENT != EnvironmentOption.PRODUCTION,
        workers=1,
        lifespan=lifespan,
    )

    # Cors conf
    app.add_middleware(
        CORSMiddleware,
        allow_origins=["*"],
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

    # Add session middleware
    app.add_middleware(
        SessionMiddleware,
        secret_key=settings.JWT_SECRET,
        session_cookie="session",
        max_age=3600,  # 1 hour
    )

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
