output "app_service_id" {
  description = "Resource ID of the App Service."
  value       = azurerm_linux_web_app.main.id
}

output "app_service_name" {
  description = "Name of the App Service."
  value       = azurerm_linux_web_app.main.name
}

output "app_service_default_hostname" {
  description = "Default hostname of the App Service."
  value       = azurerm_linux_web_app.main.default_hostname
}

output "app_service_principal_id" {
  description = "System-assigned managed identity principal ID of the App Service."
  value       = azurerm_linux_web_app.main.identity[0].principal_id
}

output "service_plan_id" {
  description = "Resource ID of the App Service Plan."
  value       = azurerm_service_plan.main.id
}

output "private_endpoint_id" {
  description = "Resource ID of the App Service private endpoint."
  value       = azurerm_private_endpoint.app_service.id
}

output "autoscale_setting_id" {
  description = "Resource ID of the App Service auto-scale setting."
  value       = azurerm_monitor_autoscale_setting.app_service.id
}
