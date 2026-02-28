# Monitoring module tests
# Uses Terraform's native testing framework (terraform test)

variables {
  resource_group_name   = "test-monitoring-rg"
  location              = "eastus2"
  name_prefix           = "test-mon"
  retention_days        = 90
  alert_email_addresses = ["ops@example.com"]
  error_rate_threshold  = 10
  tags = {
    environment = "test"
    managed_by  = "terraform"
  }
}

run "validate_retention_days" {
  command = plan

  assert {
    condition     = var.retention_days >= 30 && var.retention_days <= 730
    error_message = "Retention days must be between 30 and 730."
  }
}

run "validate_log_analytics_sku" {
  command = plan

  assert {
    condition     = azurerm_log_analytics_workspace.main.sku == "PerGB2018"
    error_message = "Log Analytics Workspace must use PerGB2018 SKU."
  }
}

run "validate_app_insights_type" {
  command = plan

  assert {
    condition     = azurerm_application_insights.main.application_type == "web"
    error_message = "Application Insights must be of type 'web'."
  }
}

run "validate_app_insights_workspace_based" {
  command = plan

  assert {
    condition     = azurerm_application_insights.main.workspace_id != null
    error_message = "Application Insights must be workspace-based (workspace_id must be set)."
  }
}

run "validate_alert_severity_availability" {
  command = plan

  assert {
    condition     = azurerm_monitor_metric_alert.availability.severity == 0
    error_message = "Availability alert must have severity 0 (Critical)."
  }
}

run "validate_availability_threshold" {
  command = plan

  assert {
    condition     = azurerm_monitor_metric_alert.availability.criteria[0].threshold == 99
    error_message = "Availability alert threshold must be 99%."
  }
}

run "validate_error_rate_threshold" {
  command = plan

  assert {
    condition     = azurerm_monitor_metric_alert.error_rate.criteria[0].threshold == var.error_rate_threshold
    error_message = "Error rate alert threshold must match the variable."
  }
}

run "validate_action_group_exists" {
  command = plan

  assert {
    condition     = azurerm_monitor_action_group.critical.short_name == "critical"
    error_message = "Action group short name must be 'critical'."
  }
}

run "validate_outputs" {
  command = plan

  assert {
    condition     = output.log_analytics_workspace_id != null
    error_message = "log_analytics_workspace_id output must not be null."
  }

  assert {
    condition     = output.app_insights_id != null
    error_message = "app_insights_id output must not be null."
  }

  assert {
    condition     = output.action_group_id != null
    error_message = "action_group_id output must not be null."
  }
}
