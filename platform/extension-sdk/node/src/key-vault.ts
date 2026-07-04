import { createDefaultCredential, type TokenCredentialLike } from "./credential.js";

export interface KeyVaultClientOptions {
  vaultUrl: string;
  credential?: TokenCredentialLike;
}

export interface KeyVaultClient {
  getSecret(name: string): Promise<string | undefined>;
  getRequiredSecret(name: string): Promise<string>;
}

export async function createKeyVaultClient(options: KeyVaultClientOptions): Promise<KeyVaultClient> {
  if (!options.vaultUrl || options.vaultUrl.trim().length === 0) {
    throw new Error("Key Vault URL is required.");
  }

  const credential = options.credential ?? await createDefaultCredential();
  const keyVault = await import("@azure/keyvault-secrets");
  const client = new keyVault.SecretClient(options.vaultUrl, credential);

  return {
    async getSecret(name: string): Promise<string | undefined> {
      const secret = await client.getSecret(name);
      return secret.value;
    },

    async getRequiredSecret(name: string): Promise<string> {
      const secret = await client.getSecret(name);
      if (!secret.value) {
        throw new Error(`Secret '${name}' was found but has no value.`);
      }
      return secret.value;
    }
  };
}
