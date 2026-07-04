---
name: code-review
description: Review repository changes for Azure platform security, maintainability, infrastructure design quality, database security boundaries, documentation alignment, and public-portfolio safety.
---

# Code Review Skill

## Purpose

Review repository changes for security, maintainability, platform design quality, and public-portfolio safety.

## Review Checklist

- No secrets, tokens, tenant IDs, subscription IDs, internal domains, kubeconfigs, or production IPs.
- Clear separation between infrastructure, database security, app deployment, and schema migrations.
- Least-privilege access model.
- Secure identity pattern using Managed Identity, Workload Identity, OIDC, or Key Vault references where appropriate.
- Maintainable Terraform/OpenTofu and Pulumi structure.
- Documentation updated when platform behavior, architecture, access patterns, or operations change.
- Public portfolio safety maintained.
- No overclaiming such as "fully production-ready" unless the repo actually implements and documents the required controls.

## Review Style

- Lead with findings ordered by severity.
- Reference files and lines when possible.
- Call out missing tests, validation, or documentation.
- Distinguish blockers from follow-up improvements.
- Keep summaries brief and actionable.
