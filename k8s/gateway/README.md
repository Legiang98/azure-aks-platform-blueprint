# Envoy Gateway

This folder contains the repo-owned Gateway API resources for the lab.

Envoy Gateway itself is installed from the official versioned upstream manifest. The local `gateway.yaml` file creates:

- `gateway-system` namespace for shared Gateway resources.
- `GatewayClass` named `envoy`.
- `EnvoyProxy` named `shared-public-proxy`.
- Public HTTP `Gateway` named `shared-public`.

Tenant routes are packaged in the app Helm chart and reconciled by Flux:

- `helm/platform-app-service/templates/httproute.yaml`
- `k8s/apps/boutique-app/dev/frontend/helmrelease.yaml`
- `k8s/apps/boutique-app/prod/frontend/helmrelease.yaml`

## Install Envoy Gateway

```bash
kubectl apply --server-side -f https://github.com/envoyproxy/gateway/releases/download/v1.8.1/install.yaml
kubectl wait --timeout=5m -n envoy-gateway-system deployment/envoy-gateway --for=condition=Available
```

## Flux Reconciliation

The shared Gateway resources are reconciled by Flux from `k8s/flux/clusters/aks-platform/gateway.yaml`.

## Manual Apply

```bash
kubectl apply -f k8s/gateway/gateway.yaml
```

## Sync TLS Certificate From Key Vault

Replace placeholders in `k8s/gateway/keyvault-tls-sync.yaml`:

```bash
terraform -chdir=platform/infrastructure/environments/platform output -raw gateway_tls_identity_client_id
terraform -chdir=platform/infrastructure/environments/platform output -raw tenant_id
```

Then apply:

```bash
kubectl apply -f k8s/gateway/keyvault-tls-sync.yaml
kubectl rollout restart deployment/keyvault-tls-sync -n gateway-system
kubectl get secret example-com-tls -n gateway-system
```

The sync deployment must keep running. Secrets Store CSI only syncs the Kubernetes TLS Secret while a pod mounts the `SecretProviderClass`.

If `/mnt/secrets-store` contains `tls.crt` and `tls.key` but the Kubernetes Secret is still missing, restart the sync deployment:

```bash
kubectl rollout restart deployment/keyvault-tls-sync -n gateway-system
kubectl get secret example-com-tls -n gateway-system
```

## Tenant Baseline

Tenant baselines are reconciled by Flux from `k8s/flux/clusters/aks-platform/tenants.yaml`.

Applications are reconciled by Flux through the Helm releases under `k8s/apps/boutique-app/`.

## Validate

```bash
kubectl get gatewayclass
kubectl get gateway -A
kubectl get httproute -A
kubectl get svc -n envoy-gateway-system
```

Get the public gateway address:

```bash
kubectl get gateway shared-public -n gateway-system
```

Point these DNS records to the gateway address:

- `boutique-app-dev.example.com`
- `boutique-app.example.com`

## Notes

The shared Gateway allows routes only from namespaces with this label:

```yaml
shared-gateway-access: "true"
```

Both tenant namespaces currently include that label.

The HTTPS listener expects this Kubernetes TLS Secret in `gateway-system`:

```text
example-com-tls
```

That Secret is synced from Azure Key Vault by `k8s/gateway/keyvault-tls-sync.yaml`.

The `shared-public` Gateway references `shared-public-proxy` through `spec.infrastructure.parametersRef`. That EnvoyProxy config adds this toleration and priority class to the generated Envoy data-plane pods:

```yaml
priorityClassName: system-cluster-critical
tolerations:
  - key: CriticalAddonsOnly
    operator: Exists
    effect: NoSchedule
```

This allows the generated Envoy proxy deployment to run on the AKS system node pool when that pool uses `only_critical_addons_enabled = true`.
