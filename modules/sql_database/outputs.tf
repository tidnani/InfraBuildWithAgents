output "server_id" {
  description = "The ID of the SQL Server."
  value       = azurerm_mssql_server.this.id
}

output "server_name" {
  description = "The name of the SQL Server."
  value       = azurerm_mssql_server.this.name
}

output "server_fqdn" {
  description = "The fully qualified domain name of the SQL Server."
  value       = azurerm_mssql_server.this.fully_qualified_domain_name
}

output "database_id" {
  description = "The ID of the SQL Database."
  value       = azurerm_mssql_database.this.id
}

output "database_name" {
  description = "The name of the SQL Database."
  value       = azurerm_mssql_database.this.name
}

output "server_principal_id" {
  description = "The principal ID of the SQL Server's system-assigned managed identity."
  value       = azurerm_mssql_server.this.identity[0].principal_id
}
