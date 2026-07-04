output "id" {
  description = "VPN VM ID."
  value       = azurerm_linux_virtual_machine.this.id
}

output "name" {
  description = "VPN VM name."
  value       = azurerm_linux_virtual_machine.this.name
}

output "private_ip_address" {
  description = "VPN VM private IP address."
  value       = azurerm_network_interface.this.private_ip_address
}

output "public_ip_address" {
  description = "VPN VM public IP address."
  value       = azurerm_public_ip.this.ip_address
}

output "ssh_command" {
  description = "SSH command for Ansible/bootstrap access."
  value       = "ssh ${var.admin_username}@${azurerm_public_ip.this.ip_address}"
}

output "network_security_group_id" {
  description = "VPN VM network security group ID."
  value       = azurerm_network_security_group.this.id
}
