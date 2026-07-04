# Terraform Refactor Plan

## Intent

Refactor the Azure infrastructure code into reusable Terraform modules with one shared `platform` environment for the multi-tenant AKS baseline.

This is a public portfolio/demo blueprint. Do not add proprietary client code, production credentials, tenant IDs, subscription IDs, internal domains, real production IPs, kubeconfigs, or company-specific infrastructure configuration.

## Target Structure

```text
platform/infrastructure/
├── modules/
│   ├── resource-group/
│   ├── network/
│   ├── vnet-peering/
│   ├── vpn-vm/
│   ├── aks/
│   ├── key-vault/
│   ├── azure-sql/
│   ├── backup-vault/
│   ├── private-endpoint/
│   ├── private-dns/
│   ├── monitoring/
│   ├── managed-identity/
│   └── container-registry/
└── environments/
    └── platform/
        ├── main.tf
        ├── providers.tf
        ├── variables.tf
        ├── outputs.tf
        ├── platform.auto.tfvars.example
        └── README.md
    └── portoflio-static-site/
        ├── main.tf
        ├── providers.tf
        ├── variables.tf
        ├── outputs.tf
        ├── portfolio-static-site.auto.tfvars.example
        └── README.md
```

Do not create separate Terraform `dev`, `stg`, or `prod` environment folders for this blueprint. The supported infrastructure environment is:

- `platform`: shared AKS platform baseline. Tenant/application environments are separated inside Kubernetes.

## Refactor Rules

- Keep modules reusable and environment-agnostic.
- Keep environment-specific values in each environment folder or `platform.auto.tfvars.example`.
- Do not hardcode secrets, tenant IDs, subscription IDs, private domains, real IPs, kubeconfigs, or company/client-specific values.
- Keep AzureRM backend settings in `backend "azurerm" {}` blocks and pass real backend values through `terraform init -backend-config`.
- Prefer Managed Identity, Workload Identity, OIDC, Key Vault references, and least-privilege access.
- Keep module inputs explicit and typed.
- Keep outputs limited to operationally useful non-secret values.
- Do not manage database schema in Terraform.

## Module Responsibilities

- `resource-group`: resource group naming, location, and baseline tags.
- `network`: VNet, subnets, route tables, and network security boundaries.
- `vnet-peering`: peering between platform VNets.
- `vpn-vm`: small Linux VM for WireGuard Portal installation through Ansible.
- `aks`: AKS cluster, node pools, OIDC issuer, workload identity, and cluster security settings.
- `key-vault`: vault configuration, RBAC mode, soft delete, purge protection, and secret reference patterns.
- `azure-sql`: Azure SQL logical server, elastic pools, and database infrastructure only, not schema objects.
- `backup-vault`: Data Protection Backup Vault foundation and managed identity for AKS backup workflows.
- `private-endpoint`: private endpoint resources and subnet integration for services such as Azure SQL.
- `private-dns`: private DNS zones and VNet links, including SQL private link resolution.
- `monitoring`: diagnostic settings, Log Analytics, alert rule examples, and dashboard references.
- `managed-identity`: user-assigned identities and federated identity credentials.
- `container-registry`: Azure Container Registry and pull permissions.

## Environment Guidance

### Platform

`platform` is the shared baseline. It may use cost-conscious demo defaults, but should still model safer architecture boundaries such as separate VPN, AKS, and data VNets.

### Portfolio Static Site

`portoflio-static-site` is an isolated Terraform root for the Azure Static Web App and its local static website source under `site/`. It uses a separate backend state key and should not be coupled to AKS lifecycle changes.

## Migration Steps

1. Keep the current `platform` environment working.
2. Create reusable modules under `platform/infrastructure/modules/`.
3. Move one resource area at a time into a module.
4. Wire the module from `platform` with `source = "../../modules/<module-name>"`.
5. Keep tenant and application environment separation in Kubernetes manifests and release pipelines.
6. Run `terraform fmt -recursive`.
7. Run validation for each environment when providers are available.
8. Update docs after each module migration.

When refactoring resources that already exist in state, use `terraform state mv` to preserve resources under the new module addresses before running a plan.

## Validation

Preferred commands:

```bash
terraform -chdir=platform/infrastructure fmt -recursive
terraform -chdir=platform/infrastructure/environments/platform init
terraform -chdir=platform/infrastructure/environments/platform validate
```
