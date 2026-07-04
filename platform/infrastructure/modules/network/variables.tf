variable "name" {
  description = "Virtual network name."
  type        = string
}

variable "location" {
  description = "Azure region for the virtual network."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name."
  type        = string
}

variable "address_space" {
  description = "Virtual network address space."
  type        = list(string)
}

variable "subnets" {
  description = "Subnets keyed by logical name."
  type = map(object({
    name                                      = string
    address_prefixes                          = list(string)
    private_endpoint_network_policies_enabled = optional(bool, true)
  }))
}

variable "tags" {
  description = "Tags applied to the virtual network."
  type        = map(string)
  default     = {}
}
