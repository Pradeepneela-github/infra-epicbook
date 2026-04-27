variable "location" {
  description = "Azure region for all resources"
  default     = "Sweden Central"
}

variable "resource_group_name" {
  description = "Name for the main resource group"
  default     = "epicbook-rg"
}

variable "admin_username" {
  description = "Admin username for the VMs"
  default     = "azureuser"
}

variable "ssh_public_key" {
  description = "Full content of the SSH public key file"
  type        = string
}

variable "mysql_admin_user" {
  description = "Admin login for MySQL Flexible Server"
  default     = "epicadmin"
}

variable "mysql_admin_password" {
  description = "Admin password for MySQL"
  type        = string
  sensitive   = true
}