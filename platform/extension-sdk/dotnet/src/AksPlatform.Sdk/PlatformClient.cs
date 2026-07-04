using Azure.Core;
using Azure.Identity;

namespace AksPlatform.Sdk;

public sealed class PlatformClient
{
    private PlatformClient(
        PlatformConfig config,
        TokenCredential credential,
        KeyVaultClient? keyVault)
    {
        Config = config;
        Credential = credential;
        KeyVault = keyVault;
    }

    public PlatformConfig Config { get; }

    public TokenCredential Credential { get; }

    public KeyVaultClient? KeyVault { get; }

    public static PlatformClient Create(
        PlatformConfig? config = null,
        TokenCredential? credential = null)
    {
        var resolvedConfig = config ?? PlatformConfig.FromEnvironment();
        var resolvedCredential = credential ?? new DefaultAzureCredential();
        var keyVault = resolvedConfig.KeyVaultUrl is not null
            ? new KeyVaultClient(resolvedConfig.KeyVaultUrl, resolvedCredential)
            : null;

        return new PlatformClient(resolvedConfig, resolvedCredential, keyVault);
    }

    public PlatformTelemetryClient InitializeTelemetry(bool enabled = true) =>
        PlatformTelemetry.Configure(
            serviceName: Config.ServiceName,
            connectionString: Config.ApplicationInsightsConnectionString,
            enabled: enabled);
}
