mock_provider "azurerm" {}

run "valid_monitoring" {
  command = plan

  module {
    source = "../modules/monitoring"
  }

  variables {
    workspace_name      = "log-test-001"
    app_insights_name   = "appi-test-001"
    location            = "eastus"
    resource_group_name = "rg-test-001"
    retention_in_days   = 30
    tags                = { environment = "test" }
  }

  assert {
    condition     = azurerm_log_analytics_workspace.this.name == "log-test-001"
    error_message = "Log Analytics Workspace name should match input variable"
  }

  assert {
    condition     = azurerm_log_analytics_workspace.this.sku == "PerGB2018"
    error_message = "Log Analytics Workspace SKU should be PerGB2018"
  }

  assert {
    condition     = azurerm_log_analytics_workspace.this.retention_in_days == 30
    error_message = "Retention in days should match input variable"
  }

  assert {
    condition     = azurerm_application_insights.this.name == "appi-test-001"
    error_message = "Application Insights name should match input variable"
  }

  assert {
    condition     = azurerm_application_insights.this.application_type == "web"
    error_message = "Application Insights type should be web"
  }
}

run "invalid_retention_too_low" {
  command = plan

  module {
    source = "../modules/monitoring"
  }

  variables {
    workspace_name      = "log-test-001"
    app_insights_name   = "appi-test-001"
    location            = "eastus"
    resource_group_name = "rg-test-001"
    retention_in_days   = 10
  }

  expect_failures = [var.retention_in_days]
}
