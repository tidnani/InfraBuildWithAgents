output "private_endpoint_ids" {
  description = "Map of private endpoint names to their IDs."
  value       = { for k, v in azurerm_private_endpoint.this : k => v.id }
}

output "private_endpoint_ip_addresses" {
  description = "Map of private endpoint names to their private IP addresses."
  value = {
    for k, v in azurerm_private_endpoint.this :
    k => v.private_service_connection[0].private_ip_address
  }
}

output "sql_private_dns_zone_id" {
  description = "The ID of the SQL private DNS zone."
  value       = var.create_dns_zones ? azurerm_private_dns_zone.sql[0].id : null
}

output "redis_private_dns_zone_id" {
  description = "The ID of the Redis private DNS zone."
  value       = var.create_dns_zones ? azurerm_private_dns_zone.redis[0].id : null
}

output "keyvault_private_dns_zone_id" {
  description = "The ID of the Key Vault private DNS zone."
  value       = var.create_dns_zones ? azurerm_private_dns_zone.keyvault[0].id : null
}
