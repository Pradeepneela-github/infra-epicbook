variable "resource_group_name" {
  description = "Name of the Azure Resource Group"
  type        = string
  default     = "epicbook-prod-rg"
}

variable "location" {
  description = "Azure region to deploy resources"
  type        = string
  default     = "Sweden Central"
}

variable "admin_username" {
  description = "Admin username for the VMs"
  type        = string
  default     = "azureadmin"
}

variable "ssh_public_key_path" {
  description = "Path to your SSH public key"
  type        = string
  default     = "~/.ssh/epicbook.pub"
}

variable "mysql_admin_password" {
  description = "MySQL administrator (root-level) password"
  type        = string
  sensitive   = true
}

variable "vm_size" {
  description = "Azure VM size for frontend and backend VMs"
  type        = string
  default     = "Standard_D2als_v6"
}