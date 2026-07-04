from pydantic import BaseModel


class DatabaseRole(BaseModel):
    name: str
    purpose: str
    permissions: list[str]


class DatabasePrincipal(BaseModel):
    name: str
    type: str
    role: str
    purpose: str
    managedBy: str


class DatabaseAccessModel(BaseModel):
    managedBy: str
    schemaMigrationManagedBy: str
    infrastructureManagedBy: str
    notes: list[str]
    roles: list[DatabaseRole]
    principals: list[DatabasePrincipal]
