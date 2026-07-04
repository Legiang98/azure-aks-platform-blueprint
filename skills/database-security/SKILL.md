---
name: database-access
description: Manage database users, roles, grants, identity mappings, connection references, and Key Vault references with Pulumi for this repository while keeping schema migrations separate from platform database security management.
---

# Database Security Skill

## Purpose

Manage database security baselines with Pulumi for this AKS portfolio blueprint.

## Scope

- Database users
- Database roles
- Grants and permissions
- Managed Identity and Entra ID mappings
- Connection string references
- Key Vault references when needed

## Non-Scope

- Tables
- Columns
- Indexes
- Views
- Stored procedures
- Seed data
- Application schema migrations

## Workflow

1. Inspect `platform/database-security/` and `docs/database-security.md` before editing.
2. Model access through roles before assigning permissions to individual users or identities.
3. Separate application access, migration access, and reporting access.
4. Prefer Managed Identity or Entra ID mappings where supported.
5. Use Key Vault references for connection material and avoid plaintext credentials.
6. Update `docs/database-security.md` when database security patterns change.

## Suggested Role Patterns

- `app_readwrite`
- `app_readonly`
- `migration_runner`
- `reporting_readonly`

## Rules

- Prefer role-based access over direct grants.
- Avoid broad permissions such as `db_owner` unless clearly documented as demo-only.
- Do not create or modify application schema objects.
- Do not hardcode credentials, tenant IDs, subscription IDs, hostnames, public IPs, or connection strings.
- Keep examples generic and safe for public portfolio use.
