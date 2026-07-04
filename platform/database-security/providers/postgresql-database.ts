import * as pulumi from "@pulumi/pulumi";
import { Client } from "pg";

export type PostgresqlAccessRole =
  | "app_readonly"
  | "app_readwrite"
  | "migration_runner"
  | "reporting_readonly";

export interface PostgresqlConnectionArgs {
  host: pulumi.Input<string>;
  port?: pulumi.Input<number>;
  database: pulumi.Input<string>;
  adminUsername: pulumi.Input<string>;
  adminPassword: pulumi.Input<string>;
  ssl?: pulumi.Input<boolean>;
}

export interface PostgresqlRoleArgs extends PostgresqlConnectionArgs {
  username: pulumi.Input<string>;
  password: pulumi.Input<string>;
  schema?: pulumi.Input<string>;
  roles?: pulumi.Input<pulumi.Input<PostgresqlAccessRole>[]>;
}

interface PostgresqlRoleInputs {
  host: string;
  port?: number;
  database: string;
  adminUsername: string;
  adminPassword: string;
  ssl?: boolean;
  username: string;
  password: string;
  schema?: string;
  roles?: PostgresqlAccessRole[];
}

function quoteIdent(value: string): string {
  return `"${value.replace(/"/g, '""')}"`;
}

function quoteLiteral(value: string): string {
  return `'${value.replace(/'/g, "''")}'`;
}

function getClient(inputs: PostgresqlRoleInputs): Client {
  return new Client({
    host: inputs.host,
    port: inputs.port ?? 5432,
    database: inputs.database,
    user: inputs.adminUsername,
    password: inputs.adminPassword,
    ssl: inputs.ssl ?? true,
  });
}

function grantStatements(username: string, schema: string, roles: PostgresqlAccessRole[] = []): string[] {
  const user = quoteIdent(username);
  const targetSchema = quoteIdent(schema);
  const statements: string[] = [`GRANT USAGE ON SCHEMA ${targetSchema} TO ${user}`];

  for (const role of roles) {
    switch (role) {
      case "app_readonly":
      case "reporting_readonly":
        statements.push(`GRANT SELECT ON ALL TABLES IN SCHEMA ${targetSchema} TO ${user}`);
        statements.push(`ALTER DEFAULT PRIVILEGES IN SCHEMA ${targetSchema} GRANT SELECT ON TABLES TO ${user}`);
        break;
      case "app_readwrite":
        statements.push(`GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA ${targetSchema} TO ${user}`);
        statements.push(`GRANT USAGE, SELECT, UPDATE ON ALL SEQUENCES IN SCHEMA ${targetSchema} TO ${user}`);
        statements.push(`ALTER DEFAULT PRIVILEGES IN SCHEMA ${targetSchema} GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO ${user}`);
        statements.push(`ALTER DEFAULT PRIVILEGES IN SCHEMA ${targetSchema} GRANT USAGE, SELECT, UPDATE ON SEQUENCES TO ${user}`);
        break;
      case "migration_runner":
        statements.push(`GRANT CREATE ON SCHEMA ${targetSchema} TO ${user}`);
        statements.push(`GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA ${targetSchema} TO ${user}`);
        statements.push(`GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA ${targetSchema} TO ${user}`);
        break;
    }
  }

  return Array.from(new Set(statements));
}

const postgresqlDatabaseRoleProvider: pulumi.dynamic.ResourceProvider = {
  async create(inputs: PostgresqlRoleInputs): Promise<pulumi.dynamic.CreateResult> {
    const client = getClient(inputs);
    const schema = inputs.schema ?? "public";

    await client.connect();
    try {
      await client.query(`CREATE ROLE ${quoteIdent(inputs.username)} LOGIN PASSWORD ${quoteLiteral(inputs.password)}`);
      for (const statement of grantStatements(inputs.username, schema, inputs.roles)) {
        await client.query(statement);
      }

      return {
        id: `${inputs.database}/${inputs.username}`,
        outs: { ...inputs, schema },
      };
    } finally {
      await client.end();
    }
  },

  async diff(_id: string, olds: PostgresqlRoleInputs, news: PostgresqlRoleInputs): Promise<pulumi.dynamic.DiffResult> {
    const replaces = [];
    if (olds.host !== news.host) replaces.push("host");
    if (olds.database !== news.database) replaces.push("database");
    if (olds.username !== news.username) replaces.push("username");
    if (olds.password !== news.password) replaces.push("password");

    const oldRoles = [...(olds.roles ?? [])].sort().join(",");
    const newRoles = [...(news.roles ?? [])].sort().join(",");
    const oldSchema = olds.schema ?? "public";
    const newSchema = news.schema ?? "public";

    return {
      changes: replaces.length > 0 || oldRoles !== newRoles || oldSchema !== newSchema,
      replaces,
      deleteBeforeReplace: replaces.length > 0,
    };
  },

  async update(_id: string, _olds: PostgresqlRoleInputs, news: PostgresqlRoleInputs): Promise<pulumi.dynamic.UpdateResult> {
    const client = getClient(news);
    const schema = news.schema ?? "public";

    await client.connect();
    try {
      for (const statement of grantStatements(news.username, schema, news.roles)) {
        await client.query(statement);
      }
      return { outs: { ...news, schema } };
    } finally {
      await client.end();
    }
  },

  async delete(_id: string, props: PostgresqlRoleInputs): Promise<void> {
    const client = getClient(props);

    await client.connect();
    try {
      await client.query(`DROP ROLE IF EXISTS ${quoteIdent(props.username)}`);
    } finally {
      await client.end();
    }
  },
};

export class PostgresqlDatabaseRole extends pulumi.dynamic.Resource {
  public readonly username!: pulumi.Output<string>;

  constructor(name: string, args: PostgresqlRoleArgs, opts?: pulumi.CustomResourceOptions) {
    super(postgresqlDatabaseRoleProvider, name, args, opts);
  }
}

export function getConnectionString(
  host: pulumi.Input<string>,
  database: pulumi.Input<string>,
  username: pulumi.Input<string>,
  password: pulumi.Input<string>,
  port: pulumi.Input<number> = 5432,
): pulumi.Output<string> {
  return pulumi.secret(pulumi.interpolate`postgresql://${username}:${password}@${host}:${port}/${database}?sslmode=require`);
}
