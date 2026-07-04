# Agent Instructions

## Project Context

This repository is an Azure AKS platform portfolio blueprint. It demonstrates Azure-first DevOps and Platform Engineering practices using Terraform/OpenTofu, Pulumi, CI/CD, identity, networking, database security management, observability, and documentation.

This repository is a portfolio/demo blueprint for learning and reference purposes. It does not contain proprietary client code, production credentials, tenant IDs, subscription IDs, internal domains, or company-specific infrastructure configuration.

## Primary Goals

- Show a reusable AKS platform reference pattern for public portfolio use.
- Keep infrastructure, database security, application deployment, and schema migration concerns separate.
- Demonstrate secure defaults, least privilege, managed identity, rollback awareness, observability, and maintainable documentation.
- Prefer small, reviewable changes that are easy to explain and validate.

## Repository Structure

- `platform/infrastructure/`: Azure infrastructure provisioned with Terraform/OpenTofu.
- `platform/database-security/`: Database security baseline managed with Pulumi.
- `apps/`: Example application workloads or deployment references.
- `docs/`: Architecture, security, CI/CD, database security, observability, and troubleshooting documentation.
- `diagrams/`: Architecture and flow diagrams.
- `skills/`: Reusable repository-local agent skills for common work patterns.
- `.github/workflows/`: CI/CD workflow definitions.
- `k8s/`: Kubernetes manifests and platform bootstrap examples when present.

## Design Principles

- Treat this repository as a public blueprint, not a client production system.
- Do not add proprietary client code, real tenant IDs, subscription IDs, private domains, secrets, tokens, kubeconfigs, or production IP addresses.
- Prefer Managed Identity, Workload Identity, OIDC, Key Vault references, and least-privilege access.
- Keep environment-specific configuration separate from reusable modules.
- Document trade-offs, operational assumptions, rollback paths, and known gaps.
- Avoid claiming the repository is fully production-ready unless the required controls are actually implemented and documented.

## Terraform/OpenTofu Infrastructure Rules

- Use `platform/infrastructure/` for Azure infrastructure provisioned with Terraform/OpenTofu.
- Keep modules small, focused, and reusable.
- Separate reusable modules from environment-specific configuration.
- Prefer secure defaults for networking, identity, storage, monitoring, and secret references.
- Do not hardcode secrets, credentials, tenant IDs, subscription IDs, private domains, public IPs, or kubeconfigs.
- Preserve existing Terraform backend blocks and backend configuration values unless the user explicitly asks to change or remove them.
- Do not manage application database schema in Terraform/OpenTofu.
- Run formatting and validation commands when changing infrastructure, such as `terraform fmt -recursive`, `terraform validate`, or the OpenTofu equivalents where applicable.
- Update documentation when infrastructure behavior, architecture, or operational assumptions change.

## Pulumi Database Security Rules

- Use `platform/database-security/` for the database security baseline managed with Pulumi.
- Database security includes users, roles, grants, identity mappings, connection string references, and Key Vault references when needed.
- Database access does not include application schema migrations.
- Prefer role-based access over direct grants.
- Separate application access, migration access, reporting access, and operator access.
- Avoid broad permissions such as `db_owner` unless clearly marked as demo-only and justified.
- Prefer Managed Identity or Entra ID mappings where supported.
- Update `docs/database-security.md` when database security patterns change.

## Schema Migration Boundary

Schema migrations such as tables, columns, indexes, views, stored procedures, and seed data must be handled separately by the application release pipeline. Do not add schema migration logic to `platform/infrastructure/` or `platform/database-security/`.

## Documentation Rules

- Keep docs concise, practical, and aligned with the current repository state.
- Use terms such as "blueprint", "reference pattern", and "demo pattern".
- Explain why a design was chosen, not only which tool is used.
- Include security considerations, observability expectations, rollback/recovery notes, and future improvements where relevant.
- Update docs whenever platform behavior, architecture, access patterns, or operational workflows change.

## Agent Behavior Rules

- Inspect existing files before editing.
- Preserve useful existing content and improve structure instead of overwriting blindly.
- Keep changes small and reviewable.
- Do not delete unrelated files or user changes.
- Do not introduce real cloud credentials, identifiers, domains, IPs, kubeconfigs, or secrets.
- Prefer generic examples and placeholders suitable for public release.
- When adding platform behavior, include validation notes and documentation updates.
