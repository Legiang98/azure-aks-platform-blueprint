from fastapi import APIRouter

from app.models.database_access import DatabaseAccessModel
from app.services.state_loader import state_loader


router = APIRouter(prefix="/api/database", tags=["database-access"])


@router.get("/access-model", response_model=DatabaseAccessModel)
def get_database_access_model() -> DatabaseAccessModel:
    return state_loader.load("database-access-model.json", DatabaseAccessModel)
