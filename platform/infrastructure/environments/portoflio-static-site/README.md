# Portfolio Static Site Infrastructure

This Terraform root is isolated from the AKS platform environment. It creates only the Azure resources needed to host the portfolio static website.

## Resources

- Resource group: `portfolio-static-rg`
- Azure Static Web App: Free tier by default

Website source lives under this Terraform root at `site/`.

Large media is intentionally not tracked from this root. Keep lightweight HTML/CSS in `site/`, but store heavy images, videos, and generated archives outside Git or in Azure Blob Storage/CDN when needed. The local `.gitignore` ignores common media folders and deploy artifacts.

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

## Local Deploy

After the Static Web App exists and Azure CLI is logged in, deploy the local site from this folder:

```bash
cd platform/infrastructure/environments/portoflio-static-site
./deploy.sh
```

The script packages `site/` into `.artifacts/static-site/portfolio-static-site.zip`, reads the Static Web Apps deployment token from Azure, and deploys the current static content. The deployment token is not written to disk.

Use `platform/infrastructure/environments/portoflio-static-site/site` as the Static Web Apps app location in CI/CD.

```yaml
app_location: "platform/infrastructure/environments/portoflio-static-site/site"
api_location: ""
output_location: ""
```

Do not commit deployment tokens, custom private domains, tenant IDs, subscription IDs, or production identifiers.
