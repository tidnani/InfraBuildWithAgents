output "sql_server_id" {
  description = "Resource ID of the primary SQL Server."
  value       = azurerm_mssql_server.primary.id
}

output "sql_server_fqdn" {
  description = "Fully qualified domain name of the primary SQL Server."
  value       = azurerm_mssql_server.primary.fully_qualified_domain_name
}

output "secondary_sql_server_id" {
  description = "Resource ID of the secondary SQL Server."
  value       = azurerm_mssql_server.secondary.id
}

output "secondary_sql_server_fqdn" {
  description = "Fully qualified domain name of the secondary SQL Server."
  value       = azurerm_mssql_server.secondary.fully_qualified_domain_name
}

output "database_id" {
  description = "Resource ID of the SQL Database."
  value       = azurerm_mssql_database.main.id
}

output "database_name" {
  description = "Name of the SQL Database."
  value       = azurerm_mssql_database.main.name
}

output "failover_group_id" {
  description = "Resource ID of the SQL Failover Group."
  value       = azurerm_mssql_failover_group.main.id
}

output "failover_group_name" {
  description = "Name of the SQL Failover Group."
  value       = azurerm_mssql_failover_group.main.name
}

output "private_endpoint_id" {
  description = "Resource ID of the primary SQL Server private endpoint."
  value       = azurerm_private_endpoint.sql_primary.id
}

output "connection_string_key_vault_uri" {
  description = "Versionless Key Vault URI for the SQL connection string secret."
  value       = azurerm_key_vault_secret.sql_connection_string.versionless_id
}
