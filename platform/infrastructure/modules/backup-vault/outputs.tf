output "id" {
  description = "Backup vault ID."
  value       = azurerm_data_protection_backup_vault.this.id
}

output "name" {
  description = "Backup vault name."
  value       = azurerm_data_protection_backup_vault.this.name
}

output "identity_principal_id" {
  description = "System-assigned managed identity principal ID."
  value       = azurerm_data_protection_backup_vault.this.identity[0].principal_id
}

output "identity_tenant_id" {
  description = "System-assigned managed identity tenant ID."
  value       = azurerm_data_protection_backup_vault.this.identity[0].tenant_id
}
