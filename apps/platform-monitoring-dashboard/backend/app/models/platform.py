from pydantic import BaseModel


class PlatformComponent(BaseModel):
    name: str
    status: str
    managedBy: str
    description: str | None = None


class PlatformSnapshot(BaseModel):
    environment: str
    region: str
    platformName: str
    lastUpdated: str
    components: list[PlatformComponent]


class PlatformSyncResult(BaseModel):
    status: str
    mode: str
    message: str
    generatedFiles: list[str]
