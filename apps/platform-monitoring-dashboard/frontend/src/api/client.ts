const API_BASE_URL = import.meta.env.VITE_API_BASE_URL ?? "";

export interface PlatformComponent {
  name: string;
  status: string;
  managedBy: string;
  description?: string;
}

export interface PlatformSnapshot {
  environment: string;
  region: string;
  platformName: string;
  lastUpdated: string;
  components: PlatformComponent[];
}

export interface ResourceInventoryItem {
  layer: string;
  resource: string;
  status: string;
  managedBy: string;
  purpose: string;
}

export interface ResourceInventory {
  resources: ResourceInventoryItem[];
}

export interface DatabaseAccessModel {
  managedBy: string;
  schemaMigrationManagedBy: string;
  infrastructureManagedBy: string;
  notes: string[];
  roles: Array<{ name: string; purpose: string; permissions: string[] }>;
  principals: Array<{ name: string; type: string; role: string; purpose: string; managedBy: string }>;
}

export interface DeploymentStatus {
  version: string;
  environment: string;
  status: string;
  startedAt: string;
  completedAt: string;
  steps: Array<{ name: string; status: string; details?: string; startedAt?: string; completedAt?: string }>;
}

export interface ObservabilitySnapshot {
  apiHealth: string;
  p95LatencyMs: number;
  errorRate: number;
  podReadiness: string;
  dbConnectivity: string;
  lastAlert: string;
  metricsEnabled: boolean;
  logsEnabled: boolean;
  tracesEnabled: boolean;
}

export interface SecurityControls {
  controls: Array<{ name: string; status: string; category: string; evidence: string }>;
}

export interface SyncResult {
  status: string;
  mode: string;
  message: string;
  generatedFiles: string[];
}

async function request<T>(path: string, options?: RequestInit): Promise<T> {
  const response = await fetch(`${API_BASE_URL}${path}`, {
    headers: { "Content-Type": "application/json" },
    ...options
  });

  if (!response.ok) {
    throw new Error(`Request failed: ${response.status} ${response.statusText}`);
  }

  return response.json() as Promise<T>;
}

export const api = {
  platformSnapshot: () => request<PlatformSnapshot>("/api/platform/snapshot"),
  resourceInventory: () => request<ResourceInventory>("/api/platform/resources"),
  databaseAccessModel: () => request<DatabaseAccessModel>("/api/database/access-model"),
  latestDeployment: () => request<DeploymentStatus>("/api/deployments/latest"),
  observabilitySnapshot: () => request<ObservabilitySnapshot>("/api/observability/snapshot"),
  securityControls: () => request<SecurityControls>("/api/security/controls"),
  syncPlatformState: () => request<SyncResult>("/api/platform/sync", { method: "POST" })
};
