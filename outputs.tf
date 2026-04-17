output "app_public_ip" {
  description = "Public IP address of the frontend VM"
  value       = azurerm_public_ip.frontend.ip_address
}

output "backend_private_ip" {
  description = "Private IP address of the backend VM"
  value       = azurerm_network_interface.backend.private_ip_address
}

output "mysql_fqdn" {
  description = "Fully qualified domain name of the MySQL Flexible Server"
  value       = azurerm_mysql_flexible_server.main.fqdn
}

output "resource_group_name" {
  description = "Name of the application resource group"
  value       = azurerm_resource_group.main.name
}