output "redis_id" {
  description = "Resource ID of the Azure Cache for Redis."
  value       = azurerm_redis_cache.main.id
}

output "redis_hostname" {
  description = "Hostname of the Redis Cache instance."
  value       = azurerm_redis_cache.main.hostname
}

output "redis_ssl_port" {
  description = "SSL port of the Redis Cache instance."
  value       = azurerm_redis_cache.main.ssl_port
}

output "redis_primary_access_key" {
  description = "Primary access key for the Redis Cache instance."
  value       = azurerm_redis_cache.main.primary_access_key
  sensitive   = true
}

output "private_endpoint_id" {
  description = "Resource ID of the Redis Cache private endpoint."
  value       = azurerm_private_endpoint.redis.id
}

output "connection_string_key_vault_uri" {
  description = "Versionless Key Vault URI for the Redis connection string secret."
  value       = azurerm_key_vault_secret.redis_connection_string.versionless_id
}
