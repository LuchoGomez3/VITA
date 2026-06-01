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
        self.POSTGRES_URI: str = os.getenv(
            "POSTGRES_URI",
            "postgresql+asyncpg://postgres:postgres@localhost:5432/vita",
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
