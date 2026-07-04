variable "zone_name" {
  description = "Azure Private DNS zone name, such as privatelink.vaultcore.azure.net."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name for the Private DNS zone."
  type        = string
}

variable "vnet_links" {
  description = "Virtual network links keyed by logical link name."
  type = map(object({
    virtual_network_id   = string
    name                 = optional(string)
    registration_enabled = optional(bool, false)
    tags                 = optional(map(string), {})
  }))
  default = {}
}

variable "tags" {
  description = "Tags applied to Private DNS resources."
  type        = map(string)
  default     = {}
}
