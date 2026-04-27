output "app_public_ip" {
  description = "Public IP of the frontend VM. This is the address users type in the browser."
  value       = azurerm_public_ip.frontend_pip.ip_address
}

output "backend_public_ip" {
  description = "Public IP of the backend VM. Ansible uses this to SSH in and configure the app."
  value       = azurerm_public_ip.backend_pip.ip_address
}

output "backend_private_ip" {
  description = "Private IP of the backend VM. Nginx uses this to forward requests to the app."
  value       = azurerm_network_interface.backend_nic.private_ip_address
}

output "mysql_fqdn" {
  description = "MySQL server hostname. The Node.js app uses this to connect to the database."
  value       = azurerm_mysql_flexible_server.epicbook_db.fqdn
}