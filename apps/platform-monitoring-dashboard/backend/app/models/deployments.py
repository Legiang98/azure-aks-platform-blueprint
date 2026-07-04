from pydantic import BaseModel


class DeploymentStep(BaseModel):
    name: str
    status: str
    startedAt: str | None = None
    completedAt: str | None = None
    details: str | None = None


class DeploymentStatus(BaseModel):
    version: str
    environment: str
    status: str
    startedAt: str
    completedAt: str
    steps: list[DeploymentStep]
