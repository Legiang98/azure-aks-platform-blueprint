variable "name" {
  description = "Virtual network peering name."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name of the local virtual network."
  type        = string
}

variable "virtual_network_name" {
  description = "Local virtual network name."
  type        = string
}

variable "remote_virtual_network_id" {
  description = "Remote virtual network ID."
  type        = string
}

variable "allow_virtual_network_access" {
  description = "Whether traffic from the remote virtual network is allowed."
  type        = bool
  default     = true
}

variable "allow_forwarded_traffic" {
  description = "Whether forwarded traffic from the remote virtual network is allowed."
  type        = bool
  default     = false
}

variable "allow_gateway_transit" {
  description = "Whether gateway links can be used in the remote virtual network."
  type        = bool
  default     = false
}

variable "use_remote_gateways" {
  description = "Whether remote gateways can be used on the local virtual network."
  type        = bool
  default     = false
}
