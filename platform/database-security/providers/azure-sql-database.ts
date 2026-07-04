import * as pulumi from "@pulumi/pulumi";
import * as mssql from "mssql";

export interface AzureSqlExternalUserResourceInputs {
  host: pulumi.Input<string>;
  database: pulumi.Input<string>;
  username: pulumi.Input<string>;
  objectId?: pulumi.Input<string>;
  isGroup?: pulumi.Input<boolean>;
  clientId?: pulumi.Input<string>;
  canRead?: pulumi.Input<boolean>;
  canWrite?: pulumi.Input<boolean>;
  canAdmin?: pulumi.Input<boolean>;
  canExecute?: pulumi.Input<boolean>;
}

interface AzureSqlExternalUserInputs {
  host: string;
  database: string;
  username: string;
  objectId?: string;
  isGroup?: boolean;
  clientId?: string;
  canRead?: boolean;
  canWrite?: boolean;
  canAdmin?: boolean;
  canExecute?: boolean;
}

type PermissionFlag = "canRead" | "canWrite" | "canAdmin" | "canExecute";

interface Permission {
  flag: PermissionFlag;
  label: string;
  role?: string;
}

const permissions: Permission[] = [
  { flag: "canRead", role: "db_datareader", label: "read" },
  { flag: "canWrite", role: "db_datawriter", label: "write" },
  { flag: "canAdmin", role: "db_ddladmin", label: "DDL admin" },
  { flag: "canExecute", label: "execute" },
];

const azureSqlExternalUserProvider: pulumi.dynamic.ResourceProvider = {
  async create(inputs: AzureSqlExternalUserInputs) {
    return withConnection(inputs, async (connection) => {
      await pulumi.log.info(`Creating Entra user on ${inputs.database}: ${inputs.username}`);
      await connection.request().query(createUserSql(inputs));
      await applyPermissions(connection, inputs);

      const principalId = await getPrincipalId(connection, inputs.username);
      return { id: principalId, outs: inputs };
    });
  },

  async update(_id: string, olds: AzureSqlExternalUserInputs, news: AzureSqlExternalUserInputs) {
    assertImmutableFields(olds, news);

    return withConnection(news, async (connection) => {
      for (const permission of permissions) {
        if (olds[permission.flag] !== news[permission.flag]) {
          await setPermission(connection, news, permission, Boolean(news[permission.flag]));
        }
      }

      return { outs: news };
    });
  },

  async delete(_id: string, props: AzureSqlExternalUserInputs) {
    return withConnection(props, async (connection) => {
      await pulumi.log.info(`Dropping Entra user on ${props.database}: ${props.username}`);
      await connection.request().query(`DROP USER IF EXISTS ${quoteName(props.username)};`);
    });
  },
};

async function withConnection<T>(
  inputs: AzureSqlExternalUserInputs,
  run: (connection: mssql.ConnectionPool) => Promise<T>,
): Promise<T> {
  const connection = await openConnection(inputs);

  try {
    return await run(connection);
  } finally {
    await connection.close();
  }
}

async function openConnection(inputs: AzureSqlExternalUserInputs) {
  const pool = new mssql.ConnectionPool({
    server: inputs.host,
    database: inputs.database,
    authentication: {
      type: "azure-active-directory-default",
      options: {
        clientId: inputs.clientId,
      },
    },
    options: {
      encrypt: true,
      trustServerCertificate: false,
    },
  });

  return pool.connect();
}

function assertImmutableFields(olds: AzureSqlExternalUserInputs, news: AzureSqlExternalUserInputs) {
  for (const field of ["host", "database", "username", "objectId"] as const) {
    if (olds[field] !== news[field]) {
      throw new Error(`${field} cannot be changed`);
    }
  }
}

function createUserSql(inputs: AzureSqlExternalUserInputs): string {
  if (!inputs.objectId) {
    return `
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = ${quoteString(inputs.username)})
BEGIN
  EXEC(${quoteString(`CREATE USER ${quoteName(inputs.username)} FROM EXTERNAL PROVIDER`)});
END;
`;
  }

  const userType = inputs.isGroup ? "X" : "E";

  return `
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = ${quoteString(inputs.username)})
BEGIN
  DECLARE @objectId UNIQUEIDENTIFIER = ${quoteString(inputs.objectId)};
  DECLARE @sid NVARCHAR(MAX) = CONVERT(VARCHAR(MAX), CONVERT(VARBINARY(16), @objectId), 1);
  DECLARE @sql NVARCHAR(MAX) = N'CREATE USER ${quoteName(inputs.username)} WITH SID = ' + @sid + N', TYPE = ${userType};';
  EXEC(@sql);
END;
`;
}

async function applyPermissions(connection: mssql.ConnectionPool, inputs: AzureSqlExternalUserInputs) {
  for (const permission of permissions) {
    if (inputs[permission.flag]) {
      await setPermission(connection, inputs, permission, true);
    }
  }
}

async function setPermission(
  connection: mssql.ConnectionPool,
  inputs: AzureSqlExternalUserInputs,
  permission: Permission,
  enabled: boolean,
) {
  const action = enabled ? "Granting" : "Revoking";
  await pulumi.log.info(`${action} ${permission.label} permission on ${inputs.database} for ${inputs.username}`);

  if (permission.role) {
    await connection.request().query(setRoleSql(permission.role, inputs.username, enabled));
    return;
  }

  const verb = enabled ? "GRANT" : "REVOKE";
  await connection.request().query(`${verb} EXECUTE TO ${quoteName(inputs.username)};`);
}

async function getPrincipalId(connection: mssql.ConnectionPool, username: string): Promise<string> {
  const result = await connection.request().query(
    `SELECT TOP(1) principal_id FROM sys.database_principals WHERE name = ${quoteString(username)};`,
  );

  const principalId = result.recordset[0]?.principal_id;
  if (!principalId) {
    throw new Error(`Azure SQL user '${username}' was not created.`);
  }

  return String(principalId);
}

function setRoleSql(role: string, username: string, enabled: boolean): string {
  const operation = enabled ? "ADD" : "DROP";
  const existsCheck = enabled ? "NOT EXISTS" : "EXISTS";

  return `
IF ${existsCheck} (
  SELECT 1
  FROM sys.database_role_members drm
  INNER JOIN sys.database_principals role_principal
    ON role_principal.principal_id = drm.role_principal_id
  INNER JOIN sys.database_principals member_principal
    ON member_principal.principal_id = drm.member_principal_id
  WHERE role_principal.name = ${quoteString(role)}
    AND member_principal.name = ${quoteString(username)}
)
BEGIN
  ALTER ROLE ${quoteName(role)} ${operation} MEMBER ${quoteName(username)};
END;
`;
}

function quoteName(value: string): string {
  return `[${value.replace(/]/g, "]]")}]`;
}

function quoteString(value: string): string {
  return `N'${value.replace(/'/g, "''")}'`;
}

export class AzureSqlExternalUser extends pulumi.dynamic.Resource {
  public readonly username!: pulumi.Output<string>;

  constructor(name: string, args: AzureSqlExternalUserResourceInputs, opts?: pulumi.CustomResourceOptions) {
    super(azureSqlExternalUserProvider, name, args, opts);
  }
}

export function getEntraConnectionString(
  host: pulumi.Input<string>,
  database: pulumi.Input<string>,
  username: pulumi.Input<string>,
): pulumi.Output<string> {
  return pulumi.secret(pulumi.interpolate`Server=tcp:${host},1433;Initial Catalog=${database};Authentication=Active Directory Default;User ID=${username};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;`);
}
