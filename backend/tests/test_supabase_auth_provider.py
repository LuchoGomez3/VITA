"""Pruebas de aislamiento entre clientes Supabase admin y publicos."""

from types import SimpleNamespace
from uuid import UUID

import pytest

from api.auth.providers import AuthProviderError
from api.auth.providers.supabase_provider import SupabaseAuthProvider
from core.config import settings


def test_sign_up_uses_separate_admin_and_public_clients(monkeypatch):
    user_id = UUID("a1d6a70e-9c81-407c-8e97-3cf06db07120")
    admin_api = _AdminApi(user_id)
    public_auth = _PublicAuth(user_id)

    monkeypatch.setattr(
        "api.auth.providers.supabase_provider._get_admin_client",
        lambda: SimpleNamespace(
            auth=SimpleNamespace(admin=admin_api),
        ),
    )
    monkeypatch.setattr(
        "api.auth.providers.supabase_provider._create_public_client",
        lambda: SimpleNamespace(auth=public_auth),
    )

    result = SupabaseAuthProvider()._sign_up_sync(
        "juan@campo.com",
        "Segura123",
    )

    assert result.user_id == user_id
    assert admin_api.created_email == "juan@campo.com"
    assert public_auth.signed_in_email == "juan@campo.com"


def test_sign_up_deletes_credentials_when_initial_login_fails(monkeypatch):
    user_id = UUID("a1d6a70e-9c81-407c-8e97-3cf06db07120")
    admin_api = _AdminApi(user_id)

    monkeypatch.setattr(
        "api.auth.providers.supabase_provider._get_admin_client",
        lambda: SimpleNamespace(
            auth=SimpleNamespace(admin=admin_api),
        ),
    )
    monkeypatch.setattr(
        "api.auth.providers.supabase_provider._create_public_client",
        lambda: SimpleNamespace(auth=_FailingPublicAuth()),
    )

    with pytest.raises(AuthProviderError):
        SupabaseAuthProvider()._sign_up_sync("juan@campo.com", "Segura123")

    assert admin_api.deleted_user_ids == [user_id]


def test_sign_out_revokes_all_supabase_sessions(monkeypatch):
    captured: dict[str, object] = {}

    def fake_post(url, *, headers, timeout):
        captured.update(url=url, headers=headers, timeout=timeout)
        return SimpleNamespace(status_code=204, text="")

    monkeypatch.setattr(settings, "SUPABASE_URL", "https://example.supabase.co")
    monkeypatch.setattr(settings, "SUPABASE_ANON_KEY", "anon-test-key")
    monkeypatch.setattr("api.auth.providers.supabase_provider.httpx.post", fake_post)

    SupabaseAuthProvider()._sign_out_sync("access-token")

    assert captured["url"] == "https://example.supabase.co/auth/v1/logout?scope=global"
    assert captured["headers"] == {
        "apikey": "anon-test-key",
        "Authorization": "Bearer access-token",
    }


def test_verify_token_requires_expected_supabase_issuer(monkeypatch):
    captured: dict[str, object] = {}

    def fake_decode(token, key, *, algorithms, audience, issuer):
        captured.update(
            token=token,
            key=key,
            algorithms=algorithms,
            audience=audience,
            issuer=issuer,
        )
        return {"sub": "a1d6a70e-9c81-407c-8e97-3cf06db07120"}

    monkeypatch.setattr(settings, "SUPABASE_URL", "https://example.supabase.co/")
    monkeypatch.setattr(settings, "SUPABASE_JWT_SECRET", "jwt-test-secret")
    monkeypatch.setattr(
        "api.auth.providers.supabase_provider.jwt.get_unverified_header",
        lambda token: {"alg": "HS256"},
    )
    monkeypatch.setattr("api.auth.providers.supabase_provider.jwt.decode", fake_decode)

    claims = SupabaseAuthProvider().verify_token("signed-token")

    assert claims["sub"] == "a1d6a70e-9c81-407c-8e97-3cf06db07120"
    assert captured["audience"] == "authenticated"
    assert captured["issuer"] == "https://example.supabase.co/auth/v1"


class _AdminApi:
    def __init__(self, user_id: UUID) -> None:
        self._user_id = user_id
        self.created_email: str | None = None
        self.deleted_user_ids: list[UUID] = []

    def create_user(self, credentials: dict[str, object]):
        self.created_email = str(credentials["email"])
        return SimpleNamespace(user=SimpleNamespace(id=self._user_id))

    def delete_user(self, user_id: str) -> None:
        self.deleted_user_ids.append(UUID(user_id))


class _PublicAuth:
    def __init__(self, user_id: UUID) -> None:
        self._user_id = user_id
        self.signed_in_email: str | None = None

    def sign_in_with_password(self, credentials: dict[str, str]):
        self.signed_in_email = credentials["email"]
        session = SimpleNamespace(
            access_token="access-token",
            refresh_token="refresh-token",
            expires_in=3600,
        )
        return SimpleNamespace(
            user=SimpleNamespace(id=self._user_id),
            session=session,
        )


class _FailingPublicAuth:
    def sign_in_with_password(self, credentials: dict[str, str]):
        raise RuntimeError("initial login failed")
