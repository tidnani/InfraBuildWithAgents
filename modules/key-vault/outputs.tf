output "key_vault_id" {
  description = "Resource ID of the Azure Key Vault."
  value       = azurerm_key_vault.main.id
}

output "key_vault_name" {
  description = "Name of the Azure Key Vault."
  value       = azurerm_key_vault.main.name
}

output "key_vault_uri" {
  description = "URI of the Azure Key Vault."
  value       = azurerm_key_vault.main.vault_uri
}

output "private_endpoint_id" {
  description = "Resource ID of the Key Vault private endpoint."
  value       = azurerm_private_endpoint.key_vault.id
}

output "sql_admin_password_secret_id" {
  description = "Resource ID of the SQL admin password secret in Key Vault."
  value       = azurerm_key_vault_secret.sql_admin_password.id
}

output "sql_admin_password_secret_uri" {
  description = "Versioned URI of the SQL admin password secret (used for Key Vault references)."
  value       = azurerm_key_vault_secret.sql_admin_password.versionless_id
}
