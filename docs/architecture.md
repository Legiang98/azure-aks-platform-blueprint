# Architecture

## Problem

Platform teams need a clear reference pattern for designing an Azure AKS foundation that separates infrastructure, identity, database security, application deployment, and operational documentation.

## Goals

- Demonstrate an Azure-first AKS platform blueprint.
- Use Terraform for cloud infrastructure.
- Use Pulumi for database security baselines.
- Prefer secure identity, private networking, observability, and maintainable documentation.
- Keep examples safe for public portfolio use.

## Non-goals

- This is not a complete enterprise production platform.
- This does not include proprietary client implementation details.
- This does not manage application database schema migrations.
- This does not deploy real production workloads.

## Architecture

The intended pattern separates Azure infrastructure, Kubernetes platform configuration, database security management, and application release responsibilities.

The platform network baseline uses separate VPN, AKS, and data VNets. The data VNet hosts private endpoints, including the Azure SQL private endpoint, while private DNS links make service names resolvable from VPN, AKS, and data network paths.

## Components

- Azure resource groups, networking, AKS, Key Vault, Azure SQL server, elastic pool, databases, private endpoints, private DNS, backup vault, and monitoring live under `platform/infrastructure/`.
- Terraform infrastructure is organized around one shared `platform` environment for the multi-tenant AKS baseline.
- Database users, roles, grants, identity mappings, and connection references live under `platform/database-security/`.
- Application-facing platform SDK packages live under `platform/sdk/`.
- Kubernetes platform controls live under `k8s/platform/`.
- Application Helm charts and Flux release manifests live under `k8s/apps/`.
- Portfolio website content lives under `platform/infrastructure/environments/portoflio-static-site/site/`.
- Application examples may live under `apps/`.
- Documentation lives under `docs/`.

## Security Considerations

- Prefer Managed Identity, Workload Identity, OIDC, and Key Vault references.
- Keep data services on private endpoints by default and disable public network access where practical.
- Use managed identities for platform recovery components such as backup vaults.
- Avoid hardcoded credentials, tenant IDs, subscription IDs, private domains, production IPs, and kubeconfigs.
- Use least-privilege access and separate operational roles.

## Observability

The blueprint should include diagnostic settings, platform metrics, logs, alerts, and dashboard references as implementation matures.

## Deployment Flow

1. Provision Azure infrastructure with Terraform.
2. Bootstrap cluster platform components and identity integrations.
3. Manage database security baselines with Pulumi.
4. Publish platform SDK artifacts to a private package registry.
5. Deploy applications through a separate application release pipeline.

## Rollback/Recovery

Rollback plans should distinguish between infrastructure replacement, Kubernetes configuration rollback, database security rollback, and application rollback.

## Trade-offs

- A blueprint keeps the repository easier to understand, but leaves implementation details for future phases.
- Separating database security from schema migration reduces coupling, but requires clear pipeline ownership.
- A platform SDK makes application integration easier, but it must stay thin so it does not become a shared business-logic library.
- Hosting the portfolio site from an isolated Static Web App Terraform root keeps documentation hosting independent from AKS platform lifecycle changes.

## Future Improvements

- Add reusable Terraform modules.
- Add Pulumi database security examples.
- Add diagrams.
- Add CI validation for formatting, security checks, and documentation consistency.
