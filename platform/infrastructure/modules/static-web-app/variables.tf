variable "name" {
  description = "Azure Static Web App name."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name."
  type        = string
}

variable "location" {
  description = "Azure region. Static Web Apps support a subset of regions."
  type        = string
}

variable "sku_tier" {
  description = "Static Web App SKU tier."
  type        = string
  default     = "Free"
}

variable "sku_size" {
  description = "Static Web App SKU size."
  type        = string
  default     = "Free"
}

variable "tags" {
  description = "Tags applied to the Static Web App."
  type        = map(string)
  default     = {}
}
