data "azurerm_client_config" "current" {}

resource "azurerm_log_analytics_workspace" "main" {
  name                = "${var.name_prefix}-law"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = var.retention_days
  tags                = var.tags
}

resource "azurerm_application_insights" "main" {
  name                = "${var.name_prefix}-appi"
  location            = var.location
  resource_group_name = var.resource_group_name
  workspace_id        = azurerm_log_analytics_workspace.main.id
  application_type    = "web"
  retention_in_days   = var.retention_days
  tags                = var.tags
}

# ── Action Group (email alerts) ───────────────────────────────────────────────

resource "azurerm_monitor_action_group" "critical" {
  name                = "${var.name_prefix}-ag-critical"
  resource_group_name = var.resource_group_name
  short_name          = "critical"
  tags                = var.tags

  dynamic "email_receiver" {
    for_each = var.alert_email_addresses
    content {
      name                    = "email-${email_receiver.key}"
      email_address           = email_receiver.value
      use_common_alert_schema = true
    }
  }
}

# ── Availability Alert ────────────────────────────────────────────────────────

resource "azurerm_monitor_metric_alert" "availability" {
  name                = "${var.name_prefix}-alert-availability"
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_application_insights.main.id]
  description         = "Alert when application availability drops below 99%."
  severity            = 0
  frequency           = "PT1M"
  window_size         = "PT5M"
  tags                = var.tags

  criteria {
    metric_namespace = "microsoft.insights/components"
    metric_name      = "availabilityResults/availabilityPercentage"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = 99
  }

  action {
    action_group_id = azurerm_monitor_action_group.critical.id
  }
}

# ── Response Time Alert ───────────────────────────────────────────────────────

resource "azurerm_monitor_metric_alert" "response_time" {
  name                = "${var.name_prefix}-alert-response-time"
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_application_insights.main.id]
  description         = "Alert when average server response time exceeds 2 seconds."
  severity            = 1
  frequency           = "PT1M"
  window_size         = "PT5M"
  tags                = var.tags

  criteria {
    metric_namespace = "microsoft.insights/components"
    metric_name      = "requests/duration"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 2000
  }

  action {
    action_group_id = azurerm_monitor_action_group.critical.id
  }
}

# ── Error Rate Alert ──────────────────────────────────────────────────────────

resource "azurerm_monitor_metric_alert" "error_rate" {
  name                = "${var.name_prefix}-alert-error-rate"
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_application_insights.main.id]
  description         = "Alert when failed request count exceeds threshold."
  severity            = 1
  frequency           = "PT1M"
  window_size         = "PT5M"
  tags                = var.tags

  criteria {
    metric_namespace = "microsoft.insights/components"
    metric_name      = "requests/failed"
    aggregation      = "Count"
    operator         = "GreaterThan"
    threshold        = var.error_rate_threshold
  }

  action {
    action_group_id = azurerm_monitor_action_group.critical.id
  }
}

# ── Azure Monitor Dashboard ───────────────────────────────────────────────────

resource "azurerm_portal_dashboard" "main" {
  name                = "${var.name_prefix}-dashboard"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags = merge(var.tags, {
    "hidden-title" = "${var.name_prefix} Operations Dashboard"
  })

  dashboard_properties = jsonencode({
    lenses = {
      "0" = {
        order = 0
        parts = {
          "0" = {
            position = { x = 0, y = 0, rowSpan = 4, colSpan = 6 }
            metadata = {
              type = "Extension/HubsExtension/PartType/MonitorChartPart"
              inputs = [{
                name = "options"
                value = {
                  chart = {
                    metrics = [{
                      resourceMetadata    = { id = azurerm_application_insights.main.id }
                      name                = "requests/count"
                      aggregationType     = 7
                      namespace           = "microsoft.insights/components"
                      metricVisualization = { displayName = "Server requests" }
                    }]
                    title         = "Server Requests"
                    titleKind     = 1
                    visualization = { chartType = 2 }
                  }
                }
              }]
            }
          }
          "1" = {
            position = { x = 6, y = 0, rowSpan = 4, colSpan = 6 }
            metadata = {
              type = "Extension/HubsExtension/PartType/MonitorChartPart"
              inputs = [{
                name = "options"
                value = {
                  chart = {
                    metrics = [{
                      resourceMetadata    = { id = azurerm_application_insights.main.id }
                      name                = "requests/failed"
                      aggregationType     = 7
                      namespace           = "microsoft.insights/components"
                      metricVisualization = { displayName = "Failed requests" }
                    }]
                    title         = "Failed Requests"
                    titleKind     = 1
                    visualization = { chartType = 2 }
                  }
                }
              }]
            }
          }
        }
      }
    }
    metadata = { model = {} }
  })
}
