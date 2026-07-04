package io.aksplatform.sdk;

public record PlatformConfig(
    String environment,
    String serviceName,
    String keyVaultUrl,
    String applicationInsightsConnectionString,
    String sqlServerHost,
    String sqlDatabaseName
) {
    public static PlatformConfig fromEnv() {
        return new PlatformConfig(
            env("PLATFORM_ENVIRONMENT", "local"),
            firstEnv("OTEL_SERVICE_NAME", "PLATFORM_SERVICE_NAME", "app"),
            System.getenv("PLATFORM_KEY_VAULT_URL"),
            firstEnv("APPLICATIONINSIGHTS_CONNECTION_STRING", "APPLICATION_INSIGHTS_CONNECTION_STRING", null),
            System.getenv("PLATFORM_SQL_SERVER_HOST"),
            System.getenv("PLATFORM_SQL_DATABASE_NAME")
        );
    }

    private static String env(String name, String fallback) {
        String value = System.getenv(name);
        return value == null || value.isBlank() ? fallback : value;
    }

    private static String firstEnv(String first, String second, String fallback) {
        String value = System.getenv(first);
        return value == null || value.isBlank() ? env(second, fallback) : value;
    }
}
