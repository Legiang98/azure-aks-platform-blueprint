import { createDefaultCredential, type TokenCredentialLike } from "./credential.js";
import { createKeyVaultClient, type KeyVaultClient } from "./key-vault.js";
import { createPlatformConfigFromEnv, type PlatformConfig } from "./platform-config.js";
import { createSqlDatabaseClient, type SqlDatabaseClient } from "./sql-database.js";
import { configurePlatformTelemetry, type PlatformTelemetryClient } from "./telemetry.js";

export interface PlatformClientOptions {
  config?: Partial<PlatformConfig>;
  credential?: TokenCredentialLike;
  telemetryEnabled?: boolean;
}

export interface PlatformClient {
  config: PlatformConfig;
  credential: TokenCredentialLike;
  keyVault?: KeyVaultClient;
  sqlDatabase?: SqlDatabaseClient;
  initializeTelemetry(): Promise<PlatformTelemetryClient>;
}

export async function createPlatformClient(options: PlatformClientOptions = {}): Promise<PlatformClient> {
  const config = createPlatformConfigFromEnv(options.config);
  const credential = options.credential ?? await createDefaultCredential();
  const keyVault = config.keyVaultUrl
    ? await createKeyVaultClient({ vaultUrl: config.keyVaultUrl, credential })
    : undefined;
  const sqlDatabase = config.sqlServerHost && config.sqlDatabaseName
    ? await createSqlDatabaseClient({
      server: config.sqlServerHost,
      database: config.sqlDatabaseName,
      credential
    })
    : undefined;

  return {
    config,
    credential,
    keyVault,
    sqlDatabase,
    async initializeTelemetry(): Promise<PlatformTelemetryClient> {
      return configurePlatformTelemetry({
        serviceName: config.serviceName,
        connectionString: config.applicationInsightsConnectionString,
        enabled: options.telemetryEnabled
      });
    }
  };
}
