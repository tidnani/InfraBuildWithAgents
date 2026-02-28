output "log_analytics_workspace_id" {
  description = "Resource ID of the Log Analytics Workspace."
  value       = azurerm_log_analytics_workspace.main.id
}

output "log_analytics_workspace_name" {
  description = "Name of the Log Analytics Workspace."
  value       = azurerm_log_analytics_workspace.main.name
}

output "app_insights_id" {
  description = "Resource ID of the Application Insights component."
  value       = azurerm_application_insights.main.id
}

output "app_insights_connection_string" {
  description = "Connection string for the Application Insights component."
  value       = azurerm_application_insights.main.connection_string
  sensitive   = true
}

output "app_insights_instrumentation_key" {
  description = "Instrumentation key for the Application Insights component."
  value       = azurerm_application_insights.main.instrumentation_key
  sensitive   = true
}

output "action_group_id" {
  description = "Resource ID of the critical alert action group."
  value       = azurerm_monitor_action_group.critical.id
}

output "dashboard_id" {
  description = "Resource ID of the Azure Portal operations dashboard."
  value       = azurerm_portal_dashboard.main.id
}
