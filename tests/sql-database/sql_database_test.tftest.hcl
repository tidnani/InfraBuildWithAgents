# SQL Database module tests
# Uses Terraform's native testing framework (terraform test)

variables {
  resource_group_name        = "test-sql-rg"
  location                   = "eastus2"
  secondary_location         = "westus2"
  name_prefix                = "test-sql"
  sku_name                   = "BC_Gen5_4"
  admin_login                = "sqladmin"
  admin_password             = "P@ssw0rd123!"
  aad_admin_object_id        = "00000000-0000-0000-0000-000000000000"
  private_endpoint_subnet_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/snet-pe"
  private_dns_zone_id        = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/privateDnsZones/privatelink.database.windows.net"
  log_analytics_workspace_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.OperationalInsights/workspaces/test-law"
  key_vault_id               = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.KeyVault/vaults/test-kv"
  tags = {
    environment = "test"
    managed_by  = "terraform"
  }
}

run "validate_sql_server_version" {
  command = plan

  assert {
    condition     = azurerm_mssql_server.primary.version == "12.0"
    error_message = "SQL Server must use version 12.0."
  }
}

run "validate_public_access_disabled" {
  command = plan

  assert {
    condition     = azurerm_mssql_server.primary.public_network_access_enabled == false
    error_message = "Primary SQL Server public network access must be disabled."
  }

  assert {
    condition     = azurerm_mssql_server.secondary.public_network_access_enabled == false
    error_message = "Secondary SQL Server public network access must be disabled."
  }
}

run "validate_minimum_tls" {
  command = plan

  assert {
    condition     = azurerm_mssql_server.primary.minimum_tls_version == "1.2"
    error_message = "SQL Server minimum TLS version must be 1.2."
  }
}

run "validate_zone_redundant_database" {
  command = plan

  assert {
    condition     = azurerm_mssql_database.main.zone_redundant == true
    error_message = "SQL Database must be zone-redundant."
  }
}

run "validate_failover_group_policy" {
  command = plan

  assert {
    condition     = azurerm_mssql_failover_group.main.read_write_endpoint_failover_policy[0].mode == "Automatic"
    error_message = "Failover group must use Automatic failover mode."
  }
}

run "validate_backup_retention" {
  command = plan

  assert {
    condition     = azurerm_mssql_database.main.short_term_retention_policy[0].retention_days == 35
    error_message = "Short-term backup retention must be 35 days."
  }
}

run "validate_secondary_in_different_region" {
  command = plan

  assert {
    condition     = var.location != var.secondary_location
    error_message = "Primary and secondary SQL Servers must be in different regions."
  }
}

run "validate_outputs" {
  command = plan

  assert {
    condition     = output.sql_server_id != null
    error_message = "sql_server_id output must not be null."
  }

  assert {
    condition     = output.failover_group_id != null
    error_message = "failover_group_id output must not be null."
  }

  assert {
    condition     = output.connection_string_key_vault_uri != null
    error_message = "connection_string_key_vault_uri output must not be null."
  }
}
