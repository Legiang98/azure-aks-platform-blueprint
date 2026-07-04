from pydantic import BaseModel


class ResourceInventoryItem(BaseModel):
    layer: str
    resource: str
    status: str
    managedBy: str
    purpose: str


class ResourceInventory(BaseModel):
    resources: list[ResourceInventoryItem]
