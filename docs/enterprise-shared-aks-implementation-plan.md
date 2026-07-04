# Enterprise Shared AKS Cluster Implementation Plan

This plan translates the Microsoft Tech Community article "Building Enterprise-Grade Shared AKS Clusters: A Guide to Multi-Tenant Kubernetes Architecture" into a step-by-step implementation path for this Terraform repo.

Current repo baseline:

- `infra/resoure_group.tf` creates one resource group in `Southeast Asia`.
- `infra/network.tf` creates one VNet and one AKS subnet.
- `infra/aks.tf` creates one basic AKS cluster with a single default node pool, Azure CNI, and system-assigned identity.

Target outcome:

- A shared AKS platform where multiple application teams can run workloads safely.
- Tenant isolation through namespaces, RBAC, network policies, resource quotas, policy enforcement, and optional dedicated node pools.
- Enterprise operations through private networking, managed identity, centralized ingress, observability, backup planning, and GitOps-friendly bootstrap.

## Reference Material

- Microsoft Tech Community article: https://techcommunity.microsoft.com/blog/azureinfrastructureblog/building-enterprise-grade-shared-aks-clusters-a-guide-to-multi-tenant-kubernetes/4468563
- AKS baseline architecture: https://learn.microsoft.com/en-us/azure/architecture/reference-architectures/containers/aks/baseline-aks
- Azure Policy for AKS: https://learn.microsoft.com/en-us/azure/aks/use-azure-policy

## Phase 0 - Prepare The Repo

Goal: Make the Terraform code easier to evolve before adding enterprise features.

Steps:

1. Rename `infra/resoure_group.tf` to `infra/resource_group.tf`.
2. Add `infra/variables.tf` for environment, location, CIDRs, node sizes, tenant definitions, and tags.
3. Add `infra/outputs.tf` for AKS name, resource group, kubeconfig command, VNet IDs, subnet IDs, and identity principal IDs.
4. Add `infra/locals.tf` for consistent names and shared tags.
5. Add `.gitignore` entries for Terraform state and local files.
6. Move `infra/terraform.tfstate` and `infra/terraform.tfstate.backup` out of source control if this repo is later committed.
7. Pin Terraform and provider versions more explicitly.

Acceptance checks:

```bash
cd infra
terraform fmt -recursive
terraform validate
terraform plan
```

Deliverables:

- Clean Terraform structure.
- No plaintext Terraform state intended for commit.
- Configurable environment naming.

## Phase 1 - Define Tenant Model

Goal: Decide how tenants are represented before creating cluster controls.

Steps:

1. Create a tenant inventory table in `docs/tenant-model.md`.
2. For each tenant, define:
   - Tenant name.
   - Business owner.
   - Workload environment inside the shared AKS cluster, such as `dev` or `prod`.
   - Namespace name.
   - Entra ID group for admins.
   - Entra ID group for developers.
   - CPU and memory quota.
   - Ingress hostname pattern.
   - Data sensitivity.
   - Need for dedicated node pool.
3. Start with namespace-level tenancy as the default.
4. Use dedicated node pools only for tenants that need stronger performance, compliance, GPU, Windows, or noisy-neighbor isolation.
5. Define a simple naming standard:
   - Namespace: `tenant-<name>-<env>`.
   - Node pool: `<name><env>` with AKS node pool name length limits considered.
   - Managed identity: `id-aks-<tenant>-<env>`.

Acceptance checks:

- Every tenant has an owner, namespace, quota, and access model.
- Tenants with special isolation needs are explicitly marked.

Deliverables:

- `docs/tenant-model.md`.
- `docs/tenant-intake-form.md`.
- Initial tenant list that Terraform or Helm values can consume later.

## Phase 2 - Upgrade Network Architecture

Goal: Move from a single flat VNet/subnet into an AKS platform network that supports private access, ingress, private endpoints, and future growth.

Steps:

1. Replace the single broad `10.0.0.0/8` VNet with a deliberate CIDR plan.
2. Split the current subnet into purpose-specific subnets:
   - `snet-aks-system` for system node pool.
   - `snet-aks-user` for shared user node pools.
   - `snet-aks-ingress` for internal ingress load balancers.
   - `snet-aks-private-endpoints` for ACR, Key Vault, and other private endpoints.
   - `snet-aks-api-server` for private AKS API server VNet integration if enabled.
   - Optional `snet-appgw` if using Application Gateway or Application Gateway for Containers.
3. Use Azure CNI Overlay unless you have a strong requirement for VNet-routable pod IPs.
4. Keep pod CIDR and service CIDR separate from VNet and peered networks.
5. Add Network Security Groups where subnet-level filtering is useful.
6. Add route tables if outbound traffic will go through Azure Firewall or a hub network.
7. Plan DNS for private endpoints and private AKS API access.

Example CIDR plan:

| Purpose | CIDR |
| --- | --- |
| VNet | `10.40.0.0/16` |
| System nodes | `10.40.0.0/24` |
| User nodes | `10.40.1.0/22` |
| Ingress | `10.40.8.0/24` |
| Private endpoints | `10.40.9.0/24` |
| API server | `10.40.10.0/28` |
| Pod CIDR | `10.244.0.0/16` |
| Service CIDR | `192.168.0.0/16` |

Acceptance checks:

```bash
terraform plan
```

Then verify:

```bash
az network vnet subnet list \
  --resource-group <resource-group> \
  --vnet-name <vnet-name> \
  --output table
```

Deliverables:

- Updated `infra/network.tf`.
- CIDR plan documented in `docs/network-plan.md`.

## Phase 3 - Harden AKS Cluster Foundation

Goal: Convert the basic AKS cluster into a private, enterprise-ready cluster.

Steps:

1. Separate the system node pool from user node pools.
2. Rename the default node pool from `default` to a system-specific name such as `system`.
3. Add node pool settings:
   - Availability zones where supported.
   - Cluster autoscaler.
   - Node labels.
   - Node taints for system pool.
   - Azure Linux or Ubuntu standard.
   - Ephemeral OS disk if the chosen VM size supports it.
4. Enable managed Microsoft Entra ID integration.
5. Enable Azure RBAC for Kubernetes authorization if it fits your access model.
6. Enable private cluster mode for production.
7. Disable local accounts for production.
8. Configure API server authorized IP ranges only if using a public API endpoint in lower environments.
9. Enable workload identity and OIDC issuer.
10. Enable Azure Policy add-on.
11. Enable secret store CSI driver if workloads need Key Vault integration.
12. Attach ACR with `AcrPull` through managed identity.
13. Use a user-assigned managed identity if you want stable identity lifecycle across cluster replacement.

Acceptance checks:

```bash
az aks show \
  --resource-group <resource-group> \
  --name <cluster-name> \
  --query "{privateCluster:apiServerAccessProfile.enablePrivateCluster, oidc:oidcIssuerProfile.enabled, workloadIdentity:securityProfile.workloadIdentity.enabled}" \
  --output table
```

```bash
kubectl get nodes -o wide
kubectl get ns
```

Deliverables:

- Updated `infra/aks.tf`.
- Optional `infra/identity.tf`.
- Optional `infra/acr.tf`.
- Optional `infra/key_vault.tf`.

## Phase 4 - Implement Tenant Namespaces

Goal: Create isolated Kubernetes namespaces with baseline tenant controls.

Steps:

1. Add a Kubernetes provider or manage tenant bootstrap with Helm/Kustomize/GitOps.
2. For each tenant namespace, create:
   - `Namespace`.
   - `ResourceQuota`.
   - `LimitRange`.
   - RBAC `Role` and `RoleBinding`.
   - Default deny ingress and egress `NetworkPolicy`.
   - Allowed ingress from ingress controller namespace.
   - Allowed egress to DNS and explicitly approved dependencies.
3. Add tenant labels to every namespace:
   - `tenant=<tenant-name>`.
   - `environment=<env>`.
   - `cost-center=<cost-center>`.
   - `data-classification=<classification>`.
4. Add Pod Security Admission labels:
   - `pod-security.kubernetes.io/enforce=restricted`.
   - `pod-security.kubernetes.io/audit=restricted`.
   - `pod-security.kubernetes.io/warn=restricted`.
5. For tenants that need dedicated compute, add node selectors, taints, and tolerations.

Acceptance checks:

```bash
kubectl get ns --show-labels
kubectl describe resourcequota -n tenant-<name>-<env>
kubectl get networkpolicy -n tenant-<name>-<env>
kubectl auth can-i create deployments --as=<tenant-user> -n tenant-<name>-<env>
kubectl auth can-i get secrets --as=<tenant-user> -n kube-system
```

Deliverables:

- `k8s/tenants/<tenant>/namespace.yaml`.
- `k8s/tenants/<tenant>/quota.yaml`.
- `k8s/tenants/<tenant>/rbac.yaml`.
- `k8s/tenants/<tenant>/network-policy.yaml`.

## Phase 5 - Add Policy Guardrails

Goal: Prevent unsafe workloads from entering the shared cluster.

Steps:

1. Enable Azure Policy add-on on AKS.
2. Assign the built-in Kubernetes baseline or restricted policy initiatives.
3. Add policies for:
   - Allowed container registries.
   - Disallow privileged containers.
   - Disallow host networking and host PID/IPC.
   - Require CPU and memory requests/limits.
   - Require read-only root filesystem where possible.
   - Restrict capabilities.
   - Restrict hostPath volumes.
4. Add exceptions only through a documented approval process.
5. Validate policy sync after assignments.

Acceptance checks:

```bash
kubectl get constrainttemplates
kubectl get constraints
```

Test expected rejection:

```bash
kubectl apply -f test/policy/privileged-pod.yaml
```

Expected result: admission webhook denies the privileged pod.

Deliverables:

- `infra/policy.tf`.
- `test/policy/privileged-pod.yaml`.
- `docs/policy-exceptions.md`.

## Phase 6 - Configure Ingress And Traffic Isolation

Goal: Provide shared ingress while keeping tenant routing and certificates manageable.

Steps:

1. Choose one ingress option:
   - NGINX ingress for simpler Kubernetes-native operations.
   - Application Gateway Ingress Controller if you need Azure Application Gateway WAF integration.
   - Application Gateway for Containers if you want the newer managed application load balancing approach.
2. Deploy ingress controller into a dedicated namespace such as `ingress-system`.
3. Use separate ingress classes if different tenants need different ingress policies.
4. Use TLS per tenant hostname.
5. Store certificates in Key Vault or use cert-manager with an approved issuer.
6. Add network policies allowing traffic from ingress namespace to tenant namespaces.
7. Add WAF policy when internet-facing workloads are hosted on the shared cluster.
8. Define hostname ownership rules to avoid tenant conflicts.

Acceptance checks:

```bash
kubectl get ingressclass
kubectl get ingress -A
kubectl get svc -n ingress-system
```

Deliverables:

- `k8s/platform/ingress/`.
- `docs/ingress-standard.md`.

## Phase 7 - Implement Workload Identity And Secrets

Goal: Remove static secrets from workloads and use Microsoft Entra-backed identities.

Steps:

1. Enable AKS workload identity and OIDC issuer.
2. Create user-assigned managed identities for workloads that access Azure resources.
3. Federate Kubernetes service accounts to managed identities.
4. Grant least-privilege Azure RBAC permissions to each workload identity.
5. Deploy Secrets Store CSI Driver for Key Vault integration.
6. Mount Key Vault secrets into workloads only when needed.
7. Prefer application runtime identity access over syncing secrets into Kubernetes secrets.

Acceptance checks:

```bash
kubectl get serviceaccount -n tenant-<name>-<env> -o yaml
az identity federated-credential list \
  --resource-group <resource-group> \
  --identity-name <identity-name>
```

Deliverables:

- `infra/workload_identity.tf`.
- `k8s/tenants/<tenant>/service-account.yaml`.
- `k8s/tenants/<tenant>/secret-provider-class.yaml`.

## Phase 8 - Add Observability And Operations

Goal: Make the shared cluster supportable by a platform team.

Steps:

1. Enable Azure Monitor managed Prometheus.
2. Enable Container Insights or Azure Monitor collection as required.
3. Create Log Analytics workspace.
4. Create Azure Managed Grafana if needed.
5. Add alerts for:
   - Node not ready.
   - Pod crash loops.
   - Pending pods.
   - CPU and memory saturation.
   - Disk pressure.
   - API server errors.
   - Ingress 5xx rate.
   - Policy violations.
6. Add tenant labels to metrics and logs.
7. Create dashboards for platform and tenant views.
8. Define runbooks for common incidents.

Acceptance checks:

```bash
kubectl top nodes
kubectl top pods -A
az monitor log-analytics workspace show \
  --resource-group <resource-group> \
  --workspace-name <workspace-name>
```

Deliverables:

- `infra/monitoring.tf`.
- `docs/operations-runbook.md`.
- `docs/tenant-observability.md`.

## Phase 9 - Add Cost Controls

Goal: Make shared cluster cost transparent and prevent uncontrolled consumption.

Steps:

1. Require tenant labels on namespaces and workloads.
2. Enforce resource requests and limits.
3. Set `ResourceQuota` per namespace.
4. Use separate node pools for materially different workload profiles.
5. Enable cluster autoscaler on user node pools.
6. Add budgets and alerts at resource group or subscription scope.
7. Export Azure cost data by tags.
8. Consider Kubecost or Azure cost analysis patterns for namespace-level reporting.

Acceptance checks:

```bash
kubectl describe resourcequota -A
kubectl get pods -A -o custom-columns=NS:.metadata.namespace,NAME:.metadata.name,CPU_REQ:.spec.containers[*].resources.requests.cpu,MEM_REQ:.spec.containers[*].resources.requests.memory
```

Deliverables:

- Tenant quota standards.
- Cost labels and tags applied across Terraform and Kubernetes manifests.

## Phase 10 - Add GitOps Deployment Flow

Goal: Make cluster configuration reproducible and auditable.

Steps:

1. Choose Flux or Argo CD.
2. Split repo layout into:
   - `infra/` for Azure resources.
   - `k8s/platform/` for cluster-wide add-ons.
   - `k8s/tenants/` for tenant bootstrap.
   - `apps/` for example workloads.
3. Bootstrap GitOps after AKS creation.
4. Require pull requests for tenant onboarding and policy exceptions.
5. Add CI checks:
   - `terraform fmt`.
   - `terraform validate`.
   - `terraform plan`.
   - Kubernetes manifest schema validation.
   - Policy checks.

Acceptance checks:

```bash
kubectl get pods -n flux-system
```

or:

```bash
kubectl get pods -n argocd
```

Deliverables:

- GitOps controller installed.
- Cluster add-ons reconciled from Git.
- Tenant onboarding through pull request.

## Phase 11 - Validate Multi-Tenant Isolation

Goal: Prove tenant boundaries before onboarding real workloads.

Test cases:

1. Tenant A cannot list secrets in Tenant B namespace.
2. Tenant A cannot create workloads in Tenant B namespace.
3. Tenant A pod cannot connect to Tenant B pod unless explicitly allowed.
4. Tenant A cannot deploy privileged pods.
5. Tenant A cannot pull images from unapproved registries.
6. Tenant A is blocked when exceeding namespace quota.
7. Tenant A workload identity cannot access Tenant B Azure resources.
8. Tenant workload can resolve DNS.
9. Tenant workload can reach only approved external dependencies.
10. Platform admins can inspect all namespaces.

Example commands:

```bash
kubectl auth can-i get secrets --as=<tenant-a-user> -n tenant-b-dev
kubectl auth can-i create deployments --as=<tenant-a-user> -n tenant-b-dev
kubectl run net-test --image=mcr.microsoft.com/azure-cli -n tenant-a-dev -- sleep 3600
kubectl exec -n tenant-a-dev net-test -- curl -I http://<tenant-b-service>.<tenant-b-namespace>.svc.cluster.local
```

Expected result:

- Cross-tenant access is denied by RBAC or NetworkPolicy unless there is an approved exception.

Deliverables:

- `docs/isolation-test-plan.md`.
- Repeatable test manifests under `test/isolation/`.

## Phase 12 - Production Readiness

Goal: Confirm the platform is ready for production tenants.

Checklist:

- Private AKS API endpoint is enabled for production.
- Local Kubernetes admin accounts are disabled for production.
- Entra ID group-based access is configured.
- Azure RBAC or Kubernetes RBAC model is documented.
- Network policies are enforced.
- Azure Policy assignments are active.
- Ingress has TLS and WAF where required.
- ACR is private or access-controlled.
- Key Vault access uses managed identity.
- Monitoring and alerts are active.
- Upgrade channel and maintenance window are defined.
- Backup and recovery approach is documented.
- Tenant onboarding and offboarding process is documented.
- Cost ownership tags are present.
- Disaster recovery expectations are documented.

Acceptance checks:

```bash
az aks show \
  --resource-group <resource-group> \
  --name <cluster-name> \
  --output table

kubectl get pods -A
kubectl get networkpolicy -A
kubectl get constraints
kubectl get resourcequota -A
```

Deliverables:

- `docs/production-readiness-checklist.md`.
- Signed-off platform readiness review.

## Suggested Implementation Order For This Repo

1. Clean repo and variables.
2. Rework networking CIDRs and subnets.
3. Rebuild AKS as private, identity-enabled, policy-enabled cluster.
4. Add ACR, Key Vault, private endpoints, and role assignments.
5. Add Kubernetes tenant bootstrap manifests.
6. Add network policies and quotas.
7. Add Azure Policy assignments.
8. Add ingress.
9. Add monitoring.
10. Add GitOps.
11. Run isolation tests.
12. Onboard first real tenant.

## Initial Terraform File Map

Recommended file layout:

```text
infra/
  providers.tf
  variables.tf
  locals.tf
  resource_group.tf
  network.tf
  identity.tf
  acr.tf
  key_vault.tf
  aks.tf
  node_pools.tf
  policy.tf
  monitoring.tf
  outputs.tf
k8s/
  platform/
    ingress/
    monitoring/
    policy-tests/
  tenants/
    example/
      namespace.yaml
      quota.yaml
      limit-range.yaml
      rbac.yaml
      network-policy.yaml
      service-account.yaml
docs/
  enterprise-shared-aks-implementation-plan.md
  tenant-model.md
  network-plan.md
  ingress-standard.md
  policy-exceptions.md
  operations-runbook.md
  isolation-test-plan.md
  production-readiness-checklist.md
```

## First Milestone Scope

The first milestone should avoid doing everything at once. Implement only the following:

1. Repo cleanup and variables.
2. Network subnet split.
3. Private AKS cluster with system and user node pools.
4. Workload identity and Azure Policy enabled.
5. One example tenant namespace with quota, RBAC, and network policy.
6. Basic validation commands documented.

This gives you a working foundation that can be expanded without redesigning the cluster later.
