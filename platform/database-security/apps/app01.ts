import { DefaultAzureCredential } from "@azure/identity";
import { BlobServiceClient } from "@azure/storage-blob";
import * as pulumi from "@pulumi/pulumi";
import {
  AzureSqlExternalUser,
  getEntraConnectionString,
} from "../providers/azure-sql-database";

interface App01AzureSqlUserConfig {
  username: string;
  objectId?: string;
  terraformIdentityKey?: string;
  isGroup?: boolean;
  canRead?: boolean;
  canWrite?: boolean;
  canAdmin?: boolean;
  canExecute?: boolean;
}

interface App01AzureSqlConfig {
  host: string;
  database: string;
  clientId?: string;
  terraformState: TerraformStateConfig;
  runtimeUser: App01AzureSqlUserConfig;
  migrationUser: App01AzureSqlUserConfig;
  reportingUser?: App01AzureSqlUserConfig;
}

interface TerraformStateConfig {
  storageAccountName: string;
  containerName: string;
  key: string;
}

interface TerraformState {
  outputs?: {
    [key: string]: {
      value: unknown;
    };
  };
}

const config = new pulumi.Config();
const app01 = config.requireObject<App01AzureSqlConfig>("app01AzureSql");

const terraformState = pulumi.output(readTerraformState(app01.terraformState));
const managedIdentityPrincipalIds = terraformState.apply((state) =>
  getTerraformOutput<Record<string, string>>(state, "managed_identity_principal_ids"),
);

const connection = {
  host: app01.host,
  database: app01.database,
  clientId: app01.clientId,
};

export const app01RuntimeUser = new AzureSqlExternalUser("app01-runtime-user", {
  ...connection,
  username: app01.runtimeUser.username,
  objectId: getObjectId(app01.runtimeUser, "app01_runtime"),
  isGroup: app01.runtimeUser.isGroup,
  canRead: app01.runtimeUser.canRead,
  canWrite: app01.runtimeUser.canWrite,
  canAdmin: app01.runtimeUser.canAdmin,
  canExecute: app01.runtimeUser.canExecute,
});

export const app01MigrationUser = new AzureSqlExternalUser("app01-migration-user", {
  ...connection,
  username: app01.migrationUser.username,
  objectId: getObjectId(app01.migrationUser, "app01_migration"),
  isGroup: app01.migrationUser.isGroup,
  canRead: app01.migrationUser.canRead,
  canWrite: app01.migrationUser.canWrite,
  canAdmin: app01.migrationUser.canAdmin,
  canExecute: app01.migrationUser.canExecute,
});

export const app01ReportingUser = app01.reportingUser
  ? new AzureSqlExternalUser("app01-reporting-user", {
      ...connection,
      username: app01.reportingUser.username,
      objectId: getObjectId(app01.reportingUser, "app01_reporting"),
      isGroup: app01.reportingUser.isGroup,
      canRead: app01.reportingUser.canRead,
      canWrite: app01.reportingUser.canWrite,
      canAdmin: app01.reportingUser.canAdmin,
      canExecute: app01.reportingUser.canExecute,
    })
  : undefined;

export const app01RuntimeConnectionString = getEntraConnectionString(
  app01.host,
  app01.database,
  app01.runtimeUser.username,
);

function getObjectId(user: App01AzureSqlUserConfig, defaultTerraformIdentityKey: string): pulumi.Input<string> {
  if (user.objectId) {
    return user.objectId;
  }

  const identityKey = user.terraformIdentityKey ?? defaultTerraformIdentityKey;
  return managedIdentityPrincipalIds.apply((principalIds) => {
    const objectId = principalIds[identityKey];
    if (!objectId) {
      throw new Error(`Terraform output managed_identity_principal_ids does not contain key '${identityKey}'.`);
    }
    return objectId;
  });
}

async function readTerraformState(args: TerraformStateConfig): Promise<TerraformState> {
  const accountUrl = `https://${args.storageAccountName}.blob.core.windows.net`;
  const blobServiceClient = new BlobServiceClient(accountUrl, new DefaultAzureCredential());
  const blobClient = blobServiceClient
    .getContainerClient(args.containerName)
    .getBlobClient(args.key);

  const download = await blobClient.download();
  const state = await streamToString(download.readableStreamBody);
  return JSON.parse(state) as TerraformState;
}

function getTerraformOutput<T>(state: TerraformState, outputName: string): T {
  const output = state.outputs?.[outputName];
  if (!output) {
    throw new Error(`Terraform state does not contain output '${outputName}'.`);
  }
  return output.value as T;
}

async function streamToString(stream: NodeJS.ReadableStream | undefined): Promise<string> {
  if (!stream) {
    return "";
  }

  const chunks: Buffer[] = [];
  for await (const chunk of stream) {
    chunks.push(Buffer.isBuffer(chunk) ? chunk : Buffer.from(chunk));
  }
  return Buffer.concat(chunks).toString("utf8");
}
