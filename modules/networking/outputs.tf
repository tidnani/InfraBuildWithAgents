output "vnet_id" {
  description = "The ID of the virtual network."
  value       = azurerm_virtual_network.this.id
}

output "vnet_name" {
  description = "The name of the virtual network."
  value       = azurerm_virtual_network.this.name
}

output "app_service_subnet_id" {
  description = "The ID of the App Service integration subnet."
  value       = azurerm_subnet.app_service_integration.id
}

output "private_endpoint_subnet_id" {
  description = "The ID of the private endpoints subnet."
  value       = azurerm_subnet.private_endpoints.id
}

output "app_service_private_dns_zone_id" {
  description = "The ID of the App Service private DNS zone."
  value       = azurerm_private_dns_zone.app_service.id
}

output "key_vault_private_dns_zone_id" {
  description = "The ID of the Key Vault private DNS zone."
  value       = azurerm_private_dns_zone.key_vault.id
}

output "app_service_private_dns_zone_name" {
  description = "The name of the App Service private DNS zone."
  value       = azurerm_private_dns_zone.app_service.name
}

output "key_vault_private_dns_zone_name" {
  description = "The name of the Key Vault private DNS zone."
  value       = azurerm_private_dns_zone.key_vault.name
}
