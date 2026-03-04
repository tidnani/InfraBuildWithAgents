output "log_analytics_workspace_id" {
  description = "The resource ID of the Log Analytics workspace."
  value       = azurerm_log_analytics_workspace.this.id
}

output "log_analytics_workspace_name" {
  description = "The name of the Log Analytics workspace."
  value       = azurerm_log_analytics_workspace.this.name
}

output "app_insights_id" {
  description = "The resource ID of the Application Insights component."
  value       = azurerm_application_insights.this.id
}

output "app_insights_name" {
  description = "The name of the Application Insights component."
  value       = azurerm_application_insights.this.name
}

output "app_insights_instrumentation_key" {
  description = "The instrumentation key for Application Insights."
  value       = azurerm_application_insights.this.instrumentation_key
  sensitive   = true
}

output "app_insights_connection_string" {
  description = "The connection string for Application Insights."
  value       = azurerm_application_insights.this.connection_string
  sensitive   = true
}

output "action_group_id" {
  description = "The resource ID of the Monitor action group."
  value       = azurerm_monitor_action_group.this.id
}
