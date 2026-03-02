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

resource "azurerm_log_analytics_workspace" "this" {
  name                = var.workspace_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = var.retention_in_days
  tags                = local.tags
}

resource "azurerm_application_insights" "this" {
  name                = var.app_insights_name
  location            = var.location
  resource_group_name = var.resource_group_name
  workspace_id        = azurerm_log_analytics_workspace.this.id
  application_type    = "web"
  tags                = local.tags
}

resource "azurerm_monitor_action_group" "this" {
  name                = "ag-${var.workspace_name}"
  resource_group_name = var.resource_group_name
  short_name          = "alerts"
  tags                = local.tags

  dynamic "email_receiver" {
    for_each = var.alert_email_receivers
    content {
      name          = email_receiver.value.name
      email_address = email_receiver.value.email_address
    }
  }
}

resource "azurerm_monitor_metric_alert" "high_cpu" {
  count = length(var.alert_scope_ids) > 0 ? 1 : 0

  name                = "alert-high-cpu-${var.workspace_name}"
  resource_group_name = var.resource_group_name
  scopes              = var.alert_scope_ids
  description         = "Alert when CPU usage exceeds 80%"
  severity            = 2
  frequency           = "PT1M"
  window_size         = "PT5M"
  tags                = local.tags

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

resource "azurerm_monitor_metric_alert" "high_memory" {
  count = length(var.alert_scope_ids) > 0 ? 1 : 0

  name                = "alert-high-memory-${var.workspace_name}"
  resource_group_name = var.resource_group_name
  scopes              = var.alert_scope_ids
  description         = "Alert when memory usage exceeds 85%"
  severity            = 2
  frequency           = "PT1M"
  window_size         = "PT5M"
  tags                = local.tags

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

resource "azurerm_monitor_metric_alert" "http_errors" {
  count = length(var.alert_scope_ids) > 0 ? 1 : 0

  name                = "alert-http-errors-${var.workspace_name}"
  resource_group_name = var.resource_group_name
  scopes              = var.alert_scope_ids
  description         = "Alert when HTTP 5xx error rate exceeds threshold"
  severity            = 1
  frequency           = "PT1M"
  window_size         = "PT5M"
  tags                = local.tags

  criteria {
    metric_namespace = "Microsoft.Web/sites"
    metric_name      = "Http5xx"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = 10
  }

  action {
    action_group_id = azurerm_monitor_action_group.this.id
  }
}
