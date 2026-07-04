from fastapi import APIRouter

from app.models.platform import PlatformSnapshot, PlatformSyncResult
from app.services.state_loader import state_loader


router = APIRouter(prefix="/api/platform", tags=["platform"])


@router.get("/snapshot", response_model=PlatformSnapshot)
def get_platform_snapshot() -> PlatformSnapshot:
    return state_loader.load("platform-snapshot.json", PlatformSnapshot)


@router.post("/sync", response_model=PlatformSyncResult)
def sync_platform_state() -> PlatformSyncResult:
    # TODO: Future collectors may read terraform output -json, pulumi stack output --json,
    # kubectl get deployments/services/pods, gh run list, and Azure Monitor / Log Analytics queries.
    # This V1 endpoint is intentionally demo-safe and does not execute external commands.
    return PlatformSyncResult(
        status="completed",
        mode="demo",
        message="Platform state sync completed using local demo data.",
        generatedFiles=[
            "platform-snapshot.json",
            "resource-inventory.json",
            "database-access-model.json",
            "deployment-status.json",
            "observability-snapshot.json",
            "security-controls.json",
        ],
    )
