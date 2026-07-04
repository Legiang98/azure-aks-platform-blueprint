# Azure Platform Monitoring Center

Azure Platform Monitoring Center is a portfolio/demo platform service for visualizing AKS platform state.

It is not a static portfolio page. It is a real dashboard/API skeleton that can run locally during development and later run inside AKS as an internal platform service.

## Purpose

The service demonstrates how a platform team could expose a read-only view of:

- Platform health
- Azure resource inventory
- Database access model
- Deployment status
- Observability snapshot
- Security controls

V1 is intentionally demo-safe. It reads local JSON files only and does not execute Terraform, Pulumi, kubectl, Azure CLI, GitHub CLI, or any destructive operations.

## Architecture

```text
apps/platform-monitoring-center/
├── backend/   # FastAPI API reading local demo JSON state
├── frontend/  # React + Vite dashboard
└── deploy/    # Kubernetes manifests and Helm chart skeleton
```

The intended AKS deployment is internal/private. Add authentication and authorization before exposing this outside a trusted platform environment.

## Backend API

| Method | Path | Purpose |
| --- | --- | --- |
| `GET` | `/health` | API healthcheck |
| `GET` | `/api/platform/snapshot` | Platform component health |
| `GET` | `/api/platform/resources` | Resource inventory |
| `GET` | `/api/database/access-model` | Database access model |
| `GET` | `/api/deployments/latest` | Latest deployment status |
| `GET` | `/api/observability/snapshot` | Observability metrics snapshot |
| `GET` | `/api/security/controls` | Security control checklist |
| `POST` | `/api/platform/sync` | Demo-only local state sync result |

## Demo Data Model

Demo state files live under `backend/data/`:

- `platform-snapshot.json`
- `resource-inventory.json`
- `database-access-model.json`
- `deployment-status.json`
- `observability-snapshot.json`
- `security-controls.json`

The database access model documents the intended boundary:

- Terraform manages Azure SQL infrastructure.
- Pulumi manages users, roles, grants, and identity mappings.
- Schema migrations are handled by the application release pipeline.

## Local Development

Backend:

```bash
cd apps/platform-monitoring-center/backend
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
uvicorn app.main:app --reload
```

Frontend:

```bash
cd apps/platform-monitoring-center/frontend
npm install
npm run dev
```

The Vite dev server proxies `/api` and `/health` to `http://localhost:8000`.

## Docker

Backend:

```bash
docker build -t platform-monitoring-center-api:0.1.0 apps/platform-monitoring-center/backend
docker run --rm -p 8000:8000 platform-monitoring-center-api:0.1.0
```

Frontend:

```bash
docker build -t platform-monitoring-center-web:0.1.0 apps/platform-monitoring-center/frontend
docker run --rm -p 8080:80 platform-monitoring-center-web:0.1.0
```

For separate frontend/API hosting, pass a build-time API base URL:

```bash
docker build \
  --build-arg VITE_API_BASE_URL=http://localhost:8000 \
  -t platform-monitoring-center-web:0.1.0 \
  apps/platform-monitoring-center/frontend
```

## AKS Deployment Plan

Raw manifests live under `deploy/k8s/`.

```bash
kubectl apply -f apps/platform-monitoring-center/deploy/k8s/namespace.yaml
kubectl apply -f apps/platform-monitoring-center/deploy/k8s/
```

Helm skeleton lives under `deploy/helm/`.

```bash
helm template platform-monitoring-center apps/platform-monitoring-center/deploy/helm
```

The placeholder ingress host is `platform-monitoring.local`. Replace image repositories and host values before deploying to a real cluster.

## Security Notes

- This is a portfolio/demo platform service.
- It currently uses local demo JSON data.
- It should run as an internal platform service inside AKS, not as a public unauthenticated admin portal.
- It does not execute real infrastructure changes.
- It is read-only/demo-safe by default.
- Do not add real secrets, tenant IDs, subscription IDs, private domains, kubeconfigs, or production IPs.

## Future Improvements

Real collectors may later be added for:

- `terraform output -json`
- `pulumi stack output --json`
- `kubectl get deployments/services/pods`
- `gh run list`
- Azure Monitor and Log Analytics queries

Before enabling real collectors, add authentication, authorization, rate limits, audit logging, and explicit read-only execution boundaries.
