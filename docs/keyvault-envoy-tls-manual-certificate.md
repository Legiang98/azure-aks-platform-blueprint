# Docker Certbot TLS Flow: Let's Encrypt -> Azure Key Vault -> AKS Envoy Gateway

This runbook describes the lab TLS flow using Docker-based Certbot, Azure Key Vault, AKS Secrets Store CSI Driver, and Envoy Gateway.

Target flow:

```text
Docker Certbot on local machine
  -> request Let's Encrypt certificate with manual DNS-01 validation
  -> write fullchain.pem and privkey.pem locally
  -> import certificate into Azure Key Vault
  -> store PEM certificate and private key as Key Vault secrets
  -> next step: choose how AKS will consume the cert from Key Vault
```

This flow does not use cert-manager.

## Prerequisites

- You control DNS for `example.com`.
- Docker is installed locally.
- Azure CLI is installed and logged in.
- AKS and Envoy Gateway are already running.
- Terraform has created or will create:
  - Azure Key Vault.
  - Key Vault RBAC access for your Azure CLI identity.

Expected values for this lab:

| Item | Value |
| --- | --- |
| Root domain | `example.com` |
| Wildcard domain | `*.example.com` |
| Key Vault | `kv-aks-platform` |
| Key Vault certificate name | `example-com` |
| Key Vault cert secret | `example-com-tls-crt` |
| Key Vault key secret | `example-com-tls-key` |
| Kubernetes namespace | `gateway-system` |

Login and confirm subscription:

```bash
az login
az account show --output table
```

## Step 1 - Request A Let's Encrypt Certificate With Docker Certbot

Create a local working folder:

```bash
mkdir -p certs/example-com
cd certs/example-com
```

Run Certbot in Docker:

```bash
docker run --rm -it \
  -v "$PWD/letsencrypt:/etc/letsencrypt" \
  -v "$PWD/lib-letsencrypt:/var/lib/letsencrypt" \
  certbot/certbot certonly \
  --manual \
  --preferred-challenges dns \
  --email <YOUR_EMAIL> \
  --agree-tos \
  --no-eff-email \
  -d example.com \
  -d "*.example.com"
```

Certbot will ask you to create one or more DNS TXT records like:

```text
Name:  _acme-challenge.example.com
Type:  TXT
Value: <value printed by certbot>
```

Create the TXT record in your DNS provider, then wait for propagation.

Check DNS propagation:

```bash
dig TXT _acme-challenge.example.com
```

Docker alternative for DNS lookup:

```bash
docker run --rm alpine nslookup -type=TXT _acme-challenge.example.com
```

After the TXT record is visible publicly, go back to the Certbot prompt and press Enter.

If successful, Certbot writes:

```text
letsencrypt/live/example.com/fullchain.pem
letsencrypt/live/example.com/privkey.pem
```

Set shell variables for the generated files:

```bash
export CERT_DIR="$PWD/letsencrypt/live/example.com"
export FULLCHAIN="$CERT_DIR/fullchain.pem"
export PRIVKEY="$CERT_DIR/privkey.pem"
```

Verify the files exist:

```bash
ls -l "$FULLCHAIN" "$PRIVKEY"
```

Inspect the certificate:

```bash
docker run --rm \
  -v "$PWD:/work" \
  -w /work \
  alpine/openssl x509 \
  -in /work/letsencrypt/live/example.com/fullchain.pem \
  -noout \
  -text
```

Confirm the certificate includes:

```text
DNS:example.com
DNS:*.example.com
```

## Step 2 - Create PFX For Azure Key Vault Certificate Import

Azure Key Vault certificate import commonly uses PFX.

Create a PFX file with Docker OpenSSL:

```bash
docker run --rm \
  -v "$PWD:/work" \
  -w /work \
  alpine/openssl pkcs12 \
  -export \
  -out example-com.pfx \
  -inkey /work/letsencrypt/live/example.com/privkey.pem \
  -in /work/letsencrypt/live/example.com/fullchain.pem \
  -passout pass:
```

Verify the PFX file exists:

```bash
ls -l example-com.pfx
```

## Step 3 - Import Certificate Into Azure Key Vault

Import the PFX into Azure Key Vault:

```bash
az keyvault certificate import \
  --vault-name kv-aks-platform \
  --name example-com \
  --file example-com.pfx
```

Verify:

```bash
az keyvault certificate show \
  --vault-name kv-aks-platform \
  --name example-com \
  --query "{name:name, enabled:attributes.enabled, expires:attributes.expires}" \
  --output table
```

## Step 4 - Store PEM Files As Key Vault Secrets For AKS Sync

Gateway API expects a Kubernetes TLS Secret with:

```text
tls.crt
tls.key
```

For this lab, store the Certbot PEM files as two Key Vault secrets:

```bash
az keyvault secret set \
  --vault-name kv-aks-platform \
  --name example-com-tls-crt \
  --file "$FULLCHAIN"

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

## Step 5 - Continue With AKS Consumption

At this point, the certificate is stored in Key Vault.

The next step is to choose how AKS should consume it:

```text
Option A: Secrets Store CSI Driver syncs Key Vault secrets into a Kubernetes TLS Secret.
Option B: External Secrets Operator syncs Key Vault secrets into a Kubernetes TLS Secret.
Option C: Manual Kubernetes TLS Secret for the lab.
```

See `docs/keyvault-certificate-import.md` for the current Key Vault-only import flow.

## Renewal Process

Let's Encrypt certificates are short-lived. This manual flow requires manual renewal.

Run Certbot again before the certificate expires:

```bash
cd certs/example-com

docker run --rm -it \
  -v "$PWD/letsencrypt:/etc/letsencrypt" \
  -v "$PWD/lib-letsencrypt:/var/lib/letsencrypt" \
  certbot/certbot certonly \
  --manual \
  --preferred-challenges dns \
  --email <YOUR_EMAIL> \
  --agree-tos \
  --no-eff-email \
  -d example.com \
  -d "*.example.com"
```

Then repeat:

1. Recreate `example-com.pfx`.
2. Import the PFX into Key Vault.
3. Update `example-com-tls-crt`.
4. Update `example-com-tls-key`.
5. Continue with the AKS consumption option you choose later.

For production, automate renewal with DNS-01 automation or cert-manager.

## Troubleshooting

Common issues:

| Symptom | Likely cause |
| --- | --- |
| Browser shows invalid cert | DNS name not included in SAN or incomplete chain |
| Key Vault certificate import fails | PFX path is wrong or current identity lacks certificate permissions |
| Key Vault secret upload fails | Current identity lacks secret permissions |

## Security Notes

- Do not commit private keys, PFX files, or PEM cert material.
- Keep `certs/` out of Git.
- Keep manual DNS challenge TXT values temporary; remove stale records after issuance.
- Restrict Key Vault access to only required identities.
- For production, consider private endpoints, stricter Key Vault networking, and automated renewal.
