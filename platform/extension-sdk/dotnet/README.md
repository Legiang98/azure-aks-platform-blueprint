# .NET Platform SDK

`AksPlatform.Sdk` is the .NET SDK for application code running on the AKS platform blueprint.

It wraps:

- Default Azure credential setup
- Key Vault secret access
- Application Insights / Azure Monitor setup
- Azure SQL Database connection strings using Microsoft Entra authentication

## Environment Variables

| Name | Purpose |
| --- | --- |
| `PLATFORM_ENVIRONMENT` | Logical app environment. |
| `PLATFORM_SERVICE_NAME` | Service name for telemetry. |
| `PLATFORM_KEY_VAULT_URL` | Key Vault URI. |
| `APPLICATIONINSIGHTS_CONNECTION_STRING` | Application Insights connection string. |
| `PLATFORM_SQL_SERVER_HOST` | Azure SQL logical server host. |
| `PLATFORM_SQL_DATABASE_NAME` | Azure SQL database name. |

## Usage

```csharp
using AksPlatform.Sdk;

var platform = PlatformClient.Create();

platform.InitializeTelemetry();

var secret = platform.KeyVault is not null
    ? await platform.KeyVault.GetRequiredSecretAsync("app01-api-key")
    : null;

var connectionString = SqlDatabase.CreateEntraConnectionString(
    platform.Config.SqlServerHost!,
    platform.Config.SqlDatabaseName!);
```

Publish this package to a private NuGet feed such as Azure Artifacts or GitHub Packages before using it from application repositories.
