using Azure.Core;
using Azure.Security.KeyVault.Secrets;

namespace AksPlatform.Sdk;

public sealed class KeyVaultClient
{
    private readonly SecretClient _client;

    public KeyVaultClient(string vaultUrl, TokenCredential credential)
    {
        if (string.IsNullOrWhiteSpace(vaultUrl))
        {
            throw new ArgumentException("Key Vault URL is required.", nameof(vaultUrl));
        }

        _client = new SecretClient(new Uri(vaultUrl), credential);
    }

    public async Task<string?> GetSecretAsync(string name, CancellationToken cancellationToken = default)
    {
        var secret = await _client.GetSecretAsync(name, cancellationToken: cancellationToken);
        return secret.Value.Value;
    }

    public async Task<string> GetRequiredSecretAsync(string name, CancellationToken cancellationToken = default)
    {
        var value = await GetSecretAsync(name, cancellationToken);
        if (string.IsNullOrEmpty(value))
        {
            throw new InvalidOperationException($"Secret '{name}' was found but has no value.");
        }

        return value;
    }
}
