from datetime import datetime, timedelta, timezone
from typing import Optional, Dict
from jose import jwt, JWTError
from fastapi import Depends, HTTPException, status, Query
from fastapi.security import OAuth2PasswordBearer
from core.config import Config

config = Config()
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/v1/auth/login", auto_error=False)

FAKE_USERS_DB = {
    "admin": {"username": "admin", "password": "admin"}
}

class AuthService:
    def authenticate_user(self, username: str, password: str) -> Optional[Dict[str, str]]:
        user = FAKE_USERS_DB.get(username)
        if not user or user["password"] != password:
            return None
        return {"username": user["username"]}

    def create_access_token(self, data: dict, expires_delta: Optional[timedelta] = None) -> str:
        to_encode = data.copy()
        expire = datetime.now(timezone.utc) + (expires_delta or timedelta(minutes=config.JWT_ACCESS_TOKEN_EXPIRE_MINUTES))
        to_encode.update({"exp": expire})
        encoded_jwt = jwt.encode(to_encode, config.JWT_SECRET_KEY, algorithm=config.JWT_ALGORITHM)
        return encoded_jwt

def get_current_user(token: Optional[str] = Depends(oauth2_scheme), token_query: Optional[str] = Query(default=None, alias="token")) -> Dict[str, str]:
    # Prefer token passed as query param for Swagger simplicity; fallback to Authorization header
    effective_token = token_query or token

    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )

    if not effective_token:
        raise credentials_exception

    try:
        payload = jwt.decode(effective_token, config.JWT_SECRET_KEY, algorithms=[config.JWT_ALGORITHM])
        username: str = payload.get("sub")  # type: ignore
        if username is None:
            raise credentials_exception
    except JWTError:
        raise credentials_exception
    user = FAKE_USERS_DB.get(username)
    if user is None:
        raise credentials_exception
    return {"username": username} 