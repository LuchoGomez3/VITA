"""Errores de tipo de Sanidad con el mismo formato que los de negocio.

FastAPI responde los errores de esquema (un número donde va texto, un UUID mal
formado) con su ``{"detail": [...]}``. El celular solo sabe leer
``errors[0].details.campo`` y ``animal_id``, así que en una carga grupal no
podría señalar qué corregir. Esta clase de ruta traduce esos 422 al envelope de
``EventoSanitarioInvalidoError``. Se aplica solo a las rutas de Sanidad para no
cambiar el formato que esperan los otros módulos.
"""

from collections.abc import Callable, Coroutine
from json import JSONDecodeError
import logging
from typing import Any

from fastapi import Request, Response
from fastapi.encoders import jsonable_encoder
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse
from fastapi.routing import APIRoute

from api.modules.eventos_sanitarios.exceptions import EventoSanitarioInvalidoError

logger = logging.getLogger(__name__)


def _campo(loc: tuple[Any, ...]) -> str | None:
    # ``loc`` empieza por el origen: ("body", "animales", 1, "referencia_muestra")
    # o ("query", "cursor").
    partes = [str(parte) for parte in loc[1:]]
    return ".".join(partes) or None


async def _animal_id(request: Request, loc: tuple[Any, ...]) -> str | None:
    if (
        len(loc) < 3
        or loc[0] != "body"
        or loc[1] != "animales"
        or not isinstance(loc[2], int)
    ):
        return None
    try:
        cuerpo = await request.json()
    except (JSONDecodeError, UnicodeDecodeError):
        return None
    animales = cuerpo.get("animales") if isinstance(cuerpo, dict) else None
    if not isinstance(animales, list) or loc[2] >= len(animales):
        return None
    item = animales[loc[2]]
    animal_id = item.get("animal_id") if isinstance(item, dict) else None
    return animal_id if isinstance(animal_id, str) else None


async def respuesta_de_validacion(
    request: Request, exc: RequestValidationError
) -> JSONResponse:
    """Primer error de esquema como rechazo corregible, con campo y animal."""
    errores = exc.errors()
    loc = tuple(errores[0].get("loc", ())) if errores else ()
    campo = _campo(loc)
    error = EventoSanitarioInvalidoError(
        f"Revisá {campo}" if campo else "La solicitud tiene datos inválidos",
        campo=campo,
    )
    detalles = dict(error.details or {})
    animal_id = await _animal_id(request, loc)
    if animal_id is not None:
        detalles["animal_id"] = animal_id
    logger.info("Sanidad rechazó un esquema inválido en %s", campo or "la solicitud")
    contenido: dict[str, Any] = {"code": error.code, "message": error.message}
    if detalles:
        contenido["details"] = jsonable_encoder(detalles)
    return JSONResponse(
        status_code=error.status_code,
        content={"success": False, "data": None, "meta": None, "errors": [contenido]},
    )


class RutaSanitaria(APIRoute):
    """Ruta que responde los errores de esquema con el envelope de Sanidad."""

    def get_route_handler(self) -> Callable[[Request], Coroutine[Any, Any, Response]]:
        original = super().get_route_handler()

        async def handler(request: Request) -> Response:
            try:
                return await original(request)
            except RequestValidationError as exc:
                return await respuesta_de_validacion(request, exc)

        return handler
