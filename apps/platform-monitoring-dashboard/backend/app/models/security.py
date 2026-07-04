from pydantic import BaseModel


class SecurityControl(BaseModel):
    name: str
    status: str
    category: str
    evidence: str


class SecurityControls(BaseModel):
    controls: list[SecurityControl]
