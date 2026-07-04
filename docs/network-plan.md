# Platform Network Plan

This blueprint uses separate VNets for VPN entry, AKS workloads, and data/private endpoint boundaries.

## CIDR Allocation

| Network | Purpose | CIDR |
| --- | --- | --- |
| `vnet-platform-vpn` | WireGuard Portal VM and future VPN landing-zone resources | `10.20.0.0/16` |
| `vnet-platform-aks` | AKS system, application, ingress, and API server subnets | `10.40.0.0/16` |
| `vnet-platform-data` | Database administration and private endpoints | `10.60.0.0/16` |
| Kubernetes services | AKS `network_profile.service_cidr` | `192.168.0.0/16` |
| Kubernetes DNS service | AKS `network_profile.dns_service_ip` | `192.168.0.10` |

## Subnets

| VNet | Subnet | CIDR | Purpose |
| --- | --- | --- | --- |
| `vpn` | `snet-wireguard` | `10.20.0.0/24` | WireGuard Portal VM |
| `vpn` | `snet-management` | `10.20.1.0/24` | Future management resources |
| `aks` | `snet-aks-system` | `10.40.0.0/24` | AKS system node pool |
| `aks` | `snet-aks-apps` | `10.40.1.0/24` | Tenant application node pool |
| `aks` | `snet-aks-ingress` | `10.40.8.0/24` | Ingress resources |
| `aks` | `snet-aks-api-server` | `10.40.10.0/28` | Future API server private networking |
| `data` | `snet-data-private-endpoints` | `10.60.0.0/24` | Azure SQL and other private endpoints |
| `data` | `snet-database-admin` | `10.60.1.0/24` | Future database administration workloads |

## Peering

The platform peers `vpn` to `aks` and `vpn` to `data` in both directions. Direct `aks` to `data` peering is intentionally not enabled by default so application data access paths can be made explicit.

## Private DNS

The Azure SQL private endpoint uses `privatelink.database.windows.net`. The private DNS zone is linked to `vpn`, `aks`, and `data` so VPN operators and platform workloads can resolve SQL to the private endpoint.

## Apply Impact

Changing VNet or subnet CIDRs can force replacement of network-dependent resources, including VM NICs, private endpoints, AKS node pools, and peering. Review `terraform plan` carefully before applying changes to existing infrastructure.
