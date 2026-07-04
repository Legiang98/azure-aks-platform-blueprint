# Portfolio Static Site Infrastructure

This Terraform root is isolated from the AKS platform environment. It creates only the Azure resources needed to host the portfolio static website.

## Resources

- Resource group: `portfolio-static-rg`
- Azure Static Web App: Free tier by default

Website source lives under `docs/site/`.

## Commands

```bash
terraform -chdir=platform/infrastructure/environments/portoflio-static-site init \
  -backend-config="resource_group_name=<tfstate-resource-group>" \
  -backend-config="storage_account_name=<tfstate-storage-account>" \
  -backend-config="container_name=<tfstate-container>" \
  -backend-config="key=portfolio-static-site.tfstate"

terraform -chdir=platform/infrastructure/environments/portoflio-static-site fmt -recursive
terraform -chdir=platform/infrastructure/environments/portoflio-static-site validate
terraform -chdir=platform/infrastructure/environments/portoflio-static-site plan
```

Use `docs/site` as the Static Web Apps app location in CI/CD.

```yaml
app_location: "docs/site"
api_location: ""
output_location: ""
```

Do not commit deployment tokens, custom private domains, tenant IDs, subscription IDs, or production identifiers.
