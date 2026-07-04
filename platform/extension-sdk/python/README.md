# Python Platform SDK

`aks-platform-sdk` is the Python SDK for application code running on the AKS platform blueprint.

It wraps:

- Key Vault secret access
- Application Insights event tracking
- Azure SQL Database connections with Microsoft Entra authentication

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

```python
from aks_platform_sdk import create_platform_client

platform = create_platform_client()
platform.initialize_telemetry()

secret = platform.key_vault.get_required_secret("app01-api-key") if platform.key_vault else None
rows = platform.sql_database.query("SELECT name FROM sys.database_principals") if platform.sql_database else []
```

Do not hardcode tenant IDs, subscription IDs, secrets, private domains, or production connection strings.
