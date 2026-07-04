# Helm Charts

This folder contains reusable Helm charts for the AKS platform blueprint.

## Charts

- `platform-service/`: reusable service chart used by application `HelmRelease` resources.

Application-specific GitOps configuration lives under `k8s/apps/`. Helm chart templates live here so they can be packaged and pushed to ACR as OCI artifacts independently from workload release manifests.

## OCI Publishing

The `platform-service` chart is intended to be published to ACR as an OCI artifact:

```bash
helm package helm/platform-service --destination .artifacts/helm
helm push .artifacts/helm/platform-service-0.1.0.tgz oci://<acr-name>.azurecr.io/helm
```

Flux reads the chart through the `OCIRepository` source in `k8s/flux/clusters/aks-platform/helm-sources.yaml`. Replace `<acr-name>` with the Terraform ACR output before applying it to a real cluster.
