variable "name" {
  description = "Azure Container Registry name."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name."
  type        = string
}

variable "location" {
  description = "Azure region for the registry."
  type        = string
}

variable "sku" {
  description = "Azure Container Registry SKU."
  type        = string
  default     = "Basic"
}

variable "admin_enabled" {
  description = "Whether ACR admin user is enabled."
  type        = bool
  default     = false
}

variable "public_network_access_enabled" {
  description = "Whether public network access is enabled for the registry."
  type        = bool
  default     = true
}

variable "pull_role_assignment_enabled" {
  description = "Whether to create a role assignment for the pull principal ID."
  type        = bool
  default     = false
}

variable "pull_principal_id" {
  description = "Optional principal ID granted AcrPull on this registry."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags applied to the registry."
  type        = map(string)
  default     = {}
}
