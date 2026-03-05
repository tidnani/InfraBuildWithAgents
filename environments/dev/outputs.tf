output "resource_group_name" {
  description = "The name of the resource group."
  value       = module.resource_group.name
}

output "vnet_id" {
  description = "The ID of the virtual network."
  value       = module.networking.vnet_id
}

output "web_app_name" {
  description = "The name of the web app."
  value       = module.app_service.web_app_name
}

output "web_app_default_hostname" {
  description = "The default hostname of the web app."
  value       = module.app_service.web_app_default_hostname
}

output "front_door_endpoint_hostname" {
  description = "The hostname of the Front Door endpoint."
  value       = module.front_door.endpoint_hostname
}

output "key_vault_uri" {
  description = "The URI of the Key Vault."
  value       = module.key_vault.key_vault_uri
}

output "log_analytics_workspace_id" {
  description = "The ID of the Log Analytics workspace."
  value       = module.monitoring.log_analytics_workspace_id
}

output "app_insights_connection_string" {
  description = "The connection string for Application Insights."
  value       = module.monitoring.app_insights_connection_string
  sensitive   = true
}
