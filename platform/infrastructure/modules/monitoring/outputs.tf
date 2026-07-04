output "log_analytics_workspace_id" {
  description = "The ID of the Log Analytics Workspace."
  value       = azurerm_log_analytics_workspace.this.id
}

output "log_analytics_workspace_name" {
  description = "The name of the Log Analytics Workspace."
  value       = azurerm_log_analytics_workspace.this.name
}

output "log_analytics_workspace_workspace_id" {
  description = "The workspace/customer ID of the Log Analytics Workspace."
  value       = azurerm_log_analytics_workspace.this.workspace_id
}

output "application_insights_id" {
  description = "The ID of the Application Insights component."
  value       = azurerm_application_insights.this.id
}

output "application_insights_name" {
  description = "The name of the Application Insights component."
  value       = azurerm_application_insights.this.name
}

output "application_insights_instrumentation_key" {
  description = "The instrumentation key for Application Insights."
  value       = azurerm_application_insights.this.instrumentation_key
  sensitive   = true
}

output "application_insights_connection_string" {
  description = "The Connection String for Application Insights."
  value       = azurerm_application_insights.this.connection_string
  sensitive   = true
}
