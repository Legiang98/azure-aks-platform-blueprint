# Database Security

Pulumi project for database security baselines in this AKS platform blueprint.

Reusable provider code lives under `providers/` and currently supports:

- Azure SQL Database
- PostgreSQL Database

This boundary manages users, roles, grants, identity mappings, and connection string helpers. It does not manage application schema migrations.

The current implementation focuses on Azure SQL Database first. Azure SQL access uses Microsoft Entra authentication through the local or CI Azure identity running Pulumi, so it does not require a SQL administrator password. PostgreSQL remains available as a provider skeleton and can be revisited later.

## Secret Handling

Use a Pulumi secrets provider before setting database administrator passwords or generated connection strings. For this blueprint, Azure Key Vault is the preferred secrets provider because encrypted Pulumi config is protected by an Azure Key Vault key and Azure RBAC instead of a local passphrase.

Create or select a Key Vault key, then configure the stack:

```bash
cd platform/database-security

pulumi stack select dev
pulumi stack change-secrets-provider \
  "azurekeyvault://<key-vault-name>.vault.azure.net/keys/<key-name>"
```

Set sensitive values only with Pulumi secret config when a provider needs native database credentials. Azure SQL does not need an admin password in the current Entra-only flow. PostgreSQL may still need one until it is refactored to an Entra-based pattern.

```bash
pulumi config set --secret postgresql:adminPassword "<postgres-admin-password>"
```

Do not commit real subscription IDs, Key Vault resource IDs, passwords, connection strings, or tenant-specific identifiers. The stack can use a real Key Vault locally, but repository examples should stay portfolio-safe.

The database access providers also wrap generated connection strings with `pulumi.secret(...)` so outputs remain encrypted by the configured secrets provider.

## App Access Models

Application-specific database access lives under `apps/`. For example, `apps/app01.ts` declares the runtime, migration, and reporting identities for app01 while the Azure SQL provider stays reusable.

The root `index.ts` imports app modules that should be part of the stack:

```ts
import "./apps/app01";
```

If an app module is imported, Pulumi will evaluate it and create its resources from TypeScript. Do not use config-level `enabled` switches for app access models; keep that decision in the TypeScript composition layer.

The app01 stack config contains only the database target and access model:

```yaml
aks-platform-database-security:app01AzureSql:
  host: sql-aks-platform.database.windows.net
  database: sqldb-platform-app
  terraformState:
    storageAccountName: <tfstate-storage-account>
    containerName: <tfstate-container>
    key: platform.tfstate
  runtimeUser:
    username: app01-runtime-mi
    terraformIdentityKey: app01_runtime
    canRead: true
    canWrite: true
    canExecute: true
```

Pulumi reads Terraform remote state from Azure Blob and uses the `managed_identity_principal_ids` output as Azure SQL user object IDs. Run Pulumi only when the machine or pipeline has access to the Terraform state blob, network access to Azure SQL, and an active Entra identity with database admin rights.
