from fastapi import APIRouter

from app.models.security import SecurityControls
from app.services.state_loader import state_loader


router = APIRouter(prefix="/api/security", tags=["security"])


@router.get("/controls", response_model=SecurityControls)
def get_security_controls() -> SecurityControls:
    return state_loader.load("security-controls.json", SecurityControls)
