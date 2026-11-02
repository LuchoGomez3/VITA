# Imagen del backend de VITA.
#
# Se construye con la RAÍZ del monorepo como contexto, porque el backend importa
# el paquete `database/` que vive fuera de `backend/`:
#
#   docker build -f backend/Dockerfile -t vita-api .

FROM python:3.12-slim

COPY --from=ghcr.io/astral-sh/uv:0.8 /uv /bin/uv

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    UV_COMPILE_BYTECODE=1 \
    UV_LINK_MODE=copy \
    UV_PROJECT_ENVIRONMENT=/opt/venv \
    PATH="/opt/venv/bin:$PATH" \
    PYTHONPATH=/app:/app/backend

WORKDIR /app/backend

# Dependencias primero: esta capa solo se reconstruye si cambia el lockfile.
COPY backend/pyproject.toml backend/uv.lock ./
RUN uv sync --frozen --no-dev --no-install-project

COPY backend/ ./
COPY database/ /app/database/

RUN useradd --system --uid 10001 vita
USER vita

EXPOSE 8000

# Forma shell para expandir $PORT (lo inyecta Render) y FORWARDED_ALLOW_IPS.
# Sin --proxy-headers, HTTPSRedirectMiddleware no ve el X-Forwarded-Proto del
# proxy y redirige cada request en loop.
CMD uvicorn core.server:create_fastapi_app --factory \
    --host 0.0.0.0 --port "${PORT:-8000}" --workers 1 \
    --proxy-headers --forwarded-allow-ips "${FORWARDED_ALLOW_IPS:-127.0.0.1}"
