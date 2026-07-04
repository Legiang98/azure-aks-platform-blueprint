# Kubernetes GitOps Layout

This folder contains Kubernetes delivery configuration for the AKS platform blueprint.

## Layout

- `flux/`: Flux bootstrap and reconciliation graph.
- `platform/`: cluster-level platform policies such as AKS NAP node provisioning.
- `tenants/`: platform-owned tenant baselines such as namespaces, quotas, limit ranges, and network policies.
- `apps/`: application Helm charts and Flux `HelmRelease` definitions.
- `gateway/`: shared Gateway API resources and Key Vault TLS sync manifests.

## Reconciliation Model

Flux is the primary deployment path:

```text
k8s/flux/bootstrap
  -> k8s/flux/clusters/aks-platform/node-provisioning.yaml
  -> k8s/flux/clusters/aks-platform/gateway.yaml
  -> k8s/flux/clusters/aks-platform/tenants.yaml
  -> k8s/flux/clusters/aks-platform/apps.yaml
```

Tenant baseline resources are reconciled before app releases. Application workloads are packaged with Helm and reconciled with Flux `HelmRelease`.

This repo does not use local Kustomize overlays for app packaging. The only `Kustomization` objects are Flux CRDs under `k8s/flux/`.
