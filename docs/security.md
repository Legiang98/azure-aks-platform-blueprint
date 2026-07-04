# Security

## Intent

This repository demonstrates secure-by-default platform engineering patterns for an Azure AKS blueprint. It is a demo pattern, not a complete production security program.

## Public Portfolio Safety

Do not commit secrets, tokens, tenant IDs, subscription IDs, private domains, kubeconfigs, production IPs, or company-specific infrastructure configuration.

Use placeholders such as:

- `<tenant-id>`
- `<subscription-id>`
- `<resource-group-name>`
- `<key-vault-name>`
- `<private-domain>`

## Identity

- Prefer Managed Identity for Azure resources.
- Prefer AKS Workload Identity for workloads.
- Prefer OIDC federation for CI/CD access to Azure.
- Avoid long-lived service principal secrets.

## Secrets

- Store secrets in Azure Key Vault or equivalent secret stores.
- Reference secrets instead of hardcoding them in Terraform, Pulumi, manifests, or documentation.
- Do not commit kubeconfigs or generated credentials.

## Network Security

- Prefer private endpoints for platform dependencies where practical.
- Keep ingress, node, private endpoint, and database security paths documented.
- Use network policies for tenant workload isolation when implemented.

## Access Control

- Use least-privilege permissions.
- Separate platform operator, application runtime, migration, and reporting access.
- Document any demo-only broad permission with a clear reason and cleanup path.
