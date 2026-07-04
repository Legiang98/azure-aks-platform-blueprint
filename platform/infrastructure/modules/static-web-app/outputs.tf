output "id" {
  description = "Static Web App ID."
  value       = azurerm_static_site.this.id
}

output "name" {
  description = "Static Web App name."
  value       = azurerm_static_site.this.name
}

output "default_host_name" {
  description = "Default Static Web App hostname."
  value       = azurerm_static_site.this.default_host_name
}
