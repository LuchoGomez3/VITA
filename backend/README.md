# Mastercad Backend API

## Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd <repository-url>
```

2. Set up virtual enviroment
```bash
uv venv
source .venv/bin/activate   # macOS/Linux
.venv\Scripts\activate      # Windows
```

3. Install dependencies using uv (recommended):
```bash
uv sync
```

4. Set up environment variables:
```bash
cp env.example .env
```

Edit `.env` with your configuration:
```env
AZURE_OPENAI_ENDPOINT=your_azure_openai_endpoint
AZURE_OPENAI_MODEL_NAME=your_model_name
AZURE_OPENAI_DEPLOYMENT=your_deployment_name
AZURE_OPENAI_SUBSCRIPTION_KEY=your_api_key
AZURE_OPENAI_API_VERSION=2024-02-15-preview
DB_URL=your_database_connection_string
LOG_LEVEL=DEBUG
JWT_SECRET_KEY=change-me
JWT_ALGORITHM=HS256
JWT_ACCESS_TOKEN_EXPIRE_MINUTES=60
```

## Run API

```bash
uvicorn api.main:app --reload
```

- Documentation: `/docs`
- Health: `GET /v1/health`
- Login: `POST /v1/auth/login` (OAuth2 form: username, password)
- Yo: `GET /v1/auth/me` (Bearer token)

Demo user: `admin` / `admin`.

## Standard response

```json
{
  "success": true,
  "data": {},
  "meta": {"request_id": "...", "timestamp": "..."},
  "errors": []
}
```

## Tests
- Todo: units (auth) and integration (httpx/pytest-asyncio).

## Migraciones de base de datos

La estructura de las bases compartidas se actualiza con Alembic. Antes de
iniciar una nueva versión del backend, el proceso de despliegue debe ejecutar:

```bash
uv run alembic upgrade head
```

La migración inicial adopta o crea los índices únicos `uq_usuarios_email` y
`uq_usuarios_cuit`. Si encuentra datos duplicados, se detiene con un mensaje
claro y no aplica parcialmente el cambio. `create_all()` se conserva solamente
como ayuda para entornos locales y de prueba; no reemplaza las migraciones.

Para consultar el estado sin modificar la base:

```bash
uv run alembic current
uv run alembic heads
```

## Protección de autenticación

Registro, login y refresh tienen límites independientes por IP dentro de una
ventana configurable mediante `AUTH_*_RATE_LIMIT`. El almacenamiento de los
contadores es local al proceso porque el despliegue actual utiliza un solo
worker; antes de escalar horizontalmente debe reemplazarse por Redis.

`POST /api/auth/logout` requiere un access token válido y revoca globalmente
las sesiones del usuario en Supabase. Mobile intenta esa revocación y siempre
elimina la sesión local, para que cerrar sesión siga funcionando sin conexión.

## Configuración segura de staging y producción

El backend no inicia fuera de local/test si faltan `DATABASE_URL`,
`SUPABASE_URL`, `SUPABASE_ANON_KEY`, `SUPABASE_SERVICE_ROLE_KEY`, el proveedor
de autenticación no es Supabase o CORS conserva un comodín/origen HTTP. Los
orígenes web permitidos se declaran separados por comas, por ejemplo:

```env
CORS_ALLOW_ORIGINS=https://app.vita.example,https://admin.vita.example
```

En staging/production, las solicitudes HTTP se redirigen a HTTPS. El proxy de
despliegue debe informar correctamente el esquema original mediante sus
encabezados reenviados para evitar redirecciones repetidas. Sus IPs o CIDRs
deben declararse explícitamente; el backend rechaza confiar en cualquier origen:

```env
FORWARDED_ALLOW_IPS=127.0.0.1,10.0.0.0/8
```

Los valores reales dependen de la red del proveedor de despliegue.

`SessionMiddleware` fue eliminado porque VITA usa tokens Bearer y ningún
endpoint utiliza sesiones basadas en cookies.
