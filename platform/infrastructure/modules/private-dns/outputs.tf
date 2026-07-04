output "zone_id" {
  description = "Private DNS zone ID."
  value       = azurerm_private_dns_zone.this.id
}

output "zone_name" {
  description = "Private DNS zone name."
  value       = azurerm_private_dns_zone.this.name
}

output "vnet_link_ids" {
  description = "Private DNS virtual network link IDs keyed by logical link name."
  value       = { for key, link in azurerm_private_dns_zone_virtual_network_link.this : key => link.id }
}
