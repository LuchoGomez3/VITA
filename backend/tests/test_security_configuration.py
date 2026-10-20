import pytest
from starlette.middleware.httpsredirect import HTTPSRedirectMiddleware
from starlette.middleware.sessions import SessionMiddleware

from core.config import EnvironmentOption, Settings, settings
from core.server import create_fastapi_app


def test_production_rejects_missing_security_configuration(monkeypatch):
    monkeypatch.setenv("ENVIRONMENT", "production")
    monkeypatch.delenv("DATABASE_URL", raising=False)
    monkeypatch.setenv("AUTH_PROVIDER", "local")
    monkeypatch.setenv("CORS_ALLOW_ORIGINS", "*")
    monkeypatch.setenv("FORWARDED_ALLOW_IPS", "*")
    monkeypatch.delenv("SUPABASE_URL", raising=False)
    monkeypatch.delenv("SUPABASE_ANON_KEY", raising=False)
    monkeypatch.delenv("SUPABASE_SERVICE_ROLE_KEY", raising=False)
    monkeypatch.delenv("SUPABASE_JWT_SECRET", raising=False)

    with pytest.raises(RuntimeError, match="Configuración insegura"):
        Settings().validate_runtime_configuration()


def test_production_rejects_unrestricted_forwarded_headers(monkeypatch):
    monkeypatch.setenv("ENVIRONMENT", "production")
    monkeypatch.setenv("DATABASE_URL", "postgresql+asyncpg://production.example/vita")
    monkeypatch.setenv("AUTH_PROVIDER", "supabase")
    monkeypatch.setenv("SUPABASE_URL", "https://example.supabase.co")
    monkeypatch.setenv("SUPABASE_ANON_KEY", "anon-test")
    monkeypatch.setenv("SUPABASE_SERVICE_ROLE_KEY", "service-test")
    monkeypatch.setenv("CORS_ALLOW_ORIGINS", "https://app.example.com")
    monkeypatch.setenv("FORWARDED_ALLOW_IPS", "*")

    with pytest.raises(RuntimeError, match="FORWARDED_ALLOW_IPS"):
        Settings().validate_runtime_configuration()


def _produccion_segura(monkeypatch):
    monkeypatch.setenv("ENVIRONMENT", "production")
    monkeypatch.setenv("DATABASE_URL", "postgresql+asyncpg://production.example/vita")
    monkeypatch.setenv("AUTH_PROVIDER", "supabase")
    monkeypatch.setenv("SUPABASE_URL", "https://example.supabase.co")
    monkeypatch.setenv("SUPABASE_ANON_KEY", "anon-test")
    monkeypatch.setenv("SUPABASE_SERVICE_ROLE_KEY", "service-test")
    monkeypatch.setenv("CORS_ALLOW_ORIGINS", "https://app.example.com")
    monkeypatch.setenv("FORWARDED_ALLOW_IPS", "10.0.0.1")
    monkeypatch.setenv("EMAIL_PROVIDER", "smtp")
    monkeypatch.setenv("SMTP_HOST", "smtp.example.com")
    monkeypatch.setenv("SMTP_FROM", "VITA <no-reply@example.com>")
    monkeypatch.setenv("INVITACION_CODIGO_SECRETO", "secreto-test")


def test_production_accepts_complete_configuration(monkeypatch):
    _produccion_segura(monkeypatch)

    Settings().validate_runtime_configuration()


def test_production_requires_smtp_for_team_invitations(monkeypatch):
    _produccion_segura(monkeypatch)
    monkeypatch.setenv("EMAIL_PROVIDER", "console")
    monkeypatch.delenv("SMTP_HOST")

    with pytest.raises(RuntimeError, match="EMAIL_PROVIDER=smtp, SMTP_HOST"):
        Settings().validate_runtime_configuration()


def test_production_requires_its_own_invitation_code_secret(monkeypatch):
    # Sin clave propia, el HMAC de los códigos caería en JWT_SECRET, que en
    # producción con Supabase puede quedar con el valor de desarrollo.
    _produccion_segura(monkeypatch)
    monkeypatch.delenv("INVITACION_CODIGO_SECRETO")

    with pytest.raises(RuntimeError, match="INVITACION_CODIGO_SECRETO"):
        Settings().validate_runtime_configuration()


def test_production_uses_https_and_has_no_cookie_sessions(monkeypatch):
    monkeypatch.setattr(settings, "ENVIRONMENT", EnvironmentOption.PRODUCTION)
    monkeypatch.setattr(settings, "AUTH_PROVIDER", "supabase")
    monkeypatch.setattr(settings, "SUPABASE_URL", "https://example.supabase.co")
    monkeypatch.setattr(settings, "SUPABASE_ANON_KEY", "anon-test")
    monkeypatch.setattr(settings, "SUPABASE_SERVICE_ROLE_KEY", "service-test")
    monkeypatch.setattr(settings, "SUPABASE_JWT_SECRET", "jwt-test")
    monkeypatch.setattr(settings, "CORS_ALLOW_ORIGINS", ["https://app.example.com"])
    monkeypatch.setattr(settings, "EMAIL_PROVIDER", "smtp")
    monkeypatch.setattr(settings, "SMTP_HOST", "smtp.example.com")
    monkeypatch.setattr(settings, "SMTP_FROM", "VITA <no-reply@example.com>")
    monkeypatch.setenv("INVITACION_CODIGO_SECRETO", "secreto-test")
    monkeypatch.setenv("DATABASE_URL", "postgresql+asyncpg://production.example/vita")

    app = create_fastapi_app()
    middleware_classes = {item.cls for item in app.user_middleware}

    assert HTTPSRedirectMiddleware in middleware_classes
    assert SessionMiddleware not in middleware_classes


def test_local_environment_does_not_force_https(monkeypatch):
    monkeypatch.setattr(settings, "ENVIRONMENT", EnvironmentOption.LOCAL)

    app = create_fastapi_app()

    assert HTTPSRedirectMiddleware not in {item.cls for item in app.user_middleware}
