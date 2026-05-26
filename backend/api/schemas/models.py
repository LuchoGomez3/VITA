from pydantic import BaseModel, Field
from typing import Any, Optional, Dict


class Pagination(BaseModel):
    page: int = Field(1, ge=1)
    size: int = Field(10, ge=1, le=100)
    total: Optional[int] = Field(default=None, ge=0)


class StandardResponse(BaseModel):
    success: bool
    data: Optional[Any] = None
    meta: Optional[Dict[str, Any]] = None
    errors: Optional[list[Dict[str, Any]]] = None


class HealthInfo(BaseModel):
    status: str
    version: str
    uptime_seconds: int
    services: Dict[str, str]


class CompaniesInfo(BaseModel):
    companies: list[str]
