variable "resource_group_name" {
  description = "Portfolio Static Web App resource group name."
  type        = string
  default     = "portfolio-static-rg"
}

variable "location" {
  description = "Resource group location."
  type        = string
  default     = "Southeast Asia"
}

variable "static_web_app_name" {
  description = "Azure Static Web App name. Must be globally unique."
  type        = string
  default     = "swa-aks-platform-portfolio"
}

variable "static_web_app_location" {
  description = "Azure Static Web App location. Static Web Apps support a subset of Azure regions."
  type        = string
  default     = "East Asia"
}

variable "static_web_app_sku_tier" {
  description = "Static Web App SKU tier."
  type        = string
  default     = "Free"
}

variable "static_web_app_sku_size" {
  description = "Static Web App SKU size."
  type        = string
  default     = "Free"
}

variable "tags" {
  description = "Tags applied to portfolio static site resources."
  type        = map(string)
  default = {
    scope      = "portfolio-site"
    project    = "azure-aks-platform-blueprint"
    purpose    = "portfolio-demo"
    managed_by = "terraform"
  }
}
