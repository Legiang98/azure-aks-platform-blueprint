# Platform Settings Contract

`platform.settings/v1` is the shared application configuration contract for services running on the AKS platform blueprint.

The contract is language-neutral. Node, Python, .NET, Go, and Java SDKs should all load the same JSON shape and expose equivalent behavior.

## Detection Order

SDKs should detect settings in this order:

1. Read `PLATFORM_APP_SETTINGS_PATH` when it is set.
2. Read `/app/config/app-settings.json` when the default file exists.
3. Fall back to platform environment variables such as `PLATFORM_ENVIRONMENT`, `PLATFORM_SERVICE_NAME`, and `PLATFORM_KEY_VAULT_URL`.
4. Use local defaults only when no platform settings are present.

## Secret Mapping

Applications do not receive secret values from Kubernetes ConfigMaps.

The settings file maps application environment names to Azure Key Vault secret names:

```json
{
  "keyVault": {
    "urlEnv": "PLATFORM_KEY_VAULT_URL",
    "secretMappings": [
      {
        "name": "appInsights",
        "env": "APPLICATIONINSIGHTS_CONNECTION_STRING",
        "secretName": "boutique-dev-appinsights-connection-string",
        "required": true
      }
    ]
  }
}
```

The SDK should resolve a mapped secret by:

1. Looking up the mapping by `env`.
2. Reading the Key Vault URL from `keyVault.urlEnv`, then `PLATFORM_KEY_VAULT_URL`.
3. Fetching `secretName` from Key Vault using Managed Identity or Workload Identity.
4. Caching the value in memory for the process lifetime.

The default API should return secrets to application code. Exporting mapped secrets into process environment variables should be opt-in for legacy services.

## Common SDK API

Recommended conceptual API:

```text
loadSettings(path?)
getSetting(path)
getDependency(name)
getSecretMapping(envName)
getMappedSecret(envName)
resolveSecretMappings()
```

Each language can use native naming conventions, but behavior should stay equivalent.

## Safety

The settings file may contain:

- Tenant, app, service, and environment names.
- Service dependency URLs inside the cluster.
- Key Vault secret names.
- Feature flags.

The settings file must not contain:

- Secret values.
- Tokens or passwords.
- Real tenant IDs or subscription IDs.
- Private domains or production IP addresses.
- Kubeconfigs or cloud credentials.
