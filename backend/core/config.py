import os
from enum import Enum

from dotenv import load_dotenv

load_dotenv()


def _csv_env(name: str, default: str = "") -> list[str]:
    """Convierte una variable separada por comas en valores no vacíos."""
    return [
        value.strip() for value in os.getenv(name, default).split(",") if value.strip()
    ]


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

        # Storage: bucket PRIVADO con la foto de perfil de cada usuario. El
        # backend entra con la service-role key y sirve la imagen él mismo; nunca
        # emite URLs públicas ni firmadas (adr-0011).
        self.SUPABASE_STORAGE_BUCKET_AVATARES: str = os.getenv(
            "SUPABASE_STORAGE_BUCKET_AVATARES", "avatars"
        )

        # Límites de la foto de perfil. Se acepta una foto de cámara sin tocar
        # (hasta 8 MB) y se guarda recomprimida a 512 px de lado mayor: se ve en
        # un círculo de ~72 px, y a ese tamaño pesa ~40 KB contra el 1 GB del
        # plan free de Supabase (el bucket rechaza más de 1 MB).
        self.AVATAR_IMAGEN_MAX_BYTES: int = int(
            os.getenv("AVATAR_IMAGEN_MAX_BYTES", str(8 * 1024 * 1024))
        )
        self.AVATAR_IMAGEN_LADO_MAX: int = int(
            os.getenv("AVATAR_IMAGEN_LADO_MAX", "512")
        )
        self.AVATAR_IMAGEN_CALIDAD: int = int(os.getenv("AVATAR_IMAGEN_CALIDAD", "85"))
        # Tope de píxeles antes de decodificar (40 MP: sobra para cualquier
        # cámara de celular y acota la memoria a ~160 MB por foto).
        self.AVATAR_IMAGEN_MAX_PIXELES: int = int(
            os.getenv("AVATAR_IMAGEN_MAX_PIXELES", str(40_000_000))
        )

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
        self.AUTH_RATE_LIMIT_WINDOW_SECONDS: int = int(
            os.getenv("AUTH_RATE_LIMIT_WINDOW_SECONDS", "60")
        )
        self.AUTH_REGISTRATION_RATE_LIMIT: int = int(
            os.getenv("AUTH_REGISTRATION_RATE_LIMIT", "5")
        )
        self.AUTH_LOGIN_RATE_LIMIT: int = int(os.getenv("AUTH_LOGIN_RATE_LIMIT", "10"))
        self.AUTH_REFRESH_RATE_LIMIT: int = int(
            os.getenv("AUTH_REFRESH_RATE_LIMIT", "20")
        )
        # IPs/CIDRs de proxies autorizados a informar el cliente y esquema real.
        # Nunca confiar en "*": permitiría falsificar X-Forwarded-For si Uvicorn
        # quedara accesible sin pasar por el proxy esperado.
        self.FORWARDED_ALLOW_IPS: str = os.getenv(
            "FORWARDED_ALLOW_IPS",
            "127.0.0.1",
        ).strip()

        # Email saliente (invitaciones al equipo, adr-0012). "console" solo
        # loguea el mensaje y es para LOCAL/TEST; staging y producción exigen
        # "smtp" (Brevo, Resend o una cuenta con contraseña de aplicación).
        self.EMAIL_PROVIDER: str = os.getenv("EMAIL_PROVIDER", "console").lower()
        self.SMTP_HOST: str = os.getenv("SMTP_HOST", "")
        self.SMTP_PORT: int = int(os.getenv("SMTP_PORT", "587"))
        self.SMTP_USER: str = os.getenv("SMTP_USER", "")
        self.SMTP_PASSWORD: str = os.getenv("SMTP_PASSWORD", "")
        self.SMTP_FROM: str = os.getenv("SMTP_FROM", "")
        # El envío es sincrónico dentro del request: el owner tiene que saber si
        # el email salió. El timeout acota cuánto espera la app.
        self.EMAIL_TIMEOUT_SECONDS: float = float(
            os.getenv("EMAIL_TIMEOUT_SECONDS", "10")
        )

        # Invitaciones al equipo de un establecimiento (adr-0012).
        self.INVITACION_VIGENCIA_DIAS: int = int(
            os.getenv("INVITACION_VIGENCIA_DIAS", "7")
        )
        # Clave del HMAC con el que se guarda el código: si se filtra la tabla,
        # sin esta clave no se pueden probar códigos por fuerza bruta offline.
        self.INVITACION_CODIGO_SECRETO: str = os.getenv(
            "INVITACION_CODIGO_SECRETO", self.JWT_SECRET
        )
        # Intentos de validar o canjear un código, por usuario y por hora.
        self.INVITACION_CODIGO_RATE_LIMIT: int = int(
            os.getenv("INVITACION_CODIGO_RATE_LIMIT", "10")
        )
        self.INVITACION_CODIGO_RATE_WINDOW_SECONDS: int = int(
            os.getenv("INVITACION_CODIGO_RATE_WINDOW_SECONDS", "3600")
        )

        # CORS. Mobile nativo no depende de CORS; esta lista protege clientes web.
        self.CORS_ALLOW_ORIGINS: list[str] = _csv_env("CORS_ALLOW_ORIGINS", "*")
        self.CORS_ALLOW_CREDENTIALS: bool = self.ENVIRONMENT not in (
            EnvironmentOption.LOCAL,
            EnvironmentOption.TEST,
        )
        self.CORS_ALLOW_METHODS: list[str] = [
            "GET",
            "POST",
            "PUT",
            "PATCH",
            "DELETE",
            "OPTIONS",
        ]
        self.CORS_ALLOW_HEADERS: list[str] = [
            "Accept",
            "Authorization",
            "Content-Type",
        ]

        # Logging
        self.LOG_LEVEL: str = os.getenv("LOG_LEVEL", "DEBUG")

    def validate_runtime_configuration(self) -> None:
        """Impide iniciar staging/producción con configuración insegura."""
        if self.ENVIRONMENT in (EnvironmentOption.LOCAL, EnvironmentOption.TEST):
            return

        missing: list[str] = []
        if not os.getenv("DATABASE_URL"):
            missing.append("DATABASE_URL")
        if self.AUTH_PROVIDER != "supabase":
            missing.append("AUTH_PROVIDER=supabase")
        for name, value in (
            ("SUPABASE_URL", self.SUPABASE_URL),
            ("SUPABASE_ANON_KEY", self.SUPABASE_ANON_KEY),
            ("SUPABASE_SERVICE_ROLE_KEY", self.SUPABASE_SERVICE_ROLE_KEY),
        ):
            if not value:
                missing.append(name)
        if self.EMAIL_PROVIDER != "smtp":
            missing.append("EMAIL_PROVIDER=smtp")
        for name, value in (
            ("SMTP_HOST", self.SMTP_HOST),
            ("SMTP_FROM", self.SMTP_FROM),
        ):
            if not value:
                missing.append(name)
        if not os.getenv("INVITACION_CODIGO_SECRETO"):
            missing.append("INVITACION_CODIGO_SECRETO")
        if not self.CORS_ALLOW_ORIGINS or "*" in self.CORS_ALLOW_ORIGINS:
            missing.append("CORS_ALLOW_ORIGINS explícito")
        if any(not origin.startswith("https://") for origin in self.CORS_ALLOW_ORIGINS):
            missing.append("CORS_ALLOW_ORIGINS solo con HTTPS")
        if not self.FORWARDED_ALLOW_IPS or self.FORWARDED_ALLOW_IPS == "*":
            missing.append("FORWARDED_ALLOW_IPS explícito y restringido")

        if missing:
            raise RuntimeError(
                "Configuración insegura para staging/production: " + ", ".join(missing)
            )


settings = Settings()
