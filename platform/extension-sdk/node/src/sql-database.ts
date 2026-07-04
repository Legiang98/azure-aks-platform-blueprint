import { createDefaultCredential, type TokenCredentialLike } from "./credential.js";

export interface SqlDatabaseClientOptions {
  server: string;
  database: string;
  credential?: TokenCredentialLike;
  connectionTimeoutMs?: number;
  requestTimeoutMs?: number;
}

export interface SqlDatabaseClient {
  query<T = Record<string, unknown>>(sql: string, parameters?: Record<string, unknown>): Promise<T[]>;
  close(): Promise<void>;
}

export function createEntraSqlConnectionString(server: string, database: string): string {
  if (!server || server.trim().length === 0) {
    throw new Error("Azure SQL server host is required.");
  }

  if (!database || database.trim().length === 0) {
    throw new Error("Azure SQL database name is required.");
  }

  return [
    `Server=tcp:${server.trim()},1433`,
    `Initial Catalog=${database.trim()}`,
    "Authentication=Active Directory Default",
    "MultipleActiveResultSets=False",
    "Encrypt=True",
    "TrustServerCertificate=False",
    "Connection Timeout=30"
  ].join(";");
}

export async function createSqlDatabaseClient(options: SqlDatabaseClientOptions): Promise<SqlDatabaseClient> {
  const credential = options.credential ?? await createDefaultCredential();
  const token = await credential.getToken("https://database.windows.net/.default");
  const accessToken = getAccessTokenValue(token);

  const mssql = await import("mssql");
  const pool = new mssql.ConnectionPool({
    server: options.server,
    database: options.database,
    authentication: {
      type: "azure-active-directory-access-token",
      options: {
        token: accessToken
      }
    },
    connectionTimeout: options.connectionTimeoutMs,
    requestTimeout: options.requestTimeoutMs,
    options: {
      encrypt: true,
      trustServerCertificate: false
    }
  });

  const connection = await pool.connect();

  return {
    async query<T = Record<string, unknown>>(sql: string, parameters: Record<string, unknown> = {}): Promise<T[]> {
      const request = connection.request();

      for (const [name, value] of Object.entries(parameters)) {
        request.input(name, value);
      }

      const result = await request.query(sql);
      return result.recordset as T[];
    },

    async close(): Promise<void> {
      await connection.close();
    }
  };
}

function getAccessTokenValue(token: unknown): string {
  if (typeof token === "object" && token !== null && "token" in token) {
    const value = (token as { token?: unknown }).token;
    if (typeof value === "string" && value.length > 0) {
      return value;
    }
  }

  throw new Error("Unable to acquire Azure SQL access token.");
}
