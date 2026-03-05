output "resource_group_primary_name" {
  description = "The name of the primary resource group."
  value       = module.resource_group_primary.name
}

output "resource_group_secondary_name" {
  description = "The name of the secondary resource group."
  value       = module.resource_group_secondary.name
}

output "primary_vnet_id" {
  description = "The ID of the primary virtual network."
  value       = module.networking_primary.vnet_id
}

output "secondary_vnet_id" {
  description = "The ID of the secondary virtual network."
  value       = module.networking_secondary.vnet_id
}

output "primary_web_app_name" {
  description = "The name of the primary web app."
  value       = module.app_service_primary.web_app_name
}

output "secondary_web_app_name" {
  description = "The name of the secondary web app."
  value       = module.app_service_secondary.web_app_name
}

output "front_door_endpoint_hostname" {
  description = "The hostname of the Front Door endpoint."
  value       = module.front_door.endpoint_hostname
}

output "key_vault_uri" {
  description = "The URI of the primary Key Vault."
  value       = module.key_vault_primary.key_vault_uri
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
