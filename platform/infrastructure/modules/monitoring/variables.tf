variable "log_analytics_workspace_name" {
  description = "Name of the Log Analytics Workspace."
  type        = string
}

variable "application_insights_name" {
  description = "Name of the Application Insights instance."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name."
  type        = string
}

variable "location" {
  description = "Azure region for the monitoring resources."
  type        = string
}

variable "retention_in_days" {
  description = "Workspace data retention in days."
  type        = number
  default     = 30
}

variable "log_analytics_workspace_sku" {
  description = "SKU for the Log Analytics Workspace."
  type        = string
  default     = "PerGB2018"
}

variable "daily_quota_gb" {
  description = "Daily ingestion quota in GB. Use -1 for unlimited."
  type        = number
  default     = -1
}

variable "internet_ingestion_enabled" {
  description = "Whether public internet ingestion is enabled for the workspace."
  type        = bool
  default     = true
}

variable "internet_query_enabled" {
  description = "Whether public internet query access is enabled for the workspace."
  type        = bool
  default     = true
}

variable "local_authentication_disabled" {
  description = "Whether local authentication is disabled for the workspace."
  type        = bool
  default     = false
}

variable "allow_resource_only_permissions" {
  description = "Whether to use resource-specific permissions for the workspace."
  type        = bool
  default     = false
}

variable "reservation_capacity_in_gb_per_day" {
  description = "Capacity reservation in GB per day. Use null for no reservation."
  type        = number
  default     = null
}

variable "immediate_data_purge_on_30_days_enabled" {
  description = "Whether data is purged immediately after 30 days."
  type        = bool
  default     = false
}

variable "application_insights_type" {
  description = "Application Insights application type."
  type        = string
  default     = "web"
}

variable "tags" {
  description = "Tags applied to the monitoring resources."
  type        = map(string)
  default     = {}
}
