output "id" {
  description = "User-assigned managed identity ID."
  value       = azurerm_user_assigned_identity.this.id
}

output "client_id" {
  description = "User-assigned managed identity client ID."
  value       = azurerm_user_assigned_identity.this.client_id
}

output "principal_id" {
  description = "User-assigned managed identity principal ID."
  value       = azurerm_user_assigned_identity.this.principal_id
}
