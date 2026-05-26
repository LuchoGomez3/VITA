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
