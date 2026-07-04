variable "name" {
  description = "AKS cluster name."
  type        = string
}

variable "location" {
  description = "Azure region for the AKS cluster."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name."
  type        = string
}

variable "dns_prefix" {
  description = "DNS prefix for the AKS cluster."
  type        = string
}

variable "default_node_pool" {
  description = "System node pool configuration."
  type = object({
    name                         = string
    node_count                   = number
    vm_size                      = string
    vnet_subnet_id               = string
    only_critical_addons_enabled = optional(bool, true)
  })
}

variable "network_profile" {
  description = "AKS network profile."
  type = object({
    network_plugin = string
    service_cidr   = string
    dns_service_ip = string
  })
}

variable "identity_type" {
  description = "AKS cluster identity type."
  type        = string
  default     = "SystemAssigned"
}

variable "oidc_issuer_enabled" {
  description = "Enable the AKS OIDC issuer."
  type        = bool
  default     = true
}

variable "workload_identity_enabled" {
  description = "Enable AKS workload identity."
  type        = bool
  default     = true
}

variable "user_node_pools" {
  description = "User node pools keyed by logical name."
  type = map(object({
    name                = string
    vm_size             = string
    vnet_subnet_id      = string
    mode                = optional(string, "User")
    priority            = optional(string, "Regular")
    eviction_policy     = optional(string)
    spot_max_price      = optional(number)
    enable_auto_scaling = optional(bool, false)
    min_count           = optional(number)
    max_count           = optional(number)
    node_count          = optional(number)
    node_labels         = optional(map(string), {})
    node_taints         = optional(list(string), [])
  }))
  default = {}
}

variable "tags" {
  description = "Tags applied to AKS resources."
  type        = map(string)
  default     = {}
}
