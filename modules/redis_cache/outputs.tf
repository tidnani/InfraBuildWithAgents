output "id" {
  description = "The ID of the Redis Cache instance."
  value       = azurerm_redis_cache.this.id
}

output "name" {
  description = "The name of the Redis Cache instance."
  value       = azurerm_redis_cache.this.name
}

output "hostname" {
  description = "The hostname of the Redis Cache instance."
  value       = azurerm_redis_cache.this.hostname
}

output "ssl_port" {
  description = "The SSL port of the Redis Cache instance."
  value       = azurerm_redis_cache.this.ssl_port
}

output "primary_access_key" {
  description = "The primary access key for the Redis Cache."
  value       = azurerm_redis_cache.this.primary_access_key
  sensitive   = true
}

output "primary_connection_string" {
  description = "The primary connection string for the Redis Cache."
  value       = azurerm_redis_cache.this.primary_connection_string
  sensitive   = true
}
