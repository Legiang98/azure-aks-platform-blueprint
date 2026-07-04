# AKS HA And Autoscaling Plan

This blueprint uses Option A for AKS capacity:

```text
AKS cluster
├── system node pool
│   └── Terraform-managed, on-demand, system workloads only
├── baseline user node pool
│   └── Terraform-managed, on-demand, critical application workloads
└── NAP spot NodePool
    └── AKS Node Auto Provisioning, spot, burst/non-critical workloads
```

## Why This Pattern

- System components should not run on spot capacity.
- Critical application services should have stable baseline capacity.
- Spot capacity is useful for burst traffic, background workers, load generation, and non-critical services.
- HPA scales pods first. NAP then provisions nodes when pending pods need capacity.

## Terraform AKS Capacity Shape

The AKS module supports:

- Default system node pool labels and taints.
- Terraform-managed user node pools.
- User node pool labels and taints.

The intended baseline user node pool should be on-demand and labeled:

```hcl
user_node_pools = {
  baseline = {
    name           = "userbase"
    mode           = "User"
    priority       = "Regular"
    vm_size        = "Standard_B2s"
    vnet_subnet_id = module.network["aks"].subnet_ids["aks_apps"]
    node_count     = 1
    node_labels = {
      "aks-platform.azure.com/node-purpose" = "user"
      "aks-platform.azure.com/capacity"     = "on-demand"
    }
  }
}
```

Do not enable classic cluster autoscaler for NAP-managed spot capacity. NAP is responsible for provisioning the spot nodes through Kubernetes `NodePool` policy.

## NAP Spot Policy

The spot capacity policy lives in:

```text
k8s/platform/node-provisioning/spot-nodepool.yaml
```

It creates a Karpenter `NodePool` named `spot-user` with:

- `karpenter.sh/capacity-type = spot`
- Linux amd64 nodes
- `aks-platform.azure.com/capacity=spot`
- `aks-platform.azure.com/node-purpose=user`
- A `NoSchedule` taint so workloads must explicitly opt in to spot.

## Workload Placement

Baseline on-demand workloads use:

```yaml
nodeSelector:
  aks-platform.azure.com/node-purpose: user
  aks-platform.azure.com/capacity: on-demand
```

Spot workloads use:

```yaml
nodeSelector:
  aks-platform.azure.com/node-purpose: user
  aks-platform.azure.com/capacity: spot
tolerations:
  - key: aks-platform.azure.com/capacity
    operator: Equal
    value: spot
    effect: NoSchedule
```

Current service split:

- Baseline: `frontend`, `cartservice`, `checkoutservice`, `paymentservice`, `productcatalogservice`, `currencyservice`, `shippingservice`
- Spot: `adservice`, `emailservice`, `recommendationservice`, `shoppingassistantservice`, `loadgenerator`

## HA Controls

The reusable chart supports:

- HPA through `autoscaling`.
- PDB through `pdb`.
- Topology spread through `topologySpreadConstraints`.
- Node placement through `nodeSelector` and `tolerations`.

For prod, critical baseline services should use:

- `autoscaling.enabled = true`
- `autoscaling.minReplicas = 2`
- `pdb.enabled = true`
- `pdb.minAvailable = 1`

## Validation

Render the application chart values:

```bash
for values in $(find k8s/apps/boutique-app -name values.yaml -type f | sort); do
  service=$(basename "$(dirname "$values")")
  env=$(basename "$(dirname "$(dirname "$values")")")
  helm template "$service" helm/platform-service \
    --namespace "tenant-boutique-$env" \
    --values "$values" >/tmp/render-$env-$service.yaml
done
```

Build the Flux cluster root:

```bash
kubectl kustomize k8s/flux/clusters/aks-platform
```

After NAP is enabled on the AKS cluster and Flux is bootstrapped:

```bash
kubectl get nodepool
kubectl describe nodepool spot-user
kubectl get nodes -L aks-platform.azure.com/capacity,aks-platform.azure.com/node-purpose
kubectl get hpa -A
kubectl get pdb -A
```

## Known Caveats

- NAP must be enabled on the AKS cluster before applying the `NodePool` policy.
- NAP and classic cluster autoscaler should not be used for the same capacity strategy.
- Spot nodes can be reclaimed. Only opt in workloads that can tolerate interruption.
- Traffic Manager only adds real HA when there are at least two independent endpoints or clusters.
