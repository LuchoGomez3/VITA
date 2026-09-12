"""Pruebas de compensacion entre Supabase Auth y el perfil de usuario."""

from uuid import UUID

import pytest
from sqlalchemy.exc import IntegrityError

from api.auth.providers import AuthProviderError, AuthResult
from api.auth.providers.local_provider import LocalAuthProvider
from api.modules.usuarios.schemas import UsuarioRegistroCreate
from api.modules.usuarios.exceptions import UsuarioYaRegistradoError
from api.modules.usuarios.service import UsuarioService

_USER_ID = UUID("a1d6a70e-9c81-407c-8e97-3cf06db07120")


@pytest.mark.anyio
async def test_registration_deletes_credentials_when_profile_creation_fails(
    session,
    monkeypatch,
):
    provider = _CompensatingAuthProvider()
    service = UsuarioService(session, provider)
    profile_error = RuntimeError("profile insert failed")

    async def fail_profile_creation(_usuario):
        raise profile_error

    monkeypatch.setattr(service.repository, "create", fail_profile_creation)

    with pytest.raises(RuntimeError) as raised:
        await service.registrar(_registration_data())

    assert raised.value is profile_error
    assert provider.deleted_user_ids == [_USER_ID]


@pytest.mark.anyio
async def test_registration_preserves_original_error_when_compensation_fails(
    session,
    monkeypatch,
):
    provider = _CompensatingAuthProvider(delete_fails=True)
    service = UsuarioService(session, provider)
    profile_error = RuntimeError("profile insert failed")

    async def fail_profile_creation(_usuario):
        raise profile_error

    monkeypatch.setattr(service.repository, "create", fail_profile_creation)

    with pytest.raises(RuntimeError) as raised:
        await service.registrar(_registration_data())

    assert raised.value is profile_error
    assert provider.deleted_user_ids == [_USER_ID]


@pytest.mark.anyio
async def test_registration_maps_concurrent_unique_violation_to_conflict(
    session,
    monkeypatch,
):
    provider = _CompensatingAuthProvider()
    service = UsuarioService(session, provider)

    async def fail_profile_creation(_usuario):
        raise IntegrityError("insert usuarios", {}, RuntimeError("duplicate"))

    monkeypatch.setattr(service.repository, "create", fail_profile_creation)

    with pytest.raises(UsuarioYaRegistradoError):
        await service.registrar(_registration_data())

    assert provider.deleted_user_ids == [_USER_ID]


class _CompensatingAuthProvider(LocalAuthProvider):
    def __init__(self, *, delete_fails: bool = False) -> None:
        self.delete_fails = delete_fails
        self.deleted_user_ids: list[UUID] = []

    async def sign_up(self, email: str, password: str) -> AuthResult:
        return AuthResult(
            user_id=_USER_ID,
            access_token="access-token",
            refresh_token="refresh-token",
            expires_in=3600,
        )

    async def delete_user(self, user_id: UUID) -> None:
        self.deleted_user_ids.append(user_id)
        if self.delete_fails:
            raise AuthProviderError("compensation failed")


def _registration_data() -> UsuarioRegistroCreate:
    return UsuarioRegistroCreate(
        nombre="Juan",
        apellido="Perez",
        cuit="20111111112",
        email="juan@campo.com",
        password="Segura123",
    )
