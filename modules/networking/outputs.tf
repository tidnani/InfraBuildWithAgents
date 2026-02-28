output "vnet_id" {
  description = "Resource ID of the Virtual Network."
  value       = azurerm_virtual_network.main.id
}

output "vnet_name" {
  description = "Name of the Virtual Network."
  value       = azurerm_virtual_network.main.name
}

output "app_service_subnet_id" {
  description = "Resource ID of the App Service integration subnet."
  value       = azurerm_subnet.app_service.id
}

output "private_endpoint_subnet_id" {
  description = "Resource ID of the private endpoint subnet."
  value       = azurerm_subnet.private_endpoints.id
}

output "bastion_subnet_id" {
  description = "Resource ID of the Azure Bastion subnet."
  value       = azurerm_subnet.bastion.id
}

output "blob_private_dns_zone_id" {
  description = "Resource ID of the Blob Storage private DNS zone."
  value       = azurerm_private_dns_zone.blob.id
}

output "sql_private_dns_zone_id" {
  description = "Resource ID of the SQL Database private DNS zone."
  value       = azurerm_private_dns_zone.sql.id
}

output "redis_private_dns_zone_id" {
  description = "Resource ID of the Redis Cache private DNS zone."
  value       = azurerm_private_dns_zone.redis.id
}

output "keyvault_private_dns_zone_id" {
  description = "Resource ID of the Key Vault private DNS zone."
  value       = azurerm_private_dns_zone.keyvault.id
}

output "sites_private_dns_zone_id" {
  description = "Resource ID of the App Service (sites) private DNS zone."
  value       = azurerm_private_dns_zone.sites.id
}

output "bastion_host_id" {
  description = "Resource ID of the Azure Bastion Host."
  value       = azurerm_bastion_host.main.id
}
