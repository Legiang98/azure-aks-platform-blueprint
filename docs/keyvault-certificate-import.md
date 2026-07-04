# Azure Key Vault Certificate Import

This is the current lab step after generating a Let's Encrypt certificate locally with Docker Certbot.

Current scope:

```text
Provision Azure Key Vault
Import the certificate into Key Vault
Store PEM cert/key as Key Vault secrets
```

AKS sync and Envoy HTTPS wiring are intentionally left for a later step.

## Terraform

Provision Key Vault:

```bash
cd infra
terraform apply
```

Get the Key Vault name:

```bash
terraform output -raw key_vault_name
```

Expected value:

```text
kv-aks-platform
```

The Terraform grants the current Azure CLI identity:

- `Key Vault Secrets Officer`
- `Key Vault Certificates Officer`

These roles allow you to import the certificate and upload the PEM values as secrets.

## Local Certificate Files

After Docker Certbot succeeds, your local files should be:

```text
certs/example-com/letsencrypt/live/example.com/fullchain.pem
certs/example-com/letsencrypt/live/example.com/privkey.pem
```

From repo root:

```bash
export CERT_DIR="$PWD/certs/example-com/letsencrypt/live/example.com"
export FULLCHAIN="$CERT_DIR/fullchain.pem"
export PRIVKEY="$CERT_DIR/privkey.pem"
```

Verify:

```bash
ls -l "$FULLCHAIN" "$PRIVKEY"
```

## Create PFX

Create a PFX file for Key Vault certificate import:

```bash
docker run --rm \
  -v "$PWD:/work" \
  -w /work \
  alpine/openssl pkcs12 \
  -export \
  -out certs/example-com/example-com.pfx \
  -inkey /work/certs/example-com/letsencrypt/live/example.com/privkey.pem \
  -in /work/certs/example-com/letsencrypt/live/example.com/fullchain.pem \
  -passout pass:
```

Verify:

```bash
ls -l certs/example-com/example-com.pfx
```

## Import Certificate Into Key Vault

```bash
az keyvault certificate import \
  --vault-name kv-aks-platform \
  --name example-com \
  --file certs/example-com/example-com.pfx
```

Verify:

```bash
az keyvault certificate show \
  --vault-name kv-aks-platform \
  --name example-com \
  --query "{name:name, enabled:attributes.enabled, expires:attributes.expires}" \
  --output table
```

## Store PEM Files As Secrets

Store the cert chain:

```bash
az keyvault secret set \
  --vault-name kv-aks-platform \
  --name example-com-tls-crt \
  --file "$FULLCHAIN"
```

Store the private key:

```bash
az keyvault secret set \
  --vault-name kv-aks-platform \
  --name example-com-tls-key \
  --file "$PRIVKEY"
```

Verify:

```bash
az keyvault secret show \
  --vault-name kv-aks-platform \
  --name example-com-tls-crt \
  --query id \
  --output tsv

az keyvault secret show \
  --vault-name kv-aks-platform \
  --name example-com-tls-key \
  --query id \
  --output tsv
```

## Next Step

After the certificate is in Key Vault, decide how AKS should consume it:

```text
Option A: Secrets Store CSI Driver syncs Key Vault secrets into a Kubernetes TLS Secret.
Option B: External Secrets Operator syncs Key Vault secrets into a Kubernetes TLS Secret.
Option C: Manual Kubernetes TLS Secret for the lab.
```

Envoy Gateway will eventually reference a Kubernetes TLS Secret named:

```text
gateway-system/example-com-tls
```
