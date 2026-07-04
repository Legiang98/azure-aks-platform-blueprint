# Tenant Intake Form

Root domain: `<platform-domain>`

Use this form for every tenant that will run workloads on the shared AKS cluster. The Terraform infrastructure environment is `platform`; tenant workload environments such as `dev` or `prod` are represented inside Kubernetes with namespaces, quotas, identity bindings, and deployment pipelines.

## Tenant Overview

| Field | Value |
| --- | --- |
| Tenant name | `<tenant-name>` |
| Business owner | `<owner>` |
| Technical owner | `<owner>` |
| Cost center / project code | `<cost-center>` |
| Application / service name | `<service-name>` |
| Repository URL | `<repository-url>` |
| Container image registry path | `<image-path>` |
| Data sensitivity | Internal / Confidential / Restricted |
| Requires dedicated node pool? | No |
| Dedicated node pool reason | Noisy-neighbor isolation / Other |

## Dev Environment

| Field | Value |
| --- | --- |
| Environment | `dev` |
| Namespace name | `tenant-<tenant-name>-dev` |
| Entra ID group for admins | `<tenant-name>-dev-admin` |
| Entra ID group for developers | `<tenant-name>-dev-developer` |
| CPU quota | 2 |
| Memory quota | 4Gi |
| Default CPU request | 100m |
| Default memory request | 256Mi |
| Default CPU limit | 2 |
| Default memory limit | 4Gi |
| Max pods | 20 |
| Ingress hostname pattern | `<tenant-name>-dev.<platform-domain>` |
| Additional hostnames |  |
| External dependencies allowed |  |
| Azure resources required | Key Vault / Storage / Database / Service Bus / Other |
| Workload identity required? | Yes / No | Yes
| Dedicated node pool required? | Yes / No | Yes
| Dedicated node pool name | `pool-dev` |

## Prod Environment

| Field | Value |
| --- | --- |
| Environment | `prod` |
| Namespace name | `tenant-<tenant-name>-prod` |
| Entra ID group for admins |  |
| Entra ID group for developers |  |
| CPU quota |  |
| Memory quota |  |
| Default CPU request |  |
| Default memory request |  |
| Default CPU limit |  |
| Default memory limit |  |
| Max pods |  |
| Ingress hostname pattern | `<tenant-name>.<platform-domain>` |
| Additional hostnames |  |
| External dependencies allowed |  |
| Azure resources required | Key Vault / Storage / Database / Service Bus / Other |
| Workload identity required? | Yes / No |
| Dedicated node pool required? | Yes / No |
| Dedicated node pool name | `<tenant-name>prod` |

## Access Model

| Access type | Dev group | Prod group | Notes |
| --- | --- | --- | --- |
| Tenant admins |  |  | Can manage workloads in tenant namespace only |
| Tenant developers |  |  | Can deploy/read workloads in tenant namespace only |
| Read-only users |  |  | Optional |
| CI/CD identity |  |  | Used by deployment pipeline |

## Network Policy Requirements

| Requirement | Dev | Prod | Notes |
| --- | --- | --- | --- |
| Allow ingress from shared ingress controller | Yes / No | Yes / No | Usually Yes |
| Allow namespace-to-namespace traffic |  |  | Specify source and destination namespaces |
| Allow outbound internet access | Yes / No | Yes / No | Prefer explicit allowlist |
| Allow Azure private endpoint access | Yes / No | Yes / No | Specify service names |
| Allow database access | Yes / No | Yes / No | Specify hostname or private endpoint |
| Allow DNS egress | Yes | Yes | Required for normal workloads |

## Resource Quota Proposal

| Environment | CPU quota | Memory quota | Max pods | Storage quota | Notes |
| --- | --- | --- | --- | --- | --- |
| dev |  |  |  |  |  |
| prod |  |  |  |  |  |

## Ingress And DNS

| Environment | Primary hostname | TLS required | WAF required | Notes |
| --- | --- | --- | --- | --- |
| dev | `<tenant-name>-dev.<platform-domain>` | Yes / No | Yes / No |  |
| prod | `<tenant-name>.<platform-domain>` | Yes | Yes / No |  |

## Data Classification

Choose one:

- Public
- Internal
- Confidential
- Restricted

Notes:

```text

```

## Dedicated Node Pool Decision

| Question | Answer |
| --- | --- |
| Is a dedicated node pool required? | Yes / No |
| Which environments need it? | dev / prod / both |
| Reason |  |
| Required VM SKU |  |
| Minimum node count |  |
| Maximum node count |  |
| Required labels |  |
| Required taints |  |

## Approval

| Role | Name | Date | Approved |
| --- | --- | --- | --- |
| Business owner |  |  | Yes / No |
| Platform owner |  |  | Yes / No |
| Security reviewer |  |  | Yes / No |
| Cost owner |  |  | Yes / No |
