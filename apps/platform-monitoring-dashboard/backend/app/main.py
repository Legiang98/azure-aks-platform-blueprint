from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.routers import database_access, deployments, health, observability, platform, resources, security


app = FastAPI(
    title="Azure Platform Monitoring Center API",
    version="0.1.0",
    description="Demo-safe platform monitoring API backed by local JSON state files.",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:5173",
        "http://127.0.0.1:5173",
    ],
    allow_credentials=False,
    allow_methods=["GET", "POST"],
    allow_headers=["*"],
)

app.include_router(health.router)
app.include_router(platform.router)
app.include_router(resources.router)
app.include_router(database_access.router)
app.include_router(deployments.router)
app.include_router(observability.router)
app.include_router(security.router)
