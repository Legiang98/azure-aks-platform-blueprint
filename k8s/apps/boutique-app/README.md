# Boutique App GitOps Releases

`boutique-app` is deployed with Flux `HelmRelease` resources. The reusable Helm chart template lives under `helm/platform-app-service`.

## Layout

- `dev/<service>/`: dev Flux `HelmRelease`, chart values, and `platform.settings/v1` ConfigMap.
- `prod/<service>/`: prod Flux `HelmRelease`, chart values, and `platform.settings/v1` ConfigMap.

Current service folders:

- `adservice`
- `cartservice`
- `checkoutservice`
- `currencyservice`
- `emailservice`
- `frontend`
- `loadgenerator`
- `paymentservice`
- `productcatalogservice`
- `recommendationservice`
- `shippingservice`
- `shoppingassistantservice`

The chart assumes the platform baseline has already created the target namespace, quotas, and network policies under `k8s/tenants/boutique/`.

## Local Render

```bash
helm template frontend helm/platform-app-service --namespace tenant-boutique-dev \
  --values k8s/apps/boutique-app/dev/frontend/values.yaml
```

## Flux Assumption

The sample `HelmRelease` files reference a Flux `GitRepository` named `platform-blueprint` in `flux-system`. Rename that source reference to match your Flux bootstrap.

The Flux reconciliation graph is defined under `k8s/flux/clusters/aks-platform/apps.yaml`. App releases depend on the shared Gateway and the matching tenant baseline.

Each microservice has a cluster-level Flux `Kustomization` so Flux can reconcile services independently while still sharing the same reusable Helm chart template.

Each service folder also includes a local `kustomization.yaml` with:

- `app-settings.yaml`
- `helmrelease.yaml`

This keeps the Flux path explicit: the Flux `Kustomization` CRD points to the service folder, and the local Kustomize file tells kustomize-controller which resources belong to that service release.

## HA And Autoscaling Placement

The boutique app follows the AKS Option A capacity model:

- Critical services run on the baseline on-demand user node pool.
- Burst/non-critical services opt in to NAP-managed spot capacity.
- Prod critical services use HPA and PDB through the reusable Helm chart.

The detailed design lives in `docs/aks-ha-autoscaling-plan.md`.

## Image Publishing

Microservice images are built by `.github/workflows/boutique-app-images.yaml` with a GitHub Actions matrix. Each service is built as a separate parallel job and pushed to ACR under:

```text
<acr-name>.azurecr.io/boutique/<service>:<tag>
```

The workflow uses GitHub OIDC through `azure/login` and expects these repository variables:

- `AZURE_CLIENT_ID`
- `AZURE_TENANT_ID`
- `AZURE_SUBSCRIPTION_ID`
- `AZURE_ACR_NAME`

The workflow does not store static Azure credentials in the repository.

## Service-Level Settings Contract

Future reusable Helm chart work should use one service chart and one `HelmRelease` per microservice. Each service folder can carry:

- `values.yaml` for Kubernetes deployment values.
- `app-settings.yaml` for the mounted `platform.settings/v1` ConfigMap.

The application reads `PLATFORM_APP_SETTINGS_PATH`, loads `app-settings.json`, and asks the platform SDK to resolve Key Vault secret mappings.

The ConfigMap does not contain secret values. It only maps application environment names to Azure Key Vault secret names. The application fetches secrets through the platform SDK using Managed Identity or Workload Identity.
