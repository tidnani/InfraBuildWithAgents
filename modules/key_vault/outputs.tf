output "key_vault_id" {
  description = "The resource ID of the Key Vault."
  value       = azurerm_key_vault.this.id
}

output "key_vault_name" {
  description = "The name of the Key Vault."
  value       = azurerm_key_vault.this.name
}

output "key_vault_uri" {
  description = "The URI of the Key Vault, used to access secrets and keys."
  value       = azurerm_key_vault.this.vault_uri
}

output "private_endpoint_id" {
  description = "The resource ID of the Key Vault private endpoint."
  value       = azurerm_private_endpoint.key_vault.id
}

output "private_endpoint_ip_address" {
  description = "The private IP address of the Key Vault private endpoint."
  value       = azurerm_private_endpoint.key_vault.private_service_connection[0].private_ip_address
}
