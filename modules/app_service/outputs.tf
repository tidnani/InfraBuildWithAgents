output "app_service_id" {
  description = "The resource ID of the Linux web app."
  value       = azurerm_linux_web_app.this.id
}

output "app_service_name" {
  description = "The name of the Linux web app."
  value       = azurerm_linux_web_app.this.name
}

output "app_service_default_hostname" {
  description = "The default hostname of the Linux web app."
  value       = azurerm_linux_web_app.this.default_hostname
}

output "app_service_plan_id" {
  description = "The resource ID of the App Service Plan."
  value       = azurerm_service_plan.this.id
}

output "principal_id" {
  description = "The principal ID of the system-assigned managed identity."
  value       = azurerm_linux_web_app.this.identity[0].principal_id
}

output "tenant_id" {
  description = "The tenant ID of the system-assigned managed identity."
  value       = azurerm_linux_web_app.this.identity[0].tenant_id
}
