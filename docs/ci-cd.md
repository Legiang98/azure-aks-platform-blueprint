# CI/CD

## Intent

CI/CD for this blueprint should validate infrastructure, database security code, Kubernetes manifests, and documentation without requiring real production credentials.

## Recommended Pipeline Stages

1. Format and lint Terraform.
2. Validate Terraform configuration.
3. Run security scanning for infrastructure as code.
4. Validate Pulumi database security code.
5. Validate Kubernetes manifests.
6. Check documentation links and required sections.
7. Run plan or preview steps only with safe demo credentials or mocked examples.

## Identity Pattern

Use OIDC federation from the CI provider to Azure. Avoid storing long-lived cloud credentials in repository secrets when a federated identity pattern is available.

## Deployment Boundaries

- Infrastructure deployment belongs to the platform pipeline.
- Database security baseline deployment belongs to the platform or database security pipeline.
- Application schema migrations belong to the application release pipeline.
- Application deployment belongs to the application pipeline or GitOps workflow.

## Placeholders

Workflow examples should use generic names and placeholders until real demo automation is intentionally added.
