variable "name" {
  description = "Azure SQL logical server name. Must be globally unique."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "server_version" {
  description = "Azure SQL server version."
  type        = string
  default     = "12.0"
}

variable "minimum_tls_version" {
  description = "Minimum TLS version for SQL connections."
  type        = string
  default     = "1.2"
}

variable "public_network_access_enabled" {
  description = "Whether public network access is enabled for the SQL server."
  type        = bool
  default     = false
}

variable "administrator_login" {
  description = "Optional SQL administrator login. Prefer Entra-only authentication for this blueprint."
  type        = string
  default     = null
}

variable "administrator_login_password" {
  description = "Optional SQL administrator password. Do not commit real values."
  type        = string
  default     = null
  sensitive   = true
}

variable "azuread_administrator" {
  description = "Optional Entra administrator configuration."
  type = object({
    login_username              = string
    object_id                   = string
    tenant_id                   = string
    azuread_authentication_only = optional(bool, true)
  })
  default = null
}

variable "elastic_pools" {
  description = "Elastic pools keyed by logical name."
  type = map(object({
    name           = string
    max_size_gb    = number
    license_type   = optional(string)
    zone_redundant = optional(bool, false)
    sku = object({
      name     = string
      tier     = string
      family   = optional(string)
      capacity = number
    })
    per_database_settings = object({
      min_capacity = number
      max_capacity = number
    })
    tags = optional(map(string), {})
  }))
  default = {}
}

variable "databases" {
  description = "SQL databases keyed by logical name."
  type = map(object({
    name                 = string
    elastic_pool_key     = optional(string)
    sku_name             = optional(string)
    collation            = optional(string, "SQL_Latin1_General_CP1_CI_AS")
    max_size_gb          = optional(number, 32)
    storage_account_type = optional(string, "Local")
    zone_redundant       = optional(bool, false)
    tags                 = optional(map(string), {})
  }))
  default = {}
}

variable "tags" {
  description = "Tags applied to Azure SQL resources."
  type        = map(string)
  default     = {}
}
