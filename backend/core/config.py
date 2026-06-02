import os
from enum import Enum

from dotenv import load_dotenv

load_dotenv()


class EnvironmentOption(str, Enum):
    LOCAL = "local"
    TEST = "test"
    STAGING = "staging"
    PRODUCTION = "production"


class Settings:
    def __init__(self):
        # App metadata
        self.APP_NAME: str = os.getenv("APP_NAME", "VITA API")
        self.APP_DESCRIPTION: str = os.getenv(
            "APP_DESCRIPTION", "API de trazabilidad ganadera"
        )
        self.VERSION: str = os.getenv("APP_VERSION", "0.1.0")

        # Environment
        env_raw = os.getenv("ENVIRONMENT", "local").lower()
        self.ENVIRONMENT: EnvironmentOption = EnvironmentOption(env_raw)
        self.DEBUG: bool = self.ENVIRONMENT in (
            EnvironmentOption.LOCAL,
            EnvironmentOption.TEST,
        )

        # Database
        # DATABASE_URL es la cadena de conexión canónica (pooler de Supabase
        # fuera de entornos locales). POSTGRES_URI queda como fallback para un
        # Postgres local (p. ej. un contenedor de desarrollo).
        self.DATABASE_URL: str = os.getenv("DATABASE_URL") or os.getenv(
            "POSTGRES_URI",
            "postgresql+asyncpg://postgres:postgres@localhost:5432/vita",
        )
        # Alias retrocompatible.
        self.POSTGRES_URI: str = self.DATABASE_URL
        # El pooler transaccional de Supabase (Supavisor en :6543) no soporta
        # prepared statements del lado del servidor; asyncpg debe deshabilitar
        # su cache de statements al conectarse a través de él.
        self.DB_USE_PGBOUNCER: bool = "pooler.supabase.com" in self.DATABASE_URL

        # Supabase
        self.SUPABASE_URL: str = os.getenv("SUPABASE_URL", "")
        self.SUPABASE_ANON_KEY: str = os.getenv("SUPABASE_ANON_KEY", "")
        self.SUPABASE_SERVICE_ROLE_KEY: str = os.getenv("SUPABASE_SERVICE_ROLE_KEY", "")
        # Secreto con el que Supabase Auth firma los JWT (HS256). Se usa para
        # validar los tokens emitidos por Supabase en el adaptador correspondiente.
        self.SUPABASE_JWT_SECRET: str = os.getenv("SUPABASE_JWT_SECRET", "")

        # Auth provider: "supabase" en entornos reales; "local" para
        # desarrollo/test (emite y valida JWT con JWT_SECRET, sin red).
        self.AUTH_PROVIDER: str = os.getenv(
            "AUTH_PROVIDER",
            "supabase" if self.ENVIRONMENT == EnvironmentOption.PRODUCTION else "local",
        )

        # JWT
        self.JWT_SECRET: str = os.getenv("JWT_SECRET_KEY", "insecure-dev-secret")
        self.JWT_ALGORITHM: str = os.getenv("JWT_ALGORITHM", "HS256")
        self.JWT_ACCESS_TOKEN_EXPIRE_MINUTES: int = int(
            os.getenv("JWT_ACCESS_TOKEN_EXPIRE_MINUTES", "60")
        )

        # CORS
        self.CORS_ALLOW_ORIGINS: list[str] = ["*"]
        self.CORS_ALLOW_CREDENTIALS: bool = True
        self.CORS_ALLOW_METHODS: list[str] = ["*"]
        self.CORS_ALLOW_HEADERS: list[str] = ["*"]

        # Logging
        self.LOG_LEVEL: str = os.getenv("LOG_LEVEL", "DEBUG")


settings = Settings()
