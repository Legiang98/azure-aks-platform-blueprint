# Platform Infrastructure

`platform` is currently a SQL-focused Terraform environment.

For this phase, it provisions only:

- Resource group
- Azure SQL logical server
- Azure SQL elastic pool
- Azure SQL database
- App managed identities for database access
- GitHub Actions managed identity for OIDC-based CI/CD
- Azure Container Registry for container images and Helm OCI artifacts

Database users, roles, grants, and privilege management are intentionally handled by Pulumi under `platform/database-security/`. Application schema migrations are handled by the application release pipeline.

Terraform outputs `managed_identity_principal_ids`; copy those values into Pulumi `app01AzureSql` user `objectId` fields so Pulumi can create Azure SQL Entra users without requiring SQL password authentication.

## Deferred Modules

The reusable modules for AKS, networking, VPN, monitoring, Key Vault, private endpoints, and backup vault remain in `platform/infrastructure/modules/`, but they are not instantiated from this environment right now.

This keeps the active Terraform plan small while the database infrastructure and Pulumi-managed database access model are being developed.

## Commands

```bash
export ARM_SUBSCRIPTION_ID="<subscription-id>"

terraform -chdir=platform/infrastructure/environments/dev init
terraform -chdir=platform/infrastructure/environments/dev fmt -recursive
terraform -chdir=platform/infrastructure/environments/dev validate
terraform -chdir=platform/infrastructure/environments/dev plan
```

The Terraform backend block is intentionally preserved in `providers.tf`. Do not remove or rewrite it unless explicitly requested.

## Safety

Do not commit real tenant IDs, subscription IDs, secrets, private domains, production IPs, kubeconfigs, or company/client-specific values.

Terraform creates Azure SQL infrastructure, managed identities, and ACR only in this active baseline. Database access and schema migration stay outside this Terraform root.
