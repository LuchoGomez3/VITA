import os
from pydantic_settings import BaseSettings
from dotenv import load_dotenv



class Settings(BaseSettings):
    DATABASE_URL: str = os.getenv("DATABASE_URL", "postgresql://usuario:password@localhost:5432/mayoral_db")

    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"
settings = Settings()

"""class Config:
    def __init__(self):
        

        


        load_dotenv()
        self.AZURE_OPENAI_ENDPOINT = os.getenv("AZURE_OPENAI_ENDPOINT")
        self.AZURE_OPENAI_MODEL_NAME = os.getenv("AZURE_OPENAI_MODEL_NAME")
        self.AZURE_OPENAI_DEPLOYMENT = os.getenv("AZURE_OPENAI_DEPLOYMENT")
        self.AZURE_OPENAI_SUBSCRIPTION_KEY = os.getenv("AZURE_OPENAI_SUBSCRIPTION_KEY") 
        self.AZURE_OPENAI_API_VERSION = os.getenv("AZURE_OPENAI_API_VERSION")
        self.DB_URL = os.getenv("DB_URL")

        # Api config
        self.TITLE: str = "Mastercard backend API"
        self.DESCRIPTION: str = "API para ejecutar procesos"
        self.VERSION: str = "1.0.0"
        self.CORS_ALLOW_ORIGINS: list[str] = ["*"]
        self.CORS_ALLOW_CREDENTIALS: bool = True
        self.CORS_ALLOW_METHODS: list[str] = ["*"]
        self.CORS_ALLOW_HEADERS: list[str] = ["*"]
        self.LOG_LEVEL = os.getenv("LOG_LEVEL", "DEBUG")

        # JWT
        self.JWT_SECRET_KEY = os.getenv("JWT_SECRET_KEY", "insecure-dev-secret")
        self.JWT_ALGORITHM = os.getenv("JWT_ALGORITHM", "HS256")
        self.JWT_ACCESS_TOKEN_EXPIRE_MINUTES = int(os.getenv("JWT_ACCESS_TOKEN_EXPIRE_MINUTES", "60"))"""
