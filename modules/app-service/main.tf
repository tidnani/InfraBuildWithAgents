resource "azurerm_service_plan" "main" {
  name                   = "${var.name_prefix}-asp"
  location               = var.location
  resource_group_name    = var.resource_group_name
  os_type                = "Linux"
  sku_name               = var.sku_name
  worker_count           = var.plan_capacity
  zone_balancing_enabled = true
  tags                   = var.tags
}

resource "azurerm_linux_web_app" "main" {
  name                          = "${var.name_prefix}-app"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  service_plan_id               = azurerm_service_plan.main.id
  virtual_network_subnet_id     = var.vnet_integration_subnet_id
  public_network_access_enabled = false
  https_only                    = true
  tags                          = var.tags

  identity {
    type = "SystemAssigned"
  }

  site_config {
    always_on                         = true
    health_check_path                 = "/health"
    health_check_eviction_time_in_min = 10
    minimum_tls_version               = "1.2"
    ftps_state                        = "Disabled"
    http2_enabled                     = true
    vnet_route_all_enabled            = true
    worker_count                      = var.plan_capacity

    application_stack {
      dotnet_version = "8.0"
    }
  }

  app_settings = {
    # Application Insights
    APPLICATIONINSIGHTS_CONNECTION_STRING = var.app_insights_connection_string
    APPINSIGHTS_INSTRUMENTATIONKEY        = var.app_insights_instrumentation_key

    # Key Vault references for secrets
    ConnectionStrings__DefaultConnection = "@Microsoft.KeyVault(SecretUri=${var.sql_connection_string_uri})"
    ConnectionStrings__Redis             = "@Microsoft.KeyVault(SecretUri=${var.redis_connection_string_uri})"

    # General settings
    WEBSITE_RUN_FROM_PACKAGE       = "1"
    WEBSITE_VNET_ROUTE_ALL         = "1"
    SCM_DO_BUILD_DURING_DEPLOYMENT = "false"
  }

  logs {
    detailed_error_messages = true
    failed_request_tracing  = true

    application_logs {
      file_system_level = "Warning"
    }

    http_logs {
      file_system {
        retention_in_days = 7
        retention_in_mb   = 100
      }
    }
  }
}

# ── RBAC: App Service → Key Vault secrets reader ──────────────────────────────

resource "azurerm_role_assignment" "app_kv_secrets_user" {
  scope                = var.key_vault_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_linux_web_app.main.identity[0].principal_id
}

# ── Private Endpoint ──────────────────────────────────────────────────────────

resource "azurerm_private_endpoint" "app_service" {
  name                = "${var.name_prefix}-pe-app"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id
  tags                = var.tags

  private_service_connection {
    name                           = "${var.name_prefix}-psc-app"
    private_connection_resource_id = azurerm_linux_web_app.main.id
    subresource_names              = ["sites"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "app-dns-zone-group"
    private_dns_zone_ids = [var.private_dns_zone_id]
  }
}

# ── Auto-scale Settings ───────────────────────────────────────────────────────

resource "azurerm_monitor_autoscale_setting" "app_service" {
  name                = "${var.name_prefix}-autoscale"
  resource_group_name = var.resource_group_name
  location            = var.location
  target_resource_id  = azurerm_service_plan.main.id
  tags                = var.tags

  profile {
    name = "default"

    capacity {
      default = var.plan_capacity
      minimum = var.autoscale_min_count
      maximum = var.autoscale_max_count
    }

    rule {
      metric_trigger {
        metric_name        = "CpuPercentage"
        metric_resource_id = azurerm_service_plan.main.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 70
      }
      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT5M"
      }
    }

    rule {
      metric_trigger {
        metric_name        = "CpuPercentage"
        metric_resource_id = azurerm_service_plan.main.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT10M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 30
      }
      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT10M"
      }
    }

    rule {
      metric_trigger {
        metric_name        = "MemoryPercentage"
        metric_resource_id = azurerm_service_plan.main.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 80
      }
      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT5M"
      }
    }
  }
}

# ── Diagnostic Settings ───────────────────────────────────────────────────────

resource "azurerm_monitor_diagnostic_setting" "app_service" {
  name                       = "${var.name_prefix}-app-diag"
  target_resource_id         = azurerm_linux_web_app.main.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "AppServiceHTTPLogs"
  }

  enabled_log {
    category = "AppServiceConsoleLogs"
  }

  enabled_log {
    category = "AppServiceAppLogs"
  }

  enabled_log {
    category = "AppServiceAuditLogs"
  }

  enabled_log {
    category = "AppServiceIPSecAuditLogs"
  }

  enabled_log {
    category = "AppServicePlatformLogs"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}
