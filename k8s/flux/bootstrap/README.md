# Flux Bootstrap

This folder documents the GitOps entry point for the AKS platform blueprint.

The committed `gotk-sync.yaml` is a portfolio-safe example. Replace the placeholder Git URL before applying it to a real cluster, or generate the equivalent files with `flux bootstrap`.

## Bootstrap Example

```bash
flux bootstrap github \
  --owner=<github-owner> \
  --repository=<repository-name> \
  --branch=main \
  --path=k8s/flux/bootstrap \
  --personal
```

## Reconciliation Flow

```text
GitRepository platform-blueprint
  -> k8s/flux/clusters/aks-platform/gateway.yaml
  -> k8s/flux/clusters/aks-platform/tenants.yaml
  -> k8s/flux/clusters/aks-platform/apps.yaml
```

Application workloads are deployed with Flux `HelmRelease`. Tenant isolation resources are reconciled separately so namespaces, quotas, and network policies exist before app releases are installed.
