---
name: terraform-module
description: Create or update Terraform/OpenTofu modules for Azure AKS platform infrastructure in this repository, including resource groups, networking, private endpoints, private DNS, AKS, Key Vault, Azure SQL infrastructure, diagnostic settings, and managed identity infrastructure.
---

# Terraform/OpenTofu Module Skill

## Purpose

Create or update Terraform/OpenTofu modules for Azure platform infrastructure in this AKS portfolio blueprint.

## Scope

- Resource groups
- VNets and subnets
- Private Endpoints
- Private DNS
- AKS
- Key Vault
- Azure SQL infrastructure
- Monitoring and diagnostic settings
- Managed identity-related infrastructure

## Workflow

1. Inspect `platform/infrastructure/` before editing.
2. Identify whether the change belongs in a reusable module or environment-specific configuration.
3. Keep module inputs and outputs explicit, typed, and documented.
4. Prefer secure defaults and least-privilege identity assignments.
5. Add or update README notes when adding modules or changing usage.
6. Run formatting and validation commands when practical.

## Rules

- Keep modules small and focused.
- Separate reusable modules from environment-specific configuration.
- Do not manage database schema.
- Do not hardcode secrets, real tenant IDs, subscription IDs, private domains, public IPs, kubeconfigs, or real environment identifiers.
- Prefer Key Vault references, Managed Identity, Workload Identity, OIDC, private networking, and diagnostic settings.
- Use generic placeholders suitable for a public portfolio repository.
- Document replacement risk, rollback considerations, and operational assumptions for non-trivial infrastructure changes.
