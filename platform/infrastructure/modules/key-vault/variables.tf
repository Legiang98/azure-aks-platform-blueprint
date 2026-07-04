variable "name" {
  description = "Key Vault name."
  type        = string
}

variable "location" {
  description = "Azure region for the Key Vault."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name."
  type        = string
}

variable "tenant_id" {
  description = "Tenant ID for the Key Vault."
  type        = string
}

variable "sku_name" {
  description = "Key Vault SKU."
  type        = string
  default     = "standard"
}

variable "enable_rbac_authorization" {
  description = "Use Azure RBAC for Key Vault authorization."
  type        = bool
  default     = true
}

variable "purge_protection_enabled" {
  description = "Enable purge protection."
  type        = bool
  default     = false
}

variable "soft_delete_retention_days" {
  description = "Soft delete retention in days."
  type        = number
  default     = 7
}

variable "role_assignments" {
  description = "Role assignments scoped to this Key Vault."
  type = map(object({
    role_definition_name = string
    principal_id         = string
  }))
  default = {}
}

variable "tags" {
  description = "Tags applied to the Key Vault."
  type        = map(string)
  default     = {}
}
