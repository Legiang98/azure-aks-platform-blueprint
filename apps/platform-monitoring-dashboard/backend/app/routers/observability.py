from fastapi import APIRouter

from app.models.observability import ObservabilitySnapshot
from app.services.state_loader import state_loader


router = APIRouter(prefix="/api/observability", tags=["observability"])


@router.get("/snapshot", response_model=ObservabilitySnapshot)
def get_observability_snapshot() -> ObservabilitySnapshot:
    return state_loader.load("observability-snapshot.json", ObservabilitySnapshot)
