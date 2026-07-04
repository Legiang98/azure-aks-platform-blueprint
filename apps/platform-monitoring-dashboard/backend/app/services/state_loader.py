import json
from pathlib import Path
from typing import TypeVar

from fastapi import HTTPException, status
from pydantic import BaseModel, ValidationError


ModelT = TypeVar("ModelT", bound=BaseModel)


class StateLoader:
    def __init__(self, data_dir: Path | None = None) -> None:
        self.data_dir = data_dir or Path(__file__).resolve().parents[2] / "data"

    def load(self, file_name: str, model: type[ModelT]) -> ModelT:
        path = self.data_dir / file_name
        if not path.exists():
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Demo state file not found: {file_name}",
            )

        try:
            with path.open("r", encoding="utf-8") as handle:
                payload = json.load(handle)
            return model.model_validate(payload)
        except json.JSONDecodeError as exc:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Demo state file is invalid JSON: {file_name}",
            ) from exc
        except ValidationError as exc:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Demo state file does not match the expected schema: {file_name}",
            ) from exc


state_loader = StateLoader()
