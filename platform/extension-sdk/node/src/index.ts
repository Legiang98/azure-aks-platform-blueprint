export {
  createPlatformClient,
  type PlatformClient,
  type PlatformClientOptions
} from "./platform-client.js";
export {
  createPlatformConfigFromEnv,
  type PlatformConfig,
  type PlatformEnvironment
} from "./platform-config.js";
export {
  createKeyVaultClient,
  type KeyVaultClient,
  type KeyVaultClientOptions
} from "./key-vault.js";
export {
  configurePlatformTelemetry,
  type PlatformTelemetryClient,
  type PlatformTelemetryOptions
} from "./telemetry.js";
export {
  createEntraSqlConnectionString,
  createSqlDatabaseClient,
  type SqlDatabaseClient,
  type SqlDatabaseClientOptions
} from "./sql-database.js";
