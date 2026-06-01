from datetime import timedelta

from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm

from api.auth.dependencies import get_current_user
from api.auth.service import AuthService
from api.shared.schemas import StandardResponse
from core.config import settings

router = APIRouter(prefix="/auth", tags=["auth"])

auth_service = AuthService()


@router.post("/login", response_model=StandardResponse)
async def login(form_data: OAuth2PasswordRequestForm = Depends()):
    user = auth_service.authenticate_user(form_data.username, form_data.password)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect username or password",
        )
    access_token_expires = timedelta(minutes=settings.JWT_ACCESS_TOKEN_EXPIRE_MINUTES)
    token = auth_service.create_access_token(
        {"sub": user["username"]}, expires_delta=access_token_expires
    )
    return StandardResponse(
        success=True, data={"access_token": token, "token_type": "bearer"}
    )


@router.get("/me", response_model=StandardResponse)
async def me(current_user: dict = Depends(get_current_user)):
    return StandardResponse(success=True, data={"username": current_user["username"]})
