variable "name" {
  description = "User-assigned managed identity name."
  type        = string
}

variable "location" {
  description = "Azure region for the identity."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name."
  type        = string
}

variable "role_assignments" {
  description = "Role assignments for the managed identity."
  type = map(object({
    scope                = string
    role_definition_name = string
  }))
  default = {}
}

variable "federated_identity_credentials" {
  description = "Federated identity credentials for workload identity."
  type = map(object({
    name     = string
    audience = list(string)
    issuer   = string
    subject  = string
  }))
  default = {}
}

variable "tags" {
  description = "Tags applied to the identity."
  type        = map(string)
  default     = {}
}
