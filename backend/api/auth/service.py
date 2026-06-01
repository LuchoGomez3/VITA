from datetime import datetime, timedelta, timezone
from typing import Optional

from jose import jwt

from core.config import settings

FAKE_USERS_DB = {
    "admin": {"username": "admin", "password": "admin"},
}


class AuthService:
    def authenticate_user(
        self, username: str, password: str
    ) -> Optional[dict[str, str]]:
        user = FAKE_USERS_DB.get(username)
        if not user or user["password"] != password:
            return None
        return {"username": user["username"]}

    def create_access_token(
        self, data: dict, expires_delta: Optional[timedelta] = None
    ) -> str:
        to_encode = data.copy()
        expire = datetime.now(timezone.utc) + (
            expires_delta
            or timedelta(minutes=settings.JWT_ACCESS_TOKEN_EXPIRE_MINUTES)
        )
        to_encode.update({"exp": expire})
        return jwt.encode(
            to_encode, settings.JWT_SECRET, algorithm=settings.JWT_ALGORITHM
        )
