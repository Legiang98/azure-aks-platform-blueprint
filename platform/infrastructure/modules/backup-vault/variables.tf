variable "name" {
  description = "Data Protection Backup Vault name."
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

variable "datastore_type" {
  description = "Backup vault datastore type."
  type        = string
  default     = "VaultStore"
}

variable "redundancy" {
  description = "Backup vault redundancy. Use LocallyRedundant for the lowest-cost blueprint default."
  type        = string
  default     = "LocallyRedundant"
}

variable "tags" {
  description = "Tags applied to the backup vault."
  type        = map(string)
  default     = {}
}
