namespace AksPlatform.Sdk;

public sealed record PlatformConfig(
    string Environment,
    string ServiceName,
    string? KeyVaultUrl,
    string? ApplicationInsightsConnectionString,
    string? SqlServerHost,
    string? SqlDatabaseName)
{
    public static PlatformConfig FromEnvironment() =>
        new(
            Environment: Read("PLATFORM_ENVIRONMENT") ?? "local",
            ServiceName: Read("PLATFORM_SERVICE_NAME") ?? Read("APPLICATIONINSIGHTS_ROLE_NAME") ?? "app",
            KeyVaultUrl: Read("PLATFORM_KEY_VAULT_URL"),
            ApplicationInsightsConnectionString:
                Read("APPLICATIONINSIGHTS_CONNECTION_STRING") ??
                Read("APPLICATION_INSIGHTS_CONNECTION_STRING"),
            SqlServerHost: Read("PLATFORM_SQL_SERVER_HOST"),
            SqlDatabaseName: Read("PLATFORM_SQL_DATABASE_NAME"));

    private static string? Read(string name)
    {
        var value = System.Environment.GetEnvironmentVariable(name);
        return string.IsNullOrWhiteSpace(value) ? null : value.Trim();
    }
}
