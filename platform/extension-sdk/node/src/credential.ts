export interface TokenCredentialLike {
  getToken(scopes: string | string[], options?: unknown): Promise<unknown>;
}

export async function createDefaultCredential(): Promise<TokenCredentialLike> {
  const identity = await import("@azure/identity");
  return new identity.DefaultAzureCredential();
}
