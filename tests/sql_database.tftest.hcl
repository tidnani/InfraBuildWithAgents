mock_provider "azurerm" {}

run "valid_sql_database" {
  command = plan

  module {
    source = "../modules/sql_database"
  }

  variables {
    server_name                  = "sql-test-001"
    database_name                = "sqldb-test-001"
    location                     = "eastus"
    resource_group_name          = "rg-test-001"
    administrator_login          = "sqladmin"
    administrator_login_password = "P@ssw0rd123!"
    azuread_admin_login          = "admin@example.com"
    azuread_admin_object_id      = "00000000-0000-0000-0000-000000000000"
    tags                         = { environment = "test" }
  }

  assert {
    condition     = azurerm_mssql_server.this.name == "sql-test-001"
    error_message = "SQL Server name should match input variable"
  }

  assert {
    condition     = azurerm_mssql_server.this.minimum_tls_version == "1.2"
    error_message = "SQL Server should enforce minimum TLS 1.2"
  }

  assert {
    condition     = azurerm_mssql_server.this.public_network_access_enabled == false
    error_message = "SQL Server should have public network access disabled"
  }

  assert {
    condition     = azurerm_mssql_database.this.transparent_data_encryption_enabled == true
    error_message = "TDE should be enabled"
  }
}

run "invalid_short_term_retention" {
  command = plan

  module {
    source = "../modules/sql_database"
  }

  variables {
    server_name                  = "sql-test-001"
    database_name                = "sqldb-test-001"
    location                     = "eastus"
    resource_group_name          = "rg-test-001"
    administrator_login          = "sqladmin"
    administrator_login_password = "P@ssw0rd123!"
    azuread_admin_login          = "admin@example.com"
    azuread_admin_object_id      = "00000000-0000-0000-0000-000000000000"
    short_term_retention_days    = 40
  }

  expect_failures = [var.short_term_retention_days]
}
