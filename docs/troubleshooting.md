# Troubleshooting

## Intent

This guide captures common checks for the AKS platform blueprint. Commands should use placeholders and avoid real production identifiers.

## Infrastructure Checks

```bash
terraform -chdir=platform/infrastructure/environments/platform fmt -recursive
terraform -chdir=platform/infrastructure/environments/platform validate
terraform -chdir=platform/infrastructure/environments/platform plan
```

The supported Terraform infrastructure environment is `platform`. Do not create separate Terraform `dev`, `stg`, or `prod` environment folders for this blueprint.

## AKS Checks

```bash
az aks show \
  --resource-group <resource-group-name> \
  --name <aks-cluster-name> \
  --query "{name:name, privateCluster:apiServerAccessProfile.enablePrivateCluster, oidc:oidcIssuerProfile.enabled}" \
  --output table
```

```bash
kubectl get nodes
kubectl get ns
kubectl get pods -A
```

## Identity Checks

- Confirm Managed Identity or Workload Identity is enabled where expected.
- Confirm federated identity credentials match the intended service account and namespace.
- Confirm Key Vault access is granted to the expected identity only.

## Database Security Checks

- Confirm users or identities are mapped to roles instead of broad direct grants.
- Confirm migration access is separate from application runtime access.
- Confirm connection references point to Key Vault or safe placeholders.

## Documentation Checks

- Update docs when platform behavior changes.
- Keep public examples generic and free of real tenant, subscription, domain, IP, or credential values.
