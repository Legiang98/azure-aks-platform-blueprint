from fastapi import APIRouter

from app.models.resources import ResourceInventory
from app.services.state_loader import state_loader


router = APIRouter(prefix="/api/platform", tags=["resources"])


@router.get("/resources", response_model=ResourceInventory)
def get_resource_inventory() -> ResourceInventory:
    return state_loader.load("resource-inventory.json", ResourceInventory)
