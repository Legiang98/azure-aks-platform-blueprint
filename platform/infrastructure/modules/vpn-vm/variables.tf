variable "name" {
  description = "VPN VM name."
  type        = string
}

variable "location" {
  description = "Azure region for the VPN VM."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name."
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for the VPN VM NIC."
  type        = string
}

variable "vm_size" {
  description = "VPN VM size."
  type        = string
  default     = "Standard_B1s"
}

variable "admin_username" {
  description = "Admin username for SSH."
  type        = string
  default     = "azureuser"
}

variable "admin_ssh_public_key" {
  description = "SSH public key for the VM admin user."
  type        = string
  sensitive   = true
}

variable "ssh_source_address_prefixes" {
  description = "CIDR ranges allowed to SSH to the VPN VM. Empty list disables public SSH."
  type        = list(string)
  default     = []
}

variable "wireguard_port" {
  description = "WireGuard UDP port."
  type        = number
  default     = 51820
}

variable "https_enabled" {
  description = "Whether to allow HTTPS for the WireGuard portal reverse proxy."
  type        = bool
  default     = true
}

variable "os_disk_size_gb" {
  description = "OS disk size in GB."
  type        = number
  default     = 30
}

variable "os_disk_storage_account_type" {
  description = "OS disk storage account type."
  type        = string
  default     = "Standard_LRS"
}

variable "tags" {
  description = "Tags applied to VPN VM resources."
  type        = map(string)
  default     = {}
}
