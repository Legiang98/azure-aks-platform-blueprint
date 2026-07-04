variable "name" {
  description = "Private Endpoint name."
  type        = string
}

variable "location" {
  description = "Azure region for the Private Endpoint."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name."
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID where the Private Endpoint is created."
  type        = string
}

variable "private_connection_resource_id" {
  description = "Resource ID of the private link target."
  type        = string
}

variable "subresource_names" {
  description = "Private Link subresource names, such as vault, registry, sqlServer, or blob."
  type        = list(string)
}

variable "private_dns_zone_ids" {
  description = "Private DNS zone IDs associated with this Private Endpoint."
  type        = list(string)
  default     = []
}

variable "private_service_connection_name" {
  description = "Private service connection name. Defaults to <name>-connection when null."
  type        = string
  default     = null
}

variable "is_manual_connection" {
  description = "Whether the private service connection requires manual approval."
  type        = bool
  default     = false
}

variable "request_message" {
  description = "Request message used when manual approval is required."
  type        = string
  default     = null
}

variable "private_dns_zone_group_name" {
  description = "Private DNS zone group name."
  type        = string
  default     = "default"
}

variable "tags" {
  description = "Tags applied to the Private Endpoint."
  type        = map(string)
  default     = {}
}
