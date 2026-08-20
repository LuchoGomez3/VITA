import json
import logging
import re
import time
from collections.abc import Callable
from typing import Any

from fastapi import HTTPException, Request
from fastapi.encoders import jsonable_encoder
from fastapi.responses import JSONResponse

from api.shared.exceptions import DomainException

logger = logging.getLogger(__name__)


async def response_time_middleware(request: Request, call_next: Callable) -> Any:
    """Middleware to measure and log the response time of the request."""
    # Start timer
    start_time = time.time()

    # Process request
    response = await call_next(request)

    # Calculate duration
    process_time = time.time() - start_time

    # Log response time
    logger.info(
        "[PERFORMANCE] Path: %s | Method: %s | Status: %s | Time: %.4fs",
        request.url.path,
        request.method,
        response.status_code,
        process_time,
    )

    return response


def camel_to_snake(name: str) -> str:
    """Convert camelCase string to snake_case."""
    name = re.sub("(.)([A-Z][a-z]+)", r"\1_\2", name)
    return re.sub("([a-z0-9])([A-Z])", r"\1_\2", name).lower()


def convert_dict_keys_to_snake_case(data: Any) -> Any:
    """Recursively convert all dictionary keys from camelCase to snake_case."""
    if isinstance(data, dict):
        return {
            camel_to_snake(k): convert_dict_keys_to_snake_case(v)
            for k, v in data.items()
        }
    elif isinstance(data, list):
        return [convert_dict_keys_to_snake_case(item) for item in data]
    return data


def contains_key_camel_case(data: dict[str, Any] | list[Any]) -> bool:
    """
    Check if the data contains camelCase keys.
    This function checks all levels of the dictionary.

    Example:
    {'email': 'lucho26@gmail.com', 'password': 'nAc!@JOiU%Dx!iiHZ', 'profile': {'name': 'string', 'last_name': 'string', 'gender': 'male', 'birthDate': '2025-04-11', 'location': 'string', 'pictureUrl': 'string'}, 'verification_code': '4077'}
    The function will return True because the key 'pictureUrl' is in camelCase.

    """
    if not isinstance(data, dict):
        return False

    for key, value in data.items():
        if re.match(r"^[a-z]+[A-Z]", key):
            return True
        if isinstance(value, dict):
            if contains_key_camel_case(value):
                return True
        elif isinstance(value, list):
            for item in value:
                if isinstance(item, dict | list):
                    if contains_key_camel_case(item):
                        return True
    return False


async def camel_case_to_snake_case_middleware(
    request: Request, call_next: Callable
) -> Any:
    """Middleware to convert camelCase request bodies to snake_case."""
    # Only apply to API routes, not GraphQL routes
    if not request.url.path.startswith("/api/graphql"):
        try:
            body = await request.body()
            if body:
                json_body = json.loads(body)
                # Only convert if the body is in camelCase (check first level keys)
                if contains_key_camel_case(json_body):
                    converted_body = convert_dict_keys_to_snake_case(json_body)
                    # Replace the request body with the converted version
                    request._body = json.dumps(converted_body).encode()
        except (json.JSONDecodeError, UnicodeDecodeError):
            # If body is not JSON (e.g. binary file upload), continue without conversion
            pass

    response = await call_next(request)
    return response


async def cache_request_body_middleware(request: Request, call_next: Callable) -> Any:
    """Middleware to cache JSON request body in request.state for reuse."""
    if request.method == "POST" and "json" in request.headers.get("content-type", ""):
        try:
            json_body = await request.json()
            request.state.json = json_body
        except Exception:
            request.state.json = {}
    response = await call_next(request)
    return response


async def custom_exception_handler(request: Request, exc: Exception) -> JSONResponse:
    if isinstance(exc, HTTPException):
        detail = exc.detail
        if isinstance(detail, dict):
            message = detail.get("message", "Request failed")
            details = detail
        else:
            if detail is not None:
                message = str(detail)
            elif exc.status_code < 500:
                message = "Request failed"
            else:
                message = "An error occurred"
            details = None
        content: dict[str, Any] = {"error": message, "status": exc.status_code}
        if details is not None:
            content["details"] = details
        return JSONResponse(
            status_code=exc.status_code,
            content=content,
            headers=exc.headers,
        )
    # Handle other types of exceptions — log internally, never expose to client
    logger.error(
        "[ERROR] Unhandled exception on %s %s: %s",
        request.method,
        request.url.path,
        exc,
        exc_info=True,
    )
    return JSONResponse(
        status_code=500,
        content={
            "error": "An unexpected error occurred. Please try again.",
            "status": 500,
        },
    )


async def domain_exception_handler(request: Request, exc: Exception) -> JSONResponse:
    """Traduce una ``DomainException`` a ``StandardResponse(success=False, ...)``."""
    if not isinstance(exc, DomainException):
        # Salvaguarda: nunca debería registrarse para otro tipo.
        return await custom_exception_handler(request, exc)

    error: dict[str, Any] = {"code": exc.code, "message": exc.message}
    if exc.details is not None:
        error["details"] = jsonable_encoder(exc.details)

    return JSONResponse(
        status_code=exc.status_code,
        content={"success": False, "data": None, "meta": None, "errors": [error]},
    )
