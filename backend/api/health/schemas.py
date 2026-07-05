from pydantic import BaseModel


class HealthInfo(BaseModel):
    status: str
    version: str
    uptime_seconds: int
    services: dict[str, str]
