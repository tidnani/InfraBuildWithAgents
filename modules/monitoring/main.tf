terraform {
  required_version = ">= 1.9"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

# Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "this" {
  name                = var.log_analytics_workspace_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = var.log_retention_days
  tags                = var.tags
}

# Application Insights
resource "azurerm_application_insights" "this" {
  name                                  = var.app_insights_name
  location                              = var.location
  resource_group_name                   = var.resource_group_name
  workspace_id                          = azurerm_log_analytics_workspace.this.id
  application_type                      = var.application_type
  retention_in_days                     = var.app_insights_retention_days
  daily_data_cap_in_gb                  = var.daily_data_cap_gb
  daily_data_cap_notifications_disabled = false
  tags                                  = var.tags
}

# Action Group for alerts
resource "azurerm_monitor_action_group" "this" {
  name                = var.action_group_name
  resource_group_name = var.resource_group_name
  short_name          = var.action_group_short_name
  tags                = var.tags

  dynamic "email_receiver" {
    for_each = var.alert_email_receivers
    content {
      name                    = email_receiver.value.name
      email_address           = email_receiver.value.email_address
      use_common_alert_schema = true
    }
  }
}

# Alert: High CPU on App Service Plan
resource "azurerm_monitor_metric_alert" "app_service_cpu" {
  count = var.app_service_plan_id != null ? 1 : 0

  name                = "${var.alert_name_prefix}-high-cpu"
  resource_group_name = var.resource_group_name
  scopes              = [var.app_service_plan_id]
  description         = "Alert when App Service Plan CPU exceeds threshold."
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"
  tags                = var.tags

  criteria {
    metric_namespace = "Microsoft.Web/serverfarms"
    metric_name      = "CpuPercentage"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.cpu_alert_threshold
  }

  action {
    action_group_id = azurerm_monitor_action_group.this.id
  }
}

# Alert: High Memory on App Service Plan
resource "azurerm_monitor_metric_alert" "app_service_memory" {
  count = var.app_service_plan_id != null ? 1 : 0

  name                = "${var.alert_name_prefix}-high-memory"
  resource_group_name = var.resource_group_name
  scopes              = [var.app_service_plan_id]
  description         = "Alert when App Service Plan memory exceeds threshold."
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"
  tags                = var.tags

  criteria {
    metric_namespace = "Microsoft.Web/serverfarms"
    metric_name      = "MemoryPercentage"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.memory_alert_threshold
  }

  action {
    action_group_id = azurerm_monitor_action_group.this.id
  }
}

# Alert: HTTP 5xx errors on Web App
resource "azurerm_monitor_metric_alert" "web_app_http5xx" {
  count = var.web_app_id != null ? 1 : 0

  name                = "${var.alert_name_prefix}-http5xx"
  resource_group_name = var.resource_group_name
  scopes              = [var.web_app_id]
  description         = "Alert when HTTP 5xx errors exceed threshold."
  severity            = 1
  frequency           = "PT5M"
  window_size         = "PT15M"
  tags                = var.tags

  criteria {
    metric_namespace = "Microsoft.Web/sites"
    metric_name      = "Http5xx"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = var.http5xx_alert_threshold
  }

  action {
    action_group_id = azurerm_monitor_action_group.this.id
  }
}

# Alert: Response time degradation
resource "azurerm_monitor_metric_alert" "web_app_response_time" {
  count = var.web_app_id != null ? 1 : 0

  name                = "${var.alert_name_prefix}-response-time"
  resource_group_name = var.resource_group_name
  scopes              = [var.web_app_id]
  description         = "Alert when average response time exceeds threshold."
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"
  tags                = var.tags

  criteria {
    metric_namespace = "Microsoft.Web/sites"
    metric_name      = "AverageResponseTime"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.response_time_alert_threshold
  }

  action {
    action_group_id = azurerm_monitor_action_group.this.id
  }
}

# Alert: Front Door origin health
resource "azurerm_monitor_metric_alert" "front_door_origin_health" {
  count = var.front_door_profile_id != null ? 1 : 0

  name                = "${var.alert_name_prefix}-front-door-origin-health"
  resource_group_name = var.resource_group_name
  scopes              = [var.front_door_profile_id]
  description         = "Alert when Front Door origin health percentage drops."
  severity            = 1
  frequency           = "PT5M"
  window_size         = "PT15M"
  tags                = var.tags

  criteria {
    metric_namespace = "Microsoft.Cdn/profiles"
    metric_name      = "OriginHealthPercentage"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = 100
  }

  action {
    action_group_id = azurerm_monitor_action_group.this.id
  }
}

# Dashboard (optional summary view)
resource "azurerm_portal_dashboard" "this" {
  count = var.create_dashboard ? 1 : 0

  name                = "${var.alert_name_prefix}-dashboard"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags

  dashboard_properties = jsonencode({
    lenses = {
      "0" = {
        order = 0
        parts = {
          "0" = {
            position = {
              x       = 0
              y       = 0
              rowSpan = 4
              colSpan = 6
            }
            metadata = {
              inputs = []
              type   = "Extension/HubsExtension/PartType/MarkdownPart"
              settings = {
                content = {
                  settings = {
                    content  = "## Mission Critical App Service\nMonitoring Dashboard"
                    title    = "Overview"
                    subtitle = "Azure App Service Mission Critical Architecture"
                  }
                }
              }
            }
          }
        }
      }
    }
    metadata = {
      model = {
        timeRange = {
          value = {
            relative = {
              duration = 24
              timeUnit = 1
            }
          }
          type = "MsPortalFx.Composition.Configuration.ValueTypes.TimeRange"
        }
      }
    }
  })
}
