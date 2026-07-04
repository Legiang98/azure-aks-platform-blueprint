export type PlatformEnvironment = "local" | "dev" | "prod" | string;

export interface PlatformConfig {
  environment: PlatformEnvironment;
  serviceName: string;
  keyVaultUrl?: string;
  applicationInsightsConnectionString?: string;
  sqlServerHost?: string;
  sqlDatabaseName?: string;
}

function readOptionalEnv(name: string): string | undefined {
  const value = process.env[name];
  return value && value.trim().length > 0 ? value.trim() : undefined;
}

export function createPlatformConfigFromEnv(overrides: Partial<PlatformConfig> = {}): PlatformConfig {
  return {
    environment: overrides.environment ?? readOptionalEnv("PLATFORM_ENVIRONMENT") ?? "local",
    serviceName: overrides.serviceName ?? readOptionalEnv("PLATFORM_SERVICE_NAME") ?? readOptionalEnv("APPLICATIONINSIGHTS_ROLE_NAME") ?? "app",
    keyVaultUrl: overrides.keyVaultUrl ?? readOptionalEnv("PLATFORM_KEY_VAULT_URL"),
    applicationInsightsConnectionString:
      overrides.applicationInsightsConnectionString ??
      readOptionalEnv("APPLICATIONINSIGHTS_CONNECTION_STRING") ??
      readOptionalEnv("APPLICATION_INSIGHTS_CONNECTION_STRING"),
    sqlServerHost: overrides.sqlServerHost ?? readOptionalEnv("PLATFORM_SQL_SERVER_HOST"),
    sqlDatabaseName: overrides.sqlDatabaseName ?? readOptionalEnv("PLATFORM_SQL_DATABASE_NAME")
  };
}
