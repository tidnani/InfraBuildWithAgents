terraform {
  required_version = ">= 1.9"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

# Virtual Network
resource "azurerm_virtual_network" "this" {
  name                = var.vnet_name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.vnet_address_space
  tags                = var.tags
}

# Subnet for App Service VNet Integration
resource "azurerm_subnet" "app_service_integration" {
  name                 = var.app_service_subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = var.app_service_subnet_prefixes

  delegation {
    name = "app-service-delegation"
    service_delegation {
      name = "Microsoft.Web/serverFarms"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/action",
      ]
    }
  }
}

# Subnet for Private Endpoints
resource "azurerm_subnet" "private_endpoints" {
  name                 = var.private_endpoint_subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = var.private_endpoint_subnet_prefixes
}

# Network Security Group for App Service Integration Subnet
resource "azurerm_network_security_group" "app_service" {
  name                = "${var.vnet_name}-app-service-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  security_rule {
    name                       = "allow-https-inbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "AzureFrontDoor.Backend"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "deny-all-inbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Network Security Group for Private Endpoints Subnet
resource "azurerm_network_security_group" "private_endpoints" {
  name                = "${var.vnet_name}-private-endpoints-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  security_rule {
    name                       = "allow-vnet-inbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }
}

# Associate NSG with App Service Integration Subnet
resource "azurerm_subnet_network_security_group_association" "app_service" {
  subnet_id                 = azurerm_subnet.app_service_integration.id
  network_security_group_id = azurerm_network_security_group.app_service.id
}

# Associate NSG with Private Endpoints Subnet
resource "azurerm_subnet_network_security_group_association" "private_endpoints" {
  subnet_id                 = azurerm_subnet.private_endpoints.id
  network_security_group_id = azurerm_network_security_group.private_endpoints.id
}

# Private DNS Zone for App Service
resource "azurerm_private_dns_zone" "app_service" {
  name                = "privatelink.azurewebsites.net"
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

# Private DNS Zone for Key Vault
resource "azurerm_private_dns_zone" "key_vault" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

# Link App Service DNS Zone to VNet
resource "azurerm_private_dns_zone_virtual_network_link" "app_service" {
  name                  = "${var.vnet_name}-app-service-dns-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.app_service.name
  virtual_network_id    = azurerm_virtual_network.this.id
  registration_enabled  = false
  tags                  = var.tags
}

# Link Key Vault DNS Zone to VNet
resource "azurerm_private_dns_zone_virtual_network_link" "key_vault" {
  name                  = "${var.vnet_name}-key-vault-dns-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.key_vault.name
  virtual_network_id    = azurerm_virtual_network.this.id
  registration_enabled  = false
  tags                  = var.tags
}
