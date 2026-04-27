# -----------------------------------------------
# Resource Group
# Think of this as a folder in Azure that holds
# all the related resources for this project.
# -----------------------------------------------
resource "azurerm_resource_group" "epicbook" {
  name     = var.resource_group_name
  location = var.location
}

# -----------------------------------------------
# Virtual Network and Subnets
# The VNet is the private network in the cloud.
# Subnets divide it into sections for each VM.
# -----------------------------------------------
resource "azurerm_virtual_network" "epicbook_vnet" {
  name                = "epicbook-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.epicbook.location
  resource_group_name = azurerm_resource_group.epicbook.name
}

resource "azurerm_subnet" "frontend_subnet" {
  name                 = "frontend-subnet"
  resource_group_name  = azurerm_resource_group.epicbook.name
  virtual_network_name = azurerm_virtual_network.epicbook_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "backend_subnet" {
  name                 = "backend-subnet"
  resource_group_name  = azurerm_resource_group.epicbook.name
  virtual_network_name = azurerm_virtual_network.epicbook_vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

# -----------------------------------------------
# Public IP Addresses
# These are the internet-facing IP addresses.
# Static means the IP does not change on reboot.
# -----------------------------------------------
resource "azurerm_public_ip" "frontend_pip" {
  name                = "epicbook-frontend-pip"
  location            = azurerm_resource_group.epicbook.location
  resource_group_name = azurerm_resource_group.epicbook.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_public_ip" "backend_pip" {
  name                = "epicbook-backend-pip"
  location            = azurerm_resource_group.epicbook.location
  resource_group_name = azurerm_resource_group.epicbook.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# -----------------------------------------------
# Network Security Groups (Firewall Rules)
# These control which traffic is allowed in.
# The frontend allows port 22 (SSH) and port 80 (web).
# The backend allows port 22 (SSH) and port 8080 (app)
# but only from inside the virtual network.
# -----------------------------------------------
resource "azurerm_network_security_group" "frontend_nsg" {
  name                = "frontend-nsg"
  location            = azurerm_resource_group.epicbook.location
  resource_group_name = azurerm_resource_group.epicbook.name

  security_rule {
    name                       = "AllowSSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowHTTP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_security_group" "backend_nsg" {
  name                = "backend-nsg"
  location            = azurerm_resource_group.epicbook.location
  resource_group_name = azurerm_resource_group.epicbook.name

  security_rule {
    name                       = "AllowSSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowAppPort"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = "10.0.0.0/16"
    destination_address_prefix = "*"
  }
}

# -----------------------------------------------
# Network Interfaces
# Like virtual ethernet cards that connect each
# VM to the subnet and assign IP addresses.
# -----------------------------------------------
resource "azurerm_network_interface" "frontend_nic" {
  name                = "frontend-nic"
  location            = azurerm_resource_group.epicbook.location
  resource_group_name = azurerm_resource_group.epicbook.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.frontend_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.frontend_pip.id
  }
}

resource "azurerm_network_interface" "backend_nic" {
  name                = "backend-nic"
  location            = azurerm_resource_group.epicbook.location
  resource_group_name = azurerm_resource_group.epicbook.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.backend_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.backend_pip.id
  }
}

# Attach the security groups to the network interfaces
resource "azurerm_network_interface_security_group_association" "frontend_assoc" {
  network_interface_id      = azurerm_network_interface.frontend_nic.id
  network_security_group_id = azurerm_network_security_group.frontend_nsg.id
}

resource "azurerm_network_interface_security_group_association" "backend_assoc" {
  network_interface_id      = azurerm_network_interface.backend_nic.id
  network_security_group_id = azurerm_network_security_group.backend_nsg.id
}

# -----------------------------------------------
# Frontend VM (runs Nginx reverse proxy)
# Ubuntu 24.04 LTS, Standard_D2als_v6 size
# -----------------------------------------------
resource "azurerm_linux_virtual_machine" "frontend_vm" {
  name                = "epicbook-frontend-vm"
  resource_group_name = azurerm_resource_group.epicbook.name
  location            = azurerm_resource_group.epicbook.location
  size                = "Standard_D2als_v6"
  admin_username      = var.admin_username

  network_interface_ids = [azurerm_network_interface.frontend_nic.id]

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-noble"
    sku       = "24_04-lts"
    version   = "latest"
  }
}

# -----------------------------------------------
# Backend VM (runs Node.js EpicBook application)
# Ubuntu 24.04 LTS, Standard_D2als_v6 size
# -----------------------------------------------
resource "azurerm_linux_virtual_machine" "backend_vm" {
  name                = "epicbook-backend-vm"
  resource_group_name = azurerm_resource_group.epicbook.name
  location            = azurerm_resource_group.epicbook.location
  size                = "Standard_D2als_v6"
  admin_username      = var.admin_username

  network_interface_ids = [azurerm_network_interface.backend_nic.id]

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-noble"
    sku       = "24_04-lts"
    version   = "latest"
  }
}

# -----------------------------------------------
# MySQL Flexible Server (PaaS - managed database)
# Azure runs the DB engine. We only manage data.
# -----------------------------------------------
resource "azurerm_mysql_flexible_server" "epicbook_db" {
  name                   = "epicbook-mysql-99"
  resource_group_name    = azurerm_resource_group.epicbook.name
  location               = azurerm_resource_group.epicbook.location
  administrator_login    = var.mysql_admin_user
  administrator_password = var.mysql_admin_password
  sku_name               = "B_Standard_B1ms"
  version                = "8.0.21"
  backup_retention_days  = 7

  storage {
    size_gb = 20
  }
}

# The bookstore database inside the MySQL server
resource "azurerm_mysql_flexible_database" "bookstore" {
  name                = "bookstore"
  resource_group_name = azurerm_resource_group.epicbook.name
  server_name         = azurerm_mysql_flexible_server.epicbook_db.name
  charset             = "utf8mb4"
  collation           = "utf8mb4_unicode_ci"
}

# Allow the backend VM to connect to MySQL
resource "azurerm_mysql_flexible_server_firewall_rule" "allow_backend" {
  name                = "allow-backend-vm"
  resource_group_name = azurerm_resource_group.epicbook.name
  server_name         = azurerm_mysql_flexible_server.epicbook_db.name
  start_ip_address    = azurerm_public_ip.backend_pip.ip_address
  end_ip_address      = azurerm_public_ip.backend_pip.ip_address
}