from pydantic import BaseModel


class ObservabilitySnapshot(BaseModel):
    apiHealth: str
    p95LatencyMs: int
    errorRate: float
    podReadiness: str
    dbConnectivity: str
    lastAlert: str
    metricsEnabled: bool
    logsEnabled: bool
    tracesEnabled: bool
