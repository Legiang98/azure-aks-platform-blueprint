from fastapi import APIRouter

from app.models.deployments import DeploymentStatus
from app.services.state_loader import state_loader


router = APIRouter(prefix="/api/deployments", tags=["deployments"])


@router.get("/latest", response_model=DeploymentStatus)
def get_latest_deployment() -> DeploymentStatus:
    return state_loader.load("deployment-status.json", DeploymentStatus)
