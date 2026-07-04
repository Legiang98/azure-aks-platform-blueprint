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

## Security Automation

The repository uses layered security checks:

- CodeQL scans application and SDK code for SAST findings.
- Gitleaks scans the repository for committed secrets.
- Checkov scans Terraform, Kubernetes, Helm, Dockerfiles, and GitHub Actions for IaC and configuration risks.
- Workflow YAML Validation catches broken GitHub Actions YAML and the disabled Dependabot scaffold before merge.
- Dependabot is scaffolded in `.github/dependabot.yaml.disable` and intentionally disabled for this lab to avoid noisy automated PRs. Rename it to `.github/dependabot.yaml` when dependency update PRs are needed.

Checkov currently runs in audit mode with `soft_fail: true`. This keeps the portfolio workflow visible while the blueprint is still being hardened. Once the expected exceptions are documented or remediated, switch Checkov to failing mode and make it a required branch protection check.

## Recommended Branch Protection

For a stricter public portfolio setup, require these checks before merging to `main`:

- CodeQL
- Secret Scan
- IaC Security
- Workflow YAML validation
- Helm render validation

Require review for changes under:

- `.github/workflows/`
- `platform/infrastructure/`
- `k8s/`
- `helm/`
- `platform/database-security/`

## Future Runtime Policy

Add Kyverno or Azure Policy for AKS when the cluster baseline is active:

- Deny privileged containers.
- Restrict hostPath mounts.
- Require resource requests and limits.
- Require tenant and app labels.
- Allow image pulls only from approved registries.
- Require Workload Identity for services that access Azure resources.
