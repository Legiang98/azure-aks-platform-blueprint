# Kubernetes Platform Manifests

This folder contains platform-owned Kubernetes resources such as tenant namespaces, quotas, limit ranges, and network policies.

Application workloads are intentionally not stored here. App teams package workloads as Helm charts under `k8s/apps/`, and Flux reconciles the app releases after the platform namespace baseline exists.

## Flux Reconciliation

Tenant baselines are reconciled by Flux from `k8s/flux/clusters/aks-platform/tenants.yaml`.

## Manual Apply

Use this only for local testing or break-glass validation:

```bash
kubectl apply -f k8s/tenants/boutique/dev
kubectl apply -f k8s/tenants/boutique/prod
```
