# Project Validation Plan

This checklist tracks what to verify when running the Azure AKS Platform Blueprint lab. It is organized by project section so each layer can be tested independently before moving to the next one.

The project is a public portfolio/demo blueprint. Do not add real secrets, tenant IDs, kubeconfigs, private domains, client data, production IPs, or static cloud credentials while testing.

## 1. Repository Safety Baseline

- [ ] Confirm no secrets or kubeconfigs are tracked.
  ```bash
  git status --short
  git ls-files | rg 'kubeconfig|\.pem$|\.key$|terraform\.tfstate|terraform\.tfvars$'
  ```
- [ ] Confirm ignored local artifacts stay ignored.
  ```bash
  git check-ignore certs/* platform/infrastructure/environments/dev/.terraform/* || true
  ```
- [ ] Confirm documentation still describes the repo as a demo blueprint, not a complete production platform.
  ```bash
  rg -n "production-ready|client|tenant id|secret|kubeconfig" README.md docs AGENTS.md
  ```

Expected result: no tracked secrets, no real kubeconfig, no private values committed.

## 2. Terraform Infrastructure

Scope:

- Resource group
- Azure SQL server, elastic pool, database
- Managed identities for app/database access
- Managed identity for GitHub Actions OIDC
- ACR for container images and Helm OCI artifacts

Checks:

- [ ] Format Terraform.
  ```bash
  terraform -chdir=platform/infrastructure fmt -recursive
  ```
- [ ] Initialize the dev infrastructure root.
  ```bash
  terraform -chdir=platform/infrastructure/environments/dev init
  ```
- [ ] Validate the dev infrastructure root.
  ```bash
  terraform -chdir=platform/infrastructure/environments/dev validate
  ```
- [ ] Review the Terraform plan before apply.
  ```bash
  terraform -chdir=platform/infrastructure/environments/dev plan
  ```
- [ ] Apply only after the plan shows the intended lab resources.
  ```bash
  terraform -chdir=platform/infrastructure/environments/dev apply
  ```
- [ ] Confirm required outputs exist.
  ```bash
  terraform -chdir=platform/infrastructure/environments/dev output
  terraform -chdir=platform/infrastructure/environments/dev output -raw github_actions_client_id
  ```

Expected result: Terraform creates only the intended SQL-focused baseline plus ACR and GitHub Actions identity. Existing backend blocks must remain intact.

Known local issue: `terraform validate` may fail on this workstation with AzureRM provider plugin handshake errors. If that happens, fix/reinstall the local provider cache before treating it as an HCL problem.

## 3. GitHub Repository Bootstrap

Scope:

- Repository variables used by GitHub Actions
- OIDC-based Azure login
- ACR push permissions

Checks:

- [ ] Confirm GitHub CLI is authenticated.
  ```bash
  gh auth status
  ```
- [ ] Confirm Azure CLI is logged in to the expected subscription.
  ```bash
  az account show --query '{name:name, subscription:id, tenant:tenantId}' -o table
  ```
- [ ] Run repository bootstrap after Terraform apply.
  ```bash
  .github/scripts/github_repo_bootsrap.sh
  ```
- [ ] Confirm GitHub repository variables.
  ```bash
  gh variable list --repo Legiang98/azure-aks-platform-blueprint
  ```

Expected result: GitHub variables include `AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, `AZURE_SUBSCRIPTION_ID`, and `AZURE_ACR_NAME`. No Azure client secret is required.

## 4. Pulumi Database Security

Scope:

- Azure SQL database users
- Role-based grants
- Separation between database access and schema migration
- Terraform remote state consumption

Checks:

- [ ] Install Pulumi dependencies.
  ```bash
  cd platform/database-security
  npm install
  ```
- [ ] Select the intended stack.
  ```bash
  pulumi stack select dev
  ```
- [ ] Preview database security changes.
  ```bash
  pulumi preview
  ```
- [ ] Apply only expected users, roles, and grants.
  ```bash
  pulumi up
  ```
- [ ] Check stack outputs.
  ```bash
  pulumi stack output
  ```

Expected result: Pulumi manages database access only. It should not create Azure infrastructure or application schema objects.

## 5. Platform Extension SDK

Scope:

- Shared platform settings contract
- Key Vault secret resolution
- Application Insights integration
- SQL connection config helper patterns
- Node, Python, Go, Java, and .NET package skeletons

Checks:

- [ ] Validate the shared settings schema and examples where supported.
- [ ] Run package-level tests/builds where available.
  ```bash
  # Example checks depend on each SDK language package.
  npm test --prefix platform/extension-sdk/node || true
  dotnet build platform/extension-sdk/dotnet/src/AksPlatform.Sdk || true
  ```
- [ ] Confirm SDKs do not contain real Key Vault URLs, real secret values, or connection strings.
  ```bash
  rg -n "AccountKey=|Password=|Secret=|DefaultEndpointsProtocol|vault.azure.net|InstrumentationKey" platform/extension-sdk
  ```

Expected result: SDKs expose reusable helpers and remain safe for public portfolio use.

## 6. Boutique App Images

Scope:

- 12 boutique microservices
- Docker build contexts
- ACR image push through GitHub Actions

Checks:

- [ ] Confirm each service has a Dockerfile.
  ```bash
  find apps/boutique-app/src -name Dockerfile -type f | sort
  ```
- [ ] Validate workflow YAML.
  ```bash
  ruby -e 'require "yaml"; YAML.load_stream(File.read(".github/workflows/boutique-app-images.yaml")); puts "ok"'
  ```
- [ ] Run the `Build Boutique App Images` workflow manually with tag `0.1.0`.
- [ ] Confirm images in ACR.
  ```bash
  az acr repository list --name craksplatformdemo001 -o table
  ```

Expected result: images are pushed under `<acr-name>.azurecr.io/boutique/<service>:<tag>`.

## 7. Helm Chart

Scope:

- Root reusable chart at `helm/platform-service`
- One chart template shared by all application services

Checks:

- [ ] Lint the reusable chart.
  ```bash
  helm lint helm/platform-service
  ```
- [ ] Render all boutique app service values.
  ```bash
  set -e
  for values in $(find k8s/apps/boutique-app -name values.yaml -type f | sort); do
    service=$(basename "$(dirname "$values")")
    env=$(basename "$(dirname "$(dirname "$values")")")
    helm template "$service" helm/platform-service \
      --namespace "tenant-boutique-$env" \
      --values "$values" >/tmp/render-$env-$service.yaml
  done
  ```
- [ ] Package and push the chart through GitHub Actions.

Expected result: all services render successfully from the same reusable chart.

## 8. Flux And Kubernetes Manifests

Scope:

- Flux bootstrap
- AKS NAP node provisioning policy
- Cluster-level reconciliation graph
- Tenant baselines
- Gateway resources
- App HelmReleases
- App settings ConfigMaps

Checks:

- [ ] Parse all Kubernetes YAML.
  ```bash
  ruby -e 'require "yaml"; ARGV.each { |p| YAML.load_stream(File.read(p)) }; puts "yaml ok"' \
    $(find k8s -name '*.yaml' -type f | sort)
  ```
- [ ] Build the Flux cluster root.
  ```bash
  kubectl kustomize k8s/flux/clusters/aks-platform
  ```
- [ ] Confirm the NAP spot NodePool policy renders.
  ```bash
  kubectl kustomize k8s/platform/node-provisioning
  ```
- [ ] Validate app settings JSON embedded in ConfigMaps.
  ```bash
  ruby -ryaml -rjson -e 'ARGV.each { |p| YAML.load_stream(File.read(p)).each { |d| next unless d && d["kind"] == "ConfigMap"; JSON.parse(d.fetch("data").fetch("app-settings.json")) } }; puts "app settings ok"' \
    $(find k8s/apps/boutique-app -name app-settings.yaml -type f | sort)
  ```
- [ ] After Flux bootstrap, check reconciliation.
  ```bash
  flux get sources all -A
  flux get kustomizations -A
  flux get helmreleases -A
  ```

Expected result: Flux sees the Helm OCI source, tenant baselines, gateway resources, and 24 boutique app releases.

## 9. CI/CD Workflows

Scope:

- Image build workflow
- Helm package workflow
- Database migration workflow placeholder/boundary
- Security workflows for SAST, secrets, IaC, and dependency updates

Checks:

- [ ] Validate workflow YAML.
  ```bash
  ruby -e 'require "yaml"; ARGV.each { |p| YAML.load_stream(File.read(p)) }; puts "workflow yaml ok"' \
    .github/workflows/*.yaml
  ```
- [ ] Confirm workflows use OIDC and do not store Azure client secrets.
  ```bash
  rg -n "azure/login|id-token|AZURE_CLIENT_SECRET|password|secret" .github/workflows .github/scripts
  ```
- [ ] Confirm security workflows exist.
  ```bash
  ls .github/workflows/codeql.yaml \
    .github/workflows/secret-scan.yaml \
    .github/workflows/iac-security.yaml \
    .github/dependabot.yaml
  ```
- [ ] Run CodeQL manually from GitHub Actions after the first push.
- [ ] Run Secret Scan manually from GitHub Actions.
- [ ] Run IaC Security manually from GitHub Actions and review Checkov findings.
- [ ] Run `Package Helm Charts` workflow manually.
- [ ] Run `Build Boutique App Images` workflow manually.

Expected result: CI/CD can authenticate through OIDC, push both images and Helm charts to ACR, and surface security findings without storing static Azure credentials.

## 10. Observability And Monitoring Demo

Scope:

- Application Insights SDK integration path
- Platform monitoring center demo service
- Local JSON demo data

Checks:

- [ ] Run backend unit tests where available.
- [ ] Start the monitoring center locally.
- [ ] Verify safe demo endpoints only return local demo state.
  ```bash
  curl http://localhost:8000/health
  curl http://localhost:8000/api/platform/snapshot
  ```
- [ ] Confirm no endpoint runs real `terraform`, `pulumi`, `kubectl`, `az`, or `gh` commands in V1.

Expected result: monitoring center remains demo-safe and read-only.

## 11. Portfolio Static Site

Scope:

- Static portfolio source under `platform/infrastructure/environments/portoflio-static-site/site`
- Isolated Static Web App Terraform root
- GitHub Actions deployment to Azure Static Web Apps

Checks:

- [ ] Open `platform/infrastructure/environments/portoflio-static-site/site/index.html` locally.
- [ ] Confirm it does not expose private environment values.
- [ ] Validate the isolated Static Web App Terraform root if used.
- [ ] Bootstrap the Static Web Apps deployment token into GitHub Secrets.
  ```bash
  .github/scripts/github_repo_bootsrap.sh
  ```
- [ ] Run the `Deploy Portfolio Static Site` workflow manually.

Expected result: portfolio site can stay online independently from the lab infrastructure.

## 12. End-To-End Lab Smoke Test

Run this only after the underlying Azure resources, ACR, GitHub variables, and Flux bootstrap are ready.

- [ ] Terraform apply completed.
- [ ] GitHub repo variables bootstrapped.
- [ ] Image workflow pushed service images.
- [ ] Helm chart workflow pushed the chart OCI artifact.
- [ ] Flux source can pull from Git and ACR.
- [ ] Tenant namespaces exist.
- [ ] HelmReleases reconcile.
- [ ] Pods become ready.
- [ ] Gateway route serves the frontend.
- [ ] Application can load `platform.settings/v1` ConfigMap.
- [ ] Application can resolve required Key Vault secret names through the platform SDK.
- [ ] Database access managed by Pulumi works for the intended identities.
- [ ] App Insights receives telemetry for at least one request.

Expected result: the lab demonstrates infrastructure provisioning, database security, CI/CD, GitOps delivery, platform SDK config, and observability without exposing secrets or destructive operations.

## Cleanup Checklist

- [ ] Destroy temporary app workloads if needed.
- [ ] Stop or scale down AKS nodes if the lab is paused.
- [ ] Destroy SQL/ACR/identity resources if the lab is complete.
  ```bash
  terraform -chdir=platform/infrastructure/environments/dev destroy
  ```
- [ ] Confirm no generated state, plans, or credentials were added to Git.
  ```bash
  git status --short
  ```
