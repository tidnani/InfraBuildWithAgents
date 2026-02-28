output "resource_group_name" {
  description = "Name of the primary resource group."
  value       = azurerm_resource_group.main.name
}

output "resource_group_id" {
  description = "Resource ID of the primary resource group."
  value       = azurerm_resource_group.main.id
}

output "front_door_endpoint_hostname" {
  description = "Public hostname of the Azure Front Door endpoint."
  value       = module.front_door.endpoint_hostname
}

output "front_door_profile_id" {
  description = "Resource ID of the Azure Front Door profile."
  value       = module.front_door.profile_id
}

output "app_service_default_hostname" {
  description = "Default hostname of the App Service."
  value       = module.app_service.app_service_default_hostname
}

output "app_service_id" {
  description = "Resource ID of the App Service."
  value       = module.app_service.app_service_id
}

output "app_service_principal_id" {
  description = "Managed identity principal ID of the App Service."
  value       = module.app_service.app_service_principal_id
}

output "sql_server_fqdn" {
  description = "Fully qualified domain name of the primary SQL Server."
  value       = module.sql_database.sql_server_fqdn
}

output "sql_failover_group_id" {
  description = "Resource ID of the SQL failover group."
  value       = module.sql_database.failover_group_id
}

output "redis_hostname" {
  description = "Hostname of the Redis Cache instance."
  value       = module.redis_cache.redis_hostname
}

output "key_vault_uri" {
  description = "URI of the Azure Key Vault."
  value       = module.key_vault.key_vault_uri
}

output "key_vault_id" {
  description = "Resource ID of the Azure Key Vault."
  value       = module.key_vault.key_vault_id
}

output "log_analytics_workspace_id" {
  description = "Resource ID of the Log Analytics Workspace."
  value       = module.monitoring.log_analytics_workspace_id
}

output "app_insights_connection_string" {
  description = "Connection string for Application Insights."
  value       = module.monitoring.app_insights_connection_string
  sensitive   = true
}

output "vnet_id" {
  description = "Resource ID of the Virtual Network."
  value       = module.networking.vnet_id
}
