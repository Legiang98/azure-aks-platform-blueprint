from fastapi import APIRouter


router = APIRouter(tags=["health"])


@router.get("/health")
def health() -> dict[str, str]:
    return {
        "status": "healthy",
        "service": "azure-platform-monitoring-center-api",
        "version": "0.1.0",
    }
