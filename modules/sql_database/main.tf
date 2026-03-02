terraform {
  required_version = "~> 1.10"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

locals {
  tags = merge(var.tags, {
    managed_by = "terraform"
  })
}

resource "azurerm_mssql_server" "this" {
  name                          = var.server_name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  version                       = "12.0"
  administrator_login           = var.administrator_login
  administrator_login_password  = var.administrator_login_password
  minimum_tls_version           = "1.2"
  public_network_access_enabled = false
  tags                          = local.tags

  azuread_administrator {
    login_username              = var.azuread_admin_login
    object_id                   = var.azuread_admin_object_id
    azuread_authentication_only = false
  }

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_mssql_database" "this" {
  name                                = var.database_name
  server_id                           = azurerm_mssql_server.this.id
  sku_name                            = var.sku_name
  zone_redundant                      = var.zone_redundant
  geo_backup_enabled                  = true
  transparent_data_encryption_enabled = true
  tags                                = local.tags

  short_term_retention_policy {
    retention_days           = var.short_term_retention_days
    backup_interval_in_hours = 12
  }

  long_term_retention_policy {
    weekly_retention  = var.ltr_weekly_retention
    monthly_retention = var.ltr_monthly_retention
    yearly_retention  = var.ltr_yearly_retention
    week_of_year      = 1
  }

  lifecycle {
    prevent_destroy = false
  }
}

resource "azurerm_mssql_server_security_alert_policy" "this" {
  resource_group_name  = var.resource_group_name
  server_name          = azurerm_mssql_server.this.name
  state                = "Enabled"
  email_account_admins = true
}

resource "azurerm_mssql_server_vulnerability_assessment" "this" {
  count = var.vulnerability_assessment_storage_container_path != "" ? 1 : 0

  server_security_alert_policy_id = azurerm_mssql_server_security_alert_policy.this.id
  storage_container_path          = var.vulnerability_assessment_storage_container_path

  recurring_scans {
    enabled                   = true
    email_subscription_admins = true
  }
}

resource "azurerm_mssql_server_extended_auditing_policy" "this" {
  server_id              = azurerm_mssql_server.this.id
  log_monitoring_enabled = true
  retention_in_days      = var.audit_retention_in_days
}

resource "azurerm_monitor_diagnostic_setting" "this" {
  count = var.log_analytics_workspace_id != null ? 1 : 0

  name                       = "diag-${var.database_name}"
  target_resource_id         = azurerm_mssql_database.this.id
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
    category = "Errors"
  }

  enabled_metric {
    category = "Basic"
  }
}
