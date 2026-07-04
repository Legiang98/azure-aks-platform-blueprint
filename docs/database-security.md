# Database Security

## Intent

Database security is managed as a platform baseline with Pulumi. The goal is to define safe, reviewable users, roles, grants, identity mappings, and connection references for Azure SQL Database and PostgreSQL Database.

## Scope

- Database users
- Database roles
- Grants and permissions
- Managed Identity and Entra ID mappings
- Connection string references
- Key Vault references when needed

## Non-scope

Database security management does not include application schema migrations. Tables, columns, indexes, views, stored procedures, and seed data must be handled by the application release pipeline.

## Role Pattern

Suggested role names:

- `app_readwrite`
- `app_readonly`
- `migration_runner`
- `reporting_readonly`

Prefer granting permissions to roles, then assigning users or identities to those roles.

## Access Separation

- Application runtime identities should receive only the permissions required to serve traffic.
- Migration identities should be separate from runtime identities.
- Reporting identities should be read-only unless a stronger permission is explicitly justified.

## Secret Handling

Connection strings, passwords, and sensitive references must not be committed. Use Key Vault references and Managed Identity where practical.

Pulumi stack secrets should be encrypted with a secrets provider before any database admin credential is configured. For this blueprint, prefer Azure Key Vault:

```bash
cd platform/database-security
pulumi stack change-secrets-provider \
  "azurekeyvault://<key-vault-name>.vault.azure.net/keys/<key-name>"
```

Set native database admin credentials only as Pulumi secrets or via CI secret injection when a provider needs them. The current Azure SQL flow uses Microsoft Entra authentication, so it does not need a SQL admin password. PostgreSQL may still need native credentials until that provider is revisited.

```bash
pulumi config set --secret postgresql:adminPassword "<postgres-admin-password>"
```

Do not commit Key Vault resource IDs, subscription IDs, passwords, or connection strings. Local stack files may reference a real secrets provider on the operator machine, but examples in this repository must remain generic.

## Provider Layout

Reusable provider code lives under `platform/database-security/providers/`.

- `azure-sql-database.ts`: Entra external users, role-oriented grants, and secret connection string helpers for Azure SQL Database.
- `postgresql-database.ts`: login roles, schema-scoped grants, and secret connection string helpers for PostgreSQL Database. This remains a later focus.

MySQL is intentionally out of scope for this blueprint.

## Future Improvements

- Add environment examples under `platform/database-security/`.
- Add example role definitions with generic placeholders.
- Add preview validation in CI.
