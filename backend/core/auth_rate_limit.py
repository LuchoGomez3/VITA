"""Límites de intentos para endpoints públicos de autenticación."""

import asyncio
import time
from collections import defaultdict, deque
from collections.abc import Callable

from fastapi import HTTPException, Request, status

from core.config import settings


class InMemoryRateLimiter:
    """Limita solicitudes por IP y operación dentro de una ventana temporal.

    La aplicación actualmente corre con un solo worker. Si se escala a varios
    procesos o instancias, este almacenamiento debe reemplazarse por Redis para
    compartir los contadores entre todos ellos.
    """

    def __init__(self, clock: Callable[[], float] = time.monotonic) -> None:
        self._attempts: dict[str, deque[float]] = defaultdict(deque)
        self._lock = asyncio.Lock()
        self._clock = clock

    async def check(
        self,
        request: Request,
        *,
        operation: str,
        limit: int,
        window_seconds: int,
    ) -> None:
        """Registra un intento o responde 429 cuando se supera el límite."""
        client_host = request.client.host if request.client else "unknown"
        key = f"{operation}:{client_host}"
        now = self._clock()
        cutoff = now - window_seconds

        async with self._lock:
            attempts = self._attempts[key]
            while attempts and attempts[0] <= cutoff:
                attempts.popleft()
            if len(attempts) >= limit:
                retry_after = max(1, int(attempts[0] + window_seconds - now))
                raise HTTPException(
                    status_code=status.HTTP_429_TOO_MANY_REQUESTS,
                    detail="Demasiados intentos. Esperá un momento y volvé a intentar.",
                    headers={"Retry-After": str(retry_after)},
                )
            attempts.append(now)

    def reset(self) -> None:
        """Limpia contadores; se usa para aislar las pruebas automatizadas."""
        self._attempts.clear()


auth_rate_limiter = InMemoryRateLimiter()


async def limit_registration(request: Request) -> None:
    """Aplica el límite configurado al registro público."""
    await auth_rate_limiter.check(
        request,
        operation="registration",
        limit=settings.AUTH_REGISTRATION_RATE_LIMIT,
        window_seconds=settings.AUTH_RATE_LIMIT_WINDOW_SECONDS,
    )


async def limit_login(request: Request) -> None:
    """Aplica el límite configurado al inicio de sesión."""
    await auth_rate_limiter.check(
        request,
        operation="login",
        limit=settings.AUTH_LOGIN_RATE_LIMIT,
        window_seconds=settings.AUTH_RATE_LIMIT_WINDOW_SECONDS,
    )


async def limit_refresh(request: Request) -> None:
    """Aplica el límite configurado a la renovación de sesión."""
    await auth_rate_limiter.check(
        request,
        operation="refresh",
        limit=settings.AUTH_REFRESH_RATE_LIMIT,
        window_seconds=settings.AUTH_RATE_LIMIT_WINDOW_SECONDS,
    )
