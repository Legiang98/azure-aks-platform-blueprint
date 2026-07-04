declare module "@azure/identity" {
  import type { TokenCredentialLike } from "./credential.js";

  export class DefaultAzureCredential implements TokenCredentialLike {
    getToken(scopes: string | string[], options?: unknown): Promise<unknown>;
  }
}

declare module "@azure/keyvault-secrets" {
  import type { TokenCredentialLike } from "./credential.js";

  export class SecretClient {
    constructor(vaultUrl: string, credential: TokenCredentialLike);
    getSecret(name: string): Promise<{ value?: string }>;
  }
}

declare module "applicationinsights" {
  export interface TelemetryClient {
    trackEvent(event: { name: string; properties?: Record<string, string> }): void;
    flush(options?: { callback?: () => void }): void;
  }

  export interface Configuration {
    setAutoCollectRequests(value: boolean): Configuration;
    setAutoCollectPerformance(value: boolean, collectExtendedMetrics?: boolean): Configuration;
    setAutoCollectExceptions(value: boolean): Configuration;
    setAutoCollectDependencies(value: boolean): Configuration;
    setAutoCollectConsole(value: boolean, collectConsoleLog?: boolean): Configuration;
    setUseDiskRetryCaching(value: boolean): Configuration;
    start(): void;
  }

  export function setup(connectionString?: string): Configuration;
  export const defaultClient: TelemetryClient | undefined;
}

declare module "mssql" {
  export interface ConnectionPoolConfig {
    server: string;
    database: string;
    authentication?: {
      type: string;
      options?: Record<string, unknown>;
    };
    connectionTimeout?: number;
    requestTimeout?: number;
    options?: {
      encrypt?: boolean;
      trustServerCertificate?: boolean;
    };
  }

  export interface Request {
    input(name: string, value: unknown): Request;
    query<T = Record<string, unknown>>(sql: string): Promise<{ recordset: T[] }>;
  }

  export class ConnectionPool {
    constructor(config: ConnectionPoolConfig);
    connect(): Promise<ConnectionPool>;
    request(): Request;
    close(): Promise<void>;
  }
}
