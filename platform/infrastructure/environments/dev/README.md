# Platform Infrastructure

`platform` is currently a SQL-focused Terraform environment.

For this phase, it provisions only:

- Resource group
- Azure SQL logical server
- Azure SQL elastic pool
- Azure SQL database
- App managed identities for database access

Database users, roles, grants, and privilege management are intentionally handled by Pulumi under `platform/database-security/`. Application schema migrations are handled by the application release pipeline.

Terraform outputs `managed_identity_principal_ids`; copy those values into Pulumi `app01AzureSql` user `objectId` fields so Pulumi can create Azure SQL Entra users without requiring SQL password authentication.

## Deferred Modules

The reusable modules for AKS, networking, VPN, monitoring, Key Vault, private endpoints, backup vault, and container registry remain in `platform/infrastructure/modules/`, but they are not instantiated from this environment right now.

This keeps the active Terraform plan small while the database infrastructure and Pulumi-managed database access model are being developed.

## Commands

```bash
export ARM_SUBSCRIPTION_ID="<subscription-id>"

terraform -chdir=platform/infrastructure/environments/platform init \
  -backend-config="resource_group_name=<tfstate-resource-group>" \
  -backend-config="storage_account_name=<tfstate-storage-account>" \
  -backend-config="container_name=<tfstate-container>" \
  -backend-config="key=platform.tfstate"

terraform -chdir=platform/infrastructure/environments/platform fmt -recursive
terraform -chdir=platform/infrastructure/environments/platform validate
terraform -chdir=platform/infrastructure/environments/platform plan
```

Backend values are supplied at init time so this public blueprint does not commit subscription IDs or real storage account identifiers.

## Safety

Do not commit real tenant IDs, subscription IDs, secrets, private domains, production IPs, kubeconfigs, or company/client-specific values.

Terraform creates Azure SQL infrastructure and managed identities only. Database access and schema migration stay outside this Terraform root.
