# api/main.py
from fastapi import FastAPI
from core.database import engine, Base
from api import models 
from api.routes import animal_route

# 1. Creación de las tablas en la base de datos local
Base.metadata.create_all(bind=engine)

# 2. Inicialización de la aplicación FastAPI
app = FastAPI(
    title="VITA - Sistema de Gestión y Trazabilidad Ganadera Inteligente",
    description="API para la gestión del ganado, lectura de caravanas y registro de pesadas.",
    version="1.0.0"
)

# 3. Inclusión de las rutas (Endpoints)
# Acá es donde le "enchufamos" al main todas las rutas que fuiste creando
app.include_router(animal_route.router)  # Ruta para gestión de animales

# 4. Endpoint de control (Health Check)
@app.get("/", tags=["Estado del Sistema"])
def read_root():
    return {
        "status": "online",
        "mensaje": "La API de trazabilidad está funcionando correctamente."
    }




"""from fastapi import FastAPI, Request, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from fastapi.exceptions import RequestValidationError
import logging
import time
import uuid
from datetime import datetime
from core.config import Config
from api.routes import health_route, auth_route, companies_route


config = Config()
level = getattr(logging, config.LOG_LEVEL, logging.INFO)
logging.basicConfig(
    level=level,
    format='%(message)s'
)
logger = logging.getLogger(__name__)

app = FastAPI(
    title=config.TITLE,
    description=config.DESCRIPTION,
    version=config.VERSION,
    openapi_tags=[
        {"name": "health", "description": "Health and readiness endpoints"},
        {"name": "auth", "description": "Authentication endpoints"},
        {"name": "companies", "description": "Companies endpoints"}
    ]
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=config.CORS_ALLOW_ORIGINS,
    allow_credentials=config.CORS_ALLOW_CREDENTIALS,
    allow_methods=config.CORS_ALLOW_METHODS,
    allow_headers=config.CORS_ALLOW_HEADERS
)

@app.middleware("http")
async def process_and_handle_exceptions(request: Request, call_next):
    request_id = str(uuid.uuid4())
    request.state.request_id = request_id
    request.state.start_time = time.time()

    try:
        response = await call_next(request)
        process_time = time.time() - request.state.start_time
        response.headers["X-Process-Time"] = str(process_time)
        return response

    except HTTPException as exc:
        process_time = time.time() - request.state.start_time
        content = {
            "success": False,
            "data": None,
            "meta": {
                "request_id": request_id,
                "timestamp": datetime.utcnow().isoformat() + "Z",
                "processing_time_ms": int(process_time * 1000)
            },
            "errors": [{"code": "HTTP_ERROR", "message": exc.detail, "status_code": exc.status_code}]
        }
        return JSONResponse(status_code=exc.status_code, content=content)

    except Exception as exc:
        process_time = time.time() - request.state.start_time
        logger.error(
            {
                "event": "unhandled_exception",
                "request_id": request_id,
                "error": str(exc)
            }
        )
        content = {
            "success": False,
            "data": None,
            "meta": {
                "request_id": request_id,
                "timestamp": datetime.utcnow().isoformat() + "Z",
                "processing_time_ms": int(process_time * 1000)
            },
            "errors": [{"code": "INTERNAL_ERROR", "message": "Internal server error"}]
        }
        return JSONResponse(status_code=500, content=content)

@app.exception_handler(RequestValidationError)
async def validation_exception_handler(request: Request, exc: RequestValidationError):
    request_id = getattr(request.state, 'request_id', str(uuid.uuid4()))
    errors = [{"code": "VALIDATION_ERROR", "message": e["msg"], "loc": e["loc"]} for e in exc.errors()]
    content = {
        "success": False,
        "data": None,
        "meta": {
            "request_id": request_id,
            "timestamp": datetime.utcnow().isoformat() + "Z"
        },
        "errors": errors
    }
    return JSONResponse(status_code=422, content=content)

app.include_router(health_route.router, prefix="/v1", tags=["health"]) 
app.include_router(auth_route.router, prefix="/v1", tags=["auth"]) 
app.include_router(companies_route.router, prefix="/v1", tags=["companies"]) 

@app.get("/")
async def root():
    return {
        "message": config.TITLE,
        "version": config.VERSION,
        "docs": "/docs",
        "health": "/v1/health"
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "api.main:app",
        host="0.0.0.0",
        port=8000,
        reload=True
    )"""