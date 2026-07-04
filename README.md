# Azure AKS Platform Blueprint

A public portfolio/demo blueprint for designing a secure Azure AKS platform with Terraform, Pulumi, CI/CD, identity, networking, database security, and observability.

This repository is a portfolio/demo blueprint for learning and reference purposes. It does not contain proprietary client code, production credentials, tenant IDs, subscription IDs, internal domains, or company-specific infrastructure configuration.

## Overview

This repository demonstrates an Azure-first platform engineering reference pattern for AKS. It is intended to show how infrastructure, database security, Kubernetes platform configuration, CI/CD, observability, and documentation can be organized in a maintainable public blueprint.

## Goals

- Demonstrate senior-level Azure AKS platform design.
- Use Terraform for Azure infrastructure.
- Use Pulumi for database security baselines.
- Separate infrastructure, database security, application deployment, and schema migration responsibilities.
- Prefer secure identity, least privilege, private networking, observability, and clear documentation.
- Use security automation for SAST, secret scanning, IaC scanning, and dependency updates.
- Keep all examples reusable and safe to publish publicly.

## Non-goals

- This is not a complete production platform.
- This is not a client-specific implementation.
- This repository should not contain real production identifiers, secrets, tenant configuration, or proprietary code.
- Application schema migrations are not managed by the platform database security baseline.

## Repository Structure

```text
.
├── AGENTS.md
├── README.md
├── apps/
├── diagrams/
├── docs/
├── k8s/
├── platform/
│   ├── database-security/
│   ├── infrastructure/
│   │   ├── environments/
│   │   │   ├── dev/
│   │   │   └── portoflio-static-site/
│   │   └── modules/
│   └── extension-sdk/
├── skills/
└── .github/
    └── workflows/
```

## Architecture Summary

The blueprint separates platform responsibilities into clear layers:

- Azure infrastructure is provisioned from `platform/infrastructure/`.
- Terraform infrastructure is currently organized around the `dev` environment for the SQL-focused lab baseline, with a separate isolated root for the portfolio static site.
- The platform infrastructure includes separate VPN, AKS, and data VNets, with Azure SQL exposed through private endpoint and private DNS.
- Database security baselines are managed from `platform/database-security/`.
- Application-facing platform SDK packages live under `platform/extension-sdk/`.
- Kubernetes platform controls, shared gateway resources, and Flux-managed app releases live under `k8s/`.
- Non-Kubernetes application examples may live under `apps/`.
- Azure Platform Monitoring Center lives under `apps/platform-monitoring-dashboard/` as a local dashboard/API for platform state.
- Architecture, security, CI/CD, database security, observability, and troubleshooting notes live under `docs/`.
- The public portfolio website source lives under `platform/infrastructure/environments/portoflio-static-site/site/` and is hosted by the isolated Static Web App Terraform root.

## Technology Stack

- Azure AKS
- Azure Virtual Network and private networking patterns
- Azure Key Vault
- Azure SQL server, elastic pool, database, private endpoint, private DNS, and backup vault patterns
- Terraform
- Pulumi
- GitHub Actions or equivalent CI/CD
- Kubernetes and Gateway API examples
- Azure Monitor and Log Analytics patterns
- Node.js platform SDK package pattern

## Security Notes

- Do not hardcode secrets, credentials, tenant IDs, subscription IDs, private domains, public IPs, or kubeconfigs.
- Prefer Managed Identity, Workload Identity, OIDC federation, Key Vault references, and least-privilege permissions.
- Keep examples generic and suitable for a public portfolio repository.
- Document any demo-only shortcut clearly.

## Database Security vs Schema Migration

Database security management includes users, roles, grants, identity mappings, connection string references, and Key Vault references when needed.

Application schema migrations are separate. Tables, columns, indexes, views, stored procedures, and seed data must be handled by the application release pipeline, not by the platform infrastructure or database security baseline.

## Kubernetes Layout

Kubernetes platform controls and application releases are separated:

- `k8s/platform/`: platform-owned namespaces, quotas, limit ranges, and network policies.
- `k8s/apps/`: application Helm charts and Flux `HelmRelease` resources.
- `k8s/gateway/`: shared Gateway API resources.

## Platform SDK

The platform SDK is a separate package artifact boundary for application teams. The first package is `platform/extension-sdk/node`, published as `@aks-platform/sdk` when connected to a private npm registry such as GitHub Packages or Azure Artifacts.

The SDK wraps platform integrations such as Managed Identity credentials, Key Vault secret access, and Application Insights setup. Application code should call the SDK instead of hardcoding Azure service wiring directly.

## Azure Platform Monitoring Center

`apps/platform-monitoring-dashboard/` contains a FastAPI and React demo platform service for visualizing platform snapshot, resource inventory, database access model, deployment status, observability, and security controls. V1 uses local demo JSON data and does not execute real infrastructure commands.

## Portfolio Static Site

The portfolio website is isolated from the AKS platform runtime:

- `platform/infrastructure/environments/portoflio-static-site/`: Azure Static Web App infrastructure and static website source.
- `platform/infrastructure/modules/static-web-app/`: reusable Static Web App module.

## How To Use This Repository

1. Read `docs/architecture.md` for the intended platform pattern.
2. Review `AGENTS.md` before making automated or agent-assisted changes.
3. Use `platform/infrastructure/` for Terraform infrastructure work.
4. Use `platform/database-security/` for Pulumi-managed database security baselines.
5. Keep documentation updated when architecture or behavior changes.

For the infrastructure refactor direction, see `docs/terraform-refactor-plan.md`.

For the lab execution checklist, see `docs/project-validation-plan.md`.

For AKS node pool HA and autoscaling design, see `docs/aks-ha-autoscaling-plan.md`.

## Public Portfolio Safety Disclaimer

This repository is a portfolio/demo blueprint for learning and reference purposes. It does not contain proprietary client code, production credentials, tenant IDs, subscription IDs, internal domains, or company-specific infrastructure configuration.

## Roadmap

- Continue expanding reusable Terraform modules.
- Add Pulumi database security examples.
- Add CI validation workflows.
- Add architecture diagrams.
- Add observability dashboards and alert examples.
- Add more complete tenant onboarding examples.
