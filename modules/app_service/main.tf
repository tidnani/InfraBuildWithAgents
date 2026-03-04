terraform {
  required_version = ">= 1.9"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

resource "azurerm_service_plan" "this" {
  name                   = var.app_service_plan_name
  resource_group_name    = var.resource_group_name
  location               = var.location
  os_type                = "Linux"
  sku_name               = "P2v3"
  zone_balancing_enabled = true
  tags                   = var.tags
}

resource "azurerm_linux_web_app" "this" {
  name                      = var.app_name
  resource_group_name       = var.resource_group_name
  location                  = var.location
  service_plan_id           = azurerm_service_plan.this.id
  https_only                = true
  virtual_network_subnet_id = var.subnet_id

  identity {
    type = "SystemAssigned"
  }

  site_config {
    always_on                     = true
    minimum_tls_version           = "1.2"
    health_check_path             = var.health_check_path
    ip_restriction_default_action = "Deny"

    ip_restriction {
      service_tag = "AzureFrontDoor.Backend"
      action      = "Allow"
      priority    = 100
      name        = "Allow-FrontDoor-Backend"

      headers {
        x_azure_fdid = var.allowed_front_door_header != "" ? [var.allowed_front_door_header] : []
      }
    }
  }

  app_settings = {
    APPINSIGHTS_INSTRUMENTATIONKEY             = var.app_insights_key
    APPLICATIONINSIGHTS_CONNECTION_STRING      = var.app_insights_connection_string
    ApplicationInsightsAgent_EXTENSION_VERSION = "~3"
    KEY_VAULT_URI                              = var.key_vault_uri
    WEBSITES_ENABLE_APP_SERVICE_STORAGE        = "false"
  }

  tags = var.tags
}

resource "azurerm_monitor_diagnostic_setting" "app_service" {
  name                       = "${var.app_name}-diagnostics"
  target_resource_id         = azurerm_linux_web_app.this.id
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