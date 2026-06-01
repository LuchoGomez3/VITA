from typing import Any, Optional

from pydantic import BaseModel, Field


class Pagination(BaseModel):
    page: int = Field(1, ge=1)
    size: int = Field(10, ge=1, le=100)
    total: Optional[int] = Field(default=None, ge=0)


class StandardResponse(BaseModel):
    success: bool
    data: Optional[Any] = None
    meta: Optional[dict[str, Any]] = None
    errors: Optional[list[dict[str, Any]]] = None
