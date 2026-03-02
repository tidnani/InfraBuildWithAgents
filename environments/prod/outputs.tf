output "resource_group_name" {
  description = "The name of the resource group."
  value       = module.resource_group.name
}

output "resource_group_id" {
  description = "The ID of the resource group."
  value       = module.resource_group.id
}

output "app_service_url" {
  description = "The URL of the App Service."
  value       = "https://${module.app_service.default_hostname}"
}

output "front_door_url" {
  description = "The URL of the Front Door endpoint."
  value       = "https://${module.front_door.endpoint_hostname}"
}

output "log_analytics_workspace_id" {
  description = "The ID of the Log Analytics Workspace."
  value       = module.monitoring.log_analytics_workspace_id
}

output "key_vault_uri" {
  description = "The URI of the Key Vault."
  value       = module.key_vault.uri
}

output "sql_server_fqdn" {
  description = "The FQDN of the SQL Server."
  value       = module.sql_database.server_fqdn
}
