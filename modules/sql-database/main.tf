resource "azurerm_mssql_server" "primary" {
  name                          = "${var.name_prefix}-sql-primary"
  resource_group_name           = var.resource_group_name
  location                      = var.location
  version                       = "12.0"
  administrator_login           = var.admin_login
  administrator_login_password  = var.admin_password
  minimum_tls_version           = "1.2"
  public_network_access_enabled = false
  tags                          = var.tags

  azuread_administrator {
    login_username              = "AzureAD Admin"
    object_id                   = var.aad_admin_object_id != "" ? var.aad_admin_object_id : data.azurerm_client_config.current.object_id
    azuread_authentication_only = false
  }

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_mssql_server" "secondary" {
  name                          = "${var.name_prefix}-sql-secondary"
  resource_group_name           = var.resource_group_name
  location                      = var.secondary_location
  version                       = "12.0"
  administrator_login           = var.admin_login
  administrator_login_password  = var.admin_password
  minimum_tls_version           = "1.2"
  public_network_access_enabled = false
  tags                          = var.tags

  identity {
    type = "SystemAssigned"
  }
}

data "azurerm_client_config" "current" {}

resource "azurerm_mssql_database" "main" {
  name           = "${var.name_prefix}-sqldb"
  server_id      = azurerm_mssql_server.primary.id
  sku_name       = var.sku_name
  zone_redundant = true
  tags           = var.tags

  short_term_retention_policy {
    retention_days           = 35
    backup_interval_in_hours = 12
  }

  long_term_retention_policy {
    weekly_retention  = "P4W"
    monthly_retention = "P12M"
    yearly_retention  = "P5Y"
    week_of_year      = 1
  }

  threat_detection_policy {
    state                = "Enabled"
    email_account_admins = "Enabled"
    retention_days       = 90
  }
}

# ── Failover Group ────────────────────────────────────────────────────────────

resource "azurerm_mssql_failover_group" "main" {
  name      = "${var.name_prefix}-fog"
  server_id = azurerm_mssql_server.primary.id
  databases = [azurerm_mssql_database.main.id]
  tags      = var.tags

  partner_server {
    id = azurerm_mssql_server.secondary.id
  }

  read_write_endpoint_failover_policy {
    mode          = "Automatic"
    grace_minutes = 60
  }

  readonly_endpoint_failover_policy_enabled = true
}

# ── Private Endpoint (Primary) ────────────────────────────────────────────────

resource "azurerm_private_endpoint" "sql_primary" {
  name                = "${var.name_prefix}-pe-sql-primary"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id
  tags                = var.tags

  private_service_connection {
    name                           = "${var.name_prefix}-psc-sql-primary"
    private_connection_resource_id = azurerm_mssql_server.primary.id
    subresource_names              = ["sqlServer"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "sql-dns-zone-group"
    private_dns_zone_ids = [var.private_dns_zone_id]
  }
}

# ── Diagnostic Settings ───────────────────────────────────────────────────────

resource "azurerm_monitor_diagnostic_setting" "sql_db" {
  name                       = "${var.name_prefix}-sqldb-diag"
  target_resource_id         = azurerm_mssql_database.main.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "SQLInsights"
  }

  enabled_log {
    category = "AutomaticTuning"
  }

  enabled_log {
    category = "QueryStoreRuntimeStatistics"
  }

  enabled_log {
    category = "QueryStoreWaitStatistics"
  }

  enabled_log {
    category = "Errors"
  }

  enabled_log {
    category = "DatabaseWaitStatistics"
  }

  enabled_log {
    category = "Timeouts"
  }

  enabled_log {
    category = "Blocks"
  }

  enabled_log {
    category = "Deadlocks"
  }

  enabled_metric {
    category = "Basic"
  }

  enabled_metric {
    category = "InstanceAndAppAdvanced"
  }

  enabled_metric {
    category = "WorkloadManagement"
  }
}

# ── Key Vault Secret: Connection String ───────────────────────────────────────

resource "azurerm_key_vault_secret" "sql_connection_string" {
  name         = "sql-connection-string"
  value        = "Server=tcp:${azurerm_mssql_failover_group.main.name}.database.windows.net,1433;Database=${azurerm_mssql_database.main.name};User ID=${var.admin_login};Password=${var.admin_password};Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
  key_vault_id = var.key_vault_id
  tags         = var.tags
}
