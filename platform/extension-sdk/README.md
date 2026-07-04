# Platform SDK

The platform SDK is a separate application-facing artifact boundary.

Application teams should consume SDK packages from a private artifact registry instead of copying platform integration code into every service.

## Packages

- `node/`: npm package published as `@aks-platform/sdk`.
- `python/`: Python package published as `aks-platform-sdk`.
- `go/`: Go module skeleton for Go services.
- `java/`: Maven package skeleton for Java services.
- `dotnet/`: NuGet package skeleton for .NET services.

## Responsibilities

The SDK can wrap:

- Managed Identity credential setup.
- Key Vault secret access.
- Application Insights setup.
- Azure SQL Database connections using Microsoft Entra authentication.
- Common platform configuration conventions.
- `platform.settings/v1` loading and Key Vault secret mapping.

The SDK should not contain:

- Business logic.
- Kubernetes manifests.
- Terraform outputs hardcoded into code.
- Secrets, tenant IDs, subscription IDs, private domains, or client-specific values.

## Artifact Registry

Use a private package registry such as GitHub Packages, Azure Artifacts, or another internal npm registry. Keep publish tokens in CI secrets.

## Platform Settings Contract

Services should read `platform.settings/v1` from `PLATFORM_APP_SETTINGS_PATH`, then fall back to `/app/config/app-settings.json`, then fall back to environment variables for local development.

The shared schema is documented in `platform-settings.md` and `platform-settings.schema.json`.
