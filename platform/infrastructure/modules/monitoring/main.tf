resource "azurerm_log_analytics_workspace" "this" {
  name                                    = var.log_analytics_workspace_name
  location                                = var.location
  resource_group_name                     = var.resource_group_name
  sku                                     = var.log_analytics_workspace_sku
  retention_in_days                       = var.retention_in_days
  daily_quota_gb                          = var.daily_quota_gb
  internet_ingestion_enabled              = var.internet_ingestion_enabled
  internet_query_enabled                  = var.internet_query_enabled
  local_authentication_disabled           = var.local_authentication_disabled
  allow_resource_only_permissions         = var.allow_resource_only_permissions
  reservation_capacity_in_gb_per_day      = var.reservation_capacity_in_gb_per_day
  immediate_data_purge_on_30_days_enabled = var.immediate_data_purge_on_30_days_enabled
  tags                                    = var.tags
}

resource "azurerm_application_insights" "this" {
  name                = var.application_insights_name
  location            = var.location
  resource_group_name = var.resource_group_name
  workspace_id        = azurerm_log_analytics_workspace.this.id
  application_type    = var.application_insights_type
  tags                = var.tags
}
