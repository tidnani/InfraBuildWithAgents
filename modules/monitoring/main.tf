terraform {
  required_version = ">= 1.9"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

resource "azurerm_log_analytics_workspace" "this" {
  name                = var.workspace_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = var.tags
}

resource "azurerm_application_insights" "this" {
  name                = var.app_insights_name
  location            = var.location
  resource_group_name = var.resource_group_name
  workspace_id        = azurerm_log_analytics_workspace.this.id
  application_type    = "web"
  tags                = var.tags
}

resource "azurerm_monitor_action_group" "this" {
  name                = var.action_group_name
  resource_group_name = var.resource_group_name
  short_name          = substr(replace(var.action_group_name, "-", ""), 0, 12)
  tags                = var.tags

  email_receiver {
    name                    = "admin-email"
    email_address           = var.alert_email
    use_common_alert_schema = true
  }
}

resource "azurerm_monitor_metric_alert" "cpu" {
  count               = var.app_service_plan_id != "" ? 1 : 0
  name                = "${var.app_insights_name}-cpu-alert"
  resource_group_name = var.resource_group_name
  scopes              = [var.app_service_plan_id]
  description         = "Alert when App Service Plan CPU utilisation exceeds 80%."
  severity            = 2
  frequency           = "PT1M"
  window_size         = "PT5M"
  tags                = var.tags

  criteria {
    metric_namespace = "Microsoft.Web/serverfarms"
    metric_name      = "CpuPercentage"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }

  action {
    action_group_id = azurerm_monitor_action_group.this.id
  }
}

resource "azurerm_monitor_metric_alert" "memory" {
  count               = var.app_service_plan_id != "" ? 1 : 0
  name                = "${var.app_insights_name}-memory-alert"
  resource_group_name = var.resource_group_name
  scopes              = [var.app_service_plan_id]
  description         = "Alert when App Service Plan memory utilisation exceeds 85%."
  severity            = 2
  frequency           = "PT1M"
  window_size         = "PT5M"
  tags                = var.tags

  criteria {
    metric_namespace = "Microsoft.Web/serverfarms"
    metric_name      = "MemoryPercentage"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 85
  }

  action {
    action_group_id = azurerm_monitor_action_group.this.id
  }
}

resource "azurerm_monitor_metric_alert" "http_5xx" {
  count               = var.app_service_id != "" ? 1 : 0
  name                = "${var.app_insights_name}-http5xx-alert"
  resource_group_name = var.resource_group_name
  scopes              = [var.app_service_id]
  description         = "Alert when App Service HTTP 5xx error count exceeds threshold."
  severity            = 1
  frequency           = "PT1M"
  window_size         = "PT5M"
  tags                = var.tags

  criteria {
    metric_namespace = "Microsoft.Web/sites"
    metric_name      = "Http5xx"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = var.http_5xx_threshold
  }

  action {
    action_group_id = azurerm_monitor_action_group.this.id
  }
}
