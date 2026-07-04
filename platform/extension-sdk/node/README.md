# Node Platform SDK

`@aks-platform/sdk` is a small application-facing SDK for the AKS platform blueprint.

It gives application code a stable interface for platform services such as Key Vault, Managed Identity, Application Insights, and Azure SQL Database. Infrastructure values still come from environment variables, Helm values, or Kubernetes secret/config references; the SDK does not hardcode tenant IDs, subscription IDs, vault names, domains, or secrets.

## Install

```bash
npm install @aks-platform/sdk
```

For this public blueprint, the package is not published. Publish it to GitHub Packages, Azure Artifacts, or another private npm registry before using it from application repositories.

## Environment Variables

| Name | Purpose |
| --- | --- |
| `PLATFORM_ENVIRONMENT` | Logical app environment, such as `dev` or `prod`. |
| `PLATFORM_SERVICE_NAME` | Service name used when telemetry is initialized. |
| `PLATFORM_KEY_VAULT_URL` | Key Vault URI, for example `https://<vault-name>.vault.azure.net/`. |
| `APPLICATIONINSIGHTS_CONNECTION_STRING` | Application Insights connection string. |
| `PLATFORM_SQL_SERVER_HOST` | Azure SQL logical server host, for example `<server>.database.windows.net`. |
| `PLATFORM_SQL_DATABASE_NAME` | Azure SQL database name. |

## Usage

```ts
import { createPlatformClient } from "@aks-platform/sdk";

const platform = await createPlatformClient();

await platform.initializeTelemetry();

const connectionString = await platform.keyVault?.getRequiredSecret("app-database-connection");
```

### Key Vault

```ts
const secret = await platform.keyVault?.getRequiredSecret("app01-api-key");
```

### Application Insights

`initializeTelemetry()` configures the native Node.js Application Insights SDK. It enables request, dependency, exception, console, and performance collection for the service process. The connection string should come from Kubernetes secret injection, Key Vault reference flow, or local development environment variables.

```ts
const telemetry = await platform.initializeTelemetry();
telemetry.trackEvent("app01.started", { component: "api" });
await telemetry.flush();
```

### Azure SQL Database

```ts
const rows = await platform.sqlDatabase?.query<{ name: string }>(
  "SELECT name FROM sys.database_principals WHERE type IN ('E', 'X')"
);
```

Azure SQL uses Microsoft Entra authentication. The workload identity running the application must have a corresponding database user and permissions managed by `platform/database-security/`.

## Build

```bash
npm install
npm run build
```

## Publish Example

```bash
npm version patch
npm publish
```

Use a private artifact registry for real platform use. Do not publish internal package names, configuration, or credentials to a public registry.

### GitHub Packages

```bash
npm config set @aks-platform:registry https://npm.pkg.github.com
npm publish
```

### Azure Artifacts

Configure the npm registry URL from your Azure Artifacts feed, then publish from this package directory:

```bash
npm publish --registry <private-npm-registry-url>
```

Keep registry tokens in CI secrets, not in this repository.
