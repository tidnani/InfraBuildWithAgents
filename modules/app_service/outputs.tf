output "app_service_plan_id" {
  description = "The ID of the App Service Plan."
  value       = azurerm_service_plan.this.id
}

output "web_app_id" {
  description = "The ID of the Web App."
  value       = azurerm_linux_web_app.this.id
}

output "web_app_name" {
  description = "The name of the Web App."
  value       = azurerm_linux_web_app.this.name
}

output "web_app_default_hostname" {
  description = "The default hostname of the Web App."
  value       = azurerm_linux_web_app.this.default_hostname
}

output "web_app_identity" {
  description = "The managed identity of the Web App."
  value       = azurerm_linux_web_app.this.identity
}

output "web_app_principal_id" {
  description = "The principal ID of the Web App's system-assigned managed identity."
  value       = azurerm_linux_web_app.this.identity[0].principal_id
}

output "private_endpoint_id" {
  description = "The ID of the private endpoint."
  value       = azurerm_private_endpoint.web_app.id
}

output "private_endpoint_ip_address" {
  description = "The private IP address of the private endpoint."
  value       = azurerm_private_endpoint.web_app.private_service_connection[0].private_ip_address
}
