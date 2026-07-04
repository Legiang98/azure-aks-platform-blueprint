output "id" {
  description = "Private Endpoint ID."
  value       = azurerm_private_endpoint.this.id
}

output "name" {
  description = "Private Endpoint name."
  value       = azurerm_private_endpoint.this.name
}

output "custom_dns_configs" {
  description = "Custom DNS configurations exposed by the Private Endpoint."
  value       = azurerm_private_endpoint.this.custom_dns_configs
}

output "network_interface" {
  description = "Network interface details for the Private Endpoint."
  value       = azurerm_private_endpoint.this.network_interface
}

output "private_service_connection" {
  description = "Private service connection details."
  value       = azurerm_private_endpoint.this.private_service_connection
}
